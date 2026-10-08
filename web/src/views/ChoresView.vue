<script setup lang="ts">
import ChoreChecklist from "../components/ChoreChecklist.vue";
import QueryState from "../components/QueryState.vue";
import SideSheet from "../components/SideSheet.vue";
import { useChores } from "../composables/useChores";

const { query, chores } = useChores();
</script>

<template>
  <SideSheet title="今日の日課" close-to="/">
    <QueryState
      :loading="query.loading.value"
      :error="query.error.value"
      :empty="!query.data.value"
      @retry="query.reload"
    >
      <ChoreChecklist :chores="chores" />
    </QueryState>
  </SideSheet>
</template>
