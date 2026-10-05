<script setup lang="ts">
import { computed, reactive, ref } from "vue";
import { api, unwrap } from "../api/client";
import HabitatScene from "../components/HabitatScene.vue";
import PageHeader from "../components/PageHeader.vue";
import QueryState from "../components/QueryState.vue";
import { useCommand } from "../composables/useCommand";
import { useQuery } from "../composables/useQuery";

const enclosures = useQuery(() => unwrap(api.GET("/enclosures")));
const animals = useQuery(() => unwrap(api.GET("/animals")));
const keepers = useQuery(() => unwrap(api.GET("/keepers")));
const veterinarians = useQuery(() => unwrap(api.GET("/veterinarians")));
const { busy, run } = useCommand();

const housedIds = computed(
  () => new Set((enclosures.data.value ?? []).flatMap((e) => e.occupants.map((a) => a.id))),
);
const arrivals = computed(() =>
  (animals.data.value ?? []).filter((a) => a.alive && !housedIds.value.has(a.id)),
);
const residentCount = computed(() => housedIds.value.size);

const building = ref(false);
const draft = reactive({ name: "", celsius: 20, capacity: 4, climate_controlled: false });

async function build() {
  const enclosure = await run(
    () => unwrap(api.POST("/enclosures", { body: { ...draft } })),
    (created) => `「${created.name}」を建設しました`,
  );
  if (!enclosure) return;
  draft.name = "";
  building.value = false;
  void enclosures.reload();
}
</script>

<template>
  <PageHeader
    title="動物園"
    :subtitle="`${enclosures.data.value?.length ?? 0} エリア・${residentCount} 頭が暮らしています`"
  />

  <QueryState
    :loading="enclosures.loading.value"
    :error="enclosures.error.value"
    :empty="!enclosures.data.value"
    @retry="enclosures.reload"
  >
    <div class="park">
      <RouterLink
        v-for="enclosure in enclosures.data.value"
        :key="enclosure.id"
        :to="`/enclosures/${enclosure.id}`"
        class="pen"
      >
        <HabitatScene :enclosure="enclosure" />
        <div class="sign">
          <strong class="grow">{{ enclosure.name }}</strong>
          <span class="muted">{{ enclosure.population }}/{{ enclosure.capacity }}</span>
        </div>
        <div class="tags">
          <span class="tag"
            >🌡️ {{ enclosure.celsius }}℃{{ enclosure.climate_controlled ? "・空調" : "" }}</span
          >
          <span v-if="enclosure.keepers.length" class="tag"
            >🧑‍🌾 {{ enclosure.keepers.map((k) => k.name).join("・") }}</span
          >
          <span v-else-if="enclosure.population" class="tag warn">担当なし</span>
          <span v-if="enclosure.filthy" class="tag bad">不潔</span>
          <span v-if="enclosure.barren" class="tag warn">退屈</span>
          <span v-if="enclosure.population >= enclosure.capacity" class="tag">満員</span>
        </div>
      </RouterLink>

      <RouterLink to="/zoo/gate" class="facility">
        <span class="landmark">🚚</span>
        <strong>搬入口</strong>
        <span class="muted">
          {{ arrivals.length ? `${arrivals.length} 頭がエリアを待っています` : "動物を迎え入れる" }}
        </span>
        <span v-if="arrivals.length" class="waiting">
          <span v-for="a in arrivals.slice(0, 6)" :key="a.id">🐾</span>
        </span>
      </RouterLink>

      <RouterLink to="/zoo/staff" class="facility">
        <span class="landmark">🏠</span>
        <strong>スタッフ詰所</strong>
        <span class="muted">
          飼育員 {{ keepers.data.value?.length ?? 0 }} 人・獣医
          {{ veterinarians.data.value?.length ?? 0 }} 人
        </span>
      </RouterLink>

      <div class="facility lot" :class="{ open: building }">
        <template v-if="!building">
          <button type="button" class="lot-button" @click="building = true">
            <span class="landmark">🚧</span>
            <strong>空き地</strong>
            <span class="muted">＋ エリアを建設する</span>
          </button>
        </template>
        <form v-else class="stack build" @submit.prevent="build">
          <strong>🚧 エリアを建設</strong>
          <label class="field">
            名前
            <input v-model.trim="draft.name" required maxlength="20" placeholder="例: 夜行性館" />
          </label>
          <div class="row">
            <label class="field grow">
              設定温度(℃)
              <input v-model.number="draft.celsius" type="number" required inputmode="numeric" />
            </label>
            <label class="field grow">
              定員
              <input
                v-model.number="draft.capacity"
                type="number"
                min="1"
                required
                inputmode="numeric"
              />
            </label>
          </div>
          <label class="row check">
            <input v-model="draft.climate_controlled" type="checkbox" />
            空調を入れる（季節の影響を受けない）
          </label>
          <div class="row">
            <button type="button" class="btn grow" @click="building = false">やめる</button>
            <button class="btn btn-primary grow" :disabled="busy">建てる</button>
          </div>
        </form>
      </div>
    </div>
  </QueryState>
</template>

<style scoped>
.park {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 20px;
  padding: 24px;
  border-radius: 28px;
  background:
    radial-gradient(circle at 12% 18%, rgb(255 255 255 / 25%) 0 6%, transparent 7%),
    radial-gradient(circle at 85% 70%, rgb(255 255 255 / 18%) 0 8%, transparent 9%), #a9cf8a;
  box-shadow: inset 0 0 0 6px #d9c9a0;
}

@media (prefers-color-scheme: dark) {
  .park {
    background: #22382b;
    box-shadow: inset 0 0 0 6px #3b4a3a;
  }
}

.pen {
  display: grid;
  gap: 8px;
  padding: 8px 8px 10px;
  border-radius: 18px;
  background: #b98d5e;
  box-shadow:
    0 0 0 3px #8a6239,
    0 6px 14px rgb(40 30 10 / 25%);
  transition: transform 0.15s ease;
}

.pen:hover {
  transform: translateY(-3px);
}

.sign {
  display: flex;
  align-items: baseline;
  gap: 8px;
  padding: 6px 10px;
  border-radius: 8px;
  background: var(--surface);
}

.sign strong {
  font-size: 1.05rem;
}

.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}

.tag {
  padding: 2px 8px;
  border-radius: 999px;
  background: rgb(255 253 247 / 90%);
  color: #2b2a22;
  font-size: 0.75rem;
  font-weight: 700;
}

.tag.warn {
  background: #f6dfa6;
}

.tag.bad {
  background: #f3b8ae;
}

.facility {
  display: grid;
  align-content: center;
  justify-items: center;
  gap: 6px;
  min-height: 240px;
  padding: 16px;
  border-radius: 18px;
  background: var(--surface);
  border: 1px solid var(--line);
  box-shadow: 0 6px 14px rgb(40 30 10 / 18%);
  text-align: center;
  transition: transform 0.15s ease;
}

a.facility:hover {
  transform: translateY(-3px);
}

.landmark {
  font-size: 3.4rem;
  line-height: 1.1;
}

.waiting {
  display: flex;
  gap: 2px;
}

.lot {
  background: transparent;
  border: 3px dashed rgb(255 255 255 / 70%);
  box-shadow: none;
}

.lot.open {
  justify-items: stretch;
  text-align: left;
  background: var(--surface);
  border: 1px solid var(--line);
}

.lot-button {
  display: grid;
  justify-items: center;
  gap: 6px;
  border: none;
  background: none;
  cursor: pointer;
}

.lot-button:hover .landmark {
  transform: scale(1.08);
}

.check {
  gap: 6px;
  font-size: 0.85rem;
}
</style>
