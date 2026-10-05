import { afterEach, describe, expect, it, vi } from "vite-plus/test";
import { ApiError, execute } from "./client";
import { TypedDocumentString } from "./generated/graphql";

const document = new TypedDocumentString<{ zoo: { day: number } }, { id: string }>(
  "query Zoo { zoo { day } }",
);

function stubFetch(status: number, body: unknown) {
  const fetchMock = vi.fn(
    async (_url: string, _init: RequestInit) =>
      new Response(JSON.stringify(body), {
        status,
        statusText: "status text",
        headers: { "Content-Type": "application/json" },
      }),
  );
  vi.stubGlobal("fetch", fetchMock);
  return fetchMock;
}

afterEach(() => {
  vi.unstubAllGlobals();
});

describe("execute", () => {
  it("POST localhost:4567/graphql に {query, variables} を JSON で送ること", async () => {
    const fetchMock = stubFetch(200, { data: { zoo: { day: 1 } } });

    await execute(document, { id: "a1" });

    const [url, init] = fetchMock.mock.calls[0]!;
    expect(url).toBe("http://localhost:4567/graphql");
    expect(init.method).toBe("POST");
    expect(new Headers(init.headers).get("Content-Type")).toBe("application/json");
    expect(JSON.parse(init.body as string)).toEqual({
      query: "query Zoo { zoo { day } }",
      variables: { id: "a1" },
    });
  });

  it("200 で {data:{zoo:{day:3}}} が返ると、data をそのまま返すこと", async () => {
    stubFetch(200, { data: { zoo: { day: 3 } } });

    await expect(execute(document, { id: "a1" })).resolves.toEqual({ zoo: { day: 3 } });
  });

  it("errors[0] が {message:'居ません', extensions:{code:'AnimalNotFound'}} のとき、ApiError(code, message) を投げること", async () => {
    stubFetch(200, {
      data: null,
      errors: [{ message: "居ません", extensions: { code: "AnimalNotFound" } }],
    });

    await expect(execute(document, { id: "a1" })).rejects.toMatchObject({
      name: "ApiError",
      code: "AnimalNotFound",
      message: "居ません",
    });
  });

  it("errors に code が無いとき、code='Unknown' の ApiError を投げること", async () => {
    stubFetch(200, { errors: [{ message: "Field 'x' doesn't exist" }] });

    await expect(execute(document, { id: "a1" })).rejects.toBeInstanceOf(ApiError);
    await expect(execute(document, { id: "a1" })).rejects.toMatchObject({ code: "Unknown" });
  });

  it("500 で本文が契約外の形のとき、ApiError(code='Unknown', message=statusText) を投げること", async () => {
    stubFetch(500, { unexpected: true });

    await expect(execute(document, { id: "a1" })).rejects.toMatchObject({
      code: "Unknown",
      message: "status text",
    });
  });
});
