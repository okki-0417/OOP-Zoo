<script setup lang="ts">
import { computed, reactive, ref } from "vue";
import { api, unwrap } from "../api/client";
import PageHeader from "../components/PageHeader.vue";
import QueryState from "../components/QueryState.vue";
import { useCommand } from "../composables/useCommand";
import { useQuery } from "../composables/useQuery";
import { emojiOf } from "../lib/emoji";

const animals = useQuery(() => unwrap(api.GET("/animals")));
const enclosures = useQuery(() => unwrap(api.GET("/enclosures")));
const species = useQuery(() => unwrap(api.GET("/species")));
const { busy, run } = useCommand();

const housedIds = computed(
  () => new Set((enclosures.data.value ?? []).flatMap((e) => e.occupants.map((a) => a.id))),
);
const arrivals = computed(() =>
  (animals.data.value ?? []).filter((a) => a.alive && !housedIds.value.has(a.id)),
);
const vacancies = computed(() =>
  (enclosures.data.value ?? []).filter((e) => e.population < e.capacity),
);
const destinations = reactive<Record<string, string>>({});

const acquiring = ref(false);
const draft = reactive({ species_code: "", name: "", sex: "female" as "female" | "male" });

async function acquire() {
  const animal = await run(
    () => unwrap(api.POST("/animals", { body: { ...draft } })),
    (created) => `${created.species}の「${created.name}」が搬入口に着きました`,
  );
  if (!animal) return;
  draft.name = "";
  acquiring.value = false;
  void animals.reload();
}

async function house(animalId: string, name: string) {
  const enclosureId = destinations[animalId];
  if (!enclosureId) return;
  const housed = await run(
    () =>
      unwrap(
        api.POST("/enclosures/{enclosure_id}/occupants", {
          params: { path: { enclosure_id: enclosureId } },
          body: { animal_id: animalId },
        }),
      ),
    (enclosure) => `${name}を${enclosure.name}に移しました`,
  );
  if (!housed) return;
  void enclosures.reload();
}
</script>

<template>
  <PageHeader
    title="搬入口"
    :crumbs="[{ label: '動物園', to: '/zoo' }]"
    subtitle="新しく迎えた動物は、ここからエリアへ移します"
  >
    <button class="btn btn-accent" @click="acquiring = !acquiring">
      {{ acquiring ? "閉じる" : "＋ 動物を迎え入れる" }}
    </button>
  </PageHeader>

  <Transition name="slide">
    <form v-if="acquiring" class="card acquire" @submit.prevent="acquire">
      <label class="field">
        種
        <select v-model="draft.species_code" required>
          <option value="" disabled>選んでください</option>
          <option v-for="s in species.data.value" :key="s.key" :value="s.key">
            {{ emojiOf(s.name_ja, s.taxon_class) }} {{ s.name_ja }}（{{ s.conservation_label }}）
          </option>
        </select>
      </label>
      <label class="field">
        名前
        <input v-model.trim="draft.name" required maxlength="20" placeholder="例: ハナコ" />
      </label>
      <div class="segmented" role="group" aria-label="性別">
        <button type="button" :aria-pressed="draft.sex === 'female'" @click="draft.sex = 'female'">
          ♀ メス
        </button>
        <button type="button" :aria-pressed="draft.sex === 'male'" @click="draft.sex = 'male'">
          ♂ オス
        </button>
      </div>
      <button class="btn btn-primary" :disabled="busy">迎え入れる</button>
    </form>
  </Transition>

  <QueryState
    :loading="animals.loading.value"
    :error="animals.error.value"
    :empty="arrivals.length === 0"
    empty-text="エリアを待っている動物はいません"
    @retry="animals.reload"
  >
    <ul class="crates">
      <li v-for="animal in arrivals" :key="animal.id" class="crate">
        <RouterLink :to="`/animals/${animal.id}`" class="occupant">
          <span class="body">{{ emojiOf(animal.species) }}</span>
          <strong>{{ animal.name }}</strong>
          <span class="muted">{{ animal.species }}</span>
        </RouterLink>
        <form class="row" @submit.prevent="house(animal.id, animal.name)">
          <select v-model="destinations[animal.id]" class="grow" required aria-label="移すエリア">
            <option :value="undefined" disabled>移すエリア…</option>
            <option v-for="e in vacancies" :key="e.id" :value="e.id">
              {{ e.name }}（{{ e.population }}/{{ e.capacity }}・{{ e.celsius }}℃）
            </option>
          </select>
          <button class="btn btn-primary" :disabled="busy || !destinations[animal.id]">移す</button>
        </form>
      </li>
    </ul>
  </QueryState>
</template>

<style scoped>
.acquire {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 12px;
  align-items: end;
  margin-bottom: 16px;
}

.crates {
  list-style: none;
  margin: 0;
  padding: 0;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  gap: 16px;
}

.crate {
  display: grid;
  gap: 12px;
  padding: 16px;
  border-radius: 14px;
  background: repeating-linear-gradient(90deg, #c9a26f 0 18px, #bb935f 18px 20px);
  box-shadow:
    0 0 0 3px #8a6239,
    0 6px 14px rgb(40 30 10 / 22%);
}

.occupant {
  display: grid;
  justify-items: center;
  gap: 2px;
  padding: 12px;
  border-radius: 10px;
  background: var(--surface);
}

.body {
  font-size: 3rem;
  line-height: 1.1;
}

select.grow {
  flex: 1 1 0;
  width: 0;
  min-width: 0;
  padding: 10px 12px;
  border-radius: 10px;
  border: 1px solid var(--line);
  background: var(--surface);
}

.slide-enter-from,
.slide-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}

.slide-enter-active,
.slide-leave-active {
  transition: all 0.2s ease;
}
</style>
