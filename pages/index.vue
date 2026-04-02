<template>
  <div class="min-h-screen bg-[#f8f9ff] pb-32">
    <main class="pt-24 px-4 max-w-lg mx-auto">
      <header class="mb-6">
        <p class="text-[11px] font-semibold uppercase tracking-[0.08em] text-[#414750] mb-2" style="font-family: 'Inter', sans-serif;">System-Status</p>
        <h2 class="text-[32px] font-extrabold text-[#191c20] tracking-tight leading-tight" style="font-family: 'Manrope', sans-serif;">Übersicht</h2>
      </header>

      <div v-if="activeSession" class="bg-[#ffffff] rounded-[24px] overflow-hidden mb-6 shadow-[0_20px_40px_-10px_rgba(0,73,125,0.08)]">
        <div class="flex items-center gap-2 px-6 pt-5">
          <div class="px-3 py-1.5 bg-[#d7e3f8] rounded-full">
            <span class="text-[11px] font-semibold text-[#535f70]" style="font-family: 'Inter', sans-serif;">Laufender Ladevorgang</span>
          </div>
          <v-icon color="#0061a4" size="18">mdi-lightning-bolt</v-icon>
        </div>

        <div class="p-6">
          <h3 class="text-[20px] font-bold text-[#191c20] mb-6" style="font-family: 'Manrope', sans-serif;">Heimladestation</h3>

          <div class="flex items-center justify-center mb-6">
            <div class="relative w-48 h-48">
              <svg class="transform -rotate-90" width="192" height="192">
                <circle
                  cx="96"
                  cy="96"
                  r="80"
                  stroke="#e1e2e8"
                  stroke-width="12"
                  fill="none"
                />
                <circle
                  cx="96"
                  cy="96"
                  r="80"
                  :stroke="'url(#gradient)'"
                  stroke-width="12"
                  fill="none"
                  :stroke-dasharray="circumference"
                  :stroke-dashoffset="circumference - (currentBatteryPercentage / 100) * circumference"
                  stroke-linecap="round"
                />
                <defs>
                  <linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" style="stop-color:#00497d;stop-opacity:1" />
                    <stop offset="100%" style="stop-color:#0061a4;stop-opacity:1" />
                  </linearGradient>
                </defs>
              </svg>
              <div class="absolute inset-0 flex flex-col items-center justify-center">
                <div class="text-[48px] font-extrabold text-[#191c20]" style="font-family: 'Manrope', sans-serif;">{{ currentBatteryPercentage }}%</div>
                <div class="text-[11px] text-[#414750] uppercase tracking-[0.08em] font-semibold" style="font-family: 'Inter', sans-serif;">SOC</div>
              </div>
            </div>
          </div>

          <div class="grid grid-cols-2 gap-4 mb-6">
            <div>
              <div class="text-[11px] text-[#414750] uppercase tracking-[0.08em] mb-2 font-semibold" style="font-family: 'Inter', sans-serif;">Leistung</div>
              <div class="text-[24px] font-bold text-[#191c20]" style="font-family: 'Manrope', sans-serif;">{{ activeSession.wallbox_power }} kW</div>
            </div>
            <div>
              <div class="text-[11px] text-[#414750] uppercase tracking-[0.08em] mb-2 font-semibold" style="font-family: 'Inter', sans-serif;">Dauer</div>
              <div class="text-[24px] font-bold text-[#191c20]" style="font-family: 'Manrope', sans-serif;">{{ activeDuration }}</div>
            </div>
          </div>

          <v-btn
            color="#ba1a1a"
            block
            size="x-large"
            class="rounded-[16px]"
            style="font-family: 'Manrope', sans-serif; text-transform: none; letter-spacing: 0; font-size: 16px;"
            @click="stopActiveCharging"
            :loading="stoppingCharge"
            height="56"
          >
            <v-icon start size="20">mdi-stop-circle-outline</v-icon>
            Ladevorgang stoppen
          </v-btn>
        </div>
      </div>

      <div v-else class="space-y-4 mb-8">
        <div class="bg-[#f2f3f9] rounded-[20px] p-6">
          <div class="flex items-center gap-3 mb-6">
            <div class="w-12 h-12 rounded-[12px] bg-[#d1e4ff] flex items-center justify-center flex-shrink-0">
              <v-icon color="#00497d" size="24">mdi-battery-charging-high</v-icon>
            </div>
            <h3 class="font-bold text-[18px] text-[#191c20]" style="font-family: 'Manrope', sans-serif;">Schnellstart</h3>
          </div>

          <div class="space-y-6">
            <div>
              <label class="block text-[11px] font-semibold uppercase tracking-[0.08em] text-[#414750] mb-3" style="font-family: 'Inter', sans-serif;">Start (%)</label>
              <div class="relative">
                <input
                  v-model.number="quickStart.start_percentage"
                  class="w-full bg-[#e1e2e8] border-none rounded-[12px] py-4 pl-5 pr-16 font-bold text-[28px] focus:ring-2 focus:ring-[#0061a4]/20 transition-all outline-none text-[#191c20]"
                  style="font-family: 'Manrope', sans-serif;"
                  type="number"
                  min="0"
                  max="100"
                />
                <div class="absolute right-5 top-1/2 -translate-y-1/2 text-[#717782] font-medium text-base" style="font-family: 'Inter', sans-serif;">%</div>
              </div>
            </div>

            <div class="grid grid-cols-2 gap-3">
              <v-btn
                color="#0061a4"
                block
                size="large"
                class="rounded-[12px]"
                style="font-family: 'Manrope', sans-serif; text-transform: none; letter-spacing: 0; font-size: 15px;"
                @click="saveQuickSession"
                :loading="savingQuick"
                height="52"
              >
                <v-icon start size="18">mdi-content-save</v-icon>
                Speichern
              </v-btn>
              <v-btn
                color="#00497d"
                block
                size="large"
                class="rounded-[12px]"
                style="font-family: 'Manrope', sans-serif; text-transform: none; letter-spacing: 0; font-size: 15px;"
                @click="startQuickCharging"
                :loading="startingQuick"
                height="52"
              >
                <v-icon start size="18">mdi-play</v-icon>
                Starten
              </v-btn>
            </div>
          </div>
        </div>
      </div>

      <div v-if="completedSessions.length > 0" class="mb-6">
        <div class="rounded-[24px] p-6 text-white mb-6 shadow-[0_20px_40px_-10px_rgba(0,73,125,0.08)]" style="background: linear-gradient(135deg, #00497d 0%, #0061a4 100%);">
          <div class="flex items-center gap-2 mb-2">
            <v-icon color="white" size="18">mdi-currency-eur</v-icon>
            <p class="text-sm opacity-90" style="font-family: 'Inter', sans-serif;">Gesamtkosten</p>
          </div>
          <p class="text-[48px] font-extrabold leading-none" style="font-family: 'Manrope', sans-serif;">{{ totalCost.toFixed(2) }} €</p>
          <p class="text-xs opacity-75 mt-2" style="font-family: 'Inter', sans-serif;">Aktueller Monat</p>
        </div>

        <div class="flex justify-between items-center mb-4">
          <h3 class="font-bold text-[18px] text-[#191c20]" style="font-family: 'Manrope', sans-serif;">Abgeschlossene Ladevorgänge</h3>
          <v-btn
            variant="text"
            color="#0061a4"
            size="small"
            @click="showAllSessions = !showAllSessions"
            style="font-family: 'Inter', sans-serif; text-transform: none; letter-spacing: 0;"
          >
            {{ showAllSessions ? 'Weniger' : 'Details' }}
            <v-icon end size="18">{{ showAllSessions ? 'mdi-chevron-up' : 'mdi-chevron-right' }}</v-icon>
          </v-btn>
        </div>

        <div class="space-y-3">
          <div
            v-for="(session, index) in displayedSessions"
            :key="session.id"
            class="bg-[#ffffff] rounded-[16px] p-4 flex items-center justify-between shadow-sm"
          >
            <div class="flex items-center gap-3">
              <div class="w-11 h-11 rounded-[10px] bg-[#f2f3f9] flex items-center justify-center flex-shrink-0">
                <v-icon :color="getStationColor(session)" size="20">{{ getStationIcon(session) }}</v-icon>
              </div>
              <div>
                <p class="font-bold text-[15px] text-[#191c20]" style="font-family: 'Manrope', sans-serif;">{{ getStationName(session) }}</p>
                <p class="text-xs text-[#414750]" style="font-family: 'Inter', sans-serif;">{{ formatShortDate(session.created_at) }} • {{ session.energy_charged.toFixed(1) }} kWh</p>
              </div>
            </div>
            <div class="text-right">
              <p class="font-bold text-[15px] text-[#0061a4]" style="font-family: 'Manrope', sans-serif;">{{ session.total_cost.toFixed(2) }} €</p>
              <p class="text-xs text-[#52405f]" style="font-family: 'Inter', sans-serif;">Erfolgreich</p>
            </div>
          </div>
        </div>
      </div>

      <div v-else-if="!loading" class="bg-[#d1e4ff]/30 rounded-[20px] p-8 text-center">
        <v-icon size="48" color="#0061a4" class="mb-3">mdi-information-outline</v-icon>
        <p class="text-[#414750]" style="font-family: 'Inter', sans-serif;">Noch keine Ladevorgänge vorhanden</p>
      </div>

      <div v-if="loading" class="text-center py-12">
        <v-progress-circular indeterminate color="#0061a4" />
      </div>
    </main>

    <nav class="fixed bottom-0 w-full z-50 bg-[#f8f9ff]/90 backdrop-blur-md rounded-t-[32px] shadow-[0_-10px_30px_rgba(0,73,125,0.05)] flex justify-around items-center pt-4 pb-7 px-4">
      <v-btn variant="text" color="#717782" class="flex-col h-auto py-2" style="min-width: 64px; opacity: 0.6">
        <v-icon size="24">mdi-calculator-variant</v-icon>
        <span class="text-[10px] font-semibold uppercase tracking-[0.08em] mt-1.5" style="font-family: 'Inter', sans-serif;">Calculator</span>
      </v-btn>
      <div class="flex flex-col items-center bg-[#0061A4] rounded-[20px] px-6 py-3 h-auto" style="min-width: 76px;">
        <v-icon color="white" size="24">mdi-chart-line</v-icon>
        <span class="text-white text-[10px] font-semibold uppercase tracking-[0.08em] mt-1.5" style="font-family: 'Inter', sans-serif;">Trends</span>
      </div>
      <v-btn variant="text" color="#717782" class="flex-col h-auto py-2" style="min-width: 64px; opacity: 0.6">
        <v-icon size="24">mdi-ev-station</v-icon>
        <span class="text-[10px] font-semibold uppercase tracking-[0.08em] mt-1.5" style="font-family: 'Inter', sans-serif;">Stations</span>
      </v-btn>
      <v-btn variant="text" color="#717782" class="flex-col h-auto py-2" style="min-width: 64px; opacity: 0.6" to="/settings">
        <v-icon size="24">mdi-account</v-icon>
        <span class="text-[10px] font-semibold uppercase tracking-[0.08em] mt-1.5" style="font-family: 'Inter', sans-serif;">Profile</span>
      </v-btn>
    </nav>
  </div>
</template>

<script setup lang="ts">
const supabase = useSupabaseClient()

const sessions = ref([])
const loading = ref(true)
const activeDuration = ref('0:00')
const currentBatteryPercentage = ref(0)
const stoppingCharge = ref(false)
const showAllSessions = ref(false)
const savingQuick = ref(false)
const startingQuick = ref(false)
let durationInterval: NodeJS.Timeout | null = null

const quickStart = reactive({
  start_percentage: 20,
  end_percentage: 80
})

const settings = ref({
  battery_capacity: 77,
  electricity_price: 0.32,
  wallbox_power: 11,
  wallbox_loss: 10
})

const circumference = 2 * Math.PI * 80

const activeSession = computed(() => {
  return sessions.value.find((s: any) => s.status === 'active')
})

const completedSessions = computed(() => {
  return sessions.value.filter((s: any) => s.status === 'completed')
})

const displayedSessions = computed(() => {
  return showAllSessions.value ? completedSessions.value : completedSessions.value.slice(0, 3)
})

const totalCost = computed(() => {
  return completedSessions.value.reduce((sum, session) => sum + Number(session.total_cost), 0)
})

const updateActiveDuration = () => {
  if (activeSession.value) {
    const startTime = new Date(activeSession.value.start_time || activeSession.value.created_at)
    const now = new Date()
    const diff = now.getTime() - startTime.getTime()
    const hours = Math.floor(diff / (1000 * 60 * 60))
    const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
    const seconds = Math.floor((diff % (1000 * 60)) / 1000)
    activeDuration.value = `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`

    const hoursElapsed = diff / (1000 * 60 * 60)
    const chargedKwh = hoursElapsed * Number(activeSession.value.wallbox_power)
    const batteryCapacity = Number(activeSession.value.battery_capacity)
    const wallboxLoss = Number(activeSession.value.wallbox_loss)
    const chargedPercentage = (chargedKwh / batteryCapacity) * 100 * (100 / (100 + wallboxLoss))
    currentBatteryPercentage.value = Math.min(100, Math.round(Number(activeSession.value.start_percentage) + chargedPercentage))
  }
}

const loadSettings = async () => {
  const { data, error } = await supabase
    .from('settings')
    .select('*')
    .maybeSingle()

  if (data && !error) {
    settings.value = {
      battery_capacity: Number(data.battery_capacity),
      electricity_price: Number(data.electricity_price),
      wallbox_power: Number(data.wallbox_power),
      wallbox_loss: Number(data.wallbox_loss)
    }
  }
}

const loadSessions = async () => {
  loading.value = true
  const { data, error } = await supabase
    .from('charging_sessions')
    .select('*')
    .order('created_at', { ascending: false })

  if (error) {
    console.error('Error loading sessions:', error)
  } else {
    sessions.value = data || []
  }
  loading.value = false
}

const saveQuickSession = async () => {
  savingQuick.value = true

  const percentageDiff = quickStart.end_percentage - quickStart.start_percentage
  const netEnergy = (settings.value.battery_capacity * percentageDiff) / 100
  const energyWithLoss = netEnergy * (1 + settings.value.wallbox_loss / 100)
  const totalCost = energyWithLoss * settings.value.electricity_price

  const sessionData = {
    start_percentage: quickStart.start_percentage,
    end_percentage: quickStart.end_percentage,
    battery_capacity: settings.value.battery_capacity,
    electricity_price: settings.value.electricity_price,
    wallbox_power: settings.value.wallbox_power,
    wallbox_loss: settings.value.wallbox_loss,
    energy_charged: energyWithLoss,
    total_cost: totalCost,
    status: 'completed'
  }

  const { error } = await supabase
    .from('charging_sessions')
    .insert([sessionData])

  if (!error) {
    await loadSessions()
  }

  savingQuick.value = false
}

const startQuickCharging = async () => {
  startingQuick.value = true

  const sessionData = {
    start_percentage: quickStart.start_percentage,
    end_percentage: quickStart.start_percentage,
    battery_capacity: settings.value.battery_capacity,
    electricity_price: settings.value.electricity_price,
    wallbox_power: settings.value.wallbox_power,
    wallbox_loss: settings.value.wallbox_loss,
    energy_charged: 0,
    total_cost: 0,
    start_time: new Date().toISOString(),
    status: 'active'
  }

  const { error } = await supabase
    .from('charging_sessions')
    .insert([sessionData])

  if (!error) {
    await loadSessions()
  }

  startingQuick.value = false
}

const stopActiveCharging = async () => {
  if (!activeSession.value) return

  stoppingCharge.value = true

  const percentageDiff = currentBatteryPercentage.value - Number(activeSession.value.start_percentage)
  const netEnergy = (Number(activeSession.value.battery_capacity) * percentageDiff) / 100
  const energyWithLoss = netEnergy * (1 + Number(activeSession.value.wallbox_loss) / 100)
  const totalCost = energyWithLoss * Number(activeSession.value.electricity_price)

  const { error } = await supabase
    .from('charging_sessions')
    .update({
      end_percentage: currentBatteryPercentage.value,
      end_time: new Date().toISOString(),
      energy_charged: energyWithLoss,
      total_cost: totalCost,
      status: 'completed'
    })
    .eq('id', activeSession.value.id)

  if (!error) {
    await loadSessions()
  }

  stoppingCharge.value = false
}

const formatShortDate = (dateString: string) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('de-DE', { day: '2-digit', month: 'short' })
}

const getStationName = (session: any) => {
  return 'Heimstation'
}

const getStationIcon = (session: any) => {
  return 'mdi-home'
}

const getStationColor = (session: any) => {
  return '#0061a4'
}

onMounted(() => {
  loadSettings()
  loadSessions()
  durationInterval = setInterval(() => {
    updateActiveDuration()
  }, 1000)
})

onUnmounted(() => {
  if (durationInterval) {
    clearInterval(durationInterval)
  }
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
