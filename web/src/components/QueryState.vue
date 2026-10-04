<script setup lang="ts">
defineProps<{ loading: boolean; error?: Error; empty?: boolean; emptyText?: string }>();
defineEmits<{ retry: [] }>();
</script>

<template>
  <div v-if="error" class="card empty">
    <p>読み込めませんでした: {{ error.message }}</p>
    <button class="btn" style="margin-top: 12px" @click="$emit('retry')">再読み込み</button>
  </div>
  <div v-else-if="loading && empty" class="empty">読み込み中…</div>
  <div v-else-if="empty" class="card empty">{{ emptyText ?? "まだ何もありません" }}</div>
  <slot v-else />
</template>
