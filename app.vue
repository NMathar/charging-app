<template>
  <v-app>
    <ClientOnly>
      <v-app-bar color="primary" prominent>
        <v-app-bar-title>
          <v-icon class="mr-2">mdi-car-electric</v-icon>
          EV Ladekosten Rechner
        </v-app-bar-title>
      </v-app-bar>

      <v-navigation-drawer permanent>
        <v-list density="compact" nav>
          <v-list-item
            prepend-icon="mdi-view-dashboard"
            title="Übersicht"
            to="/"
            exact
          />
          <v-list-item
            prepend-icon="mdi-lightning-bolt"
            title="Neuer Ladevorgang"
            to="/charging"
          />
          <v-list-item
            prepend-icon="mdi-cog"
            title="Einstellungen"
            to="/settings"
          />
        </v-list>
      </v-navigation-drawer>
    </ClientOnly>

    <v-main>
      <v-container fluid>
        <NuxtPage />
      </v-container>
    </v-main>
  </v-app>
</template>
