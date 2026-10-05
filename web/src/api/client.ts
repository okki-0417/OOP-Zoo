import createClient from "openapi-fetch";
import type { components, paths } from "./schema";

type Schemas = components["schemas"];
type ErrorBody = Schemas["Error"];

export type Alert = Schemas["Alert"];
export type Animal = Schemas["Animal"];
export type AnimalOutlook = Schemas["AnimalOutlook"];
export type AnimalSummary = Schemas["AnimalSummary"];
export type Enclosure = Schemas["Enclosure"];
export type EnclosureSummary = Schemas["EnclosureSummary"];
export type Keeper = Schemas["Keeper"];
export type Veterinarian = Schemas["Veterinarian"];
export type Deceased = Schemas["Deceased"];
export type ExhibitedSpecies = Schemas["ExhibitedSpecies"];
export type DayReport = Schemas["DayReport"];
export type OperatingSummary = Schemas["OperatingSummary"];
export type RunDaysSummary = Schemas["RunDaysSummary"];
export type ZooStatistics = Schemas["ZooStatistics"];
export type SpeciesRef = Schemas["SpeciesRef"];
export type FoodRef = Schemas["FoodRef"];
export type TaxonClassRef = Schemas["TaxonClassRef"];
export type ExamineResult = Schemas["ExamineResult"];

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
