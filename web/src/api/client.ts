import type { TypedDocumentString } from "./generated/graphql";

type GraphqlError = { message: string; extensions?: { code?: string } };
type Response<R> = { data?: R | null; errors?: GraphqlError[] };

export class ApiError extends Error {
  readonly code: string;

  constructor(code: string, message: string) {
    super(message);
    this.name = "ApiError";
    this.code = code;
  }
}

const endpoint = `${import.meta.env.VITE_API_BASE ?? "http://localhost:4567"}/graphql`;

export async function execute<R, V>(
  document: TypedDocumentString<R, V>,
  variables?: V,
): Promise<R> {
  const response = await globalThis.fetch(endpoint, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ query: document.toString(), variables }),
  });
  const body = (await response.json().catch(() => ({}))) as Response<R>;
  const error = body.errors?.[0];
  if (error) throw new ApiError(error.extensions?.code ?? "Unknown", error.message);
  if (!response.ok || !body.data) throw new ApiError("Unknown", response.statusText);
  return body.data;
}
