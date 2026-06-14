<script setup lang="ts">
import { ref } from 'vue'
import { useZooStore } from '../../stores/zoo'

const store = useZooStore()
const keeper = ref('')
const enclosure = ref('')

async function submit() {
  if (!keeper.value || !enclosure.value) return
  await store.clean(enclosure.value, keeper.value)
}
</script>

<template>
  <form class="action" @submit.prevent="submit">
    <label>飼育員
      <select v-model="keeper">
        <option value="" disabled>選択</option>
        <option v-for="k in store.keepers" :key="k.id" :value="k.id">{{ k.name }}</option>
      </select>
    </label>
    <label>エリア
      <select v-model="enclosure">
        <option value="" disabled>選択</option>
        <option v-for="e in store.enclosures" :key="e.id" :value="e.id">{{ e.name }}</option>
      </select>
    </label>
    <button :disabled="store.loading">清掃する</button>
  </form>
</template>
