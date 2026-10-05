<script setup lang="ts">
import { computed } from "vue";
import type { Chore } from "../api/client";

const props = defineProps<{ chores: Chore[] }>();

const chores = computed(() =>
  props.chores.map((chore) => ({ ...chore, pending: chore.items.filter((item) => !item.done) })),
);
const doneCount = computed(() => props.chores.reduce((sum, chore) => sum + chore.done_count, 0));
const total = computed(() => props.chores.reduce((sum, chore) => sum + chore.total, 0));

const icons: Record<Chore["kind"], string> = {
  feeding: "🍖",
  treatment: "💊",
  cleaning: "🧹",
  enrichment: "🪵",
};

const emptyTexts: Record<Chore["kind"], string> = {
  feeding: "収容中の動物はいません",
  treatment: "病気の動物はいません",
  cleaning: "動物のいるエリアはありません",
  enrichment: "動物のいるエリアはありません",
};

const pendingTexts: Record<Chore["kind"], string> = {
  feeding: "まだ食べていない",
  treatment: "治療を待っている",
  cleaning: "汚れてきた",
  enrichment: "刺激が減ってきた",
};

function linkOf(subject: Chore["items"][number]["subject"]) {
  return subject.type === "animal" ? `/animals/${subject.id}` : `/enclosures/${subject.id}`;
}

function percent(done: number, all: number) {
  return all === 0 ? 100 : Math.round((done / all) * 100);
}
</script>

<template>
  <section class="card stack checklist">
    <div class="overall">
      <span class="grow">
        <strong>{{ doneCount }} / {{ total }}</strong>
        <span class="muted"> 件完了</span>
      </span>
      <RouterLink to="/zoo/staff" class="btn">🚶 見回りへ</RouterLink>
    </div>
    <div class="bar" role="progressbar" :aria-valuenow="percent(doneCount, total)">
      <span :style="{ width: `${percent(doneCount, total)}%` }" />
    </div>

    <ul class="chores">
      <li
        v-for="chore in chores"
        :key="chore.kind"
        class="chore"
        :class="{ done: !chore.pending.length }"
      >
        <div class="head">
          <span class="check">{{ chore.pending.length ? "☐" : "☑" }}</span>
          <span class="icon">{{ icons[chore.kind] }}</span>
          <strong class="grow">{{ chore.label }}</strong>
          <span v-if="chore.kind === 'treatment'" class="tally">
            {{ chore.pending.length ? `残り ${chore.pending.length} 頭` : "なし" }}
          </span>
          <span v-else class="tally">{{ chore.done_count }} / {{ chore.total }}</span>
        </div>
        <div v-if="chore.kind !== 'treatment' && chore.total" class="bar thin">
          <span :style="{ width: `${percent(chore.done_count, chore.total)}%` }" />
        </div>
        <p v-if="chore.total === 0" class="muted note">{{ emptyTexts[chore.kind] }}</p>
        <p v-else-if="chore.pending.length" class="pending">
          <span class="muted">{{ pendingTexts[chore.kind] }}:</span>
          <RouterLink
            v-for="item in chore.pending"
            :key="item.subject.id"
            :to="linkOf(item.subject)"
            class="chip"
          >
            {{ item.subject.name }}
          </RouterLink>
        </p>
      </li>
    </ul>
  </section>
</template>

<style scoped>
.overall {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 1.05rem;
}

.bar {
  height: 10px;
  border-radius: 5px;
  background: var(--surface-sunk);
  overflow: hidden;
}

.bar span {
  display: block;
  height: 100%;
  border-radius: inherit;
  background: var(--good);
  transition: width 0.3s ease;
}

.bar.thin {
  height: 6px;
  background: var(--line);
}

.chores {
  list-style: none;
  margin: 0;
  padding: 0;
  display: grid;
  gap: 8px;
}

.chore {
  display: grid;
  gap: 6px;
  padding: 10px 12px;
  border-radius: 12px;
  background: var(--surface-sunk);
}

.head {
  display: flex;
  align-items: center;
  gap: 8px;
}

.check {
  font-size: 1.2rem;
  color: var(--ink-soft);
}

.chore.done .check {
  color: var(--good);
}

.chore.done strong {
  color: var(--ink-soft);
}

.icon {
  font-size: 1.2rem;
}

.tally {
  font-weight: 700;
  font-variant-numeric: tabular-nums;
}

.chore:not(.done) .tally {
  color: var(--warn);
}

.note {
  font-size: 0.85rem;
}

.pending {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 6px;
  font-size: 0.85rem;
}

.chip {
  padding: 2px 10px;
  border-radius: 999px;
  border: 1px solid var(--line);
  background: var(--surface);
  font-weight: 700;
}

.chip:hover {
  border-color: var(--brand);
  color: var(--brand);
}
</style>
