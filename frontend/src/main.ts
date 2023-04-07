import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import './assets/main.css'
import 'vuetify/styles'
import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'
import { VDataTable } from 'vuetify/labs/VDataTable'

const vuetify = createVuetify({
    components: {
        VDataTable,
        ...components
    },
    directives,
})

const app = createApp(App)

app.use(router)
app.use(vuetify)

app.mount('#app')
