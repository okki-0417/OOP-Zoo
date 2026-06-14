<script setup lang="ts">
import { ref } from 'vue'
import { useZooStore } from '../../stores/zoo'

const store = useZooStore()
const emit = defineEmits<{ done: [] }>()
const species = ref('')
const name = ref('')
const sex = ref('male')

async function submit() {
  if (!species.value || !name.value) return
  await store.acquire({ species: species.value, name: name.value, sex: sex.value })
  if (!store.error) emit('done')
}
</script>

<template>
  <form class="action" @submit.prevent="submit">
    <label>種
      <select v-model="species">
        <option value="" disabled>選択してください</option>
        <option v-for="s in store.species" :key="s.key" :value="s.key">
          {{ s.name_ja }}（{{ s.conservation_code }}・{{ s.taxon_class }}）
        </option>
      </select>
    </label>
    <div class="row">
      <label>名前<input v-model="name" placeholder="レオ" /></label>
      <label>性別
        <select v-model="sex"><option value="male">オス</option><option value="female">メス</option></select>
      </label>
    </div>
    <button :disabled="store.loading">導入する</button>
  </form>
</template>
