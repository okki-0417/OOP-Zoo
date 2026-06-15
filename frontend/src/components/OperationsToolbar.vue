<script setup lang="ts">
import { ref } from 'vue'
import Button from 'primevue/button'
import Dialog from 'primevue/dialog'
import InputNumber from 'primevue/inputnumber'
import { useZooStore } from '../stores/zoo'

const zoo = useZooStore()

type Mode = 'run' | 'visitors' | 'fee'
const dialog = ref<Mode | null>(null)
const num = ref(1)

const config: Record<Mode, { title: string; label: string; min: number; suffix?: string }> = {
  run: { title: 'まとめて運営', label: '日数', min: 1 },
  visitors: { title: '来園者を受け入れ', label: '人数', min: 1 },
  fee: { title: '入園料を改定', label: '料金', min: 0, suffix: ' 円' },
}

function open(mode: Mode, initial: number) {
  dialog.value = mode
  num.value = initial
}

async function submit() {
  const mode = dialog.value
  if (!mode) return
  if (mode === 'run') await zoo.runMany(num.value)
  else if (mode === 'visitors') await zoo.admitVisitors(num.value)
  else await zoo.setFee(num.value)
  dialog.value = null
}
</script>

<template>
  <div class="ops">
    <Button label="1日運営" icon="pi pi-play" size="small" :loading="zoo.loading" @click="zoo.operate()" />
    <Button label="まとめて運営" icon="pi pi-forward" size="small" severity="secondary" @click="open('run', 7)" />
    <Button label="来園者" icon="pi pi-users" size="small" severity="secondary" @click="open('visitors', 50)" />
    <Button label="入園料" icon="pi pi-tag" size="small" severity="secondary" @click="open('fee', 2000)" />
  </div>

  <Dialog
    :visible="dialog !== null"
    @update:visible="(v: boolean) => { if (!v) dialog = null }"
    modal
    :header="dialog ? config[dialog].title : ''"
    :style="{ width: '20rem' }"
  >
    <div class="field" v-if="dialog">
      <label>{{ config[dialog].label }}</label>
      <InputNumber v-model="num" :min="config[dialog].min" :suffix="config[dialog].suffix" showButtons fluid />
    </div>
    <template #footer>
      <Button label="キャンセル" text @click="dialog = null" />
      <Button label="実行" icon="pi pi-check" :loading="zoo.loading" @click="submit" />
    </template>
  </Dialog>
</template>

<style scoped>
.ops { display: flex; gap: 0.5rem; flex-wrap: wrap; }
.field { display: flex; flex-direction: column; gap: 0.4rem; }
</style>
