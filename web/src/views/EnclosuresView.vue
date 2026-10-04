<script setup lang="ts">
import { reactive, ref } from "vue";
import { api, unwrap } from "../api/client";
import MeterBar from "../components/MeterBar.vue";
import PageHeader from "../components/PageHeader.vue";
import QueryState from "../components/QueryState.vue";
import { useCommand } from "../composables/useCommand";
import { useQuery } from "../composables/useQuery";

const enclosures = useQuery(() => unwrap(api.GET("/enclosures")));
const { busy, run } = useCommand();

const building = ref(false);
const draft = reactive({ name: "", celsius: 20, capacity: 4 });

async function build() {
  const enclosure = await run(
    () => unwrap(api.POST("/enclosures", { body: { ...draft } })),
    (created) => `「${created.name}」を増設しました`,
  );
  if (!enclosure) return;
  draft.name = "";
  building.value = false;
  void enclosures.reload();
}
</script>

<template>
  <PageHeader title="エリア" :subtitle="`${enclosures.data.value?.length ?? 0} 区画`">
    <button class="btn btn-accent" @click="building = !building">
      {{ building ? "閉じる" : "＋ 増設" }}
    </button>
  </PageHeader>

  <Transition name="slide">
    <form v-if="building" class="card stack build" @submit.prevent="build">
      <label class="field">
        名前
        <input v-model.trim="draft.name" required maxlength="20" placeholder="例: 夜行性館" />
      </label>
      <div class="row">
        <label class="field grow">
          室温(℃)
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
      <button class="btn btn-primary" :disabled="busy">建てる</button>
    </form>
  </Transition>

  <QueryState
    :loading="enclosures.loading.value"
    :error="enclosures.error.value"
    :empty="!enclosures.data.value?.length"
    empty-text="エリアがありません。まずは増設しましょう"
    @retry="enclosures.reload"
  >
    <ul class="cards">
      <li v-for="enclosure in enclosures.data.value" :key="enclosure.id">
        <RouterLink :to="`/enclosures/${enclosure.id}`" class="card enclosure">
          <div class="row">
            <strong class="grow name">{{ enclosure.name }}</strong>
            <span v-if="enclosure.filthy" class="badge badge-bad">汚れている</span>
            <span v-if="enclosure.population >= enclosure.capacity" class="badge badge-warn"
              >満員</span
            >
          </div>
          <div class="seats" :aria-label="`${enclosure.population} / ${enclosure.capacity}`">
            <span
              v-for="seat in enclosure.capacity"
              :key="seat"
              class="seat"
              :class="{ taken: seat <= enclosure.population }"
            />
          </div>
          <MeterBar label="清潔度" :value="enclosure.cleanliness" :max="100" />
        </RouterLink>
      </li>
    </ul>
  </QueryState>
</template>

<style scoped>
.build {
  margin-bottom: 12px;
}

.cards {
  list-style: none;
  margin: 0;
  padding: 0;
  display: grid;
  gap: 10px;
}

.enclosure {
  display: grid;
  gap: 10px;
}

.name {
  font-size: 1.05rem;
}

.seats {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}

.seat {
  width: 14px;
  height: 14px;
  border-radius: 4px;
  background: var(--surface-sunk);
  border: 1px solid var(--line);
}

.seat.taken {
  background: var(--brand);
  border-color: var(--brand);
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
