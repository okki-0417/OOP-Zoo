<script setup lang="ts">
import { useZooStore } from '../../stores/zoo'
import { useUiStore } from '../../stores/ui'
import EnclosureCard from '../cards/EnclosureCard.vue'

const zoo = useZooStore()
const ui = useUiStore()
</script>

<template>
  <section class="panel">
    <div class="panel-head">
      <h2>飼育エリア ({{ zoo.enclosures.length }})</h2>
      <button class="add" @click="ui.openCreate('enclosure')">＋増設</button>
    </div>
    <p v-if="zoo.enclosures.length === 0" class="empty">まだエリアがありません。「＋増設」から作りましょう。</p>
    <div v-else class="card-grid">
      <EnclosureCard v-for="e in zoo.enclosures" :key="e.id" :enclosure="e" @open="ui.openEnclosure(e.id)" />
    </div>
  </section>
</template>
