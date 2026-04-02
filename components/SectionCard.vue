<template>
  <section class="card-secondary p-6">
    <div class="flex items-center gap-3 mb-6">
      <div :class="iconContainerClass">
        <v-icon :color="iconColor" size="24">{{ icon }}</v-icon>
      </div>
      <h3 class="title">{{ title }}</h3>
    </div>
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
