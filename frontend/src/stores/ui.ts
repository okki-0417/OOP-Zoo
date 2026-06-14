import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export type DetailRef =
  | { type: 'animal'; id: string }
  | { type: 'enclosure'; id: string }
  | { type: 'staff'; id: string; kind: 'keeper' | 'vet' }

export type CreateKind = 'animal' | 'enclosure' | 'staff'

// 「いま何を開いているか」だけを持つUI状態。ドリルの連鎖はスタックで表し、
// 戻る(back)で前の詳細に戻れる。データ取得・ビジネスはここに置かない。
export const useUiStore = defineStore('ui', () => {
  const stack = ref<DetailRef[]>([])
  const createModal = ref<CreateKind | null>(null)

  const current = computed<DetailRef | null>(() => stack.value[stack.value.length - 1] ?? null)
  const canBack = computed(() => stack.value.length > 1)

  function openAnimal(id: string) {
    stack.value.push({ type: 'animal', id })
  }
  function openEnclosure(id: string) {
    stack.value.push({ type: 'enclosure', id })
  }
  function openStaff(id: string, kind: 'keeper' | 'vet') {
    stack.value.push({ type: 'staff', id, kind })
  }
  function back() {
    stack.value.pop()
  }
  function close() {
    stack.value = []
  }

  function openCreate(kind: CreateKind) {
    createModal.value = kind
  }
  function closeCreate() {
    createModal.value = null
  }

  return {
    stack, createModal, current, canBack,
    openAnimal, openEnclosure, openStaff, back, close, openCreate, closeCreate,
  }
})
