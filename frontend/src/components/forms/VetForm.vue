<script setup lang="ts">
import { ref } from 'vue'
import { useZooStore } from '../../stores/zoo'

const store = useZooStore()
const vet = ref('')
const animal = ref('')

const ready = () => Boolean(vet.value && animal.value)
</script>

<template>
  <form class="action" @submit.prevent>
    <label>獣医
      <select v-model="vet">
        <option value="" disabled>選択</option>
        <option v-for="v in store.veterinarians" :key="v.id" :value="v.id">{{ v.name }}</option>
      </select>
    </label>
    <label>動物
      <select v-model="animal">
        <option value="" disabled>選択</option>
        <option v-for="a in store.animals" :key="a.id" :value="a.id">{{ a.name }}（{{ a.species }}）</option>
      </select>
    </label>
    <div class="row">
      <button :disabled="store.loading || !ready()" @click="store.treat(animal, vet)">治療</button>
      <button class="secondary" :disabled="store.loading || !ready()" @click="store.examine(animal, vet)">診察</button>
    </div>
  </form>
</template>
