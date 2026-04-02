import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'
import { VProgress } from 'vuetify/labs/VProgress'

export default defineNuxtPlugin((nuxtApp) => {
  const vuetify = createVuetify({ 
    components: {
      ...components,
      VProgress
    },
    directives,
    theme: {
      defaultTheme: 'evTheme',
      themes: {
        evTheme: {
          dark: false,
          colors: {
            primary: '#00497d',
            'primary-container': '#0061a4',
            'on-primary': '#ffffff',
            'primary-fixed': '#d1e4ff',
            'primary-fixed-dim': '#9fcaff',

            secondary: '#535f70',
            'secondary-container': '#d7e3f8',
            'on-secondary': '#ffffff',
            'secondary-fixed': '#d7e3f8',

            tertiary: '#52405f',
            'tertiary-container': '#6b5778',
            'tertiary-fixed': '#f3daff',

            background: '#f8f9ff',
            surface: '#f8f9ff',
            'surface-bright': '#f8f9ff',
            'surface-dim': '#d8dae0',
            'surface-container': '#eceef3',
            'surface-container-low': '#f2f3f9',
            'surface-container-high': '#e7e8ee',
            'surface-container-highest': '#e1e2e8',
            'surface-container-lowest': '#ffffff',

            'on-surface': '#191c20',
            'on-surface-variant': '#414750',
            'on-background': '#191c20',

            outline: '#717782',
            'outline-variant': '#c1c7d2',

            error: '#ba1a1a',
            'error-container': '#ffdad6',
            'on-error': '#ffffff',

            'surface-tint': '#0061a4',
            'inverse-surface': '#2e3135',
            'inverse-on-surface': '#eff0f6',
            'inverse-primary': '#9fcaff',
          },
        },
      },
    },
    defaults: {
      VBtn: {
        style: [
          {
            textTransform: 'none',
            letterSpacing: '0',
            fontFamily: 'Manrope, sans-serif',
            fontWeight: '700',
          }
        ],
        rounded: 'xl',
      },
      VCard: {
        rounded: '4xl',
        elevation: 0,
      },
      VTextField: {
        variant: 'outlined',
        rounded: 'xl',
      },
      VSelect: {
        variant: 'outlined',
        rounded: 'xl',
      },
      VTextarea: {
        variant: 'outlined',
        rounded: 'xl',
      },
    },
  })

  nuxtApp.vueApp.use(vuetify)
})
