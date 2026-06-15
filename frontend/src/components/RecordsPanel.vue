<script setup lang="ts">
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Tag from 'primevue/tag'
import { useZooStore } from '../stores/zoo'
import { speciesEmoji, conservationColor } from '../cosmetics'

const zoo = useZooStore()
</script>

<template>
  <div class="grid">
    <div class="col">
      <h3>絶滅危惧種（展示中）</h3>
      <DataTable :value="zoo.threatened" dataKey="name_ja" stripedRows>
        <template #empty>展示中の絶滅危惧種はいません。</template>
        <Column header="種">
          <template #body="{ data }">{{ speciesEmoji(data.name_ja) }} {{ data.name_ja }}</template>
        </Column>
        <Column header="保全状況">
          <template #body="{ data }">
            <Tag :value="`${data.status_code}・${data.status_label}`" :style="{ background: conservationColor(data.status_code) }" />
          </template>
        </Column>
        <Column field="count" header="頭数" />
      </DataTable>
    </div>

    <div class="col">
      <h3>慰霊記録（死亡）</h3>
      <DataTable :value="zoo.deceased" dataKey="name" stripedRows paginator :rows="10">
        <template #empty>死亡記録はありません。</template>
        <Column header="個体">
          <template #body="{ data }">{{ speciesEmoji(data.species) }} {{ data.name }}</template>
        </Column>
        <Column field="species" header="種" />
        <Column field="cause" header="死因" />
      </DataTable>
    </div>
  </div>
</template>

<style scoped>
.grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 1.5rem; }
.col h3 { margin: 0 0 0.5rem; }
</style>
