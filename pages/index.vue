<template>
  <div class="min-h-screen pb-32" style="background: var(--v-theme-surface)">
    <main class="pt-24 px-4 max-w-lg mx-auto">
      <header class="mb-6">
        <h2 class="headline-lg">Übersicht</h2>
      </header>

      <div v-if="activeSession" class="card-primary mb-6">
        <div class="px-6 pt-5">
          <div class="badge-info">
            <span>Laufender Ladevorgang</span>
          </div>
          <div class="text-right">
            <v-icon color="primary-container " size="18"
              >mdi-lightning-bolt</v-icon
            >
          </div>
        </div>

        <div class="pa-6 text-center">
          <h3 class="headline-sm mb-6">Wallbox</h3>

          <v-progress
            :model-value="(currentBatteryPercentage / 100) * 100"
            label="Laden..."
            hide-label
            details-position="bottom"
          >
            <template v-slot:default="{ percent }">
              <v-progress-circular
                :model-value="percent"
                color="primary-container"
                size="150"
                width="15"
                rounded
              >
                <div class="d-flex align-baseline mr-n3">
                  <div class="text-headline-large text-medium-emphasis">
                    {{ percent.toFixed() }}
                  </div>
                  <span class="ml-1">%</span>
                </div>
              </v-progress-circular>
            </template>

            <template v-slot:value="{ percent }">
              <div class="text-body-medium">
                <v-scroll-y-transition mode="out-in">
                  <div v-if="percent > 75" key="finalizing">Fertig...</div>
                  <div v-else key="loading">Laden...</div>
                </v-scroll-y-transition>
              </div>
            </template>
          </v-progress>

          <v-row class="mb-6">
            <v-col class="text-center">
              <div class="label-sm text-on-surface-variant mb-2">Leistung</div>
              <div class="headline-md">
                {{ activeSession.wallbox_power }} kW
              </div>
            </v-col>
            <v-col class="text-center">
              <div class="label-sm text-on-surface-variant mb-2">Dauer</div>
              <div class="headline-md">{{ activeDuration }}</div>
            </v-col>
          </v-row>

          <v-btn
            color="error"
            block
            class="my-4"
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
            <div class="grid grid-cols-2 ga3">
              <v-btn
                color="primary-container"
                block
                class="my-4"
                size="large"
                @click="openManualDialog"
                :loading="savingQuick"
                height="52"
              >
                <v-icon start size="18">mdi-content-save</v-icon>
                Manuell speichern
              </v-btn>
              <v-btn
                color="primary"
                block
                class="my-4"
                size="large"
                @click="openTimeDialog"
                :loading="startingQuick"
                height="52"
              >
                <v-icon start size="18">mdi-play</v-icon>
                Zeitbasiert starten
              </v-btn>
            </div>
          </div>
        </SectionCard>
      </div>

      <ChargingDialog
        v-model="showDialog"
        :mode="dialogMode"
        :initial-data="dialogData"
        :title="dialogTitle"
        :confirm-text="dialogConfirmText"
        @confirm="handleDialogConfirm"
      />

      <div v-if="completedSessions.length > 0" class="mb-6">
        <div
          class="gradient-primary rounded-4xl pa-6 text-white mb-6 shadow-ambient"
        >
          <div class="mb-2">
            <v-icon color="white" size="18">mdi-currency-eur</v-icon>
            <p class="body-sm opacity-90">Gesamtkosten</p>
          </div>
          <p class="headline-xl">
            {{
              totalCost.toLocaleString("de-DE", {
                style: "currency",
                currency: "EUR",
              })
            }}
          </p>
          <p class="body-sm opacity-75 mt-2">Aktueller Monat</p>
        </div>

        <div class="mb-4">
          <h3 class="title">Abgeschlossene Ladevorgänge</h3>
          <v-btn
            variant="text"
            color="primary-container"
            size="small"
            @click="showAllSessions = !showAllSessions"
          >
            {{ showAllSessions ? "Weniger" : "Details" }}
            <v-icon end size="18">{{
              showAllSessions ? "mdi-chevron-up" : "mdi-chevron-right"
            }}</v-icon>
          </v-btn>
        </div>

        <div>
          <v-card
            variant="tonal"
            class="mb-4"
            :color="index % 2 === 0 ? 'secondary' : 'tertiary-container'"
            v-for="(session, index) in displayedSessions"
            :key="session.id"
          >
            <v-card-text>
              <v-row class="mb-1">
                <div class="icon-container-sm">
                  <v-icon :color="getStationColor(session)" size="20">{{
                    getStationIcon(session)
                  }}</v-icon>
                </div>
                <div>
                  <p class="text-lg-title-large text-sm-title-medium">
                    {{ getStationName(session) }}
                  </p>
                  <p
                    class="text-lg-body-large text-sm-body-medium text-on-surface-variant"
                  >
                    {{ formatShortDateWithTime(session.created_at) }} Uhr •
                    {{ session.energy_charged.toFixed(1) }} kWh
                  </p>
                  <p class="text-lg-body-large text-sm-body-medium text-on-surface-variant">
                    {{ session.start_percentage }}% → {{ session.end_percentage }}%
                  </p>
                </div>
              </v-row>
              <div class="text-right">
                <p
                  class="text-lg-headline-medium text-sm-headline-small"
                  style="color: var(--v-theme-primary-container)"
                >
                  {{
                    session.total_cost.toLocaleString("de-DE", {
                      style: "currency",
                      currency: "EUR",
                    })
                  }}
                </p>
                <p class="body-sm text-on-surface-variant">Erfolgreich</p>
              </div>
            </v-card-text>
          </v-card>
        </div>
      </div>

      <div
        v-else-if="!loading"
        class="rounded-3xl pa-8 text-center"
        style="background: rgba(var(--v-theme-primary-fixed), 0.3)"
      >
        <v-icon size="48" color="primary-container" class="mb-3"
          >mdi-information-outline</v-icon
        >
        <p class="body-lg text-on-surface-variant">
          Noch keine Ladevorgänge vorhanden
        </p>
      </div>

      <div v-if="loading" class="text-center py-12">
        <v-progress-circular indeterminate color="primary-container" />
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
interface ChargingSession {
  id: string;
  start_percentage: number;
  end_percentage: number;
  start_time: string | null;
  end_time: string | null;
  battery_capacity: number;
  electricity_price: number;
  wallbox_power: number;
  wallbox_loss: number;
  energy_charged: number;
  total_cost: number;
  status: string;
  created_at: string;
}

const supabase = useSupabaseClient();

const sessions: Ref<ChargingSession[]> = ref([]);
const loading = ref(true);
const activeDuration = ref("0:00");
const currentBatteryPercentage = ref(0);
const stoppingCharge = ref(false);
const showAllSessions = ref(false);
const savingQuick = ref(false);
const startingQuick = ref(false);
let durationInterval: NodeJS.Timeout | null = null;

const showDialog = ref(false);
const dialogMode = ref<'time' | 'manual'>('time');
const dialogData = ref({
  start_percentage: 20,
  end_percentage: 80,
  wallbox_power: 11,
  wallbox_loss: 10,
  electricity_price: 0.32,
});

const settings = ref({
  battery_capacity: 77,
  electricity_price: 0.32,
  wallbox_power: 11,
  wallbox_loss: 10,
});

const circumference = 2 * Math.PI * 80;

const activeSession = computed(() => {
  return sessions.value.find((s: any) => s.status === "active");
});

const completedSessions = computed(() => {
  return sessions.value.filter((s: any) => s.status === "completed");
});

const displayedSessions = computed(() => {
  return showAllSessions.value
    ? completedSessions.value
    : completedSessions.value.slice(0, 3);
});

const totalCost = computed(() => {
  return completedSessions.value.reduce(
    (sum, session) => sum + Number(session.total_cost),
    0,
  );
});

const updateActiveDuration = () => {
  if (activeSession.value) {
    const startTime = new Date(
      activeSession.value.start_time || activeSession.value.created_at,
    );
    const now = new Date();
    const diff = now.getTime() - startTime.getTime();
    const hours = Math.floor(diff / (1000 * 60 * 60));
    const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((diff % (1000 * 60)) / 1000);
    activeDuration.value = `${hours.toString().padStart(2, "0")}:${minutes.toString().padStart(2, "0")}:${seconds.toString().padStart(2, "0")}`;

    const hoursElapsed = diff / (1000 * 60 * 60);
    const chargedKwh = hoursElapsed * Number(activeSession.value.wallbox_power);
    const batteryCapacity = Number(activeSession.value.battery_capacity);
    const wallboxLoss = Number(activeSession.value.wallbox_loss);
    const chargedPercentage =
      (chargedKwh / batteryCapacity) * 100 * (100 / (100 + wallboxLoss));
    currentBatteryPercentage.value = Math.min(
      100,
      Math.round(
        Number(activeSession.value.start_percentage) + chargedPercentage,
      ),
    );
  }
};

const dialogTitle = computed(() => {
  return dialogMode.value === 'time'
    ? 'Zeitbasierten Ladevorgang starten'
    : 'Ladevorgang manuell speichern';
});

const dialogConfirmText = computed(() => {
  return dialogMode.value === 'time' ? 'Starten' : 'Speichern';
});

const loadSettings = async () => {
  const { data, error } = await supabase
    .from("settings")
    .select("*")
    .maybeSingle();

  if (data && !error) {
    settings.value = {
      battery_capacity: Number(data.battery_capacity),
      electricity_price: Number(data.electricity_price),
      wallbox_power: Number(data.wallbox_power),
      wallbox_loss: Number(data.wallbox_loss),
    };

    dialogData.value = {
      start_percentage: 20,
      end_percentage: 80,
      wallbox_power: Number(data.wallbox_power),
      wallbox_loss: Number(data.wallbox_loss),
      electricity_price: Number(data.electricity_price),
    };
  }
};

const loadSessions = async () => {
  loading.value = true;
  const { data, error } = await supabase
    .from("charging_sessions")
    .select("*")
    .order("created_at", { ascending: false });

  if (error) {
    console.error("Error loading sessions:", error);
  } else {
    sessions.value = data || [];
  }
  loading.value = false;
};

const openManualDialog = () => {
  dialogMode.value = 'manual';
  dialogData.value = {
    start_percentage: 20,
    end_percentage: 80,
    wallbox_power: settings.value.wallbox_power,
    wallbox_loss: settings.value.wallbox_loss,
    electricity_price: settings.value.electricity_price,
  };
  showDialog.value = true;
};

const openTimeDialog = () => {
  dialogMode.value = 'time';
  dialogData.value = {
    start_percentage: 20,
    end_percentage: 80,
    wallbox_power: settings.value.wallbox_power,
    wallbox_loss: settings.value.wallbox_loss,
    electricity_price: settings.value.electricity_price,
  };
  showDialog.value = true;
};

const handleDialogConfirm = async (data: any) => {
  if (dialogMode.value === 'manual') {
    await saveManualSession(data);
  } else {
    await startTimeBasedCharging(data);
  }
  showDialog.value = false;
};

const saveManualSession = async (data: any) => {
  savingQuick.value = true;

  const percentageDiff = data.end_percentage - data.start_percentage;
  const netEnergy = (settings.value.battery_capacity * percentageDiff) / 100;
  const energyWithLoss = netEnergy * (1 + data.wallbox_loss / 100);
  const totalCost = energyWithLoss * data.electricity_price;

  const sessionData = {
    start_percentage: data.start_percentage,
    end_percentage: data.end_percentage,
    battery_capacity: settings.value.battery_capacity,
    electricity_price: data.electricity_price,
    wallbox_power: data.wallbox_power,
    wallbox_loss: data.wallbox_loss,
    energy_charged: energyWithLoss,
    total_cost: totalCost,
    status: "completed",
  };

  const { error } = await supabase
    .from("charging_sessions")
    .insert([sessionData]);

  if (!error) {
    await loadSessions();
  }

  savingQuick.value = false;
};

const startTimeBasedCharging = async (data: any) => {
  startingQuick.value = true;

  const sessionData = {
    start_percentage: data.start_percentage,
    end_percentage: data.start_percentage,
    battery_capacity: settings.value.battery_capacity,
    electricity_price: data.electricity_price,
    wallbox_power: data.wallbox_power,
    wallbox_loss: data.wallbox_loss,
    energy_charged: 0,
    total_cost: 0,
    start_time: new Date().toISOString(),
    status: "active",
  };

  const { error } = await supabase
    .from("charging_sessions")
    .insert([sessionData]);

  if (!error) {
    await loadSessions();
  }

  startingQuick.value = false;
};

const stopActiveCharging = async () => {
  if (!activeSession.value) return;

  stoppingCharge.value = true;

  const percentageDiff =
    currentBatteryPercentage.value -
    Number(activeSession.value.start_percentage);
  const netEnergy =
    (Number(activeSession.value.battery_capacity) * percentageDiff) / 100;
  const energyWithLoss =
    netEnergy * (1 + Number(activeSession.value.wallbox_loss) / 100);
  const totalCost =
    energyWithLoss * Number(activeSession.value.electricity_price);

  const { error } = await supabase
    .from("charging_sessions")
    .update({
      end_percentage: currentBatteryPercentage.value,
      end_time: new Date().toISOString(),
      energy_charged: energyWithLoss,
      total_cost: totalCost,
      status: "completed",
    })
    .eq("id", activeSession.value.id);

  if (!error) {
    await loadSessions();
  }

  stoppingCharge.value = false;
};

const formatShortDateWithTime = (dateString: string) => {
  // if date is older then one year show year, otherwise show day and month
  const today = new Date();

  const date = new Date(dateString);

  if (date.getFullYear() !== today.getFullYear()) {
    return date.toLocaleDateString("de-DE", {
      day: "2-digit",
      month: "short",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  } else {
    return date.toLocaleDateString("de-DE", {
      day: "2-digit",
      month: "short",
      hour: "2-digit",
      minute: "2-digit",
    });
  }
};

const getStationName = (session: any) => {
  return "Wallbox";
};

const getStationIcon = (session: any) => {
  return "mdi-home";
};

const getStationColor = (session: any) => {
  return "primary-container";
};

onMounted(() => {
  loadSettings();
  loadSessions();
  durationInterval = setInterval(() => {
    updateActiveDuration();
  }, 1000);
});

onUnmounted(() => {
  if (durationInterval) {
    clearInterval(durationInterval);
  }
});
</script>
