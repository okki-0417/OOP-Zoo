<script setup lang="ts">
import type { Keeper, Veterinarian } from '../api/client'

defineProps<{ keepers: Keeper[]; veterinarians: Veterinarian[] }>()
</script>

<template>
  <section class="panel">
    <h2>スタッフ</h2>
    <p class="empty" v-if="keepers.length === 0 && veterinarians.length === 0">まだスタッフがいません</p>
    <table v-else>
      <tbody>
        <tr v-for="k in keepers" :key="k.id">
          <td><span class="tag">飼育員</span> {{ k.name }}</td>
          <td>{{ k.specialties }}</td>
        </tr>
        <tr v-for="v in veterinarians" :key="v.id">
          <td><span class="tag">獣医</span> {{ v.name }}</td>
          <td></td>
        </tr>
      </tbody>
    </table>
  </section>
</template>
