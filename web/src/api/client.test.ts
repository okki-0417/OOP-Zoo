import { afterEach, describe, expect, it, vi } from "vite-plus/test";
import { api, ApiError, unwrap } from "./client";

function stubFetch(status: number, body: unknown) {
  const fetchMock = vi.fn(
    async (_request: Request) =>
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

describe("unwrap", () => {
  it("GET /species が 200 で [{key:'lion'}] を返すと、その配列をそのまま返すこと", async () => {
    stubFetch(200, [{ key: "lion", name_ja: "ライオン" }]);

    const species = await unwrap(api.GET("/species"));

    expect(species[0]?.key).toBe("lion");
  });

  it("GET /animals/{animal_id} が 404 {error:{code:'AnimalNotFound'}} を返すと、ApiError(code, message, status=404) を投げること", async () => {
    stubFetch(404, { error: { code: "AnimalNotFound", message: "居ません" } });

    await expect(
      unwrap(api.GET("/animals/{animal_id}", { params: { path: { animal_id: "x" } } })),
    ).rejects.toMatchObject({
      name: "ApiError",
      code: "AnimalNotFound",
      message: "居ません",
      status: 404,
    });
  });

  it("エラー本文が契約外の形のとき、ApiError(code='Unknown', message=statusText) を投げること", async () => {
    stubFetch(500, { unexpected: true });

    await expect(unwrap(api.GET("/report"))).rejects.toMatchObject({
      code: "Unknown",
      message: "status text",
      status: 500,
    });
  });

  it("投げる例外は Error のサブクラスの ApiError であること", async () => {
    stubFetch(422, { error: { code: "CapacityExceeded", message: "満員" } });

    await expect(unwrap(api.POST("/run-days", { body: { days: 1 } }))).rejects.toBeInstanceOf(
      ApiError,
    );
  });
});

describe("api", () => {
  it("POST /animals は body を JSON 化し、Content-Type: application/json を付けて VITE_API_BASE 既定の localhost:4567 へ送ること", async () => {
    const fetchMock = stubFetch(201, {});

    await api.POST("/animals", { body: { species_code: "lion", name: "レオ", sex: "male" } });

    const request = fetchMock.mock.calls[0]![0];
    expect(request.url).toBe("http://localhost:4567/animals");
    expect(request.method).toBe("POST");
    expect(request.headers.get("Content-Type")).toBe("application/json");
    expect(await request.json()).toEqual({ species_code: "lion", name: "レオ", sex: "male" });
  });
});
