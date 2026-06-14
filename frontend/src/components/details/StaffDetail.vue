<script setup lang="ts">
import { computed } from 'vue'
import { useZooStore } from '../../stores/zoo'

const props = defineProps<{ id: string; kind: 'keeper' | 'vet' }>()
const zoo = useZooStore()

const keeper = computed(() => zoo.keepers.find((k) => k.id === props.id))
const vet = computed(() => zoo.veterinarians.find((v) => v.id === props.id))
</script>

<template>
  <div class="detail">
    <template v-if="kind === 'keeper' && keeper">
      <div class="detail-hero">
        <span class="hero-emoji">🧑‍🌾</span>
        <div>
          <div class="hero-name">{{ keeper.name }}</div>
          <div class="hero-sub">飼育員</div>
        </div>
      </div>
      <div class="kv">担当できる綱: {{ keeper.specialties }}</div>
      <p class="muted">給餌は動物の詳細から行えます（担当する綱の動物のみ）。</p>
    </template>

    <template v-else-if="kind === 'vet' && vet">
      <div class="detail-hero">
        <span class="hero-emoji">🩺</span>
        <div>
          <div class="hero-name">{{ vet.name }}</div>
          <div class="hero-sub">獣医</div>
        </div>
      </div>
      <p class="muted">治療・診察は動物の詳細から行えます。</p>
    </template>

    <p v-else class="empty">読み込み中…</p>
  </div>
</template>
