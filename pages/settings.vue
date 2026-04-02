<template>
  <div class="min-h-screen bg-[#f8f9ff] pb-32">
    <header class="fixed top-0 w-full z-50 glass-header flex items-center justify-between px-6 py-4">
      <div class="flex items-center gap-3">
        <v-icon icon="mdi-car-electric" color="#0061A4" size="28" />
        <h1 class="text-xl font-extrabold text-[#00497d] tracking-tight" style="font-family: 'Manrope', sans-serif;">EV Intelligence</h1>
      </div>
      <div class="flex items-center gap-4">
        <v-btn icon variant="text" color="#717782" size="small">
          <v-icon size="20">mdi-bell-outline</v-icon>
        </v-btn>
        <div class="w-10 h-10 rounded-full bg-[#d7e3f8] flex items-center justify-center">
          <v-icon size="20" color="#535f70">mdi-account</v-icon>
        </div>
      </div>
    </header>

    <main class="pt-24 px-4 max-w-lg mx-auto">
      <header class="mb-8">
        <h2 class="text-[32px] font-extrabold text-[#191c20] tracking-tight mb-2 leading-tight" style="font-family: 'Manrope', sans-serif;">Einstellungen</h2>
        <p class="text-[#414750] text-base leading-relaxed" style="font-family: 'Inter', sans-serif;">Optimieren Sie Ihre Ladekalkulation für maximale Präzision.</p>
      </header>

      <div v-if="loading" class="text-center py-12">
        <v-progress-circular indeterminate color="#0061a4" />
      </div>

      <div v-else class="space-y-4">
        <section class="bg-[#f2f3f9] rounded-[20px] p-6 transition-all duration-300">
          <div class="flex items-center gap-3 mb-6">
            <div class="w-12 h-12 rounded-[12px] bg-[#d1e4ff] flex items-center justify-center flex-shrink-0">
              <v-icon color="#00497d" size="24">mdi-battery-charging-high</v-icon>
            </div>
            <h3 class="font-bold text-[18px] text-[#191c20]" style="font-family: 'Manrope', sans-serif;">Fahrzeug & Batterie</h3>
          </div>

          <div class="space-y-6">
            <div>
              <label class="block text-[11px] font-semibold uppercase tracking-[0.05em] text-[#414750] mb-3" style="font-family: 'Inter', sans-serif; letter-spacing: 0.08em;">Batteriekapazität (kWh)</label>
              <div class="relative">
                <input
                  v-model.number="form.battery_capacity"
                  class="w-full bg-[#e1e2e8] border-none rounded-[12px] py-4 pl-5 pr-20 font-bold text-[28px] focus:ring-2 focus:ring-[#0061a4]/20 transition-all outline-none text-[#191c20]"
                  style="font-family: 'Manrope', sans-serif;"
                  type="number"
                  step="0.1"
                  min="1"
                />
                <div class="absolute right-5 top-1/2 -translate-y-1/2 text-[#717782] font-medium text-base" style="font-family: 'Inter', sans-serif;">kWh</div>
              </div>
            </div>

            <div>
              <label class="block text-[11px] font-semibold uppercase tracking-[0.05em] text-[#414750] mb-3" style="font-family: 'Inter', sans-serif; letter-spacing: 0.08em;">Ladeverluste (%)</label>
              <div class="relative">
                <input
                  v-model.number="form.wallbox_loss"
                  class="w-full bg-[#e1e2e8] border-none rounded-[12px] py-4 pl-5 pr-16 font-bold text-[28px] focus:ring-2 focus:ring-[#0061a4]/20 transition-all outline-none text-[#191c20]"
                  style="font-family: 'Manrope', sans-serif;"
                  type="number"
                  step="0.1"
                  min="0"
                  max="100"
                />
                <div class="absolute right-5 top-1/2 -translate-y-1/2 text-[#717782] font-medium text-base" style="font-family: 'Inter', sans-serif;">%</div>
              </div>
            </div>
          </div>
        </section>

        <section class="bg-[#f2f3f9] rounded-[20px] p-6">
          <div class="flex items-center gap-3 mb-6">
            <div class="w-12 h-12 rounded-[12px] bg-[#f3daff] flex items-center justify-center flex-shrink-0">
              <v-icon color="#52405f" size="24">mdi-lightning-bolt</v-icon>
            </div>
            <h3 class="font-bold text-[18px] text-[#191c20]" style="font-family: 'Manrope', sans-serif;">Infrastruktur & Kosten</h3>
          </div>

          <div class="space-y-6">
            <div>
              <label class="block text-[11px] font-semibold uppercase tracking-[0.05em] text-[#414750] mb-3" style="font-family: 'Inter', sans-serif; letter-spacing: 0.08em;">Strompreis (€/kWh)</label>
              <div class="relative">
                <input
                  v-model.number="form.electricity_price"
                  class="w-full bg-[#e1e2e8] border-none rounded-[12px] py-4 pl-5 pr-12 font-bold text-[28px] focus:ring-2 focus:ring-[#0061a4]/20 transition-all outline-none text-[#191c20]"
                  style="font-family: 'Manrope', sans-serif;"
                  type="number"
                  step="0.01"
                  min="0"
                />
                <div class="absolute right-5 top-1/2 -translate-y-1/2 text-[#717782] font-medium text-base" style="font-family: 'Inter', sans-serif;">€</div>
              </div>
            </div>

            <div>
              <label class="block text-[11px] font-semibold uppercase tracking-[0.05em] text-[#414750] mb-3" style="font-family: 'Inter', sans-serif; letter-spacing: 0.08em;">Wallbox Leistung (kW)</label>
              <div class="relative">
                <input
                  v-model.number="form.wallbox_power"
                  class="w-full bg-[#e1e2e8] border-none rounded-[12px] py-4 pl-5 pr-16 font-bold text-[28px] focus:ring-2 focus:ring-[#0061a4]/20 transition-all outline-none text-[#191c20]"
                  style="font-family: 'Manrope', sans-serif;"
                  type="number"
                  step="0.1"
                  min="1"
                />
                <div class="absolute right-5 top-1/2 -translate-y-1/2 text-[#717782] font-medium text-base" style="font-family: 'Inter', sans-serif;">kW</div>
              </div>
            </div>
          </div>
        </section>

        <section class="bg-[#ffffff] rounded-[24px] overflow-hidden mt-6 shadow-[0_20px_40px_-10px_rgba(0,73,125,0.08)]">
          <div class="px-6 pt-6 pb-4">
            <h3 class="font-bold text-[18px] text-[#191c20] mb-1" style="font-family: 'Manrope', sans-serif;">Beispielrechnung</h3>
            <p class="text-sm text-[#414750]" style="font-family: 'Inter', sans-serif;">Basierend auf einer Ladung von 20% auf 80%</p>
          </div>

          <div class="px-6 pb-6 space-y-4">
            <div class="flex justify-between items-center py-2">
              <span class="text-[#414750] text-base" style="font-family: 'Inter', sans-serif;">Energiebedarf inkl. Verlust</span>
              <span class="font-bold text-[18px] text-[#0061a4]" style="font-family: 'Manrope', sans-serif;">{{ exampleEnergy.toFixed(1) }} kWh</span>
            </div>

            <div class="h-[1px] bg-[#c1c7d2] opacity-15 w-full"></div>

            <div class="flex justify-between items-center py-2">
              <span class="text-[#414750] text-base" style="font-family: 'Inter', sans-serif;">Ladedauer ca.</span>
              <span class="font-bold text-[18px] text-[#191c20]" style="font-family: 'Manrope', sans-serif;">{{ exampleDuration }}</span>
            </div>

            <div class="h-[1px] bg-[#c1c7d2] opacity-15 w-full"></div>

            <div class="flex justify-between items-center bg-[#d1e4ff]/40 px-4 py-4 rounded-[12px] mt-3">
              <span class="text-[#00497d] font-semibold text-base" style="font-family: 'Inter', sans-serif;">Gesamtkosten</span>
              <span class="font-extrabold text-[32px] text-[#00497d]" style="font-family: 'Manrope', sans-serif;">{{ exampleCost.toFixed(2) }} €</span>
            </div>
          </div>
        </section>

        <div class="mt-6 px-0">
          <v-btn
            class="w-full text-white font-bold rounded-[16px] shadow-[0_20px_40px_-10px_rgba(0,73,125,0.08)]"
            style="background: linear-gradient(135deg, #00497d 0%, #0061a4 100%); font-family: 'Manrope', sans-serif; text-transform: none; letter-spacing: 0; font-size: 16px;"
            size="x-large"
            @click="saveSettings"
            :loading="saving"
            height="64"
          >
            <v-icon start size="20">mdi-content-save</v-icon>
            Einstellungen speichern
          </v-btn>
        </div>

        <v-alert v-if="successMessage" type="success" variant="tonal" class="mt-4 rounded-[12px]">
          {{ successMessage }}
        </v-alert>

        <v-alert v-if="errorMessage" type="error" variant="tonal" class="mt-4 rounded-[12px]">
          {{ errorMessage }}
        </v-alert>
      </div>
    </main>

    <nav class="fixed bottom-0 w-full z-50 bg-[#f8f9ff]/90 backdrop-blur-md rounded-t-[32px] shadow-[0_-10px_30px_rgba(0,73,125,0.05)] flex justify-around items-center pt-4 pb-7 px-4">
      <v-btn variant="text" color="#717782" class="flex-col h-auto py-2" style="min-width: 64px; opacity: 0.6" to="/">
        <v-icon size="24">mdi-calculator-variant</v-icon>
        <span class="text-[10px] font-semibold uppercase tracking-[0.08em] mt-1.5" style="font-family: 'Inter', sans-serif;">Calculator</span>
      </v-btn>
      <v-btn variant="text" color="#717782" class="flex-col h-auto py-2" style="min-width: 64px; opacity: 0.6">
        <v-icon size="24">mdi-chart-line</v-icon>
        <span class="text-[10px] font-semibold uppercase tracking-[0.08em] mt-1.5" style="font-family: 'Inter', sans-serif;">Trends</span>
      </v-btn>
      <v-btn variant="text" color="#717782" class="flex-col h-auto py-2" style="min-width: 64px; opacity: 0.6">
        <v-icon size="24">mdi-ev-station</v-icon>
        <span class="text-[10px] font-semibold uppercase tracking-[0.08em] mt-1.5" style="font-family: 'Inter', sans-serif;">Stations</span>
      </v-btn>
      <div class="flex flex-col items-center bg-[#0061A4] rounded-[20px] px-6 py-3 h-auto" style="min-width: 76px;">
        <v-icon color="white" size="24">mdi-account</v-icon>
        <span class="text-white text-[10px] font-semibold uppercase tracking-[0.08em] mt-1.5" style="font-family: 'Inter', sans-serif;">Profile</span>
      </div>
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
@import url('https://fonts.googleapis.com/css2?family=Manrope:wght@400;700;800&family=Inter:wght@400;500;600&display=swap');

.glass-header {
  background: rgba(248, 249, 255, 0.8);
  backdrop-filter: blur(12px);
  box-shadow: 0 20px 40px -10px rgba(0, 73, 125, 0.08);
}

input[type="number"]::-webkit-inner-spin-button,
input[type="number"]::-webkit-outer-spin-button {
  -webkit-appearance: none;
  margin: 0;
}

input[type="number"] {
  -moz-appearance: textfield;
}
</style>
