<script setup lang="ts">
import { computed, shallowRef, watch } from "vue";
import { api, unwrap, type Enclosure, type Keeper } from "../api/client";
import MeterBar from "../components/MeterBar.vue";
import PageHeader from "../components/PageHeader.vue";
import QueryState from "../components/QueryState.vue";
import { useCommand } from "../composables/useCommand";
import { useQuery } from "../composables/useQuery";

type RoundsReport = Awaited<ReturnType<typeof makeRoundsOf>>;

const SHIFT_MINUTES = 480;

const keepers = useQuery(() => unwrap(api.GET("/keepers")));
const enclosures = shallowRef<Record<string, Enclosure>>({});
const reports = shallowRef<RoundsReport[]>([]);
const { busy, run } = useCommand();

const assignedIds = computed(() => [
  ...new Set((keepers.data.value ?? []).flatMap((k) => k.enclosures.map((e) => e.id))),
]);

async function loadEnclosures() {
  const loaded = await Promise.all(
    assignedIds.value.map((id) =>
      unwrap(api.GET("/enclosures/{enclosure_id}", { params: { path: { enclosure_id: id } } })),
    ),
  );
  enclosures.value = Object.fromEntries(loaded.map((enclosure) => [enclosure.id, enclosure]));
}

watch(assignedIds, () => void loadEnclosures());

function unfedIn(enclosureId: string) {
  return (enclosures.value[enclosureId]?.occupants ?? []).filter((a) => a.alive && !a.fed_today);
}

function pendingOf(keeper: Keeper) {
  return keeper.enclosures.reduce((sum, e) => sum + unfedIn(e.id).length, 0);
}

function makeRoundsOf(keeper: Keeper) {
  return unwrap(
    api.POST("/keepers/{keeper_id}/rounds", { params: { path: { keeper_id: keeper.id } } }),
  );
}

async function refresh() {
  await keepers.reload();
  await loadEnclosures();
}

async function makeRounds(targets: Keeper[]) {
  const done: RoundsReport[] = [];
  for (const keeper of targets) {
    const report = await run(() => makeRoundsOf(keeper));
    if (report) done.push(report);
  }
  reports.value = done;
  await refresh();
}

const staffed = computed(() => (keepers.data.value ?? []).filter((k) => k.enclosures.length > 0));
const idle = computed(() => (keepers.data.value ?? []).filter((k) => k.enclosures.length === 0));
</script>

<template>
  <PageHeader title="今日の業務" subtitle="担当エリアの見回りと、飼育員の勤務時間">
    <button
      class="btn btn-primary"
      :disabled="busy || staffed.length === 0"
      @click="makeRounds(staffed)"
    >
      🚶 全員で見回る
    </button>
  </PageHeader>

  <section v-if="reports.length" class="card stack results">
    <h2 class="section-title">見回りの結果</h2>
    <div v-for="report in reports" :key="report.keeper_id" class="result">
      <strong>{{ report.keeper_name }}</strong>
      <span class="muted">（残り {{ report.remaining_minutes }} 分）</span>
      <ul>
        <li v-for="round in report.rounds" :key="round.enclosure.id">
          {{ round.enclosure.name }}:
          {{ round.fed.length ? `${round.fed.join("・")}に給餌` : "給餌なし" }}
          <span v-if="round.cleaned">・清掃</span>
          <span v-if="round.enriched">・遊具を補充</span>
          <span v-for="skip in round.skipped" :key="skip.subject + skip.reason" class="skip">
            ⚠️ {{ skip.subject }}: {{ skip.reason }}
          </span>
        </li>
      </ul>
    </div>
  </section>

  <QueryState
    :loading="keepers.loading.value"
    :error="keepers.error.value"
    :empty="!keepers.data.value?.length"
    empty-text="飼育員がいません。スタッフ画面で採用しましょう"
    @retry="keepers.reload"
  >
    <ul class="card-grid">
      <li v-for="keeper in staffed" :key="keeper.id" class="card stack keeper">
        <div class="row">
          <span class="avatar small">🧑‍🌾</span>
          <span class="grow">
            <strong>{{ keeper.name }}</strong>
            <span class="muted"> {{ keeper.specialties }}</span>
          </span>
          <span v-if="pendingOf(keeper)" class="badge badge-warn"
            >未給餌 {{ pendingOf(keeper) }}</span
          >
          <span v-else class="badge badge-good">給餌済み</span>
        </div>
        <MeterBar label="勤務時間(分)" :value="keeper.worked_minutes" :max="SHIFT_MINUTES" invert />
        <ul class="areas">
          <li v-for="area in keeper.enclosures" :key="area.id">
            <RouterLink :to="`/enclosures/${area.id}`" class="row area">
              <span class="grow">🌳 {{ area.name }}</span>
              <span v-if="enclosures[area.id]" class="muted">
                {{ enclosures[area.id]!.population }}頭・清潔{{
                  enclosures[area.id]!.cleanliness
                }}・刺激{{ enclosures[area.id]!.enrichment }}
              </span>
            </RouterLink>
          </li>
        </ul>
        <button class="btn" :disabled="busy" @click="makeRounds([keeper])">見回る</button>
      </li>
    </ul>

    <template v-if="idle.length">
      <h2 class="section-title">担当エリアのない飼育員</h2>
      <p class="card muted">
        {{ idle.map((k) => k.name).join("・") }} — エリア画面で担当を割り当てると見回れます
      </p>
    </template>
  </QueryState>
</template>

<style scoped>
.results {
  margin-bottom: 16px;
}

.results .section-title {
  margin-top: 0;
}

.result ul {
  margin: 4px 0 0;
  padding-left: 20px;
}

.skip {
  display: block;
  color: var(--warn);
  font-size: 0.85rem;
}

.keeper {
  list-style: none;
}

.avatar.small {
  width: 36px;
  height: 36px;
  border-radius: 10px;
  font-size: 1.2rem;
}

.areas {
  list-style: none;
  margin: 0;
  padding: 0;
  display: grid;
  gap: 4px;
}

.area {
  padding: 8px 10px;
  border-radius: 10px;
  background: var(--surface-sunk);
  font-size: 0.9rem;
}

.area:hover {
  filter: brightness(0.97);
}
</style>
