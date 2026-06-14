import { defineStore } from 'pinia'
import { ref } from 'vue'
import { api, ApiError } from '../api/client'
import type {
  Animal, Enclosure, AnimalSummary, EnclosureSummary, Keeper, Veterinarian, ZooStatistics,
  ExhibitedSpecies, Deceased, SpeciesRef, FoodRef, TaxonClassRef,
} from '../api/client'

// 動物園の表示状態(ViewModel)。取得・整形・操作後の再取得・通知/エラーの一元管理を担う。
// ビジネスルールはサーバが正であり、ここには複製しない。
export const useZooStore = defineStore('zoo', () => {
  const animals = ref<AnimalSummary[]>([])
  const enclosures = ref<EnclosureSummary[]>([])
  const keepers = ref<Keeper[]>([])
  const veterinarians = ref<Veterinarian[]>([])
  const report = ref<ZooStatistics | null>(null)
  const threatened = ref<ExhibitedSpecies[]>([])
  const deceased = ref<Deceased[]>([])

  // 参照データ(選択肢の正はサーバのカタログ)
  const species = ref<SpeciesRef[]>([])
  const foods = ref<FoodRef[]>([])
  const taxonClasses = ref<TaxonClassRef[]>([])

  const loading = ref(false)
  const error = ref<string | null>(null)
  const notice = ref<string | null>(null)

  async function refresh() {
    const [a, e, k, v, r, t, d] = await Promise.all([
      api.listAnimals(), api.listEnclosures(), api.listKeepers(),
      api.listVeterinarians(), api.report(), api.listThreatened(), api.listDeceased(),
    ])
    animals.value = a
    enclosures.value = e
    keepers.value = k
    veterinarians.value = v
    report.value = r
    threatened.value = t
    deceased.value = d
  }

  // 副作用を伴う操作の共通ラッパ。ローディング・エラー(契約の解釈)・操作後の再取得・
  // 成功通知をここに集約し、各アクションは命令の発行だけに集中する。
  async function run<T>(message: string, fn: () => Promise<T>): Promise<T | undefined> {
    loading.value = true
    error.value = null
    notice.value = null
    try {
      const result = await fn()
      await refresh()
      notice.value = message
      return result
    } catch (e) {
      error.value = e instanceof ApiError ? e.message : String(e)
      return undefined
    } finally {
      loading.value = false
    }
  }

  // ドリルダウン用の詳細取得(読み取り)。失敗時は error に積み null を返す。
  async function loadAnimal(id: string): Promise<Animal | null> {
    try {
      return await api.getAnimal(id)
    } catch (e) {
      error.value = e instanceof ApiError ? e.message : String(e)
      return null
    }
  }
  async function loadEnclosure(id: string): Promise<Enclosure | null> {
    try {
      return await api.getEnclosure(id)
    } catch (e) {
      error.value = e instanceof ApiError ? e.message : String(e)
      return null
    }
  }

  async function bootstrap() {
    loading.value = true
    error.value = null
    try {
      const [s, f, t] = await Promise.all([
        api.listSpecies(), api.listFoods(), api.listTaxonClasses(),
      ])
      species.value = s
      foods.value = f
      taxonClasses.value = t
      await refresh()
    } catch (e) {
      error.value = e instanceof ApiError ? e.message : String(e)
    } finally {
      loading.value = false
    }
  }

  const acquire = (b: { species: string; name: string; sex: string }) =>
    run(`${b.name} を導入しました`, () => api.acquireAnimal(b))
  const rename = (id: string, name: string) =>
    run(`${name} に改名しました`, () => api.renameAnimal(id, name))
  const feed = (id: string, keeperId: string, food: string) =>
    run('給餌しました', () => api.feedAnimal(id, keeperId, food))
  const treat = (id: string, vetId: string) =>
    run('治療しました', () => api.treatAnimal(id, vetId))
  async function examine(id: string, vetId: string) {
    const r = await run('診察しました', () => api.examineAnimal(id, vetId))
    if (r) notice.value = `診察結果: ${r.result}`
    return r
  }
  const transfer = (id: string, enclosureId: string) =>
    run('移送しました', () => api.transferAnimal(id, enclosureId))

  const addEnclosure = (b: { name: string; celsius: number; capacity: number }) =>
    run(`${b.name} を増設しました`, () => api.addEnclosure(b))
  const house = (enclosureId: string, animalId: string) =>
    run('収容しました', () => api.houseAnimal(enclosureId, animalId))
  const release = (enclosureId: string, animalId: string) =>
    run('退去させました', () => api.releaseAnimal(enclosureId, animalId))
  const clean = (enclosureId: string, keeperId: string) =>
    run('清掃しました', () => api.cleanEnclosure(enclosureId, keeperId))

  const breed = (b: { sire_id: string; dam_id: string; enclosure_id: string; name: string; sex: string }) =>
    run(`${b.name} が誕生しました`, () => api.breed(b))

  const hireKeeper = (name: string, specialties: string[]) =>
    run(`飼育員 ${name} を採用しました`, () => api.hireKeeper(name, specialties))
  const hireVet = (name: string) =>
    run(`獣医 ${name} を採用しました`, () => api.hireVeterinarian(name))

  const admitVisitors = (count: number) =>
    run(`${count}人を受け入れました`, () => api.admitVisitors(count))
  const setFee = (fee: number) =>
    run(`入園料を ¥${fee.toLocaleString()} に改定しました`, () => api.setAdmissionFee(fee))

  async function operate() {
    const r = await run('1日運営しました', () => api.operate())
    if (r) notice.value = `来園 ${r.visitors}人・収入 ¥${r.income.toLocaleString()}・死亡 ${r.deaths}頭`
    return r
  }
  async function runMany(days: number) {
    const r = await run(`${days}日運営しました`, () => api.runDays(days))
    if (r) notice.value = `${r.days}日経過・死亡 ${r.total_deaths}頭`
    return r
  }

  return {
    animals, enclosures, keepers, veterinarians, report, threatened, deceased,
    species, foods, taxonClasses, loading, error, notice,
    bootstrap, refresh, loadAnimal, loadEnclosure,
    acquire, rename, feed, treat, examine, transfer,
    addEnclosure, house, release, clean, breed,
    hireKeeper, hireVet, admitVisitors, setFee, operate, runMany,
  }
})
