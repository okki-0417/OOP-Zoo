<script setup lang="ts">
import { ref } from 'vue'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Button from 'primevue/button'
import Tag from 'primevue/tag'
import ProgressBar from 'primevue/progressbar'
import Dialog from 'primevue/dialog'
import Select from 'primevue/select'
import InputText from 'primevue/inputtext'
import InputNumber from 'primevue/inputnumber'
import { useZooStore } from '../stores/zoo'
import type { Enclosure, EnclosureSummary } from '../api/client'
import { speciesEmoji } from '../cosmetics'

const zoo = useZooStore()

// --- 増設 ---
const addOpen = ref(false)
const addForm = ref({ name: '', celsius: 25, capacity: 4 })
async function add() {
  await zoo.addEnclosure({ ...addForm.value })
  addOpen.value = false
  addForm.value = { name: '', celsius: 25, capacity: 4 }
}

// --- 清掃 ---
const cleanOpen = ref(false)
const current = ref<EnclosureSummary | null>(null)
const keeperId = ref('')
function openClean(row: EnclosureSummary) {
  current.value = row
  keeperId.value = ''
  cleanOpen.value = true
}
async function clean() {
  if (current.value) await zoo.clean(current.value.id, keeperId.value)
  cleanOpen.value = false
}

// --- 詳細（収容個体・退去） ---
const detail = ref<Enclosure | null>(null)
const detailOpen = ref(false)
async function openDetail(row: EnclosureSummary) {
  detailOpen.value = true
  detail.value = null
  detail.value = await zoo.loadEnclosure(row.id)
}
async function release(animalId: string) {
  if (!detail.value) return
  await zoo.release(detail.value.id, animalId)
  detail.value = await zoo.loadEnclosure(detail.value.id)
}
</script>

<template>
  <div class="panel-actions">
    <Button label="エリアを増設" icon="pi pi-plus" size="small" @click="addOpen = true" />
  </div>

  <DataTable :value="zoo.enclosures" dataKey="id" paginator :rows="10" stripedRows removableSort>
    <template #empty>飼育エリアがありません。「エリアを増設」から追加してください。</template>
    <Column field="name" header="名前" sortable />
    <Column field="population" header="収容" sortable>
      <template #body="{ data }">{{ data.population }} / {{ data.capacity }}</template>
    </Column>
    <Column field="cleanliness" header="清潔度" sortable style="width: 12rem">
      <template #body="{ data }">
        <ProgressBar :value="data.cleanliness" :showValue="false" style="height: 0.6rem" />
        <Tag v-if="data.filthy" value="不衛生" severity="danger" />
      </template>
    </Column>
    <Column header="操作" style="width: 10rem">
      <template #body="{ data }">
        <Button icon="pi pi-search" text rounded size="small" v-tooltip.top="'詳細'" @click="openDetail(data)" />
        <Button icon="pi pi-sparkles" text rounded size="small" v-tooltip.top="'清掃'" @click="openClean(data)" />
      </template>
    </Column>
  </DataTable>

  <!-- 増設 -->
  <Dialog v-model:visible="addOpen" modal header="エリアを増設" :style="{ width: '24rem' }">
    <div class="form">
      <label>名前</label>
      <InputText v-model="addForm.name" fluid />
      <label>気温（℃）</label>
      <InputNumber v-model="addForm.celsius" showButtons fluid />
      <label>定員</label>
      <InputNumber v-model="addForm.capacity" :min="1" showButtons fluid />
    </div>
    <template #footer>
      <Button label="キャンセル" text @click="addOpen = false" />
      <Button label="増設" icon="pi pi-check" :loading="zoo.loading" @click="add" />
    </template>
  </Dialog>

  <!-- 清掃 -->
  <Dialog v-model:visible="cleanOpen" modal :header="`${current?.name} — 清掃`" :style="{ width: '22rem' }">
    <div class="form">
      <label>担当飼育員</label>
      <Select v-model="keeperId" :options="zoo.keepers" optionLabel="name" optionValue="id" placeholder="選択" fluid />
    </div>
    <template #footer>
      <Button label="キャンセル" text @click="cleanOpen = false" />
      <Button label="清掃" icon="pi pi-check" :loading="zoo.loading" @click="clean" />
    </template>
  </Dialog>

  <!-- 詳細 -->
  <Dialog v-model:visible="detailOpen" modal :header="detail?.name ?? '詳細'" :style="{ width: '30rem' }">
    <div v-if="detail">
      <p>収容 {{ detail.population }} / {{ detail.capacity }}　清潔度 {{ detail.cleanliness }}</p>
      <DataTable :value="detail.occupants" dataKey="id" class="occupants">
        <template #empty>収容中の個体はいません。</template>
        <Column header="個体">
          <template #body="{ data }">{{ speciesEmoji(data.species) }} {{ data.name }}（{{ data.species }}）</template>
        </Column>
        <Column header="" style="width: 6rem">
          <template #body="{ data }">
            <Button label="退去" size="small" severity="secondary" outlined @click="release(data.id)" />
          </template>
        </Column>
      </DataTable>
    </div>
    <div v-else>読み込み中…</div>
  </Dialog>
</template>

<style scoped>
.panel-actions { display: flex; gap: 0.5rem; margin-bottom: 0.75rem; }
.form { display: flex; flex-direction: column; gap: 0.4rem; }
.form label { font-size: 0.85rem; font-weight: 600; margin-top: 0.4rem; }
.occupants { margin-top: 0.5rem; }
</style>
