import { describe, it, expect, vi, beforeEach } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useZooStore } from './zoo'
import { api, ApiError } from '../api/client'
import type { ZooStatistics } from '../api/client'

const emptyReport: ZooStatistics = {
  population: 0, species_count: 0, threatened_count: 0, births: 0,
  deaths_by_cause: {}, revenue: 0, balance: 100_000, reputation: 50,
}

// refresh が呼ぶ7つの取得をすべて無害化する。
function stubRefresh() {
  vi.spyOn(api, 'listAnimals').mockResolvedValue([])
  vi.spyOn(api, 'listEnclosures').mockResolvedValue([])
  vi.spyOn(api, 'listKeepers').mockResolvedValue([])
  vi.spyOn(api, 'listVeterinarians').mockResolvedValue([])
  vi.spyOn(api, 'report').mockResolvedValue(emptyReport)
  vi.spyOn(api, 'listThreatened').mockResolvedValue([])
  vi.spyOn(api, 'listDeceased').mockResolvedValue([])
}

describe('useZooStore', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    vi.restoreAllMocks()
  })

  it('refresh は各取得結果をストア状態へ反映すること', async () => {
    stubRefresh()
    vi.spyOn(api, 'listAnimals').mockResolvedValue([
      { id: '1', name: 'レオ', species: 'ライオン', alive: true },
    ])
    const store = useZooStore()

    await store.refresh()

    expect(store.animals.map((a) => a.name)).toEqual(['レオ'])
    expect(store.report?.balance).toBe(100_000)
  })

  it('成功した操作は refresh を呼び notice を立て error を消すこと', async () => {
    stubRefresh()
    vi.spyOn(api, 'acquireAnimal').mockResolvedValue(undefined as never)
    const store = useZooStore()

    await store.acquire({ species: 'lion', name: 'レオ', sex: 'male' })

    expect(store.error).toBeNull()
    expect(store.notice).toContain('レオ')
    expect(api.listAnimals).toHaveBeenCalled()
  })

  it('ApiError を投げる操作は error にメッセージを入れ refresh しないこと', async () => {
    stubRefresh()
    vi.spyOn(api, 'acquireAnimal').mockRejectedValue(new ApiError('ArgumentError', '未知の種です', 400))
    const store = useZooStore()

    await store.acquire({ species: 'dragon', name: 'X', sex: 'male' })

    expect(store.error).toBe('未知の種です')
    expect(store.notice).toBeNull()
    expect(api.listAnimals).not.toHaveBeenCalled()
  })

  it('examine は診察結果を notice に反映すること', async () => {
    stubRefresh()
    vi.spyOn(api, 'examineAnimal').mockResolvedValue({ animal_id: '1', result: 'healthy' })
    const store = useZooStore()

    await store.examine('1', 'v1')

    expect(store.notice).toBe('診察結果: healthy')
  })
})
