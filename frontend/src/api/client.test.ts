import { describe, it, expect, vi } from 'vitest'
import { api, ApiError } from './client'

function mockFetch(status: number, body: unknown) {
  globalThis.fetch = vi.fn().mockResolvedValue({
    ok: status >= 200 && status < 300,
    status,
    statusText: 'status',
    text: async () => JSON.stringify(body),
  }) as unknown as typeof fetch
}

describe('api client', () => {
  it('2xx のときはレスポンスJSONをそのまま返すこと', async () => {
    mockFetch(200, [{ key: 'lion', name_ja: 'ライオン' }])

    const result = await api.listSpecies()

    expect(result[0].key).toBe('lion')
  })

  it('404 の {error:{code,message}} を ApiError(code=AnimalNotFound, status=404) に翻訳すること', async () => {
    mockFetch(404, { error: { code: 'AnimalNotFound', message: '居ません' } })

    await expect(api.getAnimal('x')).rejects.toMatchObject({
      name: 'ApiError', code: 'AnimalNotFound', message: '居ません', status: 404,
    })
  })

  it('ApiError は Error のサブクラスであること', async () => {
    mockFetch(422, { error: { code: 'CapacityExceeded', message: '満員' } })

    await expect(api.houseAnimal('e', 'a')).rejects.toBeInstanceOf(ApiError)
  })

  it('POST はボディを JSON 化し Content-Type:application/json を付けて送ること', async () => {
    const fetchMock = vi.fn().mockResolvedValue({
      ok: true, status: 201, statusText: '', text: async () => '{}',
    })
    globalThis.fetch = fetchMock as unknown as typeof fetch

    await api.acquireAnimal({ species: 'lion', name: 'レオ', sex: 'male' })

    const [, options] = fetchMock.mock.calls[0]
    expect(options.method).toBe('POST')
    expect(options.headers['Content-Type']).toBe('application/json')
    expect(JSON.parse(options.body)).toEqual({ species: 'lion', name: 'レオ', sex: 'male' })
  })

  it('GET はボディを付けず Content-Type も付けないこと', async () => {
    const fetchMock = vi.fn().mockResolvedValue({
      ok: true, status: 200, statusText: '', text: async () => '[]',
    })
    globalThis.fetch = fetchMock as unknown as typeof fetch

    await api.listAnimals()

    const [, options] = fetchMock.mock.calls[0]
    expect(options.method).toBe('GET')
    expect(options.body).toBeUndefined()
  })
})
