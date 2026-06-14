<script setup lang="ts">
import type { EnclosureSummary } from '../api/client'

defineProps<{ enclosures: EnclosureSummary[] }>()
</script>

<template>
  <section class="panel">
    <h2>飼育エリア ({{ enclosures.length }})</h2>
    <p v-if="enclosures.length === 0" class="empty">まだエリアがありません</p>
    <table v-else>
      <thead><tr><th>名前</th><th>収容</th></tr></thead>
      <tbody>
        <tr v-for="e in enclosures" :key="e.id">
          <td>{{ e.name }}</td>
          <td>{{ e.population }} / {{ e.capacity }}</td>
        </tr>
      </tbody>
    </table>
  </section>
</template>
