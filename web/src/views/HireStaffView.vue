<script setup lang="ts">
import { ref } from "vue";
import { useRouter } from "vue-router";
import { graphql } from "../api/generated";
import SideSheet from "../components/SideSheet.vue";
import { useMutation } from "../composables/useMutation";
import { useQuery } from "../composables/useQuery";

const TaxonClassesQuery = graphql(`
  query TaxonClasses {
    taxonClasses {
      code
      label
    }
  }
`);

const HireKeeperMutation = graphql(`
  mutation HireKeeper($name: String!, $specialties: [String!]!) {
    hireKeeper(name: $name, specialties: $specialties) {
      id
      name
    }
  }
`);

const HireVeterinarianMutation = graphql(`
  mutation HireVeterinarian($name: String!) {
    hireVeterinarian(name: $name) {
      name
    }
  }
`);

const query = useQuery(TaxonClassesQuery);
const { busy, mutate } = useMutation();
const router = useRouter();

const role = ref<"keeper" | "veterinarian">("keeper");
const name = ref("");
const specialties = ref<string[]>([]);

function toggle(code: string) {
  specialties.value = specialties.value.includes(code)
    ? specialties.value.filter((c) => c !== code)
    : [...specialties.value, code];
}

async function hire() {
  if (role.value === "keeper") {
    const hired = await mutate(
      HireKeeperMutation,
      { name: name.value, specialties: specialties.value },
      ({ hireKeeper }) => `飼育員の${hireKeeper.name}さんを採用しました`,
    );
    if (hired) await router.push(`/staff/${hired.hireKeeper.id}`);
    return;
  }
  const hired = await mutate(
    HireVeterinarianMutation,
    { name: name.value },
    ({ hireVeterinarian }) => `獣医の${hireVeterinarian.name}さんを採用しました`,
  );
  if (hired) await router.push("/staff");
}
</script>

<template>
  <SideSheet title="スタッフを採用する" close-to="/staff">
    <form class="stack" @submit.prevent="hire">
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
      <input
        v-model.trim="name"
        class="inline-select name"
        required
        maxlength="20"
        placeholder="名前（例: 田中）"
        aria-label="名前"
      />
      <fieldset v-if="role === 'keeper'" class="specialties">
        <legend class="muted">専門（複数可）</legend>
        <button
          v-for="t in query.data.value?.taxonClasses"
          :key="t.code"
          type="button"
          class="chip"
          :aria-pressed="specialties.includes(t.code)"
          @click="toggle(t.code)"
        >
          {{ t.label }}
        </button>
      </fieldset>
      <button class="btn btn-primary" :disabled="busy || !name">採用する</button>
    </form>
  </SideSheet>
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

.name {
  padding: 10px 12px;
  font-size: 1rem;
}

.chip {
  border: 1px solid var(--line);
  background: var(--surface-sunk);
  border-radius: 999px;
  padding: 4px 10px;
  font-size: 0.8rem;
  font-weight: 700;
  cursor: pointer;
}

.chip[aria-pressed="true"] {
  background: var(--brand);
  border-color: var(--brand);
  color: var(--brand-ink);
}
</style>
