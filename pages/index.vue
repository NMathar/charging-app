<template>
  <div>
    <v-row>
      <v-col cols="12">
        <h1 class="text-h4 mb-4">Ladevorgang Übersicht</h1>
      </v-col>
    </v-row>

    <v-row v-if="activeSession">
      <v-col cols="12">
        <v-card color="success" variant="tonal">
          <v-card-title class="d-flex align-center">
            <v-icon icon="mdi-lightning-bolt" class="mr-2" />
            Laufender Ladevorgang
          </v-card-title>
          <v-card-text>
            <v-row dense>
              <v-col cols="6" sm="3">
                <div class="text-caption">Gestartet</div>
                <div class="text-h6">{{ formatDate(activeSession.start_time || activeSession.created_at) }}</div>
              </v-col>
              <v-col cols="6" sm="3">
                <div class="text-caption">Start Ladung</div>
                <div class="text-h6">{{ activeSession.start_percentage }}%</div>
              </v-col>
              <v-col cols="6" sm="3">
                <div class="text-caption">Aktuell</div>
                <div class="text-h6">{{ currentBatteryPercentage }}%</div>
              </v-col>
              <v-col cols="6" sm="3">
                <div class="text-caption">Dauer</div>
                <div class="text-h6">{{ activeDuration }}</div>
              </v-col>
            </v-row>
            <v-divider class="my-4" />
            <v-row dense>
              <v-col cols="12" sm="6">
                <v-btn
                  color="error"
                  block
                  @click="stopActiveCharging"
                  prepend-icon="mdi-stop"
                  :loading="stoppingCharge"
                >
                  Ladevorgang beenden
                </v-btn>
              </v-col>
              <v-col cols="12" sm="6">
                <v-btn
                  color="primary"
                  variant="outlined"
                  block
                  :to="'/charging'"
                  prepend-icon="mdi-pencil"
                >
                  Details anzeigen
                </v-btn>
              </v-col>
            </v-row>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

    <v-row v-if="loading">
      <v-col cols="12" class="text-center">
        <v-progress-circular indeterminate color="primary" />
      </v-col>
    </v-row>

    <v-row v-else-if="completedSessions.length === 0">
      <v-col cols="12">
        <v-alert type="info" variant="tonal">
          Noch keine Ladevorgänge vorhanden. Erstellen Sie einen neuen Ladevorgang.
        </v-alert>
      </v-col>
    </v-row>

    <v-row v-else>
      <v-col cols="12">
        <v-card>
          <v-card-title>
            <v-row align="center">
              <v-col>Abgeschlossene Ladevorgänge</v-col>
              <v-col cols="auto">
                <v-chip color="primary" variant="elevated">
                  Gesamt: {{ totalCost.toFixed(2) }} €
                </v-chip>
              </v-col>
            </v-row>
          </v-card-title>
          <v-divider />
          <v-table>
            <thead>
              <tr>
                <th>Datum</th>
                <th>Start %</th>
                <th>Ende %</th>
                <th>Geladen (kWh)</th>
                <th>Kosten (€)</th>
                <th>Dauer</th>
                <th>Aktionen</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="session in completedSessions" :key="session.id">
                <td>{{ formatDate(session.created_at) }}</td>
                <td>{{ session.start_percentage }}%</td>
                <td>{{ session.end_percentage }}%</td>
                <td>{{ session.energy_charged.toFixed(2) }} kWh</td>
                <td>{{ session.total_cost.toFixed(2) }} €</td>
                <td>{{ formatDuration(session) }}</td>
                <td>
                  <v-btn
                    icon="mdi-delete"
                    size="small"
                    variant="text"
                    color="error"
                    @click="deleteSession(session.id)"
                  />
                </td>
              </tr>
            </tbody>
          </v-table>
        </v-card>
      </v-col>
    </v-row>

    <v-row v-if="completedSessions.length > 0">
      <v-col cols="12" md="6">
        <v-card>
          <v-card-title>Statistiken</v-card-title>
          <v-card-text>
            <v-list>
              <v-list-item>
                <v-list-item-title>Durchschnittliche Ladung</v-list-item-title>
                <v-list-item-subtitle>
                  {{ averageEnergy.toFixed(2) }} kWh
                </v-list-item-subtitle>
              </v-list-item>
              <v-list-item>
                <v-list-item-title>Durchschnittliche Kosten</v-list-item-title>
                <v-list-item-subtitle>
                  {{ averageCost.toFixed(2) }} €
                </v-list-item-subtitle>
              </v-list-item>
              <v-list-item>
                <v-list-item-title>Anzahl Ladevorgänge</v-list-item-title>
                <v-list-item-subtitle>
                  {{ completedSessions.length }}
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

const sessions = ref([])
const loading = ref(true)
const activeDuration = ref('0:00')
const currentBatteryPercentage = ref(0)
const stoppingCharge = ref(false)
let durationInterval: NodeJS.Timeout | null = null

const activeSession = computed(() => {
  return sessions.value.find((s: any) => s.status === 'active')
})

const completedSessions = computed(() => {
  return sessions.value.filter((s: any) => s.status === 'completed')
})

const totalCost = computed(() => {
  return completedSessions.value.reduce((sum, session) => sum + Number(session.total_cost), 0)
})

const averageEnergy = computed(() => {
  if (completedSessions.value.length === 0) return 0
  const total = completedSessions.value.reduce((sum, session) => sum + Number(session.energy_charged), 0)
  return total / completedSessions.value.length
})

const averageCost = computed(() => {
  if (completedSessions.value.length === 0) return 0
  return totalCost.value / completedSessions.value.length
})

const updateActiveDuration = () => {
  if (activeSession.value) {
    const startTime = new Date(activeSession.value.start_time || activeSession.value.created_at)
    const now = new Date()
    const diff = now.getTime() - startTime.getTime()
    const hours = Math.floor(diff / (1000 * 60 * 60))
    const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
    activeDuration.value = `${hours}:${minutes.toString().padStart(2, '0')}`

    const hoursElapsed = diff / (1000 * 60 * 60)
    const chargedKwh = hoursElapsed * Number(activeSession.value.wallbox_power)
    const batteryCapacity = Number(activeSession.value.battery_capacity)
    const wallboxLoss = Number(activeSession.value.wallbox_loss)
    const chargedPercentage = (chargedKwh / batteryCapacity) * 100 * (100 / (100 + wallboxLoss))
    currentBatteryPercentage.value = Math.min(100, Math.round(Number(activeSession.value.start_percentage) + chargedPercentage))
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

const deleteSession = async (id: string) => {
  if (!confirm('Möchten Sie diesen Ladevorgang wirklich löschen?')) return

  const { error } = await supabase
    .from('charging_sessions')
    .delete()
    .eq('id', id)

  if (error) {
    console.error('Error deleting session:', error)
  } else {
    await loadSessions()
  }
}

const formatDate = (dateString: string) => {
  const date = new Date(dateString)
  return date.toLocaleString('de-DE', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const formatDuration = (session: any) => {
  if (!session.start_time || !session.end_time) return '-'

  const start = new Date(session.start_time)
  const end = new Date(session.end_time)
  const durationMs = end.getTime() - start.getTime()
  const hours = Math.floor(durationMs / (1000 * 60 * 60))
  const minutes = Math.floor((durationMs % (1000 * 60 * 60)) / (1000 * 60))

  if (hours > 0) {
    return `${hours}h ${minutes}m`
  }
  return `${minutes}m`
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

  if (error) {
    console.error('Error stopping charging session:', error)
  } else {
    await loadSessions()
  }

  stoppingCharge.value = false
}

onMounted(() => {
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
