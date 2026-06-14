<script setup lang="ts">
import { useZooStore } from '../../stores/zoo'
import { useUiStore } from '../../stores/ui'
import AnimalCard from '../cards/AnimalCard.vue'

const zoo = useZooStore()
const ui = useUiStore()
</script>

<template>
  <section class="panel">
    <div class="panel-head">
      <h2>動物 ({{ zoo.animals.length }})</h2>
      <button class="add" @click="ui.openCreate('animal')">＋導入</button>
    </div>
    <p v-if="zoo.animals.length === 0" class="empty">まだ動物がいません。「＋導入」から迎え入れましょう。</p>
    <div v-else class="card-grid">
      <AnimalCard v-for="a in zoo.animals" :key="a.id" :animal="a" @open="ui.openAnimal(a.id)" />
    </div>
  </section>
</template>
