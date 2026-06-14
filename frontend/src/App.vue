<script setup lang="ts">
import { onMounted } from 'vue'
import { useZooStore } from './stores/zoo'
import KpiBar from './components/KpiBar.vue'
import OperationsBar from './components/OperationsBar.vue'
import AnimalsSection from './components/sections/AnimalsSection.vue'
import EnclosuresSection from './components/sections/EnclosuresSection.vue'
import StaffSection from './components/sections/StaffSection.vue'
import RecordsSection from './components/sections/RecordsSection.vue'
import DetailDrawerHost from './components/DetailDrawerHost.vue'
import CreateModalHost from './components/CreateModalHost.vue'

const zoo = useZooStore()
onMounted(() => zoo.bootstrap())
</script>

<template>
  <header class="app-header">
    <h1>🦁 OOP動物園</h1>
  </header>

  <KpiBar />
  <OperationsBar />

  <div v-if="zoo.error" class="banner error">⚠ {{ zoo.error }}</div>
  <div v-else-if="zoo.notice" class="banner notice">✓ {{ zoo.notice }}</div>

  <AnimalsSection />
  <EnclosuresSection />
  <StaffSection />
  <RecordsSection />

  <DetailDrawerHost />
  <CreateModalHost />
</template>
