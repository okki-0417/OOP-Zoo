<script setup lang="ts">
import type { ZooStatistics } from '../api/client'
import { yen } from '../format'

defineProps<{ report: ZooStatistics | null }>()
</script>

<template>
  <section class="panel">
    <h2>園の状況</h2>
    <div v-if="report" class="stats">
      <div class="stat"><div class="v">{{ report.population }}</div><div class="k">在園数</div></div>
      <div class="stat"><div class="v">{{ report.species_count }}</div><div class="k">種数</div></div>
      <div class="stat"><div class="v">{{ report.threatened_count }}</div><div class="k">絶滅危惧種</div></div>
      <div class="stat"><div class="v">{{ report.births }}</div><div class="k">繁殖数</div></div>
      <div class="stat"><div class="v">{{ report.reputation }}</div><div class="k">評判 /100</div></div>
      <div class="stat"><div class="v">{{ yen(report.balance) }}</div><div class="k">残高</div></div>
      <div class="stat"><div class="v">{{ yen(report.revenue) }}</div><div class="k">累計収益</div></div>
    </div>
    <p v-else class="empty">読み込み中…</p>
  </section>
</template>
