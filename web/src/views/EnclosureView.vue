<script setup lang="ts">
import { computed, ref, watch } from "vue";
import { graphql } from "../api/generated";
import MeterBar from "../components/MeterBar.vue";
import PageHeader from "../components/PageHeader.vue";
import QueryState from "../components/QueryState.vue";
import { useMutation } from "../composables/useMutation";
import { useQuery } from "../composables/useQuery";
import { emojiOf } from "../lib/emoji";

const props = defineProps<{ id: string }>();

const EnclosureQuery = graphql(`
  query Enclosure($id: ID!) {
    enclosure(id: $id) {
      id
      name
      celsius
      climateControlled
      capacity
      cleanliness
      enrichment
      occupancy {
        full
      }
      occupants {
        id
        name
        health
        maxHealth
        ailing
        hungry
        fedToday
        species {
          nameJa
        }
      }
      keepers {
        id
        name
      }
    }
    animals {
      id
      name
      alive
      enclosure {
        id
      }
      species {
        nameJa
      }
    }
    keepers {
      id
      name
      remainingMinutes
      specialties {
        label
      }
    }
  }
`);

const CleanEnclosureMutation = graphql(`
  mutation CleanEnclosure($enclosureId: ID!, $keeperId: ID!) {
    cleanEnclosure(enclosureId: $enclosureId, keeperId: $keeperId) {
      name
    }
  }
`);

const EnrichEnclosureMutation = graphql(`
  mutation EnrichEnclosure($enclosureId: ID!, $keeperId: ID!) {
    enrichEnclosure(enclosureId: $enclosureId, keeperId: $keeperId) {
      name
    }
  }
`);

const AssignKeeperMutation = graphql(`
  mutation AssignKeeper($enclosureId: ID!, $keeperId: ID!) {
    assignKeeper(enclosureId: $enclosureId, keeperId: $keeperId) {
      id
    }
  }
`);

const DischargeKeeperMutation = graphql(`
  mutation DischargeKeeper($enclosureId: ID!, $keeperId: ID!) {
    dischargeKeeper(enclosureId: $enclosureId, keeperId: $keeperId) {
      id
    }
  }
`);

const HouseOccupantMutation = graphql(`
  mutation HouseOccupant($enclosureId: ID!, $animalId: ID!) {
    houseAnimal(enclosureId: $enclosureId, animalId: $animalId) {
      id
    }
  }
`);

const ReleaseAnimalMutation = graphql(`
  mutation ReleaseAnimal($animalId: ID!) {
    releaseAnimal(animalId: $animalId) {
      id
    }
  }
`);

const query = useQuery(EnclosureQuery, () => ({ id: props.id }));
const enclosure = computed(() => query.data.value?.enclosure ?? undefined);
const keepers = computed(() => query.data.value?.keepers ?? []);
const { busy, mutate } = useMutation();

const keeperId = ref("");
const animalId = ref("");
const assigneeId = ref("");

const unassigned = computed(() => {
  const assigned = new Set(enclosure.value?.keepers.map((k) => k.id));
  return keepers.value.filter((k) => !assigned.has(k.id));
});

function remainingOf(id: string) {
  return keepers.value.find((k) => k.id === id)?.remainingMinutes;
}

watch(keepers, (list) => (keeperId.value ||= list[0]?.id ?? ""));

const candidates = computed(() =>
  (query.data.value?.animals ?? []).filter((a) => a.alive && a.enclosure?.id !== props.id),
);

const full = computed(() => !!enclosure.value?.occupancy.full);

async function clean() {
  await mutate(
    CleanEnclosureMutation,
    { enclosureId: props.id, keeperId: keeperId.value },
    ({ cleanEnclosure }) => `${cleanEnclosure.name}をきれいにしました`,
  );
}

async function enrich() {
  await mutate(
    EnrichEnclosureMutation,
    { enclosureId: props.id, keeperId: keeperId.value },
    ({ enrichEnclosure }) => `${enrichEnclosure.name}に遊具を補充しました`,
  );
}

async function assign() {
  const assigned = await mutate(
    AssignKeeperMutation,
    { enclosureId: props.id, keeperId: assigneeId.value },
    () => "担当に割り当てました",
  );
  if (assigned) assigneeId.value = "";
}

async function discharge(id: string, name: string) {
  await mutate(
    DischargeKeeperMutation,
    { enclosureId: props.id, keeperId: id },
    () => `${name}さんを担当から外しました`,
  );
}

async function house() {
  const housed = await mutate(
    HouseOccupantMutation,
    { enclosureId: props.id, animalId: animalId.value },
    () => "収容しました",
  );
  if (housed) animalId.value = "";
}

async function release(id: string, name: string | null) {
  await mutate(ReleaseAnimalMutation, { animalId: id }, () => `${name}を退去させました`);
}
</script>

<template>
  <PageHeader
    :title="enclosure?.name ?? 'エリア'"
    :crumbs="[{ label: 'エリア', to: '/enclosures' }]"
    :subtitle="
      enclosure
        ? `設定 ${enclosure.celsius}℃${enclosure.climateControlled ? '（空調）' : ''}・${enclosure.occupants.length} / ${enclosure.capacity} 頭`
        : undefined
    "
  />

  <QueryState
    :loading="query.loading.value"
    :error="query.error.value"
    :empty="!enclosure"
    @retry="query.reload"
  >
    <div v-if="enclosure" class="inside">
      <section class="stack">
        <form class="toolbar" @submit.prevent="house">
          <select v-model="animalId" class="inline-select grow" required aria-label="収容する動物">
            <option value="" disabled>収容する動物…</option>
            <option v-for="a in candidates" :key="a.id" :value="a.id">
              {{ emojiOf(a.species.nameJa) }} {{ a.name }}（{{ a.species.nameJa }}）
            </option>
          </select>
          <button class="btn btn-primary btn-small" :disabled="busy || !animalId || full">
            収容
          </button>
          <span v-if="full" class="muted">満員です</span>
        </form>
        <div v-if="enclosure.occupants.length" class="card table-card">
          <table class="data-table">
            <thead>
              <tr>
                <th>名前</th>
                <th>種</th>
                <th>体力</th>
                <th>状態</th>
                <th />
              </tr>
            </thead>
            <tbody>
              <tr v-for="occupant in enclosure.occupants" :key="occupant.id">
                <td>
                  <RouterLink :to="`/animals/${occupant.id}`" class="cell-link">
                    <span>{{ emojiOf(occupant.species.nameJa) }}</span>
                    {{ occupant.name }}
                  </RouterLink>
                </td>
                <td>{{ occupant.species.nameJa }}</td>
                <td class="meter-cell">
                  <MeterBar label="" :value="occupant.health" :max="occupant.maxHealth" />
                </td>
                <td>
                  <div class="badges">
                    <span v-if="occupant.ailing" class="badge badge-bad">不調</span>
                    <span v-if="occupant.hungry" class="badge badge-bad">空腹</span>
                    <span v-if="!occupant.fedToday" class="badge badge-warn">未給餌</span>
                    <span
                      v-if="!occupant.ailing && !occupant.hungry && occupant.fedToday"
                      class="badge badge-good"
                      >良好</span
                    >
                  </div>
                </td>
                <td class="actions">
                  <button
                    class="btn btn-small"
                    :disabled="busy"
                    @click="release(occupant.id, occupant.name)"
                  >
                    退去
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <p v-else class="card empty">住人はいません</p>
      </section>

      <aside class="inspector">
        <section class="card stack">
          <h2 class="panel-title">環境</h2>
          <MeterBar label="清潔度" :value="enclosure.cleanliness" :max="100" />
          <MeterBar label="刺激" :value="enclosure.enrichment" :max="100" />
          <form class="stack" @submit.prevent="clean">
            <label class="field">
              作業する飼育員
              <select v-model="keeperId" required>
                <option v-for="k in keepers" :key="k.id" :value="k.id">
                  {{ k.name }}（残り{{ k.remainingMinutes }}分）
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
          <ul v-if="enclosure.keepers.length" class="people">
            <li v-for="k in enclosure.keepers" :key="k.id" class="row">
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
                {{ k.name }}（{{ k.specialties.map((s) => s.label).join("・") }}）
              </option>
            </select>
            <button class="btn" :disabled="busy || !assigneeId">割り当て</button>
          </form>
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
