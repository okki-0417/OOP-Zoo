<script setup lang="ts">
import { ref, onMounted, watch, computed } from 'vue'
import { useZooStore } from '../../stores/zoo'
import type { Enclosure } from '../../api/client'
import { speciesEmoji, ratioColor } from '../../cosmetics'
import Meter from '../ui/Meter.vue'
import Badge from '../ui/Badge.vue'

const props = defineProps<{ id: string }>()
const emit = defineEmits<{ openAnimal: [id: string] }>()
const zoo = useZooStore()

const enclosure = ref<Enclosure | null>(null)
const animalId = ref('')
const keeperId = ref('')
const sireId = ref('')
const damId = ref('')
const childName = ref('')
const childSex = ref('male')

function doBreed() {
  if (!sireId.value || !damId.value || !childName.value) return
  act(
    zoo.breed({
      sire_id: sireId.value, dam_id: damId.value, enclosure_id: props.id,
      name: childName.value, sex: childSex.value,
    }),
  ).then(() => {
    childName.value = ''
    sireId.value = ''
    damId.value = ''
  })
}

async function load() {
  enclosure.value = await zoo.loadEnclosure(props.id)
}
onMounted(load)
watch(() => props.id, load)

async function act(run: Promise<unknown>) {
  await run
  await load()
}

// すでにこのエリアにいる個体は収容候補から外す。
const housedIds = computed(() => new Set((enclosure.value?.occupants ?? []).map((o) => o.id)))
const candidates = computed(() => zoo.animals.filter((a) => a.alive && !housedIds.value.has(a.id)))
</script>

<template>
  <div v-if="enclosure" class="detail">
    <div class="detail-hero">
      <span class="hero-emoji">🏕️</span>
      <div>
        <div class="hero-name">{{ enclosure.name }}</div>
        <div class="hero-sub">収容 {{ enclosure.population }} / {{ enclosure.capacity }}</div>
      </div>
    </div>

    <Meter label="清潔度" :value="enclosure.cleanliness" :max="100"
           :color="ratioColor(enclosure.cleanliness / 100)" />
    <Badge v-if="enclosure.filthy" text="不衛生（病気が広がります）" color="#e5736b" />

    <h4>収容中 ({{ enclosure.occupants.length }})</h4>
    <p v-if="enclosure.occupants.length === 0" class="empty">この区画は空です</p>
    <div v-else class="occupants">
      <button v-for="o in enclosure.occupants" :key="o.id" class="chip" @click="emit('openAnimal', o.id)">
        {{ speciesEmoji(o.species) }} {{ o.name }} →
      </button>
    </div>

    <h4>収容する</h4>
    <div class="row">
      <select v-model="animalId">
        <option value="" disabled>動物を選択</option>
        <option v-for="a in candidates" :key="a.id" :value="a.id">{{ a.name }}（{{ a.species }}）</option>
      </select>
      <button :disabled="zoo.loading || !animalId"
              @click="act(zoo.house(id, animalId)).then(() => (animalId = ''))">収容</button>
    </div>

    <h4>清掃</h4>
    <div class="row">
      <select v-model="keeperId">
        <option value="" disabled>飼育員を選択</option>
        <option v-for="k in zoo.keepers" :key="k.id" :value="k.id">{{ k.name }}</option>
      </select>
      <button :disabled="zoo.loading || !keeperId" @click="act(zoo.clean(id, keeperId))">清掃</button>
    </div>

    <h4>繁殖（このエリアの成獣同士）</h4>
    <div class="row">
      <select v-model="sireId">
        <option value="" disabled>父</option>
        <option v-for="o in enclosure.occupants" :key="o.id" :value="o.id">{{ o.name }}</option>
      </select>
      <select v-model="damId">
        <option value="" disabled>母</option>
        <option v-for="o in enclosure.occupants" :key="o.id" :value="o.id">{{ o.name }}</option>
      </select>
    </div>
    <div class="row">
      <input v-model="childName" placeholder="仔の名前" />
      <select v-model="childSex"><option value="male">オス</option><option value="female">メス</option></select>
      <button :disabled="zoo.loading || !sireId || !damId || !childName" @click="doBreed">繁殖</button>
    </div>
  </div>
  <p v-else class="empty">読み込み中…</p>
</template>
