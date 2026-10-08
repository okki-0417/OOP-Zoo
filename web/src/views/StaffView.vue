<script setup lang="ts">
import { computed } from "vue";
import { useRouter } from "vue-router";
import { graphql } from "../api/generated";
import type { StaffQuery } from "../api/generated/graphql";
import PageHeader from "../components/PageHeader.vue";
import QueryState from "../components/QueryState.vue";
import { useQuery } from "../composables/useQuery";
import { useRounds } from "../composables/useRounds";

type Keeper = StaffQuery["keepers"][number];

const StaffQuery = graphql(`
  query Staff {
    keepers {
      id
      name
      remainingMinutes
      specialties {
        label
      }
      enclosures {
        id
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
  }
`);

const query = useQuery(StaffQuery);
const keepers = computed(() => query.data.value?.keepers ?? []);
const veterinarians = computed(() => query.data.value?.veterinarians ?? []);
const staffed = computed(() => keepers.value.filter((k) => k.enclosures.length > 0));
const { busy, makeRounds } = useRounds();
const router = useRouter();

function pendingOf(keeper: Keeper) {
  return keeper.enclosures
    .flatMap((enclosure) => enclosure.occupants)
    .filter((a) => a.alive && !a.fedToday).length;
}

async function makeRoundsWithEveryone() {
  await makeRounds(staffed.value.map((k) => k.id));
  await router.push("/staff/rounds");
}
</script>

<template>
  <PageHeader
    title="スタッフ"
    :subtitle="`飼育員 ${keepers.length} 人・獣医 ${veterinarians.length} 人`"
  >
    <RouterLink to="/staff/new" class="btn btn-small">＋ 採用</RouterLink>
    <button
      class="btn btn-primary btn-small"
      :disabled="busy || staffed.length === 0"
      @click="makeRoundsWithEveryone"
    >
      🚶 全員で見回る
    </button>
  </PageHeader>

  <div class="split">
    <div>
      <QueryState
        :loading="query.loading.value"
        :error="query.error.value"
        :empty="keepers.length + veterinarians.length === 0"
        empty-text="スタッフがいません。採用しましょう"
        @retry="query.reload"
      >
        <ul class="scroll-box tiles">
          <li v-for="keeper in keepers" :key="keeper.id">
            <RouterLink :to="`/staff/${keeper.id}`" class="tile">
              <span class="tile-icon">🧑‍🌾</span>
              <span class="tile-text">
                <strong>{{ keeper.name }}</strong>
                <small class="muted">
                  {{ keeper.specialties.map((s) => s.label).join("・") }}・残り{{
                    keeper.remainingMinutes
                  }}分
                </small>
              </span>
              <span class="tile-signs">
                <span v-if="keeper.enclosures.length === 0" class="badge badge-warn">未割当</span>
                <span v-else-if="pendingOf(keeper)" class="badge badge-warn">
                  未給餌 {{ pendingOf(keeper) }}
                </span>
                <span v-else class="badge badge-good">済み</span>
              </span>
            </RouterLink>
          </li>
          <li v-for="v in veterinarians" :key="v.id">
            <div class="tile">
              <span class="tile-icon">🧑‍⚕️</span>
              <span class="tile-text">
                <strong>{{ v.name }}</strong>
                <small class="muted">獣医</small>
              </span>
            </div>
          </li>
        </ul>
      </QueryState>
    </div>

    <RouterView />
  </div>
</template>
