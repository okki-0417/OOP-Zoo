<script setup lang="ts">
import { ref } from 'vue'
import { useZooStore } from '../../stores/zoo'

const store = useZooStore()
const animal = ref('')
const enclosure = ref('')

const ready = () => Boolean(animal.value && enclosure.value)
</script>

<template>
  <form class="action" @submit.prevent>
    <label>動物
      <select v-model="animal">
        <option value="" disabled>選択</option>
        <option v-for="a in store.animals" :key="a.id" :value="a.id">{{ a.name }}（{{ a.species }}）</option>
      </select>
    </label>
    <label>エリア
      <select v-model="enclosure">
        <option value="" disabled>選択</option>
        <option v-for="e in store.enclosures" :key="e.id" :value="e.id">{{ e.name }}（{{ e.population }}/{{ e.capacity }}）</option>
      </select>
    </label>
    <div class="row">
      <button :disabled="store.loading || !ready()" @click="store.house(enclosure, animal)">収容</button>
      <button class="secondary" :disabled="store.loading || !ready()" @click="store.transfer(animal, enclosure)">移送</button>
      <button class="secondary" :disabled="store.loading || !ready()" @click="store.release(enclosure, animal)">退去</button>
    </div>
  </form>
</template>
