<script setup lang="ts">
import { computed } from "vue";
import { useRouter } from "vue-router";
import { graphql } from "../api/generated";
import MeterBar from "../components/MeterBar.vue";
import QueryState from "../components/QueryState.vue";
import SideSheet from "../components/SideSheet.vue";
import { useQuery } from "../composables/useQuery";
import { useRounds } from "../composables/useRounds";

const props = defineProps<{ id: string }>();

const KeepersQuery = graphql(`
  query Keepers {
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
  }
`);

const SHIFT_MINUTES = 480;

const query = useQuery(KeepersQuery);
const keeper = computed(() => query.data.value?.keepers.find((k) => k.id === props.id));
const { busy, makeRounds } = useRounds();
const router = useRouter();

function pendingIn(enclosure: { occupants: { alive: boolean; fedToday: boolean }[] }) {
  return enclosure.occupants.filter((a) => a.alive && !a.fedToday).length;
}

async function makeRoundsAlone() {
  await makeRounds([props.id]);
  await router.push("/staff/rounds");
}
</script>

<template>
  <SideSheet :title="keeper?.name ?? '飼育員'" close-to="/staff">
    <QueryState
      :loading="query.loading.value"
      :error="query.error.value"
      :empty="!keeper"
      @retry="query.reload"
    >
      <template v-if="keeper">
        <dl class="facts">
          <dt>専門</dt>
          <dd>{{ keeper.specialties.map((s) => s.label).join("・") }}</dd>
        </dl>
        <MeterBar
          label="今日の勤務(分)"
          :value="keeper.workedMinutes"
          :max="SHIFT_MINUTES"
          invert
        />
        <ul v-if="keeper.enclosures.length" class="list areas">
          <li v-for="area in keeper.enclosures" :key="area.id" class="row">
            <RouterLink :to="`/enclosures/${area.id}`" class="grow">
              🌳 <strong>{{ area.name }}</strong>
            </RouterLink>
            <span v-if="pendingIn(area)" class="badge badge-warn"
              >未給餌 {{ pendingIn(area) }}</span
            >
            <span v-else class="badge badge-good">済み</span>
          </li>
        </ul>
        <p v-else class="muted">担当エリアがありません。エリアの「担当」から割り当てます</p>
        <button
          class="btn btn-primary"
          :disabled="busy || keeper.enclosures.length === 0"
          @click="makeRoundsAlone"
        >
          🚶 見回る
        </button>
      </template>
    </QueryState>
  </SideSheet>
</template>

<style scoped>
.areas {
  padding: 0;
}

.areas > li {
  padding: 6px 0;
}
</style>
