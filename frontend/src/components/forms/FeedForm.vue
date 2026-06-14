<script setup lang="ts">
import { ref } from 'vue'
import { useZooStore } from '../../stores/zoo'

const store = useZooStore()
const keeper = ref('')
const animal = ref('')
const food = ref('')

async function submit() {
  if (!keeper.value || !animal.value || !food.value) return
  await store.feed(animal.value, keeper.value, food.value)
}
</script>

<template>
  <form class="action" @submit.prevent="submit">
    <label>飼育員
      <select v-model="keeper">
        <option value="" disabled>選択</option>
        <option v-for="k in store.keepers" :key="k.id" :value="k.id">{{ k.name }}（{{ k.specialties }}）</option>
      </select>
    </label>
    <div class="row">
      <label>動物
        <select v-model="animal">
          <option value="" disabled>選択</option>
          <option v-for="a in store.animals" :key="a.id" :value="a.id">{{ a.name }}</option>
        </select>
      </label>
      <label>餌
        <select v-model="food">
          <option value="" disabled>選択</option>
          <option v-for="f in store.foods" :key="f.key" :value="f.key">{{ f.name_ja }}</option>
        </select>
      </label>
    </div>
    <button :disabled="store.loading">給餌する</button>
  </form>
</template>
