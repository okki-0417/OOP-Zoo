<script setup lang="ts">
import { computed, ref, shallowRef } from "vue";
import { graphql } from "../api/generated";
import type { MakeRoundsMutation, StaffQuery } from "../api/generated/graphql";
import MeterBar from "../components/MeterBar.vue";
import PageHeader from "../components/PageHeader.vue";
import QueryState from "../components/QueryState.vue";
import { useMutation } from "../composables/useMutation";
import { useQuery } from "../composables/useQuery";

type Keeper = StaffQuery["keepers"][number];
type Rounds = MakeRoundsMutation["makeRounds"];

const SHIFT_MINUTES = 480;

const StaffQuery = graphql(`
  query Staff {
    keepers {
      id
      name
      workedMinutes
      specialties {
        label
      }
      enclosures {
        id
        name
        occupants {
          alive
          fedToday
        }
      }
    }
    veterinarians {
      id
      name
    }
    taxonClasses {
      code
      label
    }
  }
`);

const MakeRoundsMutation = graphql(`
  mutation MakeRounds($keeperId: ID!) {
    makeRounds(keeperId: $keeperId) {
      keeper {
        id
        name
        remainingMinutes
      }
      reports {
        enclosure {
          id
          name
        }
        fed {
          name
        }
        cleaned
        enriched
        skipped {
          subject
          reason
        }
      }
    }
  }
`);

const HireKeeperMutation = graphql(`
  mutation HireKeeper($name: String!, $specialties: [String!]!) {
    hireKeeper(name: $name, specialties: $specialties) {
      name
    }
  }
`);

const HireVeterinarianMutation = graphql(`
  mutation HireVeterinarian($name: String!) {
    hireVeterinarian(name: $name) {
      name
    }
  }
`);

const query = useQuery(StaffQuery);
const keepers = computed(() => query.data.value?.keepers ?? []);
const veterinarians = computed(() => query.data.value?.veterinarians ?? []);
const reports = shallowRef<Rounds[]>([]);
const { busy, mutate } = useMutation();

const staffed = computed(() => keepers.value.filter((k) => k.enclosures.length > 0));

function pendingOf(keeper: Keeper) {
  return keeper.enclosures
    .flatMap((enclosure) => enclosure.occupants)
    .filter((a) => a.alive && !a.fedToday).length;
}

async function makeRounds(targets: Keeper[]) {
  const done: Rounds[] = [];
  for (const keeper of targets) {
    const result = await mutate(MakeRoundsMutation, { keeperId: keeper.id });
    if (result) done.push(result.makeRounds);
  }
  reports.value = done;
}

const hiring = ref(false);
const role = ref<"keeper" | "veterinarian">("keeper");
const name = ref("");
const specialties = ref<string[]>([]);

function toggle(code: string) {
  specialties.value = specialties.value.includes(code)
    ? specialties.value.filter((c) => c !== code)
    : [...specialties.value, code];
}

async function hire() {
  const hired =
    role.value === "keeper"
      ? await mutate(
          HireKeeperMutation,
          { name: name.value, specialties: specialties.value },
          ({ hireKeeper }) => `飼育員の${hireKeeper.name}さんを採用しました`,
        )
      : await mutate(
          HireVeterinarianMutation,
          { name: name.value },
          ({ hireVeterinarian }) => `獣医の${hireVeterinarian.name}さんを採用しました`,
        );
  if (!hired) return;
  name.value = "";
  specialties.value = [];
  hiring.value = false;
}
</script>

<template>
  <PageHeader
    title="スタッフ"
    :subtitle="`飼育員 ${keepers.length} 人・獣医 ${veterinarians.length} 人`"
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
          v-for="t in query.data.value?.taxonClasses"
          :key="t.code"
          type="button"
          class="chip"
          :aria-pressed="specialties.includes(t.code)"
          @click="toggle(t.code)"
        >
          {{ t.label }}
        </button>
      </fieldset>
      <button class="btn btn-primary" :disabled="busy || !name">採用する</button>
    </form>
  </Transition>

  <section v-if="reports.length" class="card stack results">
    <h2 class="section-title">見回りの結果</h2>
    <div v-for="rounds in reports" :key="rounds.keeper.id">
      <strong>{{ rounds.keeper.name }}</strong>
      <span class="muted">（残り {{ rounds.keeper.remainingMinutes }} 分）</span>
      <ul>
        <li v-for="round in rounds.reports" :key="round.enclosure.id">
          {{ round.enclosure.name }}:
          {{ round.fed.length ? `${round.fed.map((a) => a.name).join("・")}に給餌` : "給餌なし" }}
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
    :loading="query.loading.value"
    :error="query.error.value"
    :empty="keepers.length === 0"
    empty-text="飼育員がいません。採用しましょう"
    @retry="query.reload"
  >
    <div class="card table-card">
      <table class="data-table">
        <thead>
          <tr>
            <th>名前</th>
            <th>専門</th>
            <th>担当エリア</th>
            <th>勤務時間(分)</th>
            <th>給餌</th>
            <th />
          </tr>
        </thead>
        <tbody>
          <tr v-for="keeper in keepers" :key="keeper.id">
            <td>
              <strong>🧑‍🌾 {{ keeper.name }}</strong>
            </td>
            <td>{{ keeper.specialties.map((s) => s.label).join("・") || "—" }}</td>
            <td>
              <span v-if="keeper.enclosures.length" class="areas">
                <RouterLink
                  v-for="area in keeper.enclosures"
                  :key="area.id"
                  :to="`/enclosures/${area.id}`"
                  class="cell-link"
                >
                  {{ area.name }}
                </RouterLink>
              </span>
              <span v-else class="badge badge-warn">未割り当て</span>
            </td>
            <td class="meter-cell">
              <MeterBar label="" :value="keeper.workedMinutes" :max="SHIFT_MINUTES" invert />
            </td>
            <td>
              <template v-if="keeper.enclosures.length">
                <span v-if="pendingOf(keeper)" class="badge badge-warn"
                  >未給餌 {{ pendingOf(keeper) }}</span
                >
                <span v-else class="badge badge-good">済み</span>
              </template>
              <span v-else class="muted">—</span>
            </td>
            <td class="actions">
              <button
                class="btn btn-small"
                :disabled="busy || keeper.enclosures.length === 0"
                @click="makeRounds([keeper])"
              >
                見回る
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </QueryState>

  <h2 class="section-title">獣医</h2>
  <QueryState
    :loading="query.loading.value"
    :error="query.error.value"
    :empty="veterinarians.length === 0"
    empty-text="獣医がいません。病気の治療ができません"
    @retry="query.reload"
  >
    <div class="card table-card">
      <table class="data-table">
        <thead>
          <tr>
            <th>名前</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="v in veterinarians" :key="v.id">
            <td>
              <strong>🧑‍⚕️ {{ v.name }}</strong>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
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

.areas {
  display: flex;
  flex-wrap: wrap;
  gap: 4px 12px;
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
</style>
