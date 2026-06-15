<script setup lang="ts">
import { computed } from 'vue'
import Card from 'primevue/card'
import Tag from 'primevue/tag'
import { useZooStore } from '../stores/zoo'
import { yen } from '../format'

const zoo = useZooStore()

const stats = computed(() => {
  const r = zoo.report
  if (!r) return []
  return [
    { label: '飼育頭数', value: `${r.population}`, icon: 'pi pi-heart' },
    { label: '種数', value: `${r.species_count}`, icon: 'pi pi-sitemap' },
    { label: '絶滅危惧種', value: `${r.threatened_count}`, icon: 'pi pi-exclamation-triangle' },
    { label: '誕生数', value: `${r.births}`, icon: 'pi pi-star' },
    { label: '収益', value: yen(r.revenue), icon: 'pi pi-wallet' },
    { label: '残高', value: yen(r.balance), icon: 'pi pi-money-bill' },
  ]
})
</script>

<template>
  <div class="stats" v-if="zoo.report">
    <Card v-for="s in stats" :key="s.label" class="stat">
      <template #content>
        <div class="stat-body">
          <i :class="s.icon" class="stat-icon" />
          <div>
            <div class="stat-value">{{ s.value }}</div>
            <div class="stat-label">{{ s.label }}</div>
          </div>
        </div>
      </template>
    </Card>
    <Card class="stat">
      <template #content>
        <div class="stat-body">
          <i class="pi pi-star-fill stat-icon" />
          <div>
            <div class="stat-value">
              {{ zoo.report.reputation }}
              <Tag
                :value="zoo.report.reputation >= 60 ? '良' : zoo.report.reputation >= 40 ? '普' : '要改善'"
                :severity="zoo.report.reputation >= 60 ? 'success' : zoo.report.reputation >= 40 ? 'warn' : 'danger'"
              />
            </div>
            <div class="stat-label">評判</div>
          </div>
        </div>
      </template>
    </Card>
  </div>
</template>

<style scoped>
.stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 0.75rem; }
.stat-body { display: flex; align-items: center; gap: 0.75rem; }
.stat-icon { font-size: 1.5rem; opacity: 0.6; }
.stat-value { font-size: 1.35rem; font-weight: 700; display: flex; align-items: center; gap: 0.4rem; }
.stat-label { font-size: 0.8rem; color: var(--p-text-muted-color); }
</style>
