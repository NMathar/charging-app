<template>
  <div>
    <v-row>
      <v-col cols="12">
        <h1 class="text-h4 mb-4">Standard-Einstellungen</h1>
        <p class="text-body-2 text-medium-emphasis mb-6">
          Diese Werte werden als Standard für neue Ladevorgänge verwendet. Sie können beim Erstellen eines Ladevorgangs individuell angepasst werden.
        </p>
      </v-col>
    </v-row>

    <v-row v-if="loading">
      <v-col cols="12" class="text-center">
        <v-progress-circular indeterminate color="primary" />
      </v-col>
    </v-row>

    <v-row v-else>
      <v-col cols="12" md="8" lg="6">
        <v-card>
          <v-card-title>Fahrzeug & Ladestation</v-card-title>
          <v-card-text>
            <v-form @submit.prevent="saveSettings">
              <v-text-field
                v-model.number="form.battery_capacity"
                label="Batteriekapazität (kWh)"
                type="number"
                step="0.1"
                min="1"
                variant="outlined"
                prepend-icon="mdi-battery-high"
                hint="Gesamtkapazität der Fahrzeugbatterie"
                persistent-hint
                class="mb-4"
              />

              <v-text-field
                v-model.number="form.electricity_price"
                label="Strompreis (€/kWh)"
                type="number"
                step="0.01"
                min="0"
                variant="outlined"
                prepend-icon="mdi-currency-eur"
                hint="Preis pro Kilowattstunde"
                persistent-hint
                class="mb-4"
              />

              <v-text-field
                v-model.number="form.wallbox_power"
                label="Wallbox Leistung (kW)"
                type="number"
                step="0.1"
                min="1"
                variant="outlined"
                prepend-icon="mdi-lightning-bolt"
                hint="Maximale Ladeleistung der Wallbox"
                persistent-hint
                class="mb-4"
              />

              <v-text-field
                v-model.number="form.wallbox_loss"
                label="Wallbox Verlust (%)"
                type="number"
                step="0.1"
                min="0"
                max="100"
                variant="outlined"
                prepend-icon="mdi-chart-line-variant"
                hint="Energieverlust durch Ladeelektronik (typisch 5-15%)"
                persistent-hint
                class="mb-4"
              />

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
                block
                size="large"
              >
                Einstellungen speichern
              </v-btn>
            </v-form>
          </v-card-text>
        </v-card>

        <v-card class="mt-6">
          <v-card-title>Beispielrechnung</v-card-title>
          <v-card-text>
            <p class="text-body-2 mb-2">
              Bei einer Ladung von 20% bis 80% ({{ ((form.battery_capacity * 60) / 100).toFixed(2) }} kWh):
            </p>
            <v-list density="compact">
              <v-list-item>
                <v-list-item-title>Netto-Energie</v-list-item-title>
                <v-list-item-subtitle>
                  {{ ((form.battery_capacity * 60) / 100).toFixed(2) }} kWh
                </v-list-item-subtitle>
              </v-list-item>
              <v-list-item>
                <v-list-item-title>Mit Verlusten</v-list-item-title>
                <v-list-item-subtitle>
                  {{ (((form.battery_capacity * 60) / 100) * (1 + form.wallbox_loss / 100)).toFixed(2) }} kWh
                </v-list-item-subtitle>
              </v-list-item>
              <v-list-item>
                <v-list-item-title>Kosten</v-list-item-title>
                <v-list-item-subtitle>
                  {{ (((form.battery_capacity * 60) / 100) * (1 + form.wallbox_loss / 100) * form.electricity_price).toFixed(2) }} €
                </v-list-item-subtitle>
              </v-list-item>
              <v-list-item>
                <v-list-item-title>Ladedauer (ca.)</v-list-item-title>
                <v-list-item-subtitle>
                  {{ Math.ceil(((form.battery_capacity * 60) / 100) / form.wallbox_power * 60) }} Minuten
                </v-list-item-subtitle>
              </v-list-item>
            </v-list>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
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
  battery_capacity: 50,
  electricity_price: 0.30,
  wallbox_power: 11,
  wallbox_loss: 10
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
