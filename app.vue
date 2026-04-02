<template>
  <v-app>
    <ClientOnly>
      <v-app-bar color="primary" prominent>
        <v-app-bar-title>
          <v-btn
            variant="text"
            to="/"
            class="px-0"
            title="Startseite"
            :hover="'Startseite'"
          >
            <v-icon class="mr-2">mdi-car-electric</v-icon>
            EV Ladekosten Rechner
          </v-btn>
        </v-app-bar-title>

        <v-spacer></v-spacer>
        <v-btn
          icon
          to="/settings"
          title="Einstellungen"
          :hover="'Einstellungen'"
        >
          <v-icon>mdi-cog</v-icon>
        </v-btn>
      </v-app-bar>
    </ClientOnly>

    <v-main>
      <v-container
        :max-width="$vuetify.display.smAndDown ? '100%' : '800px'"
        class="py-4"
      >
        <NuxtPage />
      </v-container>
    </v-main>
  </v-app>
</template>
