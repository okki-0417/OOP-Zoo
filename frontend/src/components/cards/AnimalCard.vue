<script setup lang="ts">
import type { AnimalSummary } from '../../api/client'
import { speciesEmoji, ratioColor } from '../../cosmetics'

const props = defineProps<{ animal: AnimalSummary }>()
const emit = defineEmits<{ open: [] }>()
const ratio = () => props.animal.max_health > 0 ? props.animal.health / props.animal.max_health : 0
</script>

<template>
  <button class="card" :class="{ dead: !animal.alive }" @click="emit('open')">
    <span class="card-emoji">{{ speciesEmoji(animal.species) }}</span>
    <span class="card-main">
      <span class="card-name">{{ animal.name }}</span>
      <span class="card-sub">{{ animal.species }}</span>
    </span>
    <span class="card-status">
      <template v-if="animal.alive">
        <span class="dot" :style="{ background: ratioColor(ratio()) }" />
        <span class="hp">❤{{ animal.health }}</span>
        <span v-if="animal.ailing" class="warn" title="不調">⚠</span>
      </template>
      <span v-else class="tag">死亡</span>
    </span>
  </button>
</template>
