<template>
  <div class="min-h-screen pb-32" style="background: var(--v-theme-surface)">

    <main class="pt-24 px-4 max-w-lg mx-auto">
      <header class="mb-8">
        <h2 class="headline-lg mb-2">Einstellungen</h2>
        <p class="body-lg text-on-surface-variant">Optimieren Sie Ihre Ladekalkulation für maximale Präzision.</p>
      </header>

      <div v-if="loading" class="text-center py-12">
        <v-progress-circular indeterminate color="primary-container" />
      </div>

      <div v-else class="space-y-4">
        <SectionCard
          title="Fahrzeug & Batterie"
          icon="mdi-battery-charging-high"
          variant="primary"
        >
          <div class="space-y-6">
            <SoftWellInput
              v-model="form.battery_capacity"
              label="Batteriekapazität (kWh)"
              unit="kWh"
              type="number"
              step="0.1"
              :min="1"
            />

            <SoftWellInput
              v-model="form.wallbox_loss"
              label="Ladeverluste (%)"
              unit="%"
              type="number"
              step="0.1"
              :min="0"
              :max="100"
            />
          </div>
        </SectionCard>

        <SectionCard
          title="Infrastruktur & Kosten"
          icon="mdi-lightning-bolt"
          variant="tertiary"
        >
          <div class="space-y-6">
            <SoftWellInput
              v-model="form.electricity_price"
              label="Strompreis (€/kWh)"
              unit="€"
              type="number"
              step="0.01"
              :min="0"
            />

            <SoftWellInput
              v-model="form.wallbox_power"
              label="Wallbox Leistung (kW)"
              unit="kW"
              type="number"
              step="0.1"
              :min="1"
            />
          </div>
        </SectionCard>

        <section class="card-primary mt-6">
          <div class="px-6 pt-6 pb-4">
            <h3 class="title mb-1">Beispielrechnung</h3>
            <p class="body-md text-on-surface-variant">Basierend auf einer Ladung von 20% auf 80%</p>
          </div>

          <div class="px-6 pb-6 space-y-4">
            <div class="flex justify-between items-center py-2">
              <span class="body-lg text-on-surface-variant">Energiebedarf inkl. Verlust</span>
              <span class="title" style="color: var(--v-theme-primary-container)">{{ exampleEnergy.toFixed(1) }} kWh</span>
            </div>

            <div class="divider-subtle"></div>

            <div class="flex justify-between items-center py-2">
              <span class="body-lg text-on-surface-variant">Ladedauer ca.</span>
              <span class="title">{{ exampleDuration }}</span>
            </div>

            <div class="divider-subtle"></div>

            <div class="flex justify-between items-center rounded-xl px-4 py-4 mt-3" style="background: rgba(var(--v-theme-primary-fixed), 0.4)">
              <span class="label-lg" style="color: var(--v-theme-primary)">Gesamtkosten</span>
              <span class="headline-lg" style="color: var(--v-theme-primary)">{{ exampleCost.toFixed(2) }} €</span>
            </div>
          </div>
        </section>

        <div class="mt-6">
          <v-btn
            class="gradient-primary shadow-ambient"
            color="primary"
            block
            size="x-large"
            @click="saveSettings"
            :loading="saving"
            height="64"
          >
            <v-icon start size="20">mdi-content-save</v-icon>
            Einstellungen speichern
          </v-btn>
        </div>

        <v-alert v-if="successMessage" type="success" variant="tonal" class="mt-4 rounded-xl">
          {{ successMessage }}
        </v-alert>

        <v-alert v-if="errorMessage" type="error" variant="tonal" class="mt-4 rounded-xl">
          {{ errorMessage }}
        </v-alert>
      </div>
    </main>

  </div>
</template>

<script setup lang="ts">
const supabase = useSupabaseClient()

const loading = ref(true)
const saving = ref(false)
const successMessage = ref('')
const errorMessage = ref('')
const settingsId = ref<string | null>(null)

const form = reactive({
  battery_capacity: 77,
  electricity_price: 0.32,
  wallbox_power: 11,
  wallbox_loss: 10
})

const exampleEnergy = computed(() => {
  const percentageDiff = 60
  const netEnergy = (form.battery_capacity * percentageDiff) / 100
  return netEnergy * (1 + form.wallbox_loss / 100)
})

const exampleCost = computed(() => {
  return exampleEnergy.value * form.electricity_price
})

const exampleDuration = computed(() => {
  const hours = Math.floor(exampleEnergy.value / form.wallbox_power)
  const minutes = Math.round(((exampleEnergy.value / form.wallbox_power) % 1) * 60)
  return `${hours}h ${minutes}min`
})

const loadSettings = async () => {
  loading.value = true
  const { data, error } = await supabase
    .from('settings')
    .select('*')
    .maybeSingle()

  if (error) {
    console.error('Error loading settings:', error)
  } else if (data) {
    settingsId.value = data.id
    form.battery_capacity = Number(data.battery_capacity)
    form.electricity_price = Number(data.electricity_price)
    form.wallbox_power = Number(data.wallbox_power)
    form.wallbox_loss = Number(data.wallbox_loss)
  }
  loading.value = false
}

const saveSettings = async () => {
  saving.value = true
  successMessage.value = ''
  errorMessage.value = ''

  let result
  if (settingsId.value) {
    result = await supabase
      .from('settings')
      .update({
        ...form,
        updated_at: new Date().toISOString()
      })
      .eq('id', settingsId.value)
  } else {
    result = await supabase
      .from('settings')
      .insert([form])
      .select()
      .single()

    if (result.data) {
      settingsId.value = result.data.id
    }
  }

  if (result.error) {
    errorMessage.value = 'Fehler beim Speichern der Einstellungen'
    console.error('Error saving settings:', result.error)
  } else {
    successMessage.value = 'Einstellungen erfolgreich gespeichert'
    setTimeout(() => {
      successMessage.value = ''
    }, 3000)
  }

  saving.value = false
}

onMounted(() => {
  loadSettings()
})
</script>
