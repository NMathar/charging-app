<template>
  <div class="min-h-screen bg-[#f8f9ff] pb-32">
    <header class="fixed top-0 w-full z-50 glass-header flex items-center justify-between px-6 py-4">
      <div class="flex items-center gap-3">
        <v-icon icon="mdi-car-electric" color="#0061A4" />
        <h1 class="text-xl font-bold text-[#00497d] tracking-tight">EV Intelligence</h1>
      </div>
      <div class="flex items-center gap-4">
        <v-btn icon variant="text" color="#717782">
          <v-icon>mdi-bell-outline</v-icon>
        </v-btn>
        <div class="w-8 h-8 rounded-full bg-[#d7e3f8] flex items-center justify-center">
          <v-icon size="small" color="#535f70">mdi-account</v-icon>
        </div>
      </div>
    </header>

    <main class="pt-24 px-4 max-w-lg mx-auto">
      <header class="mb-8">
        <h2 class="text-3xl font-bold text-[#191c20] tracking-tight mb-2">Einstellungen</h2>
        <p class="text-[#414750]">Optimieren Sie Ihre Ladekalkulation für maximale Präzision.</p>
      </header>

      <div v-if="loading" class="text-center py-12">
        <v-progress-circular indeterminate color="#0061a4" />
      </div>

      <div v-else class="space-y-4">
        <section class="bg-[#f2f3f9] rounded-xl p-6 transition-all duration-300">
          <div class="flex items-center gap-3 mb-6">
            <div class="w-10 h-10 rounded-lg bg-[#d1e4ff] flex items-center justify-center">
              <v-icon color="#00497d">mdi-battery-charging-full</v-icon>
            </div>
            <h3 class="font-bold text-lg">Fahrzeug & Batterie</h3>
          </div>

          <div class="space-y-6">
            <div>
              <label class="block text-xs font-medium uppercase tracking-widest text-[#414750] mb-2">Batteriekapazität (kWh)</label>
              <div class="relative">
                <input
                  v-model.number="form.battery_capacity"
                  class="w-full bg-[#e1e2e8] border-none rounded-lg py-4 px-4 font-bold text-xl focus:ring-2 focus:ring-[#0061a4]/20 transition-all outline-none"
                  type="number"
                  step="0.1"
                  min="1"
                />
                <div class="absolute right-4 top-1/2 -translate-y-1/2 text-[#414750] font-medium">kWh</div>
              </div>
            </div>

            <div>
              <label class="block text-xs font-medium uppercase tracking-widest text-[#414750] mb-2">Ladeverluste (%)</label>
              <div class="relative">
                <input
                  v-model.number="form.wallbox_loss"
                  class="w-full bg-[#e1e2e8] border-none rounded-lg py-4 px-4 font-bold text-xl focus:ring-2 focus:ring-[#0061a4]/20 transition-all outline-none"
                  type="number"
                  step="0.1"
                  min="0"
                  max="100"
                />
                <div class="absolute right-4 top-1/2 -translate-y-1/2 text-[#414750] font-medium">%</div>
              </div>
            </div>
          </div>
        </section>

        <section class="bg-[#f2f3f9] rounded-xl p-6">
          <div class="flex items-center gap-3 mb-6">
            <div class="w-10 h-10 rounded-lg bg-[#f3daff] flex items-center justify-center">
              <v-icon color="#52405f">mdi-lightning-bolt</v-icon>
            </div>
            <h3 class="font-bold text-lg">Infrastruktur & Kosten</h3>
          </div>

          <div class="space-y-6">
            <div>
              <label class="block text-xs font-medium uppercase tracking-widest text-[#414750] mb-2">Strompreis (€/kWh)</label>
              <div class="relative">
                <input
                  v-model.number="form.electricity_price"
                  class="w-full bg-[#e1e2e8] border-none rounded-lg py-4 px-4 font-bold text-xl focus:ring-2 focus:ring-[#0061a4]/20 transition-all outline-none"
                  type="number"
                  step="0.01"
                  min="0"
                />
                <div class="absolute right-4 top-1/2 -translate-y-1/2 text-[#414750] font-medium">€</div>
              </div>
            </div>

            <div>
              <label class="block text-xs font-medium uppercase tracking-widest text-[#414750] mb-2">Wallbox Leistung (kW)</label>
              <div class="relative">
                <input
                  v-model.number="form.wallbox_power"
                  class="w-full bg-[#e1e2e8] border-none rounded-lg py-4 px-4 font-bold text-xl focus:ring-2 focus:ring-[#0061a4]/20 transition-all outline-none"
                  type="number"
                  step="0.1"
                  min="1"
                />
                <div class="absolute right-4 top-1/2 -translate-y-1/2 text-[#414750] font-medium">kW</div>
              </div>
            </div>
          </div>
        </section>

        <section class="bg-[#ffffff] rounded-2xl overflow-hidden mt-2 shadow-[0_20px_40px_-10px_rgba(0,73,125,0.08)]">
          <div class="p-6 bg-[#d7e3f8]/30">
            <h3 class="font-bold text-[#535f70] mb-1">Beispielrechnung</h3>
            <p class="text-sm text-[#414750]">Basierend auf einer Ladung von 20% auf 80%</p>
          </div>

          <div class="p-6 space-y-4">
            <div class="flex justify-between items-center">
              <span class="text-[#414750]">Energiebedarf inkl. Verlust</span>
              <span class="font-bold text-[#0061a4]">{{ exampleEnergy.toFixed(1) }} kWh</span>
            </div>
            <div class="h-px bg-[#c1c7d2]/15 w-full"></div>
            <div class="flex justify-between items-center">
              <span class="text-[#414750]">Ladedauer ca.</span>
              <span class="font-bold text-[#191c20]">{{ exampleDuration }}</span>
            </div>
            <div class="h-px bg-[#c1c7d2]/15 w-full"></div>
            <div class="flex justify-between items-center bg-[#d1e4ff]/30 p-3 rounded-lg">
              <span class="text-[#00497d] font-semibold">Gesamtkosten</span>
              <span class="font-bold text-2xl text-[#00497d]">{{ exampleCost.toFixed(2) }} €</span>
            </div>
          </div>
        </section>

        <div class="mt-4 px-2">
          <v-btn
            class="w-full bg-gradient-to-br from-[#00497d] to-[#0061a4] text-white font-bold py-5 rounded-xl shadow-[0_20px_40px_-10px_rgba(0,73,125,0.08)]"
            size="large"
            @click="saveSettings"
            :loading="saving"
          >
            <v-icon start>mdi-content-save</v-icon>
            Einstellungen speichern
          </v-btn>
        </div>

        <v-alert v-if="successMessage" type="success" variant="tonal" class="mt-4">
          {{ successMessage }}
        </v-alert>

        <v-alert v-if="errorMessage" type="error" variant="tonal" class="mt-4">
          {{ errorMessage }}
        </v-alert>
      </div>
    </main>

    <nav class="fixed bottom-0 w-full z-50 bg-[#f8f9ff]/90 backdrop-blur-md rounded-t-3xl shadow-[0_-10px_30px_rgba(0,73,125,0.05)] flex justify-around items-center pt-3 pb-6 px-4">
      <v-btn variant="text" color="#191c20" class="flex-col" style="opacity: 0.6" to="/">
        <v-icon>mdi-calculator</v-icon>
        <span class="text-[11px] font-medium uppercase tracking-wider mt-1">Calculator</span>
      </v-btn>
      <v-btn variant="text" color="#191c20" class="flex-col" style="opacity: 0.6">
        <v-icon>mdi-chart-line</v-icon>
        <span class="text-[11px] font-medium uppercase tracking-wider mt-1">Trends</span>
      </v-btn>
      <v-btn variant="text" color="#191c20" class="flex-col" style="opacity: 0.6">
        <v-icon>mdi-ev-station</v-icon>
        <span class="text-[11px] font-medium uppercase tracking-wider mt-1">Stations</span>
      </v-btn>
      <v-btn variant="text" class="flex-col bg-[#0061A4] text-white rounded-2xl px-5">
        <v-icon>mdi-account</v-icon>
        <span class="text-[11px] font-medium uppercase tracking-wider mt-1">Profile</span>
      </v-btn>
    </nav>
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

<style scoped>
.glass-header {
  background: rgba(248, 249, 255, 0.8);
  backdrop-filter: blur(12px);
  box-shadow: 0 20px 40px -10px rgba(0, 73, 125, 0.08);
}
</style>
