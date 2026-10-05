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
  if (cleaned) enclosure.data.value = cleaned;
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
          <form class="row bottom" @submit.prevent="clean">
            <label class="field grow">
              担当飼育員
              <select v-model="keeperId" required>
                <option v-for="k in keepers.data.value" :key="k.id" :value="k.id">
                  {{ k.name }}
                </option>
              </select>
            </label>
            <button class="btn btn-primary" :disabled="busy || !keeperId">🧹 清掃</button>
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

.note {
  margin: 8px 4px 0;
}
</style>
