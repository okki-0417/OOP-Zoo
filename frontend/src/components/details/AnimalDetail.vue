<script setup lang="ts">
import { ref, onMounted, watch, computed } from 'vue'
import { useZooStore } from '../../stores/zoo'
import type { Animal } from '../../api/client'
import { speciesEmoji, conservationColor, ratioColor } from '../../cosmetics'
import Meter from '../ui/Meter.vue'
import Badge from '../ui/Badge.vue'

const props = defineProps<{ id: string }>()
const emit = defineEmits<{ openEnclosure: [id: string] }>()
const zoo = useZooStore()

const animal = ref<Animal | null>(null)
const keeperId = ref('')
const vetId = ref('')
const foodKey = ref('')
const newName = ref('')
const targetEnclosure = ref('')

async function load() {
  animal.value = await zoo.loadAnimal(props.id)
}
onMounted(load)
watch(() => props.id, load)

async function act(run: Promise<unknown>) {
  await run
  await load()
}

const otherEnclosures = computed(() =>
  zoo.enclosures.filter((e) => e.id !== animal.value?.enclosure_id),
)

function doRelease() {
  const a = animal.value
  if (a?.enclosure_id && confirm(`${a.name} を ${a.enclosure_name} から退去させますか？`)) {
    act(zoo.release(a.enclosure_id, props.id))
  }
}
</script>

<template>
  <div v-if="animal" class="detail">
    <div class="detail-hero">
      <span class="hero-emoji">{{ speciesEmoji(animal.species) }}</span>
      <div>
        <div class="hero-name">{{ animal.name }}</div>
        <div class="hero-sub">
          {{ animal.species }}
          <Badge :text="animal.conservation_code" :color="conservationColor(animal.conservation_code)" />
        </div>
      </div>
    </div>

    <div class="badges">
      <Badge :text="animal.life_stage" />
      <Badge :text="animal.sex" />
      <Badge :text="animal.taxon_class" />
      <Badge :text="animal.diet" />
      <Badge v-if="animal.illness" :text="`病気: ${animal.illness}`" color="#e5736b" />
      <Badge v-if="animal.starving" text="飢餓" color="#e5736b" />
      <Badge v-if="!animal.alive" :text="`死亡: ${animal.cause}`" color="#8a99a6" />
    </div>

    <Meter label="体力" :value="animal.health" :max="animal.max_health"
           :color="ratioColor(animal.health / animal.max_health)" />
    <Meter label="空腹" :value="animal.hunger" :max="100" :color="ratioColor(1 - animal.hunger / 100)" />

    <div class="kv">
      <span>日齢 {{ animal.age_in_days }}日</span>
      <span>親 {{ animal.parents }}頭</span>
    </div>

    <div class="kv link" v-if="animal.enclosure_id" @click="emit('openEnclosure', animal.enclosure_id)">
      所属: {{ animal.enclosure_name }} →
    </div>
    <div class="kv muted" v-else>どのエリアにも未収容</div>

    <template v-if="animal.alive">
      <h4>給餌</h4>
      <div class="row">
        <select v-model="keeperId">
          <option value="" disabled>飼育員</option>
          <option v-for="k in zoo.keepers" :key="k.id" :value="k.id">{{ k.name }}</option>
        </select>
        <select v-model="foodKey">
          <option value="" disabled>餌</option>
          <option v-for="f in zoo.foods" :key="f.key" :value="f.key">{{ f.name_ja }}</option>
        </select>
        <button :disabled="zoo.loading || !keeperId || !foodKey"
                @click="act(zoo.feed(id, keeperId, foodKey))">給餌</button>
      </div>

      <h4>診療</h4>
      <div class="row">
        <select v-model="vetId">
          <option value="" disabled>獣医</option>
          <option v-for="v in zoo.veterinarians" :key="v.id" :value="v.id">{{ v.name }}</option>
        </select>
        <button :disabled="zoo.loading || !vetId" @click="act(zoo.treat(id, vetId))">治療</button>
        <button class="secondary" :disabled="zoo.loading || !vetId" @click="act(zoo.examine(id, vetId))">診察</button>
      </div>

      <h4>改名</h4>
      <div class="row">
        <input v-model="newName" placeholder="新しい名前" />
        <button :disabled="zoo.loading || !newName"
                @click="act(zoo.rename(id, newName)).then(() => (newName = ''))">改名</button>
      </div>

      <h4>移送・退去</h4>
      <div class="row">
        <select v-model="targetEnclosure">
          <option value="" disabled>移送先エリア</option>
          <option v-for="e in otherEnclosures" :key="e.id" :value="e.id">{{ e.name }}</option>
        </select>
        <button :disabled="zoo.loading || !targetEnclosure"
                @click="act(zoo.transfer(id, targetEnclosure))">移送</button>
        <button class="secondary" :disabled="zoo.loading || !animal.enclosure_id" @click="doRelease">退去</button>
      </div>
    </template>
  </div>
  <p v-else class="empty">読み込み中…</p>
</template>
