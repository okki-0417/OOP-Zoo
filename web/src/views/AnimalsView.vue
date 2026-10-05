<script setup lang="ts">
import { computed, reactive, ref } from "vue";
import { api, unwrap, type AnimalSummary } from "../api/client";
import MeterBar from "../components/MeterBar.vue";
import PageHeader from "../components/PageHeader.vue";
import QueryState from "../components/QueryState.vue";
import { useCommand } from "../composables/useCommand";
import { useQuery } from "../composables/useQuery";
import { emojiOf } from "../lib/emoji";

type Filter = "alive" | "unhoused" | "ailing" | "dead";

const animals = useQuery(() => unwrap(api.GET("/animals")));
const enclosures = useQuery(() => unwrap(api.GET("/enclosures")));
const species = useQuery(() => unwrap(api.GET("/species")));
const { busy, run } = useCommand();

const enclosureOf = computed(
  () =>
    new Map(
      (enclosures.data.value ?? []).flatMap((e) => e.occupants.map((a) => [a.id, e] as const)),
    ),
);
const vacancies = computed(() =>
  (enclosures.data.value ?? []).filter((e) => e.population < e.capacity),
);

const matchers: Record<Filter, (animal: AnimalSummary) => boolean> = {
  alive: (a) => a.alive,
  unhoused: (a) => a.alive && !enclosureOf.value.has(a.id),
  ailing: (a) => a.alive && (a.ailing || a.hungry),
  dead: (a) => !a.alive,
};
const filters: { key: Filter; label: string }[] = [
  { key: "alive", label: "飼育中" },
  { key: "unhoused", label: "未収容" },
  { key: "ailing", label: "要注意" },
  { key: "dead", label: "亡くなった" },
];
const filter = ref<Filter>("alive");
const keyword = ref("");

function countOf(key: Filter) {
  return (animals.data.value ?? []).filter(matchers[key]).length;
}

const visible = computed(() =>
  (animals.data.value ?? [])
    .filter(matchers[filter.value])
    .filter((a) => !keyword.value || `${a.name}${a.species}`.includes(keyword.value)),
);

const destinations = reactive<Record<string, string>>({});

async function house(animal: AnimalSummary) {
  const enclosureId = destinations[animal.id];
  if (!enclosureId) return;
  const housed = await run(
    () =>
      unwrap(
        api.POST("/enclosures/{enclosure_id}/occupants", {
          params: { path: { enclosure_id: enclosureId } },
          body: { animal_id: animal.id },
        }),
      ),
    (enclosure) => `${animal.name}を${enclosure.name}に収容しました`,
  );
  if (!housed) return;
  delete destinations[animal.id];
  void enclosures.reload();
}

const acquiring = ref(false);
const draft = reactive({ species_code: "", name: "", sex: "female" as "female" | "male" });

async function acquire() {
  const animal = await run(
    () => unwrap(api.POST("/animals", { body: { ...draft } })),
    (created) => `${created.species}の「${created.name}」を導入しました`,
  );
  if (!animal) return;
  draft.name = "";
  acquiring.value = false;
  filter.value = "unhoused";
  void animals.reload();
}
</script>

<template>
  <PageHeader title="動物" :subtitle="`飼育中 ${countOf('alive')} 頭`">
    <button class="btn btn-accent" @click="acquiring = !acquiring">
      {{ acquiring ? "閉じる" : "＋ 導入" }}
    </button>
  </PageHeader>

  <Transition name="slide">
    <form v-if="acquiring" class="card acquire" @submit.prevent="acquire">
      <label class="field">
        種
        <select v-model="draft.species_code" required>
          <option value="" disabled>選んでください</option>
          <option v-for="s in species.data.value" :key="s.key" :value="s.key">
            {{ emojiOf(s.name_ja, s.taxon_class) }} {{ s.name_ja }}（{{ s.conservation_label }}）
          </option>
        </select>
      </label>
      <label class="field">
        名前
        <input v-model.trim="draft.name" required maxlength="20" placeholder="例: ハナコ" />
      </label>
      <div class="segmented" role="group" aria-label="性別">
        <button type="button" :aria-pressed="draft.sex === 'female'" @click="draft.sex = 'female'">
          ♀ メス
        </button>
        <button type="button" :aria-pressed="draft.sex === 'male'" @click="draft.sex = 'male'">
          ♂ オス
        </button>
      </div>
      <button class="btn btn-primary" :disabled="busy">導入する</button>
    </form>
  </Transition>

  <div class="toolbar">
    <div class="segmented filters" role="group" aria-label="絞り込み">
      <button
        v-for="f in filters"
        :key="f.key"
        type="button"
        :aria-pressed="filter === f.key"
        @click="filter = f.key"
      >
        {{ f.label }} <span class="count">{{ countOf(f.key) }}</span>
      </button>
    </div>
    <input
      v-model.trim="keyword"
      class="inline-select search"
      type="search"
      placeholder="名前・種で検索"
      aria-label="検索"
    />
  </div>

  <QueryState
    :loading="animals.loading.value"
    :error="animals.error.value"
    :empty="visible.length === 0"
    empty-text="該当する動物はいません"
    @retry="animals.reload"
  >
    <div class="card table-card">
      <table class="data-table">
        <thead>
          <tr>
            <th>名前</th>
            <th>種</th>
            <th>エリア</th>
            <th>体力</th>
            <th>状態</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="animal in visible" :key="animal.id" :class="{ dead: !animal.alive }">
            <td>
              <RouterLink :to="`/animals/${animal.id}`" class="cell-link">
                <span>{{ animal.alive ? emojiOf(animal.species) : "🪦" }}</span>
                {{ animal.name }}
              </RouterLink>
            </td>
            <td>{{ animal.species }}</td>
            <td>
              <RouterLink
                v-if="enclosureOf.get(animal.id)"
                :to="`/enclosures/${enclosureOf.get(animal.id)!.id}`"
                class="cell-link"
              >
                {{ enclosureOf.get(animal.id)!.name }}
              </RouterLink>
              <form v-else-if="animal.alive" class="row house" @submit.prevent="house(animal)">
                <select
                  v-model="destinations[animal.id]"
                  class="inline-select"
                  required
                  aria-label="収容するエリア"
                >
                  <option :value="undefined" disabled>未収容 — 収容先…</option>
                  <option v-for="e in vacancies" :key="e.id" :value="e.id">
                    {{ e.name }}（{{ e.population }}/{{ e.capacity }}・{{ e.celsius }}℃）
                  </option>
                </select>
                <button
                  class="btn btn-primary btn-small"
                  :disabled="busy || !destinations[animal.id]"
                >
                  収容
                </button>
              </form>
              <span v-else class="muted">—</span>
            </td>
            <td class="meter-cell">
              <MeterBar
                v-if="animal.alive"
                label=""
                :value="animal.health"
                :max="animal.max_health"
              />
            </td>
            <td>
              <div class="badges">
                <template v-if="animal.alive">
                  <span v-if="animal.ailing" class="badge badge-bad">不調</span>
                  <span v-if="animal.hungry" class="badge badge-bad">空腹</span>
                  <span v-if="!animal.fed_today" class="badge badge-warn">未給餌</span>
                  <span v-if="!enclosureOf.has(animal.id)" class="badge badge-warn">未収容</span>
                </template>
                <span v-else class="badge">死亡</span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </QueryState>
</template>

<style scoped>
.acquire {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 12px;
  align-items: end;
  margin-bottom: 16px;
}

.filters {
  flex: 0 1 520px;
}

.count {
  margin-left: 2px;
  font-variant-numeric: tabular-nums;
  opacity: 0.7;
}

.search {
  flex: 0 1 240px;
  padding: 8px 12px;
}

.house {
  gap: 6px;
}

.house select {
  max-width: 240px;
}

tr.dead {
  color: var(--ink-soft);
}
</style>
