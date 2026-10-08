<script setup lang="ts">
import { reactive } from "vue";
import { useRouter } from "vue-router";
import { graphql } from "../api/generated";
import SideSheet from "../components/SideSheet.vue";
import { useMutation } from "../composables/useMutation";

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
      id
      name
    }
  }
`);

const { busy, mutate } = useMutation();
const router = useRouter();
const draft = reactive({ name: "", celsius: 20, capacity: 4, climateControlled: false });

async function build() {
  const built = await mutate(
    AddEnclosureMutation,
    { ...draft },
    ({ addEnclosure }) => `「${addEnclosure.name}」を建設しました`,
  );
  if (built) await router.push(`/enclosures/${built.addEnclosure.id}`);
}
</script>

<template>
  <SideSheet title="エリアを建設する" close-to="/enclosures">
    <form class="stack" @submit.prevent="build">
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
        <input v-model="draft.climateControlled" type="checkbox" />
        空調を入れる
      </label>
      <button class="btn btn-primary" :disabled="busy">建てる</button>
    </form>
  </SideSheet>
</template>

<style scoped>
.check {
  font-size: 0.9rem;
}
</style>
