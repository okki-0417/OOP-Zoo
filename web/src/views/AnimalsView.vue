<script setup lang="ts">
import { computed, reactive, ref } from "vue";
import { api, unwrap } from "../api/client";
import MeterBar from "../components/MeterBar.vue";
import PageHeader from "../components/PageHeader.vue";
import QueryState from "../components/QueryState.vue";
import { useCommand } from "../composables/useCommand";
import { useQuery } from "../composables/useQuery";
import { emojiOf } from "../format";

type Filter = "alive" | "ailing" | "dead";

const animals = useQuery(() => unwrap(api.GET("/animals")));
const species = useQuery(() => unwrap(api.GET("/species")));
const { busy, run } = useCommand();

const filter = ref<Filter>("alive");
const filters: { key: Filter; label: string }[] = [
  { key: "alive", label: "飼育中" },
  { key: "ailing", label: "要注意" },
  { key: "dead", label: "亡くなった" },
];

const visible = computed(() =>
  (animals.data.value ?? []).filter((animal) => {
    if (filter.value === "dead") return !animal.alive;
    if (filter.value === "ailing") return animal.alive && animal.ailing;
    return animal.alive;
  }),
);

const acquiring = ref(false);
const draft = reactive({ species_code: "", name: "", sex: "female" as "female" | "male" });

async function acquire() {
  const animal = await run(
    () => unwrap(api.POST("/animals", { body: { ...draft } })),
    (created) => `${created.species}の「${created.name}」がやってきました`,
  );
  if (!animal) return;
  draft.name = "";
  acquiring.value = false;
  filter.value = "alive";
  void animals.reload();
}
</script>

<template>
  <PageHeader title="どうぶつ" :subtitle="`${visible.length} 頭`">
    <button class="btn btn-accent" @click="acquiring = !acquiring">
      {{ acquiring ? "閉じる" : "＋ 導入" }}
    </button>
  </PageHeader>

  <Transition name="slide">
    <form v-if="acquiring" class="card stack acquire" @submit.prevent="acquire">
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

  <div class="segmented filters" role="group" aria-label="絞り込み">
    <button
      v-for="f in filters"
      :key="f.key"
      type="button"
      :aria-pressed="filter === f.key"
      @click="filter = f.key"
    >
      {{ f.label }}
    </button>
  </div>

  <QueryState
    :loading="animals.loading.value"
    :error="animals.error.value"
    :empty="visible.length === 0"
    empty-text="該当する動物はいません"
    @retry="animals.reload"
  >
    <ul class="cards">
      <li v-for="animal in visible" :key="animal.id">
        <RouterLink
          :to="`/animals/${animal.id}`"
          class="card animal"
          :class="{ dead: !animal.alive }"
        >
          <span class="avatar">{{ animal.alive ? emojiOf(animal.species) : "🪦" }}</span>
          <div class="grow stack body">
            <div class="row">
              <strong class="grow name">{{ animal.name }}</strong>
              <span v-if="animal.ailing && animal.alive" class="badge badge-bad">不調</span>
            </div>
            <span class="muted">{{ animal.species }}</span>
            <MeterBar
              v-if="animal.alive"
              label="体力"
              :value="animal.health"
              :max="animal.max_health"
            />
          </div>
        </RouterLink>
      </li>
    </ul>
  </QueryState>
</template>

<style scoped>
.acquire {
  margin-bottom: 12px;
}

.filters {
  margin: 4px 0 12px;
}

.cards {
  list-style: none;
  margin: 0;
  padding: 0;
  display: grid;
  gap: 10px;
}

.animal {
  display: flex;
  gap: 12px;
  align-items: flex-start;
  padding: 12px;
}

.animal:active {
  transform: scale(0.99);
}

.animal.dead {
  opacity: 0.6;
}

.body {
  gap: 4px;
}

.name {
  font-size: 1.05rem;
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
