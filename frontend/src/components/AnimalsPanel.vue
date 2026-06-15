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
import Menu from 'primevue/menu'
import type { MenuItem } from 'primevue/menuitem'
import { useZooStore } from '../stores/zoo'
import type { Animal, AnimalSummary } from '../api/client'
import { speciesEmoji } from '../cosmetics'

const zoo = useZooStore()
const SEX = [{ label: 'オス', value: 'male' }, { label: 'メス', value: 'female' }]

const healthPct = (a: AnimalSummary) => Math.round((a.health / a.max_health) * 100)

// --- 行アクションメニュー ---
const menu = ref<InstanceType<typeof Menu> | null>(null)
const current = ref<AnimalSummary | null>(null)
const items: MenuItem[] = [
  { label: '詳細', icon: 'pi pi-search', command: () => openDetail() },
  { separator: true },
  { label: '改名', icon: 'pi pi-pencil', command: () => open('rename') },
  { label: '給餌', icon: 'pi pi-apple', command: () => open('feed') },
  { label: '治療', icon: 'pi pi-plus-circle', command: () => open('treat') },
  { label: '診察', icon: 'pi pi-search-plus', command: () => open('examine') },
  { separator: true },
  { label: 'エリアへ収容', icon: 'pi pi-sign-in', command: () => open('house') },
  { label: '別エリアへ移送', icon: 'pi pi-arrow-right-arrow-left', command: () => open('transfer') },
]
function toggleMenu(event: Event, row: AnimalSummary) {
  current.value = row
  menu.value?.toggle(event)
}

// --- アクションダイアログ ---
type Mode = 'rename' | 'feed' | 'treat' | 'examine' | 'house' | 'transfer'
const mode = ref<Mode | null>(null)
const form = ref({ name: '', keeperId: '', food: '', vetId: '', enclosureId: '' })
const titles: Record<Mode, string> = {
  rename: '改名', feed: '給餌', treat: '治療', examine: '診察', house: 'エリアへ収容', transfer: '別エリアへ移送',
}
function open(m: Mode) {
  mode.value = m
  form.value = { name: current.value?.name ?? '', keeperId: '', food: '', vetId: '', enclosureId: '' }
}
async function submit() {
  const a = current.value
  if (!a || !mode.value) return
  const f = form.value
  if (mode.value === 'rename') await zoo.rename(a.id, f.name)
  else if (mode.value === 'feed') await zoo.feed(a.id, f.keeperId, f.food)
  else if (mode.value === 'treat') await zoo.treat(a.id, f.vetId)
  else if (mode.value === 'examine') await zoo.examine(a.id, f.vetId)
  else if (mode.value === 'house') await zoo.house(f.enclosureId, a.id)
  else if (mode.value === 'transfer') await zoo.transfer(a.id, f.enclosureId)
  mode.value = null
}

// --- 詳細ダイアログ ---
const detail = ref<Animal | null>(null)
const detailOpen = ref(false)
async function openDetail() {
  detailOpen.value = true
  detail.value = null
  if (current.value) detail.value = await zoo.loadAnimal(current.value.id)
}

// --- 導入ダイアログ ---
const acquireOpen = ref(false)
const acquireForm = ref({ species: '', name: '', sex: 'male' })
async function acquire() {
  await zoo.acquire({ ...acquireForm.value })
  acquireOpen.value = false
  acquireForm.value = { species: '', name: '', sex: 'male' }
}

// --- 繁殖ダイアログ ---
const breedOpen = ref(false)
const breedForm = ref({ sire_id: '', dam_id: '', enclosure_id: '', name: '', sex: 'male' })
async function breed() {
  await zoo.breed({ ...breedForm.value })
  breedOpen.value = false
  breedForm.value = { sire_id: '', dam_id: '', enclosure_id: '', name: '', sex: 'male' }
}
</script>

<template>
  <div class="panel-actions">
    <Button label="動物を導入" icon="pi pi-plus" size="small" @click="acquireOpen = true" />
    <Button label="繁殖させる" icon="pi pi-star" size="small" severity="help" @click="breedOpen = true" />
  </div>

  <DataTable :value="zoo.animals" dataKey="id" paginator :rows="10" stripedRows removableSort>
    <template #empty>動物がいません。「動物を導入」から追加してください。</template>
    <Column field="name" header="名前" sortable>
      <template #body="{ data }">{{ speciesEmoji(data.species) }} {{ data.name }}</template>
    </Column>
    <Column field="species" header="種" sortable />
    <Column field="health" header="体力" sortable style="width: 12rem">
      <template #body="{ data }">
        <ProgressBar :value="healthPct(data)" :showValue="false" style="height: 0.6rem" />
        <small>{{ data.health }}/{{ data.max_health }}</small>
      </template>
    </Column>
    <Column field="alive" header="状態" sortable>
      <template #body="{ data }">
        <Tag v-if="!data.alive" value="死亡" severity="contrast" />
        <Tag v-else-if="data.ailing" value="不調" severity="warn" />
        <Tag v-else value="健康" severity="success" />
      </template>
    </Column>
    <Column header="操作" style="width: 5rem">
      <template #body="{ data }">
        <Button icon="pi pi-ellipsis-v" text rounded size="small" @click="toggleMenu($event, data)" />
      </template>
    </Column>
  </DataTable>
  <Menu ref="menu" :model="items" popup />

  <!-- アクション -->
  <Dialog
    :visible="mode !== null" @update:visible="(v: boolean) => { if (!v) mode = null }"
    modal :header="mode ? `${current?.name} — ${titles[mode]}` : ''" :style="{ width: '24rem' }"
  >
    <div class="form" v-if="mode">
      <template v-if="mode === 'rename'">
        <label>新しい名前</label>
        <InputText v-model="form.name" fluid />
      </template>
      <template v-else-if="mode === 'feed'">
        <label>担当飼育員</label>
        <Select v-model="form.keeperId" :options="zoo.keepers" optionLabel="name" optionValue="id" placeholder="選択" fluid />
        <label>餌</label>
        <Select v-model="form.food" :options="zoo.foods" optionLabel="name_ja" optionValue="key" placeholder="選択" fluid />
      </template>
      <template v-else-if="mode === 'treat' || mode === 'examine'">
        <label>担当獣医</label>
        <Select v-model="form.vetId" :options="zoo.veterinarians" optionLabel="name" optionValue="id" placeholder="選択" fluid />
      </template>
      <template v-else>
        <label>飼育エリア</label>
        <Select v-model="form.enclosureId" :options="zoo.enclosures" optionLabel="name" optionValue="id" placeholder="選択" fluid />
      </template>
    </div>
    <template #footer>
      <Button label="キャンセル" text @click="mode = null" />
      <Button label="実行" icon="pi pi-check" :loading="zoo.loading" @click="submit" />
    </template>
  </Dialog>

  <!-- 詳細 -->
  <Dialog v-model:visible="detailOpen" modal :header="detail?.name ?? '詳細'" :style="{ width: '28rem' }">
    <div v-if="detail" class="detail">
      <div><b>種</b><span>{{ detail.species }}（{{ detail.taxon_class }}・{{ detail.diet }}）</span></div>
      <div><b>保全</b><span>{{ detail.conservation_label }}（{{ detail.conservation_code }}）</span></div>
      <div><b>性別 / 段階</b><span>{{ detail.sex }} / {{ detail.life_stage }}</span></div>
      <div><b>日齢</b><span>{{ detail.age_in_days }}日</span></div>
      <div><b>体力</b><span>{{ detail.health }}/{{ detail.max_health }}{{ detail.weak ? '（衰弱）' : '' }}</span></div>
      <div><b>空腹</b><span>{{ detail.hunger }}{{ detail.starving ? '（飢餓）' : '' }}</span></div>
      <div><b>病気</b><span>{{ detail.illness ?? 'なし' }}</span></div>
      <div><b>エリア</b><span>{{ detail.enclosure_name ?? '未収容' }}</span></div>
      <div><b>状態</b><span>{{ detail.alive ? '生存' : `死亡（${detail.cause}）` }}</span></div>
    </div>
    <div v-else>読み込み中…</div>
  </Dialog>

  <!-- 導入 -->
  <Dialog v-model:visible="acquireOpen" modal header="動物を導入" :style="{ width: '24rem' }">
    <div class="form">
      <label>種</label>
      <Select v-model="acquireForm.species" :options="zoo.species" optionLabel="name_ja" optionValue="key" placeholder="選択" fluid filter />
      <label>名前</label>
      <InputText v-model="acquireForm.name" fluid />
      <label>性別</label>
      <Select v-model="acquireForm.sex" :options="SEX" optionLabel="label" optionValue="value" fluid />
    </div>
    <template #footer>
      <Button label="キャンセル" text @click="acquireOpen = false" />
      <Button label="導入" icon="pi pi-check" :loading="zoo.loading" @click="acquire" />
    </template>
  </Dialog>

  <!-- 繁殖 -->
  <Dialog v-model:visible="breedOpen" modal header="繁殖させる" :style="{ width: '24rem' }">
    <div class="form">
      <label>父（オス）</label>
      <Select v-model="breedForm.sire_id" :options="zoo.animals" optionLabel="name" optionValue="id" placeholder="選択" fluid filter />
      <label>母（メス）</label>
      <Select v-model="breedForm.dam_id" :options="zoo.animals" optionLabel="name" optionValue="id" placeholder="選択" fluid filter />
      <label>出産先エリア</label>
      <Select v-model="breedForm.enclosure_id" :options="zoo.enclosures" optionLabel="name" optionValue="id" placeholder="選択" fluid />
      <label>仔の名前</label>
      <InputText v-model="breedForm.name" fluid />
      <label>仔の性別</label>
      <Select v-model="breedForm.sex" :options="SEX" optionLabel="label" optionValue="value" fluid />
    </div>
    <template #footer>
      <Button label="キャンセル" text @click="breedOpen = false" />
      <Button label="交配" icon="pi pi-check" :loading="zoo.loading" @click="breed" />
    </template>
  </Dialog>
</template>

<style scoped>
.panel-actions { display: flex; gap: 0.5rem; margin-bottom: 0.75rem; }
.form { display: flex; flex-direction: column; gap: 0.4rem; }
.form label { font-size: 0.85rem; font-weight: 600; margin-top: 0.4rem; }
.detail { display: flex; flex-direction: column; gap: 0.5rem; }
.detail > div { display: flex; justify-content: space-between; gap: 1rem; border-bottom: 1px solid var(--p-content-border-color); padding-bottom: 0.4rem; }
.detail b { color: var(--p-text-muted-color); font-weight: 600; }
</style>
