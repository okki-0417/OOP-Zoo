<script setup lang="ts">
import { useZooStore } from '../stores/zoo'
import { yen } from '../format'

const zoo = useZooStore()
</script>

<template>
  <div v-if="zoo.report" class="kpi">
    <span>残高 <strong>{{ yen(zoo.report.balance) }}</strong></span>
    <span>評判 <strong>{{ zoo.report.reputation }}/100</strong></span>
    <span>在園 <strong>{{ zoo.report.population }}</strong></span>
    <span>種 <strong>{{ zoo.report.species_count }}</strong></span>
    <span>絶滅危惧 <strong>{{ zoo.report.threatened_count }}</strong></span>
    <span>繁殖 <strong>{{ zoo.report.births }}</strong></span>
    <span v-if="zoo.loading" class="loading">更新中…</span>
  </div>
</template>
