<script setup lang="ts">
import { ref } from 'vue'
import { useZooStore } from '../../stores/zoo'

const store = useZooStore()
const emit = defineEmits<{ done: [] }>()
const name = ref('')
const celsius = ref(25)
const capacity = ref(4)

async function submit() {
  if (!name.value) return
  await store.addEnclosure({ name: name.value, celsius: Number(celsius.value), capacity: Number(capacity.value) })
  if (!store.error) emit('done')
}
</script>

<template>
  <form class="action" @submit.prevent="submit">
    <label>名前<input v-model="name" placeholder="サバンナ" /></label>
    <div class="row">
      <label>気温(℃)<input type="number" v-model="celsius" /></label>
      <label>定員<input type="number" min="1" v-model="capacity" /></label>
    </div>
    <button :disabled="store.loading">増設する</button>
  </form>
</template>
