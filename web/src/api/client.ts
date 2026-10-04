import createClient from "openapi-fetch";
import type { components, paths } from "./schema";

type Schemas = components["schemas"];
type ErrorBody = Schemas["Error"];

export class ApiError extends Error {
  readonly code: string;
  readonly status: number;

  constructor(code: string, message: string, status: number) {
    super(message);
    this.name = "ApiError";
    this.code = code;
    this.status = status;
  }

  static from(body: unknown, response: Response): ApiError {
    const error = (body as Partial<ErrorBody> | undefined)?.error;
    return new ApiError(
      error?.code ?? "Unknown",
      error?.message ?? response.statusText,
      response.status,
    );
  }
}

export const api = createClient<paths>({
  baseUrl: import.meta.env.VITE_API_BASE ?? "http://localhost:4567",
  fetch: (request) => globalThis.fetch(request),
});

type Result<D> = { data?: D; error?: unknown; response: Response };

export async function unwrap<D>(request: Promise<Result<D>>): Promise<D> {
  const { data, error, response } = await request;
  if (!response.ok) throw ApiError.from(error, response);
  return data as D;
}
