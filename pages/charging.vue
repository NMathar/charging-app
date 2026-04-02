<template>
  <div>
    <v-row>
      <v-col cols="12">
        <h1 class="text-h4 mb-4">Neuer Ladevorgang</h1>
      </v-col>
    </v-row>

    <v-row>
      <v-col cols="12" md="8" lg="6">
        <v-card>
          <v-card-title>Ladevorgang erfassen</v-card-title>
          <v-card-text>
            <v-tabs v-model="tab" class="mb-6">
              <v-tab value="manual">Manuelle Eingabe</v-tab>
              <v-tab value="timer">Mit Timer</v-tab>
            </v-tabs>

            <v-form @submit.prevent="saveChargingSession">
              <v-window v-model="tab">
                <v-window-item value="manual">
                  <v-row>
                    <v-col cols="12" sm="6">
                      <v-text-field
                        v-model.number="form.start_percentage"
                        label="Start (%)"
                        type="number"
                        step="1"
                        min="0"
                        max="100"
                        variant="outlined"
                        prepend-icon="mdi-battery-low"
                        :rules="[v => v >= 0 && v <= 100 || 'Wert zwischen 0 und 100']"
                      />
                    </v-col>
                    <v-col cols="12" sm="6">
                      <v-text-field
                        v-model.number="form.end_percentage"
                        label="Ende (%)"
                        type="number"
                        step="1"
                        min="0"
                        max="100"
                        variant="outlined"
                        prepend-icon="mdi-battery-high"
                        :rules="[
                          v => v >= 0 && v <= 100 || 'Wert zwischen 0 und 100',
                          v => v > form.start_percentage || 'Muss größer als Start sein'
                        ]"
                      />
                    </v-col>
                  </v-row>
                </v-window-item>

                <v-window-item value="timer">
                  <v-alert v-if="!isCharging" type="info" variant="tonal" class="mb-4">
                    Starten Sie den Timer beim Beginn des Ladevorgangs
                  </v-alert>
                  <v-alert v-else type="success" variant="tonal" class="mb-4">
                    Ladevorgang läuft seit {{ chargingDuration }}
                  </v-alert>

                  <v-row>
                    <v-col cols="12" sm="6">
                      <v-text-field
                        v-model.number="form.start_percentage"
                        label="Start (%)"
                        type="number"
                        step="1"
                        min="0"
                        max="100"
                        variant="outlined"
                        prepend-icon="mdi-battery-low"
                        :disabled="isCharging"
                        :rules="[v => v >= 0 && v <= 100 || 'Wert zwischen 0 und 100']"
                      />
                    </v-col>
                    <v-col cols="12" sm="6">
                      <v-text-field
                        v-model.number="currentPercentage"
                        label="Aktuell (%)"
                        type="number"
                        variant="outlined"
                        prepend-icon="mdi-battery-charging"
                        readonly
                        :disabled="!isCharging"
                        hint="Wird automatisch anhand der Zeit berechnet"
                        persistent-hint
                      />
                    </v-col>
                  </v-row>

                  <v-row>
                    <v-col cols="12">
                      <v-btn
                        v-if="!isCharging"
                        @click="startCharging"
                        color="success"
                        block
                        size="large"
                        prepend-icon="mdi-play"
                      >
                        Ladevorgang starten
                      </v-btn>
                      <v-btn
                        v-else
                        @click="stopCharging"
                        color="error"
                        block
                        size="large"
                        prepend-icon="mdi-stop"
                      >
                        Ladevorgang beenden
                      </v-btn>
                    </v-col>
                  </v-row>
                </v-window-item>
              </v-window>

              <v-divider class="my-6" />

              <v-row>
                <v-col cols="12">
                  <v-switch
                    v-model="useCustomSettings"
                    label="Individuelle Einstellungen für diesen Ladevorgang"
                    color="primary"
                  />
                </v-col>
              </v-row>

              <v-expand-transition>
                <div v-if="useCustomSettings">
                  <v-row>
                    <v-col cols="12" sm="6">
                      <v-text-field
                        v-model.number="form.battery_capacity"
                        label="Batteriekapazität (kWh)"
                        type="number"
                        step="0.1"
                        min="1"
                        variant="outlined"
                        density="compact"
                      />
                    </v-col>
                    <v-col cols="12" sm="6">
                      <v-text-field
                        v-model.number="form.electricity_price"
                        label="Strompreis (€/kWh)"
                        type="number"
                        step="0.01"
                        min="0"
                        variant="outlined"
                        density="compact"
                      />
                    </v-col>
                    <v-col cols="12" sm="6">
                      <v-text-field
                        v-model.number="form.wallbox_power"
                        label="Wallbox Leistung (kW)"
                        type="number"
                        step="0.1"
                        min="1"
                        variant="outlined"
                        density="compact"
                      />
                    </v-col>
                    <v-col cols="12" sm="6">
                      <v-text-field
                        v-model.number="form.wallbox_loss"
                        label="Wallbox Verlust (%)"
                        type="number"
                        step="0.1"
                        min="0"
                        max="100"
                        variant="outlined"
                        density="compact"
                      />
                    </v-col>
                  </v-row>
                </div>
              </v-expand-transition>

              <v-divider class="my-6" />

              <v-card variant="tonal" color="primary" class="mb-6">
                <v-card-text>
                  <v-row dense>
                    <v-col cols="6">
                      <div class="text-caption">Geladene Energie</div>
                      <div class="text-h6">{{ calculatedEnergy.toFixed(2) }} kWh</div>
                    </v-col>
                    <v-col cols="6">
                      <div class="text-caption">Voraussichtliche Kosten</div>
                      <div class="text-h6">{{ calculatedCost.toFixed(2) }} €</div>
                    </v-col>
                  </v-row>
                </v-card-text>
              </v-card>

              <v-alert
                v-if="successMessage"
                type="success"
                variant="tonal"
                class="mb-4"
              >
                {{ successMessage }}
              </v-alert>

              <v-alert
                v-if="errorMessage"
                type="error"
                variant="tonal"
                class="mb-4"
              >
                {{ errorMessage }}
              </v-alert>

              <v-btn
                type="submit"
                color="primary"
                :loading="saving"
                :disabled="tab === 'timer' && isCharging"
                block
                size="large"
              >
                Ladevorgang speichern
              </v-btn>
            </v-form>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </div>
</template>

<script setup lang="ts">
const supabase = useSupabaseClient()
const router = useRouter()

const tab = ref('manual')
const saving = ref(false)
const successMessage = ref('')
const errorMessage = ref('')
const useCustomSettings = ref(false)

const isCharging = ref(false)
const chargingStartTime = ref<Date | null>(null)
const chargingDuration = ref('0:00')
const activeSessionId = ref<string | null>(null)
const currentPercentage = ref(0)
let durationInterval: NodeJS.Timeout | null = null

const form = reactive({
  start_percentage: 20,
  end_percentage: 80,
  battery_capacity: 50,
  electricity_price: 0.30,
  wallbox_power: 11,
  wallbox_loss: 10
})

const calculatedEnergy = computed(() => {
  const endPercent = tab.value === 'timer' && isCharging.value ? currentPercentage.value : form.end_percentage
  const percentageDiff = endPercent - form.start_percentage
  if (percentageDiff <= 0) return 0

  const netEnergy = (form.battery_capacity * percentageDiff) / 100
  const energyWithLoss = netEnergy * (1 + form.wallbox_loss / 100)
  return energyWithLoss
})

const calculatedCost = computed(() => {
  return calculatedEnergy.value * form.electricity_price
})

const loadDefaultSettings = async () => {
  const { data, error } = await supabase
    .from('settings')
    .select('*')
    .maybeSingle()

  if (data && !error) {
    form.battery_capacity = Number(data.battery_capacity)
    form.electricity_price = Number(data.electricity_price)
    form.wallbox_power = Number(data.wallbox_power)
    form.wallbox_loss = Number(data.wallbox_loss)
  }
}

const loadActiveSession = async () => {
  const { data, error } = await supabase
    .from('charging_sessions')
    .select('*')
    .eq('status', 'active')
    .maybeSingle()

  if (data && !error) {
    activeSessionId.value = data.id
    isCharging.value = true
    chargingStartTime.value = data.start_time ? new Date(data.start_time) : new Date(data.created_at)
    form.start_percentage = Number(data.start_percentage)
    form.end_percentage = Number(data.end_percentage)
    form.battery_capacity = Number(data.battery_capacity)
    form.electricity_price = Number(data.electricity_price)
    form.wallbox_power = Number(data.wallbox_power)
    form.wallbox_loss = Number(data.wallbox_loss)
    currentPercentage.value = form.start_percentage
    tab.value = 'timer'

    durationInterval = setInterval(() => {
      if (chargingStartTime.value) {
        const now = new Date()
        const diff = now.getTime() - chargingStartTime.value.getTime()
        const hours = Math.floor(diff / (1000 * 60 * 60))
        const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
        chargingDuration.value = `${hours}:${minutes.toString().padStart(2, '0')}`

        const hoursElapsed = diff / (1000 * 60 * 60)
        const chargedKwh = hoursElapsed * form.wallbox_power
        const chargedPercentage = (chargedKwh / form.battery_capacity) * 100 * (100 / (100 + form.wallbox_loss))
        currentPercentage.value = Math.min(100, Math.round(form.start_percentage + chargedPercentage))
      }
    }, 1000)
  }
}

const startCharging = async () => {
  chargingStartTime.value = new Date()

  const sessionData = {
    start_percentage: form.start_percentage,
    end_percentage: form.start_percentage,
    battery_capacity: form.battery_capacity,
    electricity_price: form.electricity_price,
    wallbox_power: form.wallbox_power,
    wallbox_loss: form.wallbox_loss,
    energy_charged: 0,
    total_cost: 0,
    start_time: chargingStartTime.value.toISOString(),
    status: 'active'
  }

  const { data, error } = await supabase
    .from('charging_sessions')
    .insert([sessionData])
    .select()
    .single()

  if (error) {
    errorMessage.value = 'Fehler beim Starten des Ladevorgangs'
    console.error('Error starting charging session:', error)
    return
  }

  if (data) {
    activeSessionId.value = data.id
    isCharging.value = true
    currentPercentage.value = form.start_percentage

    durationInterval = setInterval(() => {
      if (chargingStartTime.value) {
        const now = new Date()
        const diff = now.getTime() - chargingStartTime.value.getTime()
        const hours = Math.floor(diff / (1000 * 60 * 60))
        const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
        chargingDuration.value = `${hours}:${minutes.toString().padStart(2, '0')}`

        const hoursElapsed = diff / (1000 * 60 * 60)
        const chargedKwh = hoursElapsed * form.wallbox_power
        const chargedPercentage = (chargedKwh / form.battery_capacity) * 100 * (100 / (100 + form.wallbox_loss))
        currentPercentage.value = Math.min(100, Math.round(form.start_percentage + chargedPercentage))
      }
    }, 1000)
  }
}

const stopCharging = async () => {
  if (!activeSessionId.value) return

  const { error } = await supabase
    .from('charging_sessions')
    .update({
      end_percentage: currentPercentage.value,
      end_time: new Date().toISOString(),
      energy_charged: calculatedEnergy.value,
      total_cost: calculatedCost.value,
      status: 'completed'
    })
    .eq('id', activeSessionId.value)

  if (error) {
    errorMessage.value = 'Fehler beim Beenden des Ladevorgangs'
    console.error('Error stopping charging session:', error)
    return
  }

  isCharging.value = false
  activeSessionId.value = null
  if (durationInterval) {
    clearInterval(durationInterval)
    durationInterval = null
  }

  successMessage.value = 'Ladevorgang erfolgreich beendet'
  setTimeout(() => {
    router.push('/')
  }, 1500)
}

const saveChargingSession = async () => {
  if (form.end_percentage <= form.start_percentage) {
    errorMessage.value = 'Ende-Prozentsatz muss größer als Start-Prozentsatz sein'
    return
  }

  saving.value = true
  successMessage.value = ''
  errorMessage.value = ''

  const sessionData = {
    start_percentage: form.start_percentage,
    end_percentage: form.end_percentage,
    battery_capacity: form.battery_capacity,
    electricity_price: form.electricity_price,
    wallbox_power: form.wallbox_power,
    wallbox_loss: form.wallbox_loss,
    energy_charged: calculatedEnergy.value,
    total_cost: calculatedCost.value,
    start_time: tab.value === 'timer' && chargingStartTime.value ? chargingStartTime.value.toISOString() : null,
    end_time: tab.value === 'timer' && chargingStartTime.value ? new Date().toISOString() : null,
    status: 'completed'
  }

  const { error } = await supabase
    .from('charging_sessions')
    .insert([sessionData])

  if (error) {
    errorMessage.value = 'Fehler beim Speichern des Ladevorgangs'
    console.error('Error saving charging session:', error)
  } else {
    successMessage.value = 'Ladevorgang erfolgreich gespeichert'
    setTimeout(() => {
      router.push('/')
    }, 1500)
  }

  saving.value = false
}

onMounted(() => {
  loadDefaultSettings()
  loadActiveSession()
})

onUnmounted(() => {
  if (durationInterval) {
    clearInterval(durationInterval)
  }
})
</script>
