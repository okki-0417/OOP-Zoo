<script setup lang="ts">
defineProps<{ title: string; canBack: boolean }>()
const emit = defineEmits<{ close: []; back: [] }>()
</script>

<template>
  <div class="overlay" @click.self="emit('close')">
    <aside class="drawer">
      <header class="drawer-head">
        <button v-if="canBack" class="icon" title="戻る" @click="emit('back')">←</button>
        <h3>{{ title }}</h3>
        <button class="icon" title="閉じる" @click="emit('close')">✕</button>
      </header>
      <div class="drawer-body"><slot /></div>
    </aside>
  </div>
</template>
