<template>
  <nav class="bottom-nav fixed bottom-0 w-full z-50 flex justify-around items-center pt-4 pb-7 px-4">
    <v-btn
      variant="text"
      color="outline"
      class="bottom-nav-item"
      :class="{ active: activeTab === 'calculator' }"
      @click="$emit('navigate', 'calculator')"
    >
      <v-icon size="24">mdi-calculator-variant</v-icon>
      <span class="label-xs mt-1.5">Calculator</span>
    </v-btn>

    <v-btn
      variant="text"
      class="bottom-nav-item"
      :class="{ active: activeTab === 'trends' }"
      @click="$emit('navigate', 'trends')"
    >
      <v-icon size="24">mdi-chart-line</v-icon>
      <span class="label-xs mt-1.5">Trends</span>
    </v-btn>

    <v-btn
      variant="text"
      color="outline"
      class="bottom-nav-item"
      :class="{ active: activeTab === 'stations' }"
      @click="$emit('navigate', 'stations')"
    >
      <v-icon size="24">mdi-ev-station</v-icon>
      <span class="label-xs mt-1.5">Stations</span>
    </v-btn>

    <v-btn
      variant="text"
      class="bottom-nav-item"
      :class="{ active: activeTab === 'profile' }"
      to="/settings"
    >
      <v-icon size="24">mdi-account</v-icon>
      <span class="label-xs mt-1.5">Profile</span>
    </v-btn>
  </nav>
</template>

<script setup lang="ts">
defineProps<{
  activeTab?: string
}>()

defineEmits<{
  navigate: [tab: string]
}>()
</script>
