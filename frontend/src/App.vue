<script setup lang="ts">
import { onMounted } from 'vue'
import { useZooStore } from './stores/zoo'
import { yen } from './format'

import StatsPanel from './components/StatsPanel.vue'
import AnimalsPanel from './components/AnimalsPanel.vue'
import EnclosuresPanel from './components/EnclosuresPanel.vue'
import StaffPanel from './components/StaffPanel.vue'
import WatchPanel from './components/WatchPanel.vue'

import AcquireForm from './components/forms/AcquireForm.vue'
import EnclosureForm from './components/forms/EnclosureForm.vue'
import HousingForm from './components/forms/HousingForm.vue'
import FeedForm from './components/forms/FeedForm.vue'
import VetForm from './components/forms/VetForm.vue'
import CleanForm from './components/forms/CleanForm.vue'
import StaffForm from './components/forms/StaffForm.vue'
import EconomyForm from './components/forms/EconomyForm.vue'

const store = useZooStore()
onMounted(() => store.bootstrap())
</script>

<template>
  <header class="app-header">
    <h1>🦁 OOP動物園</h1>
    <div class="funds" v-if="store.report">
      残高 <strong>{{ yen(store.report.balance) }}</strong> ・ 評判 <strong>{{ store.report.reputation }}/100</strong>
      <span v-if="store.loading" class="loading">　更新中…</span>
    </div>
  </header>

  <div v-if="store.error" class="banner error">⚠ {{ store.error }}</div>
  <div v-else-if="store.notice" class="banner notice">✓ {{ store.notice }}</div>

  <div class="layout">
    <div class="actions">
      <details class="action-group" open>
        <summary>動物を導入</summary>
        <div class="body"><AcquireForm /></div>
      </details>
      <details class="action-group">
        <summary>エリアを増設</summary>
        <div class="body"><EnclosureForm /></div>
      </details>
      <details class="action-group">
        <summary>収容・移送・退去</summary>
        <div class="body"><HousingForm /></div>
      </details>
      <details class="action-group">
        <summary>給餌</summary>
        <div class="body"><FeedForm /></div>
      </details>
      <details class="action-group">
        <summary>治療・診察</summary>
        <div class="body"><VetForm /></div>
      </details>
      <details class="action-group">
        <summary>清掃</summary>
        <div class="body"><CleanForm /></div>
      </details>
      <details class="action-group">
        <summary>スタッフ採用</summary>
        <div class="body"><StaffForm /></div>
      </details>
      <details class="action-group" open>
        <summary>運営・経営</summary>
        <div class="body"><EconomyForm /></div>
      </details>
    </div>

    <div class="dashboard">
      <StatsPanel :report="store.report" />
      <AnimalsPanel :animals="store.animals" />
      <EnclosuresPanel :enclosures="store.enclosures" />
      <StaffPanel :keepers="store.keepers" :veterinarians="store.veterinarians" />
      <WatchPanel :threatened="store.threatened" :deceased="store.deceased" />
    </div>
  </div>
</template>
