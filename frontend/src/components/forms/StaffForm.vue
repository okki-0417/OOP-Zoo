<script setup lang="ts">
import { ref } from 'vue'
import { useZooStore } from '../../stores/zoo'

const store = useZooStore()
const emit = defineEmits<{ done: [] }>()
const keeperName = ref('')
const specialties = ref<string[]>([])
const vetName = ref('')

async function hireKeeper() {
  if (!keeperName.value || specialties.value.length === 0) return
  await store.hireKeeper(keeperName.value, specialties.value)
  if (!store.error) emit('done')
}

async function hireVet() {
  if (!vetName.value) return
  await store.hireVet(vetName.value)
  if (!store.error) emit('done')
}
</script>

<template>
  <form class="action" @submit.prevent="hireKeeper">
    <label>飼育員名<input v-model="keeperName" placeholder="田中" /></label>
    <label>専門の綱（複数選択可）
      <select v-model="specialties" multiple size="4">
        <option v-for="t in store.taxonClasses" :key="t.key" :value="t.key">{{ t.label }}</option>
      </select>
    </label>
    <button :disabled="store.loading">飼育員を採用</button>
  </form>
  <form class="action" @submit.prevent="hireVet" style="margin-top:10px">
    <label>獣医名<input v-model="vetName" placeholder="山田" /></label>
    <button :disabled="store.loading">獣医を採用</button>
  </form>
</template>
