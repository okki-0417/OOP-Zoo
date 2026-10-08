<script setup lang="ts">
import { computed, ref, watch } from "vue";
import { graphql } from "../api/generated";
import MeterBar from "../components/MeterBar.vue";
import QueryState from "../components/QueryState.vue";
import SideSheet from "../components/SideSheet.vue";
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

type Tab = "residents" | "chores" | "keepers";
const tabs: { key: Tab; label: string }[] = [
  { key: "residents", label: "住人" },
  { key: "chores", label: "環境・作業" },
  { key: "keepers", label: "担当" },
];
const tab = ref<Tab>("residents");

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
  <SideSheet :title="enclosure?.name ?? 'エリア'" close-to="/enclosures">
    <QueryState
      :loading="query.loading.value"
      :error="query.error.value"
      :empty="!enclosure"
      @retry="query.reload"
    >
      <template v-if="enclosure">
        <p class="muted">
          設定 {{ enclosure.celsius }}℃{{ enclosure.climateControlled ? "（空調）" : "" }}・{{
            enclosure.occupants.length
          }}
          / {{ enclosure.capacity }} 頭
        </p>

        <div class="segmented" role="tablist">
          <button
            v-for="t in tabs"
            :key="t.key"
            type="button"
            role="tab"
            :aria-pressed="tab === t.key"
            @click="tab = t.key"
          >
            {{ t.label }}
          </button>
        </div>

        <template v-if="tab === 'residents'">
          <form class="action-row" @submit.prevent="house">
            <select
              v-model="animalId"
              class="inline-select grow"
              required
              aria-label="収容する動物"
            >
              <option value="" disabled>{{ full ? "満員です" : "収容する動物…" }}</option>
              <option v-for="a in candidates" :key="a.id" :value="a.id">
                {{ emojiOf(a.species.nameJa) }} {{ a.name }}（{{ a.species.nameJa }}）
              </option>
            </select>
            <button class="btn btn-primary btn-small" :disabled="busy || !animalId || full">
              収容
            </button>
          </form>
          <ul v-if="enclosure.occupants.length" class="list people">
            <li v-for="occupant in enclosure.occupants" :key="occupant.id" class="row">
              <RouterLink :to="`/animals/${occupant.id}`" class="grow who">
                {{ emojiOf(occupant.species.nameJa) }} <strong>{{ occupant.name }}</strong>
                <small class="muted">{{ occupant.species.nameJa }}</small>
              </RouterLink>
              <span v-if="occupant.ailing" class="badge badge-bad">不調</span>
              <span v-else-if="occupant.hungry" class="badge badge-bad">空腹</span>
              <span v-else-if="!occupant.fedToday" class="badge badge-warn">未給餌</span>
              <button
                class="btn btn-small"
                :disabled="busy"
                @click="release(occupant.id, occupant.name)"
              >
                退去
              </button>
            </li>
          </ul>
          <p v-else class="muted">住人はいません</p>
        </template>

        <template v-else-if="tab === 'chores'">
          <MeterBar label="清潔度" :value="enclosure.cleanliness" :max="100" />
          <MeterBar label="刺激" :value="enclosure.enrichment" :max="100" />
          <form class="stack" @submit.prevent="clean">
            <select v-model="keeperId" class="inline-select" required aria-label="作業する飼育員">
              <option v-for="k in keepers" :key="k.id" :value="k.id">
                {{ k.name }}（残り{{ k.remainingMinutes }}分）
              </option>
            </select>
            <div class="row">
              <button class="btn btn-primary btn-small grow" :disabled="busy || !keeperId">
                🧹 清掃 60分
              </button>
              <button
                type="button"
                class="btn btn-small grow"
                :disabled="busy || !keeperId"
                @click="enrich"
              >
                🪵 補充 30分
              </button>
            </div>
          </form>
        </template>

        <template v-else>
          <form class="action-row" @submit.prevent="assign">
            <select
              v-model="assigneeId"
              class="inline-select grow"
              required
              aria-label="担当に加える飼育員"
            >
              <option value="" disabled>担当に加える…</option>
              <option v-for="k in unassigned" :key="k.id" :value="k.id">
                {{ k.name }}（{{ k.specialties.map((s) => s.label).join("・") }}）
              </option>
            </select>
            <button class="btn btn-small" :disabled="busy || !assigneeId">割り当て</button>
          </form>
          <ul v-if="enclosure.keepers.length" class="list people">
            <li v-for="k in enclosure.keepers" :key="k.id" class="row">
              <span class="grow"
                >🧑‍🌾 <strong>{{ k.name }}</strong></span
              >
              <span class="muted">残り{{ remainingOf(k.id) ?? "-" }}分</span>
              <button class="btn btn-small" :disabled="busy" @click="discharge(k.id, k.name)">
                外す
              </button>
            </li>
          </ul>
          <p v-else class="muted">担当がいません。日々の見回りが行われません</p>
        </template>
      </template>
    </QueryState>
  </SideSheet>
</template>

<style scoped>
.people {
  padding: 0;
}

.people > li {
  padding: 6px 0;
}

.who {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
</style>
