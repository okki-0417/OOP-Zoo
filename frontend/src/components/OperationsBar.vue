<script setup lang="ts">
import { ref } from 'vue'
import { useZooStore } from '../stores/zoo'

const zoo = useZooStore()
const days = ref(7)
const fee = ref(2000)
const visitors = ref(50)
</script>

<template>
  <div class="ops-bar">
    <button :disabled="zoo.loading" @click="zoo.operate()">▶ 1日運営</button>
    <div class="ops-item">
      <input type="number" min="1" v-model="days" />
      <button class="secondary" :disabled="zoo.loading" @click="zoo.runMany(Number(days))">日運営</button>
    </div>
    <div class="ops-item">
      <span>入園料</span>
      <input type="number" min="0" v-model="fee" />
      <button class="secondary" :disabled="zoo.loading" @click="zoo.setFee(Number(fee))">改定</button>
    </div>
    <div class="ops-item">
      <span>来園</span>
      <input type="number" min="0" v-model="visitors" />
      <button class="secondary" :disabled="zoo.loading" @click="zoo.admitVisitors(Number(visitors))">受入</button>
    </div>
  </div>
</template>
