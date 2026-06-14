<script setup lang="ts">
import { useZooStore } from '../../stores/zoo'
import { useUiStore } from '../../stores/ui'

const zoo = useZooStore()
const ui = useUiStore()
</script>

<template>
  <section class="panel">
    <div class="panel-head">
      <h2>スタッフ ({{ zoo.keepers.length + zoo.veterinarians.length }})</h2>
      <button class="add" @click="ui.openCreate('staff')">＋採用</button>
    </div>
    <p v-if="zoo.keepers.length === 0 && zoo.veterinarians.length === 0" class="empty">
      まだスタッフがいません。「＋採用」から雇いましょう。
    </p>
    <div v-else class="card-grid">
      <button v-for="k in zoo.keepers" :key="k.id" class="card" @click="ui.openStaff(k.id, 'keeper')">
        <span class="card-emoji">🧑‍🌾</span>
        <span class="card-main">
          <span class="card-name">{{ k.name }}</span>
          <span class="card-sub">飼育員 · {{ k.specialties }}</span>
        </span>
      </button>
      <button v-for="v in zoo.veterinarians" :key="v.id" class="card" @click="ui.openStaff(v.id, 'vet')">
        <span class="card-emoji">🩺</span>
        <span class="card-main">
          <span class="card-name">{{ v.name }}</span>
          <span class="card-sub">獣医</span>
        </span>
      </button>
    </div>
  </section>
</template>
