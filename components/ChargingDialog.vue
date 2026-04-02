<template>
  <v-dialog v-model="dialogModel" max-width="500" persistent>
    <v-card>
      <v-card-title class="pa-6">
        <h3 class="headline-md">{{ title }}</h3>
      </v-card-title>

      <v-card-text class="px-6 pb-2">
        <SoftWellInput
          v-model="localData.start_percentage"
          label="Start Batteriestand (%)"
          unit="%"
          type="number"
          :min="0"
          :max="100"
          class="mb-4"
        />

        <SoftWellInput
          v-if="mode === 'manual'"
          v-model="localData.end_percentage"
          label="Aktueller Batteriestand (%)"
          unit="%"
          type="number"
          :min="0"
          :max="100"
          class="mb-4"
        />

        <v-checkbox
          v-model="showAdvanced"
          label="Erweiterte Einstellungen"
          color="primary-container"
          hide-details
          class="mt-2 mb-4"
        />

        <div v-if="showAdvanced" class="space-y-4">
          <SoftWellInput
            v-model="localData.wallbox_power"
            label="Ladeleistung"
            unit="kW"
            type="number"
            step="0.1"
            :min="0"
          />

          <SoftWellInput
            v-model="localData.wallbox_loss"
            label="Ladeverlust"
            unit="%"
            type="number"
            :min="0"
            :max="100"
          />

          <SoftWellInput
            v-model="localData.electricity_price"
            label="Strompreis"
            unit="€/kWh"
            type="number"
            step="0.01"
            :min="0"
          />
        </div>
      </v-card-text>

      <v-card-actions class="pa-6 pt-4">
        <v-btn
          variant="text"
          @click="cancel"
          :disabled="loading"
        >
          Abbrechen
        </v-btn>
        <v-spacer />
        <v-btn
          color="primary"
          @click="confirm"
          :loading="loading"
        >
          {{ confirmText }}
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup lang="ts">
interface ChargingDialogData {
  start_percentage: number;
  end_percentage: number;
  wallbox_power: number;
  wallbox_loss: number;
  electricity_price: number;
}

const props = defineProps<{
  modelValue: boolean;
  mode: 'time' | 'manual';
  initialData: ChargingDialogData;
  title?: string;
  confirmText?: string;
}>();

const emit = defineEmits<{
  'update:modelValue': [value: boolean];
  'confirm': [data: ChargingDialogData];
}>();

const dialogModel = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value),
});

const showAdvanced = ref(false);
const loading = ref(false);
const localData = ref<ChargingDialogData>({ ...props.initialData });

watch(() => props.modelValue, (newVal) => {
  if (newVal) {
    localData.value = { ...props.initialData };
    showAdvanced.value = false;
  }
});

const cancel = () => {
  dialogModel.value = false;
};

const confirm = () => {
  emit('confirm', { ...localData.value });
};
</script>
