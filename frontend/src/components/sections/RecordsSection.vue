<script setup lang="ts">
import { useZooStore } from '../../stores/zoo'
import Badge from '../ui/Badge.vue'
import { conservationColor } from '../../cosmetics'

const zoo = useZooStore()
</script>

<template>
  <section class="panel">
    <h2>記録</h2>
    <h3 class="sub">絶滅危惧種</h3>
    <table v-if="zoo.threatened.length">
      <tbody>
        <tr v-for="s in zoo.threatened" :key="s.name_ja">
          <td>{{ s.name_ja }}</td>
          <td><Badge :text="s.status_code" :color="conservationColor(s.status_code)" /> {{ s.status_label }}</td>
          <td>{{ s.count }}頭</td>
        </tr>
      </tbody>
    </table>
    <p v-else class="empty">展示中の絶滅危惧種はいません</p>

    <h3 class="sub">慰霊</h3>
    <table v-if="zoo.deceased.length">
      <tbody>
        <tr v-for="(d, i) in zoo.deceased" :key="i" class="dead">
          <td>{{ d.name }}</td><td>{{ d.species }}</td><td>{{ d.cause }}</td>
        </tr>
      </tbody>
    </table>
    <p v-else class="empty">死亡記録はありません</p>
  </section>
</template>
