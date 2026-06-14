<script setup lang="ts">
import { computed } from 'vue'
import { useUiStore } from '../stores/ui'
import Drawer from './ui/Drawer.vue'
import AnimalDetail from './details/AnimalDetail.vue'
import EnclosureDetail from './details/EnclosureDetail.vue'
import StaffDetail from './details/StaffDetail.vue'

const ui = useUiStore()

const title = computed(() => {
  switch (ui.current?.type) {
    case 'animal': return '動物'
    case 'enclosure': return 'エリア'
    case 'staff': return 'スタッフ'
    default: return ''
  }
})
</script>

<template>
  <Drawer v-if="ui.current" :title="title" :can-back="ui.canBack" @close="ui.close()" @back="ui.back()">
    <AnimalDetail v-if="ui.current.type === 'animal'" :key="'a' + ui.current.id" :id="ui.current.id"
                  @open-enclosure="ui.openEnclosure" />
    <EnclosureDetail v-else-if="ui.current.type === 'enclosure'" :key="'e' + ui.current.id" :id="ui.current.id"
                     @open-animal="ui.openAnimal" />
    <StaffDetail v-else-if="ui.current.type === 'staff'" :key="'s' + ui.current.id"
                 :id="ui.current.id" :kind="ui.current.kind" />
  </Drawer>
</template>
