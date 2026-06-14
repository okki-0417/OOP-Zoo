<script setup lang="ts">
defineProps<{ title: string }>()
const emit = defineEmits<{ close: [] }>()
</script>

<template>
  <div class="overlay center" @click.self="emit('close')">
    <div class="modal">
      <header class="modal-head">
        <h3>{{ title }}</h3>
        <button class="icon" title="閉じる" @click="emit('close')">✕</button>
      </header>
      <div class="modal-body"><slot /></div>
    </div>
  </div>
</template>
