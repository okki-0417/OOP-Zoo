<script setup lang="ts">
import type { EnclosureSummary } from '../../api/client'
import { ratioColor } from '../../cosmetics'

const props = defineProps<{ enclosure: EnclosureSummary }>()
const emit = defineEmits<{ open: [] }>()
const fill = () => props.enclosure.capacity > 0 ? props.enclosure.population / props.enclosure.capacity : 0
</script>

<template>
  <button class="card" @click="emit('open')">
    <span class="card-emoji">🏕️</span>
    <span class="card-main">
      <span class="card-name">{{ enclosure.name }}</span>
      <span class="card-sub">収容 {{ enclosure.population }}/{{ enclosure.capacity }}</span>
    </span>
    <span class="card-status">
      <span class="dot" :style="{ background: ratioColor(1 - fill()) }" />
      <span class="hp">🧹{{ enclosure.cleanliness }}</span>
      <span v-if="enclosure.filthy" class="warn" title="不衛生">⚠</span>
    </span>
  </button>
</template>
