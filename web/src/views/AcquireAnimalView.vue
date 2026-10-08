<script setup lang="ts">
import { reactive } from "vue";
import { useRouter } from "vue-router";
import { graphql } from "../api/generated";
import type { Sex } from "../api/generated/graphql";
import SideSheet from "../components/SideSheet.vue";
import { useMutation } from "../composables/useMutation";
import { useQuery } from "../composables/useQuery";
import { emojiOf } from "../lib/emoji";

const SpeciesCatalogQuery = graphql(`
  query SpeciesCatalog {
    species {
      code
      nameJa
      conservationLabel
      taxonClass {
        label
      }
    }
  }
`);

const AcquireAnimalMutation = graphql(`
  mutation AcquireAnimal($speciesCode: String!, $name: String!, $sex: Sex!) {
    acquireAnimal(speciesCode: $speciesCode, name: $name, sex: $sex) {
      id
      name
      species {
        nameJa
      }
    }
  }
`);

const query = useQuery(SpeciesCatalogQuery);
const { busy, mutate } = useMutation();
const router = useRouter();
const draft = reactive({ speciesCode: "", name: "", sex: "FEMALE" as Sex });

async function acquire() {
  const acquired = await mutate(
    AcquireAnimalMutation,
    { ...draft },
    ({ acquireAnimal }) =>
      `${acquireAnimal.species.nameJa}の「${acquireAnimal.name}」を導入しました`,
  );
  if (acquired) await router.push(`/animals/${acquired.acquireAnimal.id}`);
}
</script>

<template>
  <SideSheet title="動物を導入する" close-to="/animals">
    <form class="stack" @submit.prevent="acquire">
      <label class="field">
        種
        <select v-model="draft.speciesCode" required>
          <option value="" disabled>選んでください</option>
          <option v-for="s in query.data.value?.species" :key="s.code" :value="s.code">
            {{ emojiOf(s.nameJa, s.taxonClass.label) }} {{ s.nameJa }}（{{ s.conservationLabel }}）
          </option>
        </select>
      </label>
      <label class="field">
        名前
        <input v-model.trim="draft.name" required maxlength="20" placeholder="例: ハナコ" />
      </label>
      <div class="segmented" role="group" aria-label="性別">
        <button type="button" :aria-pressed="draft.sex === 'FEMALE'" @click="draft.sex = 'FEMALE'">
          ♀ メス
        </button>
        <button type="button" :aria-pressed="draft.sex === 'MALE'" @click="draft.sex = 'MALE'">
          ♂ オス
        </button>
      </div>
      <button class="btn btn-primary" :disabled="busy">導入する</button>
    </form>
  </SideSheet>
</template>
