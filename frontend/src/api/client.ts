import type { components } from './schema'

// 生成スキーマ(openapi.yaml 由来)から表示用の型を取り出す。契約の唯一の出所。
type Schemas = components['schemas']
export type Animal = Schemas['Animal']
export type AnimalSummary = Schemas['AnimalSummary']
export type Enclosure = Schemas['Enclosure']
export type EnclosureSummary = Schemas['EnclosureSummary']
export type Keeper = Schemas['Keeper']
export type Veterinarian = Schemas['Veterinarian']
export type Deceased = Schemas['Deceased']
export type ExhibitedSpecies = Schemas['ExhibitedSpecies']
export type DayReport = Schemas['DayReport']
export type RunDaysSummary = Schemas['RunDaysSummary']
export type ZooStatistics = Schemas['ZooStatistics']
export type SpeciesRef = Schemas['SpeciesRef']
export type FoodRef = Schemas['FoodRef']
export type TaxonClassRef = Schemas['TaxonClassRef']
export type ExamineResult = Schemas['ExamineResult']

const BASE = import.meta.env.VITE_API_BASE ?? 'http://localhost:4567'

// サーバのエラー契約 {error:{code,message}} をそのまま型にした例外。
// UI はこの code/message を見て出し分けできる。
export class ApiError extends Error {
  code: string
  status: number
  constructor(code: string, message: string, status: number) {
    super(message)
    this.name = 'ApiError'
    this.code = code
    this.status = status
  }
}

async function request<T>(method: string, path: string, body?: unknown): Promise<T> {
  const res = await fetch(BASE + path, {
    method,
    headers: body === undefined ? {} : { 'Content-Type': 'application/json' },
    body: body === undefined ? undefined : JSON.stringify(body),
  })
  const text = await res.text()
  const data = text ? JSON.parse(text) : null
  if (!res.ok) {
    const err = data?.error ?? { code: 'Unknown', message: res.statusText }
    throw new ApiError(err.code, err.message, res.status)
  }
  return data as T
}

// 通信の唯一の口。コンポーネントは fetch を直接触らず、必ずここを経由する。
export const api = {
  // 参照データ(選択肢)
  listSpecies: () => request<SpeciesRef[]>('GET', '/species'),
  listFoods: () => request<FoodRef[]>('GET', '/foods'),
  listTaxonClasses: () => request<TaxonClassRef[]>('GET', '/taxon-classes'),

  // 動物
  listAnimals: () => request<AnimalSummary[]>('GET', '/animals'),
  getAnimal: (id: string) => request<Animal>('GET', `/animals/${id}`),
  acquireAnimal: (b: { species: string; name: string; sex: string }) =>
    request<Animal>('POST', '/animals', b),
  renameAnimal: (id: string, name: string) =>
    request<Animal>('PATCH', `/animals/${id}/name`, { name }),
  feedAnimal: (id: string, keeperId: string, food: string) =>
    request<Animal>('POST', `/animals/${id}/feedings`, { keeper_id: keeperId, food }),
  treatAnimal: (id: string, vetId: string) =>
    request<Animal>('POST', `/animals/${id}/treatments`, { veterinarian_id: vetId }),
  examineAnimal: (id: string, vetId: string) =>
    request<ExamineResult>('POST', `/animals/${id}/examinations`, { veterinarian_id: vetId }),
  transferAnimal: (id: string, enclosureId: string) =>
    request<Animal>('POST', `/animals/${id}/transfer`, { enclosure_id: enclosureId }),

  // エリア
  listEnclosures: () => request<EnclosureSummary[]>('GET', '/enclosures'),
  getEnclosure: (id: string) => request<Enclosure>('GET', `/enclosures/${id}`),
  addEnclosure: (b: { name: string; celsius: number; capacity: number }) =>
    request<Enclosure>('POST', '/enclosures', b),
  houseAnimal: (enclosureId: string, animalId: string) =>
    request<Enclosure>('POST', `/enclosures/${enclosureId}/occupants`, { animal_id: animalId }),
  releaseAnimal: (enclosureId: string, animalId: string) =>
    request<Animal>('DELETE', `/enclosures/${enclosureId}/occupants/${animalId}`),
  cleanEnclosure: (enclosureId: string, keeperId: string) =>
    request<Enclosure>('POST', `/enclosures/${enclosureId}/cleanings`, { keeper_id: keeperId }),

  // 繁殖
  breed: (b: { sire_id: string; dam_id: string; enclosure_id: string; name: string; sex: string }) =>
    request<Animal>('POST', '/breedings', b),

  // スタッフ
  listKeepers: () => request<Keeper[]>('GET', '/keepers'),
  hireKeeper: (name: string, specialties: string[]) =>
    request<Keeper>('POST', '/keepers', { name, specialties }),
  listVeterinarians: () => request<Veterinarian[]>('GET', '/veterinarians'),
  hireVeterinarian: (name: string) => request<Veterinarian>('POST', '/veterinarians', { name }),

  // 経営・運営
  report: () => request<ZooStatistics>('GET', '/report'),
  listDeceased: () => request<Deceased[]>('GET', '/deceased'),
  listThreatened: () => request<ExhibitedSpecies[]>('GET', '/threatened'),
  admitVisitors: (count: number) => request<{ revenue: number }>('POST', '/visitors', { count }),
  setAdmissionFee: (fee: number) =>
    request<{ admission_fee: number }>('PATCH', '/admission-fee', { fee }),
  operate: () => request<DayReport>('POST', '/operate'),
  runDays: (days: number) => request<RunDaysSummary>('POST', '/run-days', { days }),
}
