<script setup lang="ts">
import type { AnimalSummary } from '../api/client'

defineProps<{ animals: AnimalSummary[] }>()
</script>

<template>
  <section class="panel">
    <h2>動物 ({{ animals.length }})</h2>
    <p v-if="animals.length === 0" class="empty">まだ動物がいません</p>
    <table v-else>
      <thead><tr><th>名前</th><th>種</th><th>状態</th></tr></thead>
      <tbody>
        <tr v-for="a in animals" :key="a.id" :class="{ dead: !a.alive }">
          <td>{{ a.name }}</td>
          <td>{{ a.species }}</td>
          <td>{{ a.alive ? '生存' : '死亡' }}</td>
        </tr>
      </tbody>
    </table>
  </section>
</template>
