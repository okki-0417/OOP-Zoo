<script setup lang="ts">
import { ref } from 'vue'
import { useZooStore } from '../../stores/zoo'

const store = useZooStore()
const fee = ref(2000)
const visitors = ref(50)
const days = ref(7)
</script>

<template>
  <form class="action" @submit.prevent>
    <div class="row">
      <button :disabled="store.loading" @click="store.operate()">1日運営する</button>
      <label style="flex:0 0 90px">日数<input type="number" min="1" v-model="days" /></label>
      <button class="secondary" :disabled="store.loading" @click="store.runMany(Number(days))">まとめて運営</button>
    </div>
    <div class="row">
      <label>入園料(円)<input type="number" min="0" v-model="fee" /></label>
      <button class="secondary" :disabled="store.loading" @click="store.setFee(Number(fee))">改定</button>
    </div>
    <div class="row">
      <label>来園者数<input type="number" min="0" v-model="visitors" /></label>
      <button class="secondary" :disabled="store.loading" @click="store.admitVisitors(Number(visitors))">受け入れ</button>
    </div>
  </form>
</template>
