<template>
  <div>
    <label v-if="label" class="label-sm block text-on-surface-variant mb-3">
      {{ label }}
    </label>
    <div class="relative">
      <input
        :value="modelValue"
        @input="$emit('update:modelValue', parseFloat($event.target.value) || 0)"
        class="input-soft-well"
        :type="type"
        :step="step"
        :min="min"
        :max="max"
        :placeholder="placeholder"
      />
      <div v-if="unit" class="input-unit">{{ unit }}</div>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  modelValue: number
  label?: string
  unit?: string
  type?: string
  step?: string
  min?: string | number
  max?: string | number
  placeholder?: string
}>()

defineEmits<{
  'update:modelValue': [value: number]
}>()
</script>
