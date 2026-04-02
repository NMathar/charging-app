<template>
  <header class="glass-header fixed top-0 w-full z-50 flex items-center justify-between px-6 py-4">
    <div class="flex items-center gap-3">
      <v-icon icon="mdi-car-electric" color="primary-container" size="28" />
      <h1 class="headline-sm" style="color: var(--v-theme-primary)">EV Intelligence</h1>
    </div>
    <div class="flex items-center gap-4">
      <v-btn icon variant="text" color="outline" size="small">
        <v-icon size="20">mdi-bell-outline</v-icon>
      </v-btn>
      <div class="w-10 h-10 rounded-full bg-secondary-container flex items-center justify-center">
        <v-icon size="20" color="secondary">mdi-account</v-icon>
      </div>
    </div>
  </header>
</template>

<script setup lang="ts">
</script>
