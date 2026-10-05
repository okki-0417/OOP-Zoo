<script setup lang="ts">
import { computed, ref, watch } from "vue";
import { api, unwrap } from "../api/client";
import HabitatScene from "../components/HabitatScene.vue";
import MeterBar from "../components/MeterBar.vue";
import PageHeader from "../components/PageHeader.vue";
import QueryState from "../components/QueryState.vue";
import { useCommand } from "../composables/useCommand";
import { useQuery } from "../composables/useQuery";
import { emojiOf } from "../lib/emoji";

const props = defineProps<{ id: string }>();

const path = computed(() => ({ path: { enclosure_id: props.id } }));
const enclosure = useQuery(() =>
  unwrap(api.GET("/enclosures/{enclosure_id}", { params: path.value })),
);
const animals = useQuery(() => unwrap(api.GET("/animals")));
const keepers = useQuery(() => unwrap(api.GET("/keepers")));
const { busy, run } = useCommand();

const keeperId = ref("");
const animalId = ref("");
const assigneeId = ref("");

const unassigned = computed(() => {
  const assigned = new Set(enclosure.data.value?.keepers.map((k) => k.id));
  return (keepers.data.value ?? []).filter((k) => !assigned.has(k.id));
});

function remainingOf(id: string) {
  return keepers.data.value?.find((k) => k.id === id)?.remaining_minutes;
}

watch(keepers.data, (list) => (keeperId.value ||= list?.[0]?.id ?? ""));

const candidates = computed(() => {
  const housed = new Set(enclosure.data.value?.occupants.map((o) => o.id));
  return (animals.data.value ?? []).filter((a) => a.alive && !housed.has(a.id));
});

const full = computed(
  () => !!enclosure.data.value && enclosure.data.value.population >= enclosure.data.value.capacity,
);

async function clean() {
  const cleaned = await run(
    () =>
      unwrap(
        api.POST("/enclosures/{enclosure_id}/cleanings", {
          params: path.value,
          body: { keeper_id: keeperId.value },
        }),
      ),
    (e) => `${e.name}をきれいにしました`,
  );
  if (!cleaned) return;
  enclosure.data.value = cleaned;
  void keepers.reload();
}

async function enrich() {
  const enriched = await run(
    () =>
      unwrap(
        api.POST("/enclosures/{enclosure_id}/enrichments", {
          params: path.value,
          body: { keeper_id: keeperId.value },
        }),
      ),
    (e) => `${e.name}に遊具を補充しました`,
  );
  if (!enriched) return;
  enclosure.data.value = enriched;
  void keepers.reload();
}

async function assign() {
  const assigned = await run(
    () =>
      unwrap(
        api.POST("/enclosures/{enclosure_id}/keepers", {
          params: path.value,
          body: { keeper_id: assigneeId.value },
        }),
      ),
    () => "担当に割り当てました",
  );
  if (!assigned) return;
  enclosure.data.value = assigned;
  assigneeId.value = "";
}

async function discharge(id: string, name: string) {
  const discharged = await run(
    () =>
      unwrap(
        api.DELETE("/enclosures/{enclosure_id}/keepers/{keeper_id}", {
          params: { path: { enclosure_id: props.id, keeper_id: id } },
        }),
      ),
    () => `${name}さんを担当から外しました`,
  );
  if (discharged) enclosure.data.value = discharged;
}

async function house() {
  const housed = await run(
    () =>
      unwrap(
        api.POST("/enclosures/{enclosure_id}/occupants", {
          params: path.value,
          body: { animal_id: animalId.value },
        }),
      ),
    () => "収容しました",
  );
  if (!housed) return;
  enclosure.data.value = housed;
  animalId.value = "";
}

async function release(id: string, name: string) {
  const released = await run(
    () =>
      unwrap(
        api.DELETE("/enclosures/{enclosure_id}/occupants/{animal_id}", {
          params: { path: { enclosure_id: props.id, animal_id: id } },
        }),
      ),
    () => `${name}を退去させました`,
  );
  if (released) void enclosure.reload();
}
</script>

<template>
  <PageHeader
    :title="enclosure.data.value?.name ?? 'エリア'"
    :crumbs="[{ label: '動物園', to: '/zoo' }]"
    :subtitle="
      enclosure.data.value
        ? `設定 ${enclosure.data.value.celsius}℃${enclosure.data.value.climate_controlled ? '（空調）' : ''}・${enclosure.data.value.population} / ${enclosure.data.value.capacity} 頭`
        : undefined
    "
  />

  <QueryState
    :loading="enclosure.loading.value"
    :error="enclosure.error.value"
    :empty="!enclosure.data.value"
    @retry="enclosure.reload"
  >
    <div v-if="enclosure.data.value" class="inside">
      <div class="habitat">
        <HabitatScene :enclosure="enclosure.data.value" large />
        <p class="muted hint">動物をクリックすると、その個体の様子を見られます</p>
      </div>

      <aside class="inspector">
        <section class="card stack">
          <h2 class="panel-title">環境</h2>
          <MeterBar label="清潔度" :value="enclosure.data.value.cleanliness" :max="100" />
          <MeterBar label="刺激" :value="enclosure.data.value.enrichment" :max="100" />
          <form class="stack" @submit.prevent="clean">
            <label class="field">
              作業する飼育員
              <select v-model="keeperId" required>
                <option v-for="k in keepers.data.value" :key="k.id" :value="k.id">
                  {{ k.name }}（残り{{ k.remaining_minutes }}分）
                </option>
              </select>
            </label>
            <div class="row">
              <button class="btn btn-primary grow" :disabled="busy || !keeperId">
                🧹 清掃 60分
              </button>
              <button type="button" class="btn grow" :disabled="busy || !keeperId" @click="enrich">
                🪵 補充 30分
              </button>
            </div>
          </form>
        </section>

        <section class="card stack">
          <h2 class="panel-title">担当飼育員</h2>
          <ul v-if="enclosure.data.value.keepers.length" class="people">
            <li v-for="k in enclosure.data.value.keepers" :key="k.id" class="row">
              <span>🧑‍🌾</span>
              <strong class="grow">{{ k.name }}</strong>
              <span class="muted">残り{{ remainingOf(k.id) ?? "-" }}分</span>
              <button class="btn small-btn" :disabled="busy" @click="discharge(k.id, k.name)">
                外す
              </button>
            </li>
          </ul>
          <p v-else class="muted">担当がいません。日々の見回りが行われません</p>
          <form class="row bottom" @submit.prevent="assign">
            <select v-model="assigneeId" class="grow" required aria-label="担当に加える飼育員">
              <option value="" disabled>担当に加える…</option>
              <option v-for="k in unassigned" :key="k.id" :value="k.id">
                {{ k.name }}（{{ k.specialties }}）
              </option>
            </select>
            <button class="btn" :disabled="busy || !assigneeId">割り当て</button>
          </form>
        </section>

        <section class="card stack">
          <h2 class="panel-title">住人</h2>
          <ul v-if="enclosure.data.value.occupants.length" class="people">
            <li v-for="occupant in enclosure.data.value.occupants" :key="occupant.id" class="row">
              <RouterLink :to="`/animals/${occupant.id}`" class="row grow">
                <span>{{ emojiOf(occupant.species) }}</span>
                <strong>{{ occupant.name }}</strong>
                <span class="muted">{{ occupant.species }}</span>
              </RouterLink>
              <button
                class="btn small-btn"
                :disabled="busy"
                @click="release(occupant.id, occupant.name)"
              >
                退去
              </button>
            </li>
          </ul>
          <form class="row bottom" @submit.prevent="house">
            <select v-model="animalId" class="grow" required aria-label="迎え入れる動物">
              <option value="" disabled>迎え入れる…</option>
              <option v-for="a in candidates" :key="a.id" :value="a.id">
                {{ emojiOf(a.species) }} {{ a.name }}（{{ a.species }}）
              </option>
            </select>
            <button class="btn btn-primary" :disabled="busy || !animalId || full">収容</button>
          </form>
          <p v-if="full" class="muted">満員のため収容できません</p>
        </section>
      </aside>
    </div>
  </QueryState>
</template>

<style scoped>
.inside {
  display: grid;
  grid-template-columns: minmax(0, 1fr) minmax(0, 340px);
  gap: 20px;
  align-items: start;
}

@media (width < 1100px) {
  .inside {
    grid-template-columns: minmax(0, 1fr);
  }
}

.habitat {
  position: sticky;
  top: 16px;
  padding: 10px;
  border-radius: 28px;
  background: #b98d5e;
  box-shadow:
    0 0 0 4px #8a6239,
    0 10px 24px rgb(40 30 10 / 25%);
}

.hint {
  margin: 8px 6px 0;
  font-size: 0.8rem;
  color: #fff8e8;
}

.inspector {
  display: grid;
  grid-template-columns: minmax(0, 1fr);
  gap: 12px;
}

.inspector > * {
  min-width: 0;
}

.panel-title {
  font-size: 0.85rem;
  font-weight: 800;
  color: var(--ink-soft);
}

.people {
  list-style: none;
  margin: 0;
  padding: 0;
  display: grid;
  gap: 6px;
}

.people .row {
  gap: 8px;
}

.bottom {
  align-items: end;
}

select.grow {
  flex: 1 1 0;
  width: 0;
  min-width: 0;
  padding: 10px 12px;
  border-radius: 10px;
  border: 1px solid var(--line);
  background: var(--surface-sunk);
}

.small-btn {
  padding: 6px 12px;
  font-size: 0.8rem;
}
</style>
