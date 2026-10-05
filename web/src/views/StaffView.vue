<script setup lang="ts">
import { ref } from "vue";
import { api, unwrap } from "../api/client";
import PageHeader from "../components/PageHeader.vue";
import QueryState from "../components/QueryState.vue";
import { useCommand } from "../composables/useCommand";
import { useQuery } from "../composables/useQuery";

const keepers = useQuery(() => unwrap(api.GET("/keepers")));
const veterinarians = useQuery(() => unwrap(api.GET("/veterinarians")));
const taxonClasses = useQuery(() => unwrap(api.GET("/taxon-classes")));
const { busy, run } = useCommand();

const role = ref<"keeper" | "veterinarian">("keeper");
const name = ref("");
const specialties = ref<string[]>([]);

function toggle(key: string) {
  specialties.value = specialties.value.includes(key)
    ? specialties.value.filter((k) => k !== key)
    : [...specialties.value, key];
}

async function hire() {
  const hired =
    role.value === "keeper"
      ? await run(
          () =>
            unwrap(
              api.POST("/keepers", { body: { name: name.value, specialties: specialties.value } }),
            ),
          (k) => `飼育員の${k.name}さんを採用しました`,
        )
      : await run(
          () => unwrap(api.POST("/veterinarians", { body: { name: name.value } })),
          (v) => `獣医の${v.name}さんを採用しました`,
        );
  if (!hired) return;
  name.value = "";
  specialties.value = [];
  void (role.value === "keeper" ? keepers.reload() : veterinarians.reload());
}
</script>

<template>
  <PageHeader title="スタッフ" />

  <div class="columns">
    <div>
      <h2 class="section-title">採用</h2>
      <form class="card stack" @submit.prevent="hire">
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
            v-for="t in taxonClasses.data.value"
            :key="t.key"
            type="button"
            class="chip"
            :aria-pressed="specialties.includes(t.key)"
            @click="toggle(t.key)"
          >
            {{ t.label }}
          </button>
        </fieldset>
        <button class="btn btn-primary" :disabled="busy || !name">採用する</button>
      </form>
    </div>

    <div>
      <h2 class="section-title">飼育員</h2>
      <QueryState
        :loading="keepers.loading.value"
        :error="keepers.error.value"
        :empty="!keepers.data.value?.length"
        empty-text="飼育員がいません"
        @retry="keepers.reload"
      >
        <ul class="card list">
          <li v-for="k in keepers.data.value" :key="k.id" class="row">
            <span class="avatar small">🧑‍🌾</span>
            <strong class="grow">{{ k.name }}</strong>
            <span class="muted">{{ k.specialties || "専門なし" }}</span>
            <span class="muted">
              {{ k.enclosures.length ? k.enclosures.map((e) => e.name).join("・") : "担当なし" }}
            </span>
            <span class="badge" :class="k.remaining_minutes === 0 ? 'badge-bad' : ''"
              >残り{{ k.remaining_minutes }}分</span
            >
          </li>
        </ul>
      </QueryState>

      <h2 class="section-title">獣医</h2>
      <QueryState
        :loading="veterinarians.loading.value"
        :error="veterinarians.error.value"
        :empty="!veterinarians.data.value?.length"
        empty-text="獣医がいません"
        @retry="veterinarians.reload"
      >
        <ul class="card list">
          <li v-for="v in veterinarians.data.value" :key="v.id" class="row">
            <span class="avatar small">🧑‍⚕️</span>
            <strong class="grow">{{ v.name }}</strong>
          </li>
        </ul>
      </QueryState>
    </div>
  </div>
</template>

<style scoped>
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

.avatar.small {
  width: 36px;
  height: 36px;
  border-radius: 10px;
  font-size: 1.2rem;
}
</style>
