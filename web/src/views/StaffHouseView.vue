<script setup lang="ts">
import { computed, ref, shallowRef } from "vue";
import { api, unwrap, type Keeper } from "../api/client";
import MeterBar from "../components/MeterBar.vue";
import PageHeader from "../components/PageHeader.vue";
import QueryState from "../components/QueryState.vue";
import { useCommand } from "../composables/useCommand";
import { useQuery } from "../composables/useQuery";

type RoundsReport = Awaited<ReturnType<typeof makeRoundsOf>>;

const SHIFT_MINUTES = 480;

const keepers = useQuery(() => unwrap(api.GET("/keepers")));
const veterinarians = useQuery(() => unwrap(api.GET("/veterinarians")));
const enclosures = useQuery(() => unwrap(api.GET("/enclosures")));
const taxonClasses = useQuery(() => unwrap(api.GET("/taxon-classes")));
const reports = shallowRef<RoundsReport[]>([]);
const { busy, run } = useCommand();

const enclosureById = computed(
  () => new Map((enclosures.data.value ?? []).map((enclosure) => [enclosure.id, enclosure])),
);
const staffed = computed(() => (keepers.data.value ?? []).filter((k) => k.enclosures.length > 0));

function unfedIn(enclosureId: string) {
  return (enclosureById.value.get(enclosureId)?.occupants ?? []).filter(
    (a) => a.alive && !a.fed_today,
  ).length;
}

function pendingOf(keeper: Keeper) {
  return keeper.enclosures.reduce((sum, e) => sum + unfedIn(e.id), 0);
}

function makeRoundsOf(keeper: Keeper) {
  return unwrap(
    api.POST("/keepers/{keeper_id}/rounds", { params: { path: { keeper_id: keeper.id } } }),
  );
}

async function makeRounds(targets: Keeper[]) {
  const done: RoundsReport[] = [];
  for (const keeper of targets) {
    const report = await run(() => makeRoundsOf(keeper));
    if (report) done.push(report);
  }
  reports.value = done;
  void keepers.reload();
  void enclosures.reload();
}

const hiring = ref(false);
const role = ref<"keeper" | "veterinarian">("keeper");
const name = ref("");
const specialties = ref<string[]>([]);

function toggle(key: string) {
  specialties.value = specialties.value.includes(key)
    ? specialties.value.filter((k) => k !== key)
    : [...specialties.value, key];
}

async function hire() {
  const hired =
    role.value === "keeper"
      ? await run(
          () =>
            unwrap(
              api.POST("/keepers", { body: { name: name.value, specialties: specialties.value } }),
            ),
          (k) => `飼育員の${k.name}さんを採用しました`,
        )
      : await run(
          () => unwrap(api.POST("/veterinarians", { body: { name: name.value } })),
          (v) => `獣医の${v.name}さんを採用しました`,
        );
  if (!hired) return;
  name.value = "";
  specialties.value = [];
  hiring.value = false;
  void (role.value === "keeper" ? keepers.reload() : veterinarians.reload());
}
</script>

<template>
  <PageHeader
    title="スタッフ詰所"
    :crumbs="[{ label: '動物園', to: '/zoo' }]"
    subtitle="飼育員の担当エリアと勤務時間、獣医の顔ぶれ"
  >
    <button class="btn" @click="hiring = !hiring">{{ hiring ? "閉じる" : "＋ 採用" }}</button>
    <button
      class="btn btn-primary"
      :disabled="busy || staffed.length === 0"
      @click="makeRounds(staffed)"
    >
      🚶 全員で見回る
    </button>
  </PageHeader>

  <Transition name="slide">
    <form v-if="hiring" class="card hire" @submit.prevent="hire">
      <div class="segmented" role="group" aria-label="職種">
        <button type="button" :aria-pressed="role === 'keeper'" @click="role = 'keeper'">
          🧑‍🌾 飼育員
        </button>
        <button
          type="button"
          :aria-pressed="role === 'veterinarian'"
          @click="role = 'veterinarian'"
        >
          🧑‍⚕️ 獣医
        </button>
      </div>
      <label class="field">
        名前
        <input v-model.trim="name" required maxlength="20" placeholder="例: 田中" />
      </label>
      <fieldset v-if="role === 'keeper'" class="specialties">
        <legend class="muted">専門（複数可）</legend>
        <button
          v-for="t in taxonClasses.data.value"
          :key="t.key"
          type="button"
          class="chip"
          :aria-pressed="specialties.includes(t.key)"
          @click="toggle(t.key)"
        >
          {{ t.label }}
        </button>
      </fieldset>
      <button class="btn btn-primary" :disabled="busy || !name">採用する</button>
    </form>
  </Transition>

  <section v-if="reports.length" class="card stack results">
    <h2 class="section-title">見回りの結果</h2>
    <div v-for="report in reports" :key="report.keeper_id">
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

  <h2 class="section-title">飼育員</h2>
  <QueryState
    :loading="keepers.loading.value"
    :error="keepers.error.value"
    :empty="!keepers.data.value?.length"
    empty-text="飼育員がいません。採用しましょう"
    @retry="keepers.reload"
  >
    <ul class="people">
      <li v-for="keeper in keepers.data.value" :key="keeper.id" class="card person">
        <div class="row">
          <span class="portrait">🧑‍🌾</span>
          <span class="grow">
            <strong class="name">{{ keeper.name }}</strong>
            <span class="muted">{{ keeper.specialties || "専門なし" }}</span>
          </span>
          <template v-if="keeper.enclosures.length">
            <span v-if="pendingOf(keeper)" class="badge badge-warn"
              >未給餌 {{ pendingOf(keeper) }}</span
            >
            <span v-else class="badge badge-good">給餌済み</span>
          </template>
        </div>
        <MeterBar label="勤務時間(分)" :value="keeper.worked_minutes" :max="SHIFT_MINUTES" invert />
        <div v-if="keeper.enclosures.length" class="areas">
          <RouterLink
            v-for="area in keeper.enclosures"
            :key="area.id"
            :to="`/enclosures/${area.id}`"
            class="area"
          >
            🌳 {{ area.name }}
          </RouterLink>
        </div>
        <p v-else class="muted note">
          担当エリアがありません。エリアの中で担当に割り当てると見回れます
        </p>
        <button
          class="btn"
          :disabled="busy || keeper.enclosures.length === 0"
          @click="makeRounds([keeper])"
        >
          見回る
        </button>
      </li>
    </ul>
  </QueryState>

  <h2 class="section-title">獣医</h2>
  <QueryState
    :loading="veterinarians.loading.value"
    :error="veterinarians.error.value"
    :empty="!veterinarians.data.value?.length"
    empty-text="獣医がいません。病気の治療ができません"
    @retry="veterinarians.reload"
  >
    <ul class="people">
      <li v-for="v in veterinarians.data.value" :key="v.id" class="card person">
        <div class="row">
          <span class="portrait">🧑‍⚕️</span>
          <strong class="name grow">{{ v.name }}</strong>
        </div>
      </li>
    </ul>
  </QueryState>
</template>

<style scoped>
.hire {
  display: grid;
  gap: 12px;
  max-width: 560px;
  margin-bottom: 16px;
}

.results ul {
  margin: 4px 0 0;
  padding-left: 20px;
}

.results .section-title {
  margin-top: 0;
}

.skip {
  display: block;
  color: var(--warn);
  font-size: 0.85rem;
}

.people {
  list-style: none;
  margin: 0;
  padding: 0;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 12px;
}

.person {
  display: grid;
  gap: 10px;
  align-content: start;
}

.portrait {
  display: grid;
  place-items: center;
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: var(--surface-sunk);
  font-size: 1.6rem;
}

.name {
  display: block;
  font-size: 1.05rem;
}

.areas {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.area {
  padding: 4px 10px;
  border-radius: 999px;
  background: var(--surface-sunk);
  font-size: 0.85rem;
  font-weight: 700;
}

.area:hover {
  color: var(--brand);
}

.note {
  font-size: 0.85rem;
}

.specialties {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  border: none;
  margin: 0;
  padding: 0;
}

.specialties legend {
  margin-bottom: 6px;
}

.chip {
  border: 1px solid var(--line);
  background: var(--surface-sunk);
  border-radius: 999px;
  padding: 6px 12px;
  font-size: 0.85rem;
  font-weight: 700;
  cursor: pointer;
}

.chip[aria-pressed="true"] {
  background: var(--brand);
  border-color: var(--brand);
  color: var(--brand-ink);
}

.slide-enter-from,
.slide-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}

.slide-enter-active,
.slide-leave-active {
  transition: all 0.2s ease;
}
</style>
