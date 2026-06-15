<script setup lang="ts">
import { ref } from 'vue'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Button from 'primevue/button'
import Dialog from 'primevue/dialog'
import InputText from 'primevue/inputtext'
import MultiSelect from 'primevue/multiselect'
import { useZooStore } from '../stores/zoo'

const zoo = useZooStore()

// --- 飼育員採用 ---
const keeperOpen = ref(false)
const keeperForm = ref<{ name: string; specialties: string[] }>({ name: '', specialties: [] })
async function hireKeeper() {
  await zoo.hireKeeper(keeperForm.value.name, keeperForm.value.specialties)
  keeperOpen.value = false
  keeperForm.value = { name: '', specialties: [] }
}

// --- 獣医採用 ---
const vetOpen = ref(false)
const vetName = ref('')
async function hireVet() {
  await zoo.hireVet(vetName.value)
  vetOpen.value = false
  vetName.value = ''
}
</script>

<template>
  <div class="grid">
    <div class="col">
      <div class="panel-actions">
        <h3>飼育員</h3>
        <Button label="採用" icon="pi pi-plus" size="small" @click="keeperOpen = true" />
      </div>
      <DataTable :value="zoo.keepers" dataKey="id" stripedRows>
        <template #empty>飼育員がいません。</template>
        <Column field="name" header="名前" />
        <Column field="specialties" header="専門" />
      </DataTable>
    </div>

    <div class="col">
      <div class="panel-actions">
        <h3>獣医</h3>
        <Button label="採用" icon="pi pi-plus" size="small" @click="vetOpen = true" />
      </div>
      <DataTable :value="zoo.veterinarians" dataKey="id" stripedRows>
        <template #empty>獣医がいません。</template>
        <Column field="name" header="名前" />
      </DataTable>
    </div>
  </div>

  <!-- 飼育員採用 -->
  <Dialog v-model:visible="keeperOpen" modal header="飼育員を採用" :style="{ width: '24rem' }">
    <div class="form">
      <label>名前</label>
      <InputText v-model="keeperForm.name" fluid />
      <label>専門（綱）</label>
      <MultiSelect
        v-model="keeperForm.specialties" :options="zoo.taxonClasses"
        optionLabel="label" optionValue="key" placeholder="選択" fluid display="chip"
      />
    </div>
    <template #footer>
      <Button label="キャンセル" text @click="keeperOpen = false" />
      <Button label="採用" icon="pi pi-check" :loading="zoo.loading" @click="hireKeeper" />
    </template>
  </Dialog>

  <!-- 獣医採用 -->
  <Dialog v-model:visible="vetOpen" modal header="獣医を採用" :style="{ width: '22rem' }">
    <div class="form">
      <label>名前</label>
      <InputText v-model="vetName" fluid />
    </div>
    <template #footer>
      <Button label="キャンセル" text @click="vetOpen = false" />
      <Button label="採用" icon="pi pi-check" :loading="zoo.loading" @click="hireVet" />
    </template>
  </Dialog>
</template>

<style scoped>
.grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1.5rem; }
.panel-actions { display: flex; align-items: center; justify-content: space-between; margin-bottom: 0.5rem; }
.panel-actions h3 { margin: 0; }
.form { display: flex; flex-direction: column; gap: 0.4rem; }
.form label { font-size: 0.85rem; font-weight: 600; margin-top: 0.4rem; }
</style>
