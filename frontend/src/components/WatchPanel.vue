<script setup lang="ts">
import type { ExhibitedSpecies, Deceased } from '../api/client'

defineProps<{ threatened: ExhibitedSpecies[]; deceased: Deceased[] }>()
</script>

<template>
  <section class="panel">
    <h2>絶滅危惧種 / 慰霊</h2>
    <table v-if="threatened.length">
      <thead><tr><th>絶滅危惧種</th><th>状況</th><th>頭数</th></tr></thead>
      <tbody>
        <tr v-for="s in threatened" :key="s.name_ja">
          <td>{{ s.name_ja }}</td>
          <td><span class="tag">{{ s.status_code }}</span> {{ s.status_label }}</td>
          <td>{{ s.count }}</td>
        </tr>
      </tbody>
    </table>
    <p v-else class="empty">展示中の絶滅危惧種はいません</p>

    <table v-if="deceased.length" style="margin-top:12px">
      <thead><tr><th>慰霊</th><th>種</th><th>死因</th></tr></thead>
      <tbody>
        <tr v-for="(d, i) in deceased" :key="i" class="dead">
          <td>{{ d.name }}</td>
          <td>{{ d.species }}</td>
          <td>{{ d.cause }}</td>
        </tr>
      </tbody>
    </table>
  </section>
</template>
