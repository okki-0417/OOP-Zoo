<script setup lang="ts">
import { onMounted, watch } from 'vue'
import { useToast } from 'primevue/usetoast'
import Toolbar from 'primevue/toolbar'
import Tabs from 'primevue/tabs'
import TabList from 'primevue/tablist'
import Tab from 'primevue/tab'
import TabPanels from 'primevue/tabpanels'
import TabPanel from 'primevue/tabpanel'
import Toast from 'primevue/toast'
import ConfirmDialog from 'primevue/confirmdialog'
import ProgressBar from 'primevue/progressbar'
import { useZooStore } from './stores/zoo'
import StatsBar from './components/StatsBar.vue'
import OperationsToolbar from './components/OperationsToolbar.vue'
import AnimalsPanel from './components/AnimalsPanel.vue'
import EnclosuresPanel from './components/EnclosuresPanel.vue'
import StaffPanel from './components/StaffPanel.vue'
import RecordsPanel from './components/RecordsPanel.vue'

const zoo = useZooStore()
const toast = useToast()

onMounted(() => zoo.bootstrap())

watch(() => zoo.notice, (msg) => {
  if (msg) toast.add({ severity: 'success', summary: '完了', detail: msg, life: 3500 })
})
watch(() => zoo.error, (msg) => {
  if (msg) toast.add({ severity: 'error', summary: 'エラー', detail: msg, life: 5000 })
})
</script>

<template>
  <Toast />
  <ConfirmDialog />

  <Toolbar class="app-bar">
    <template #start>
      <span class="app-title">🦁 OOP動物園</span>
    </template>
    <template #end>
      <OperationsToolbar />
    </template>
  </Toolbar>

  <ProgressBar v-if="zoo.loading" mode="indeterminate" style="height: 3px" />

  <main class="app-main">
    <StatsBar />

    <Tabs value="animals" class="app-tabs">
      <TabList>
        <Tab value="animals"><i class="pi pi-heart" /> 動物</Tab>
        <Tab value="enclosures"><i class="pi pi-map" /> 飼育エリア</Tab>
        <Tab value="staff"><i class="pi pi-users" /> スタッフ</Tab>
        <Tab value="records"><i class="pi pi-book" /> 記録</Tab>
      </TabList>
      <TabPanels>
        <TabPanel value="animals"><AnimalsPanel /></TabPanel>
        <TabPanel value="enclosures"><EnclosuresPanel /></TabPanel>
        <TabPanel value="staff"><StaffPanel /></TabPanel>
        <TabPanel value="records"><RecordsPanel /></TabPanel>
      </TabPanels>
    </Tabs>
  </main>
</template>

<style scoped>
.app-bar { border-radius: 0; position: sticky; top: 0; z-index: 10; }
.app-title { font-size: 1.25rem; font-weight: 700; }
.app-main { max-width: 1200px; margin: 0 auto; padding: 1rem; }
.app-tabs { margin-top: 1rem; }
</style>
