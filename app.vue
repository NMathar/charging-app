<template>
  <v-app>
    <ClientOnly>
      <v-app-bar color="primary" prominent>
        <v-app-bar-title>
          <v-icon class="mr-2">mdi-car-electric</v-icon>
          EV Ladekosten Rechner
        </v-app-bar-title>

        <v-spacer></v-spacer>
        <v-btn icon to="/settings" title="Einstellungen" :hover="'Einstellungen'">
          <v-icon>mdi-cog</v-icon>
        </v-btn>
      </v-app-bar>
    </ClientOnly>

    <v-main>
      <v-container fluid>
        <NuxtPage />
      </v-container>
    </v-main>
  </v-app>
</template>
