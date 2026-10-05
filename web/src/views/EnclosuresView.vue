<script setup lang="ts">
import { computed, reactive, ref } from "vue";
import { graphql } from "../api/generated";
import MeterBar from "../components/MeterBar.vue";
import PageHeader from "../components/PageHeader.vue";
import QueryState from "../components/QueryState.vue";
import { useMutation } from "../composables/useMutation";
import { useQuery } from "../composables/useQuery";

const EnclosuresQuery = graphql(`
  query Enclosures {
    enclosures {
      id
      name
      celsius
      climateControlled
      capacity
      cleanliness
      enrichment
      filthy
      barren
      occupants {
        id
      }
      occupancy {
        full
      }
      keepers {
        id
        name
      }
    }
  }
`);

const AddEnclosureMutation = graphql(`
  mutation AddEnclosure(
    $name: String!
    $celsius: Int!
    $capacity: Int!
    $climateControlled: Boolean
  ) {
    addEnclosure(
      name: $name
      celsius: $celsius
      capacity: $capacity
      climateControlled: $climateControlled
    ) {
      name
    }
  }
`);

const query = useQuery(EnclosuresQuery);
const enclosures = computed(() => query.data.value?.enclosures ?? []);
const { busy, mutate } = useMutation();

const residents = computed(() => enclosures.value.reduce((sum, e) => sum + e.occupants.length, 0));
const seats = computed(() => enclosures.value.reduce((sum, e) => sum + e.capacity, 0));

const building = ref(false);
const draft = reactive({ name: "", celsius: 20, capacity: 4, climateControlled: false });

async function build() {
  const built = await mutate(
    AddEnclosureMutation,
    { ...draft },
    ({ addEnclosure }) => `「${addEnclosure.name}」を建設しました`,
  );
  if (!built) return;
  draft.name = "";
  draft.climateControlled = false;
  building.value = false;
}
</script>

<template>
  <PageHeader
    title="エリア"
    :subtitle="`${enclosures.length} 区画・収容 ${residents} / ${seats} 頭`"
  >
    <button class="btn btn-accent" @click="building = !building">
      {{ building ? "閉じる" : "＋ 建設" }}
    </button>
  </PageHeader>

  <Transition name="slide">
    <form v-if="building" class="card build" @submit.prevent="build">
      <label class="field">
        名前
        <input v-model.trim="draft.name" required maxlength="20" placeholder="例: 夜行性館" />
      </label>
      <label class="field">
        設定温度(℃)
        <input v-model.number="draft.celsius" type="number" required inputmode="numeric" />
      </label>
      <label class="field">
        定員
        <input v-model.number="draft.capacity" type="number" min="1" required inputmode="numeric" />
      </label>
      <label class="row check">
        <input v-model="draft.climateControlled" type="checkbox" />
        空調を入れる
      </label>
      <button class="btn btn-primary" :disabled="busy">建てる</button>
    </form>
  </Transition>

  <QueryState
    :loading="query.loading.value"
    :error="query.error.value"
    :empty="enclosures.length === 0"
    empty-text="エリアがありません。まずは建設しましょう"
    @retry="query.reload"
  >
    <div class="card table-card">
      <table class="data-table">
        <thead>
          <tr>
            <th>名前</th>
            <th class="num">設定温度</th>
            <th class="num">収容</th>
            <th>担当飼育員</th>
            <th>清潔度</th>
            <th>刺激</th>
            <th>状態</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="enclosure in enclosures" :key="enclosure.id">
            <td>
              <RouterLink :to="`/enclosures/${enclosure.id}`" class="cell-link">
                {{ enclosure.name }}
              </RouterLink>
            </td>
            <td class="num">
              {{ enclosure.celsius }}℃
              <span v-if="enclosure.climateControlled" class="badge">空調</span>
            </td>
            <td class="num">{{ enclosure.occupants.length }} / {{ enclosure.capacity }}</td>
            <td>
              <span v-if="enclosure.keepers.length">{{
                enclosure.keepers.map((k) => k.name).join("・")
              }}</span>
              <span v-else-if="enclosure.occupants.length" class="badge badge-warn">担当なし</span>
              <span v-else class="muted">—</span>
            </td>
            <td class="meter-cell">
              <MeterBar label="" :value="enclosure.cleanliness" :max="100" />
            </td>
            <td class="meter-cell">
              <MeterBar label="" :value="enclosure.enrichment" :max="100" />
            </td>
            <td>
              <div class="badges">
                <span v-if="enclosure.filthy" class="badge badge-bad">不潔</span>
                <span v-if="enclosure.barren" class="badge badge-warn">退屈</span>
                <span v-if="enclosure.occupancy.full" class="badge">満員</span>
                <span v-if="enclosure.occupants.length === 0" class="badge">空き</span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </QueryState>
</template>

<style scoped>
.build {
  display: grid;
  grid-template-columns: 2fr 1fr 1fr auto auto;
  gap: 12px;
  align-items: end;
  margin-bottom: 16px;
}

.check {
  gap: 6px;
  padding-bottom: 10px;
  font-size: 0.85rem;
  white-space: nowrap;
}
</style>
