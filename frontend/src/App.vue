<script setup lang="ts">
import { reactive, watch } from 'vue'
import { selectedDashboard, user } from '@/lib/util/store'
import { onMounted } from 'vue'
import { redirectToLogin } from './lib/util/redirect'
import type { User } from './lib/model/user'
import type { Dashboard } from './lib/model/dashboard'
import { get, post } from './lib/util/http'

const DEFAULT_DASHBOARD: string = 'default'

const state = reactive<{ dashboards: Dashboard[], loading: boolean, addDashboardDisabled: boolean }>({
  dashboards: [],
  loading: true,
  addDashboardDisabled: false
})

const selectDashboard = ({ query, id }: Dashboard) => {
  selectedDashboard.selected = query
  selectedDashboard.id = id
}

const newDashboard = () => {
  state.addDashboardDisabled = true;
  try {
    post<Dashboard>('/api/dashboards', {
      name: 'New Dashboard',
      query: '?size=100'
    } as Dashboard)
      .then((json: Dashboard) => {
        state.dashboards.push(json)
        selectedDashboard.id = json.id
        selectedDashboard.selected = json.query
      })
  } finally {
    state.addDashboardDisabled = false
  }

}

onMounted(() => {
  Promise.all([
    get<User>('/api/users/identify').then(t => { if (t) return t; else throw Error() }),
    get<Dashboard[]>('/api/dashboards')
  ]).then(([identified, dashboards]) => {
    user.is_admin = identified.is_admin ? true : false // is_admin is 0 or 1
    user.name = identified.name
    state.dashboards = dashboards
    if (state.dashboards.length) {
      selectDashboard(dashboards[0])
    }
    state.loading = false;
  }).catch(redirectToLogin)
})
</script>

<template>
  <v-card>
    <v-layout wrap>
      <v-navigation-drawer>
        <v-list class="max-h-screen" nav>
          <v-list-item>{{ user.name }}'s Dashboards</v-list-item>
          <v-list-item v-if="!state.loading">
            <v-list class="overflow-y-auto" style="max-height: 80vh">
              <v-list-item v-for="db in state.dashboards" @click="() => selectDashboard(db)" :title="db.name"
                :value="db.query" :active="selectedDashboard.id === db.id"
                class="text-semibold overflow-ellipsis"></v-list-item>
            </v-list>
          </v-list-item>
          <v-list-item v-if="state.loading">
            <center class="m-auto self-center">
              <v-progress-circular indeterminate color="primary"></v-progress-circular>
            </center>
          </v-list-item>
          <v-list-item class="align-center justify-center" v-if="!state.loading">
            <div class="m-3">
              <v-btn icon="mdi-plus" class="elevation-1" :disabled="state.addDashboardDisabled" size="small"
                @click="() => newDashboard()">
                <v-icon icon="mdi-plus"></v-icon>
                <v-tooltip activator="parent" location="bottom" text="Add dashboard"></v-tooltip>
              </v-btn>
            </div>
          </v-list-item>
          <div class="h-full flex flex-column justify-end">
            <hr class="mt-auto">
            <v-list-item class="justify-self-end justify-center">
              <div class="flex justify-between w-full">
                <RouterLink to="/admin" class="block mr-8 underline text-blue-500" v-if="user.is_admin">
                  Admin Zone
                </RouterLink>
                <a href="https://github.com/mollusc-labs/clark" class="block underline text-blue-500">Help</a>
              </div>
            </v-list-item>
          </div>
        </v-list>
      </v-navigation-drawer>
      <v-main>
        <v-container v-if="!state.loading" class="w-fill h-screen align-center m-0" fluid>
          <RouterView />
        </v-container>
        <v-container v-if="state.loading" class="w-fill h-screen align-center m-0 flex">
          <center class="m-auto self-center">
            <v-progress-circular indeterminate color="primary" size="70"></v-progress-circular>
          </center>
        </v-container>
      </v-main>
    </v-layout>
  </v-card>
</template>

<style scoped></style>
