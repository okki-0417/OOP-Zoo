<script setup lang="ts">
import { computed } from 'vue'
import { useUiStore } from '../stores/ui'
import Modal from './ui/Modal.vue'
import AcquireForm from './forms/AcquireForm.vue'
import EnclosureForm from './forms/EnclosureForm.vue'
import StaffForm from './forms/StaffForm.vue'

const ui = useUiStore()

const TITLES: Record<string, string> = {
  animal: '動物を導入', enclosure: 'エリアを増設', staff: 'スタッフを採用',
}
const title = computed(() => (ui.createModal ? TITLES[ui.createModal] : ''))
</script>

<template>
  <Modal v-if="ui.createModal" :title="title" @close="ui.closeCreate()">
    <AcquireForm v-if="ui.createModal === 'animal'" @done="ui.closeCreate()" />
    <EnclosureForm v-else-if="ui.createModal === 'enclosure'" @done="ui.closeCreate()" />
    <StaffForm v-else-if="ui.createModal === 'staff'" @done="ui.closeCreate()" />
  </Modal>
</template>
