<template>
  <div class="min-h-screen pb-32" style="background: var(--v-theme-surface)">
    <AppHeader />

    <main class="pt-24 px-4 max-w-lg mx-auto">
      <header class="mb-6">
        <p class="label-sm text-on-surface-variant mb-2">System-Status</p>
        <h2 class="headline-lg">Übersicht</h2>
      </header>

      <div v-if="activeSession" class="card-primary mb-6">
        <div class="flex items-center gap-2 px-6 pt-5">
          <div class="badge-info">
            <span>Laufender Ladevorgang</span>
          </div>
          <v-icon color="primary-container" size="18">mdi-lightning-bolt</v-icon>
        </div>

        <div class="p-6">
          <h3 class="headline-sm mb-6">Heimladestation</h3>

          <div class="flex items-center justify-center mb-6">
            <div class="relative w-48 h-48">
              <svg class="transform -rotate-90" width="192" height="192">
                <circle
                  cx="96"
                  cy="96"
                  r="80"
                  stroke="rgb(var(--v-theme-surface-container-highest))"
                  stroke-width="12"
                  fill="none"
                />
                <circle
                  cx="96"
                  cy="96"
                  r="80"
                  stroke="url(#gradient)"
                  stroke-width="12"
                  fill="none"
                  :stroke-dasharray="circumference"
                  :stroke-dashoffset="circumference - (currentBatteryPercentage / 100) * circumference"
                  stroke-linecap="round"
                />
                <defs>
                  <linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" stop-color="rgb(var(--v-theme-primary))" />
                    <stop offset="100%" stop-color="rgb(var(--v-theme-primary-container))" />
                  </linearGradient>
                </defs>
              </svg>
              <div class="absolute inset-0 flex flex-col items-center justify-center">
                <div class="headline-xl">{{ currentBatteryPercentage }}%</div>
                <div class="label-sm text-on-surface-variant">SOC</div>
              </div>
            </div>
          </div>

          <div class="grid grid-cols-2 gap-4 mb-6">
            <div>
              <div class="label-sm text-on-surface-variant mb-2">Leistung</div>
              <div class="headline-md">{{ activeSession.wallbox_power }} kW</div>
            </div>
            <div>
              <div class="label-sm text-on-surface-variant mb-2">Dauer</div>
              <div class="headline-md">{{ activeDuration }}</div>
            </div>
          </div>

          <v-btn
            color="error"
            block
            size="x-large"
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
        <SectionCard
          title="Schnellstart"
          icon="mdi-battery-charging-high"
          variant="primary"
        >
          <div class="space-y-6">
            <SoftWellInput
              v-model="quickStart.start_percentage"
              label="Start (%)"
              unit="%"
              type="number"
              :min="0"
              :max="100"
            />

            <div class="grid grid-cols-2 gap-3">
              <v-btn
                color="primary-container"
                block
                size="large"
                @click="saveQuickSession"
                :loading="savingQuick"
                height="52"
              >
                <v-icon start size="18">mdi-content-save</v-icon>
                Speichern
              </v-btn>
              <v-btn
                color="primary"
                block
                size="large"
                @click="startQuickCharging"
                :loading="startingQuick"
                height="52"
              >
                <v-icon start size="18">mdi-play</v-icon>
                Starten
              </v-btn>
            </div>
          </div>
        </SectionCard>
      </div>

      <div v-if="completedSessions.length > 0" class="mb-6">
        <div class="gradient-primary rounded-4xl p-6 text-white mb-6 shadow-ambient">
          <div class="flex items-center gap-2 mb-2">
            <v-icon color="white" size="18">mdi-currency-eur</v-icon>
            <p class="body-sm opacity-90">Gesamtkosten</p>
          </div>
          <p class="headline-xl">{{ totalCost.toFixed(2) }} €</p>
          <p class="body-sm opacity-75 mt-2">Aktueller Monat</p>
        </div>

        <div class="flex justify-between items-center mb-4">
          <h3 class="title">Abgeschlossene Ladevorgänge</h3>
          <v-btn
            variant="text"
            color="primary-container"
            size="small"
            @click="showAllSessions = !showAllSessions"
          >
            {{ showAllSessions ? 'Weniger' : 'Details' }}
            <v-icon end size="18">{{ showAllSessions ? 'mdi-chevron-up' : 'mdi-chevron-right' }}</v-icon>
          </v-btn>
        </div>

        <div class="space-y-3">
          <div
            v-for="session in displayedSessions"
            :key="session.id"
            class="card-tertiary p-4 flex items-center justify-between"
          >
            <div class="flex items-center gap-3">
              <div class="icon-container-sm">
                <v-icon :color="getStationColor(session)" size="20">{{ getStationIcon(session) }}</v-icon>
              </div>
              <div>
                <p class="label-lg">{{ getStationName(session) }}</p>
                <p class="body-sm text-on-surface-variant">{{ formatShortDate(session.created_at) }} • {{ session.energy_charged.toFixed(1) }} kWh</p>
              </div>
            </div>
            <div class="text-right">
              <p class="label-lg" style="color: var(--v-theme-primary-container)">{{ session.total_cost.toFixed(2) }} €</p>
              <p class="body-sm" style="color: var(--v-theme-tertiary)">Erfolgreich</p>
            </div>
          </div>
        </div>
      </div>

      <div v-else-if="!loading" class="rounded-3xl p-8 text-center" style="background: rgba(var(--v-theme-primary-fixed), 0.3)">
        <v-icon size="48" color="primary-container" class="mb-3">mdi-information-outline</v-icon>
        <p class="body-lg text-on-surface-variant">Noch keine Ladevorgänge vorhanden</p>
      </div>

      <div v-if="loading" class="text-center py-12">
        <v-progress-circular indeterminate color="primary-container" />
      </div>
    </main>

    <BottomNav active-tab="trends" />
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
  return 'primary-container'
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
