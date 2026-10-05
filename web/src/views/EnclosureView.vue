<script setup lang="ts">
import { computed, ref, watch } from "vue";
import { api, unwrap } from "../api/client";
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
  <PageHeader :title="enclosure.data.value?.name ?? 'エリア'" back="/enclosures" />

  <QueryState
    :loading="enclosure.loading.value"
    :error="enclosure.error.value"
    :empty="!enclosure.data.value"
    @retry="enclosure.reload"
  >
    <div v-if="enclosure.data.value" class="columns">
      <div>
        <h2 class="section-title">状態</h2>
        <section class="card stack">
          <MeterBar
            label="収容数"
            :value="enclosure.data.value.population"
            :max="enclosure.data.value.capacity"
            invert
          />
          <MeterBar label="清潔度" :value="enclosure.data.value.cleanliness" :max="100" />
          <MeterBar label="刺激" :value="enclosure.data.value.enrichment" :max="100" />
          <form class="row bottom" @submit.prevent="clean">
            <label class="field grow">
              作業する飼育員
              <select v-model="keeperId" required>
                <option v-for="k in keepers.data.value" :key="k.id" :value="k.id">
                  {{ k.name }}（残り{{ k.remaining_minutes }}分）
                </option>
              </select>
            </label>
            <button class="btn btn-primary" :disabled="busy || !keeperId">🧹 清掃 60分</button>
            <button type="button" class="btn" :disabled="busy || !keeperId" @click="enrich">
              🧸 補充 30分
            </button>
          </form>
        </section>

        <h2 class="section-title">担当飼育員</h2>
        <section class="card stack">
          <ul v-if="enclosure.data.value.keepers.length" class="list plain">
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
            <label class="field grow">
              担当に加える
              <select v-model="assigneeId" required>
                <option value="" disabled>選んでください</option>
                <option v-for="k in unassigned" :key="k.id" :value="k.id">
                  {{ k.name }}（{{ k.specialties }}）
                </option>
              </select>
            </label>
            <button class="btn" :disabled="busy || !assigneeId">割り当て</button>
          </form>
        </section>

        <h2 class="section-title">迎え入れる</h2>
        <form class="card row bottom" @submit.prevent="house">
          <label class="field grow">
            動物
            <select v-model="animalId" required>
              <option value="" disabled>選んでください</option>
              <option v-for="a in candidates" :key="a.id" :value="a.id">
                {{ emojiOf(a.species) }} {{ a.name }}（{{ a.species }}）
              </option>
            </select>
          </label>
          <button class="btn btn-primary" :disabled="busy || !animalId || full">収容</button>
        </form>
        <p v-if="full" class="muted note">満員のため収容できません</p>
      </div>

      <div>
        <h2 class="section-title">住んでいる動物</h2>
        <ul v-if="enclosure.data.value.occupants.length" class="card list">
          <li v-for="occupant in enclosure.data.value.occupants" :key="occupant.id" class="row">
            <RouterLink :to="`/animals/${occupant.id}`" class="row grow">
              <span class="avatar small">{{ emojiOf(occupant.species) }}</span>
              <span class="grow occupant">
                <strong>{{ occupant.name }}</strong>
                <span class="muted">{{ occupant.species }}</span>
              </span>
              <span v-if="occupant.ailing" class="badge badge-bad">不調</span>
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
        <p v-else class="card empty">まだ誰も住んでいません</p>
      </div>
    </div>
  </QueryState>
</template>

<style scoped>
.bottom {
  align-items: end;
}

.avatar.small {
  width: 36px;
  height: 36px;
  border-radius: 10px;
  font-size: 1.2rem;
}

.occupant {
  display: flex;
  align-items: baseline;
  gap: 6px;
}

.small-btn {
  padding: 6px 12px;
  font-size: 0.8rem;
}

.list.plain {
  padding: 0;
}

.note {
  margin: 8px 4px 0;
}
</style>
