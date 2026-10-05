<script setup lang="ts">
import { computed } from "vue";
import type { AnimalSummary, Enclosure } from "../api/client";
import { emojiOf } from "../lib/emoji";

const props = defineProps<{ enclosure: Enclosure; large?: boolean }>();

type Biome = { key: string; label: string; scenery: string[] };

const biome = computed<Biome>(() => {
  const celsius = props.enclosure.celsius;
  if (celsius <= 5) return { key: "ice", label: "寒冷", scenery: ["🧊", "❄️", "🧊"] };
  if (celsius <= 16) return { key: "forest", label: "冷温帯", scenery: ["🌲", "🌲", "🍂"] };
  if (celsius <= 24) return { key: "meadow", label: "温帯", scenery: ["🌳", "🌼", "🌿"] };
  if (celsius <= 30) return { key: "savanna", label: "サバンナ", scenery: ["🌾", "🪨", "🌾"] };
  return { key: "desert", label: "熱帯", scenery: ["🌵", "🪨", "🌴"] };
});

function hash(text: string) {
  let value = 2166136261;
  for (const char of text) value = Math.imul(value ^ char.charCodeAt(0), 16777619);
  return (value >>> 0) / 4294967296;
}

const residents = computed(() => {
  const animals = props.enclosure.occupants.filter((animal) => animal.alive);
  const columns = Math.max(1, Math.ceil(Math.sqrt(animals.length * 1.8)));
  const rows = Math.max(1, Math.ceil(animals.length / columns));
  return animals.map((animal, index) => {
    const column = index % columns;
    const row = Math.floor(index / columns);
    const x = ((column + 0.25 + hash(animal.id) * 0.5) / columns) * 80 + 10;
    const y = ((row + 0.25 + hash(`${animal.id}y`) * 0.5) / rows) * 60 + 22;
    return { animal, x, y };
  });
});

const scenery = computed(() =>
  biome.value.scenery.map((icon, index) => ({
    icon,
    x: [6, 88, 50][index]! + (hash(`${props.enclosure.id}${index}`) - 0.5) * 8,
    y: [8, 12, 86][index]!,
  })),
);

const droppings = computed(() =>
  Array.from({ length: Math.floor((100 - props.enclosure.cleanliness) / 25) }, (_, index) => ({
    x: 15 + hash(`${props.enclosure.id}d${index}`) * 70,
    y: 30 + hash(`${props.enclosure.id}e${index}`) * 60,
  })),
);

const toys = computed(() =>
  props.enclosure.enrichment > 50 ? 2 : props.enclosure.enrichment > 30 ? 1 : 0,
);

function moodOf(animal: AnimalSummary) {
  if (animal.ailing) return { icon: "🤒", label: "具合が悪い" };
  if (animal.hungry) return { icon: "🍖", label: "おなかを空かせている" };
  if (!animal.fed_today) return { icon: "🍽️", label: "今日はまだ食べていない" };
  return undefined;
}
</script>

<template>
  <div
    class="scene"
    :class="[`biome-${biome.key}`, { large }]"
    :title="`${biome.label}・${enclosure.celsius}℃`"
  >
    <span
      v-for="(item, index) in scenery"
      :key="`s${index}`"
      class="prop"
      :style="{ left: `${item.x}%`, top: `${item.y}%` }"
      aria-hidden="true"
      >{{ item.icon }}</span
    >
    <span
      v-for="index in toys"
      :key="`t${index}`"
      class="prop toy"
      :style="{ left: `${index === 1 ? 24 : 70}%`, top: `${index === 1 ? 82 : 78}%` }"
      aria-hidden="true"
      >{{ index === 1 ? "🪵" : "⚽" }}</span
    >
    <span
      v-for="(dropping, index) in droppings"
      :key="`d${index}`"
      class="prop dropping"
      :style="{ left: `${dropping.x}%`, top: `${dropping.y}%` }"
      aria-hidden="true"
      >💩</span
    >

    <component
      :is="large ? 'RouterLink' : 'span'"
      v-for="{ animal, x, y } in residents"
      :key="animal.id"
      :to="large ? `/animals/${animal.id}` : undefined"
      class="resident"
      :style="{ left: `${x}%`, top: `${y}%` }"
      :title="animal.name"
    >
      <span class="body">{{ emojiOf(animal.species) }}</span>
      <span v-if="moodOf(animal)" class="mood" :title="moodOf(animal)!.label">{{
        moodOf(animal)!.icon
      }}</span>
      <span v-if="large" class="nameplate">{{ animal.name }}</span>
    </component>

    <p v-if="residents.length === 0" class="vacant">だれもいません</p>
  </div>
</template>

<style scoped>
.scene {
  position: relative;
  overflow: hidden;
  height: 160px;
  border-radius: 12px;
  isolation: isolate;
}

.scene.large {
  height: min(62vh, 520px);
  border-radius: 20px;
}

.biome-ice {
  background:
    radial-gradient(ellipse 24% 16% at 72% 74%, #a9d6ec 96%, transparent 100%),
    linear-gradient(180deg, #eef7fb, #cfe6f1);
}

.biome-forest {
  background: linear-gradient(180deg, #d5e6c4, #a9c98f);
}

.biome-meadow {
  background: linear-gradient(180deg, #e0efc4, #b7d88c);
}

.biome-savanna {
  background: linear-gradient(180deg, #f2e4b3, #dcc27a);
}

.biome-desert {
  background: linear-gradient(180deg, #f6dfb0, #e6bd7b);
}

@media (prefers-color-scheme: dark) {
  .scene::before {
    content: "";
    position: absolute;
    inset: 0;
    z-index: -1;
    background: rgb(10 20 15 / 30%);
  }
}

.prop,
.resident {
  position: absolute;
  transform: translate(-50%, -50%);
  line-height: 1;
}

.prop {
  font-size: 1.3rem;
  opacity: 0.85;
  pointer-events: none;
}

.large .prop {
  font-size: 2.4rem;
}

.prop.toy {
  font-size: 1rem;
}

.large .prop.toy {
  font-size: 1.8rem;
}

.prop.dropping {
  font-size: 0.8rem;
}

.large .prop.dropping {
  font-size: 1.3rem;
}

.resident {
  display: grid;
  justify-items: center;
  gap: 2px;
}

.body {
  font-size: 2.4rem;
  filter: drop-shadow(0 3px 2px rgb(0 0 0 / 25%));
}

.large .body {
  font-size: 4rem;
  transition: transform 0.15s ease;
}

.large a.resident:hover .body {
  transform: scale(1.12) translateY(-4px);
}

.mood {
  position: absolute;
  top: -10px;
  right: -14px;
  font-size: 0.9rem;
  padding: 1px 3px;
  border-radius: 999px;
  background: rgb(255 255 255 / 85%);
  box-shadow: 0 1px 3px rgb(0 0 0 / 20%);
}

.large .mood {
  top: -6px;
  right: -18px;
  font-size: 1.3rem;
}

.nameplate {
  padding: 2px 10px;
  border-radius: 999px;
  background: rgb(255 253 247 / 92%);
  color: #2b2a22;
  font-size: 0.85rem;
  font-weight: 800;
  box-shadow: 0 1px 3px rgb(0 0 0 / 18%);
  white-space: nowrap;
}

.vacant {
  position: absolute;
  inset: 0;
  display: grid;
  place-items: center;
  color: rgb(43 42 34 / 55%);
  font-weight: 700;
  font-size: 0.9rem;
}
</style>
