<template>
  <section class="card-secondary mb-6 pa-6">
    <!-- TODO: set titel next to icon, not in header of section card -->

    <v-row class="mb-2">
      <div :class="iconContainerClass">
        <v-icon :color="iconColor" size="24">{{ icon }}</v-icon>
      </div>      
      <span class="title mb-4 mt-2">{{ title }}</span>
    </v-row>
    


    <slot /> 
  </section>
</template>

<script setup lang="ts">
const props = defineProps<{
  title: string
  icon: string
  iconColor?: string
  variant?: 'primary' | 'tertiary'
}>()

const iconContainerClass = computed(() => {
  return props.variant === 'tertiary'
    ? 'icon-container-tertiary'
    : 'icon-container-primary'
})
</script>
