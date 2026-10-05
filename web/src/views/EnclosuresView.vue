<script setup lang="ts">
import { computed, reactive, ref } from "vue";
import { api, unwrap } from "../api/client";
import MeterBar from "../components/MeterBar.vue";
import PageHeader from "../components/PageHeader.vue";
import QueryState from "../components/QueryState.vue";
import { useCommand } from "../composables/useCommand";
import { useQuery } from "../composables/useQuery";

const enclosures = useQuery(() => unwrap(api.GET("/enclosures")));
const { busy, run } = useCommand();

const residents = computed(() =>
  (enclosures.data.value ?? []).reduce((sum, e) => sum + e.population, 0),
);
const seats = computed(() => (enclosures.data.value ?? []).reduce((sum, e) => sum + e.capacity, 0));

const building = ref(false);
const draft = reactive({ name: "", celsius: 20, capacity: 4, climate_controlled: false });

async function build() {
  const enclosure = await run(
    () => unwrap(api.POST("/enclosures", { body: { ...draft } })),
    (created) => `「${created.name}」を建設しました`,
  );
  if (!enclosure) return;
  draft.name = "";
  draft.climate_controlled = false;
  building.value = false;
  void enclosures.reload();
}
</script>

<template>
  <PageHeader
    title="エリア"
    :subtitle="`${enclosures.data.value?.length ?? 0} 区画・収容 ${residents} / ${seats} 頭`"
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
        <input v-model="draft.climate_controlled" type="checkbox" />
        空調を入れる
      </label>
      <button class="btn btn-primary" :disabled="busy">建てる</button>
    </form>
  </Transition>

  <QueryState
    :loading="enclosures.loading.value"
    :error="enclosures.error.value"
    :empty="!enclosures.data.value?.length"
    empty-text="エリアがありません。まずは建設しましょう"
    @retry="enclosures.reload"
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
          <tr v-for="enclosure in enclosures.data.value" :key="enclosure.id">
            <td>
              <RouterLink :to="`/enclosures/${enclosure.id}`" class="cell-link">
                {{ enclosure.name }}
              </RouterLink>
            </td>
            <td class="num">
              {{ enclosure.celsius }}℃
              <span v-if="enclosure.climate_controlled" class="badge">空調</span>
            </td>
            <td class="num">{{ enclosure.population }} / {{ enclosure.capacity }}</td>
            <td>
              <span v-if="enclosure.keepers.length">{{
                enclosure.keepers.map((k) => k.name).join("・")
              }}</span>
              <span v-else-if="enclosure.population" class="badge badge-warn">担当なし</span>
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
                <span v-if="enclosure.population >= enclosure.capacity" class="badge">満員</span>
                <span v-if="enclosure.population === 0" class="badge">空き</span>
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
