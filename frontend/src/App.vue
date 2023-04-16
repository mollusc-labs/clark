<script setup lang="ts">
import { reactive } from 'vue'
import { selectedDashboard, user, dashboards, error, notice } from '@/lib/util/store'
import { onMounted } from 'vue'
import { redirectToLogin } from './lib/util/redirect'
import type { User } from './lib/model/user'
import type { Dashboard } from './lib/model/dashboard'
import { get, post } from './lib/util/http'
import router from './router'

const state = reactive<{ loading: boolean, addDashboardDisabled: boolean }>({
  loading: true,
  addDashboardDisabled: false
})

const selectDashboard = (d: Dashboard) => {
  if (router.currentRoute.value.fullPath !== '/dashboard') {
    router.push({ path: '/dashboard', replace: true })
  }
  selectedDashboard.value = d
}

const newDashboard = () => {
  state.addDashboardDisabled = true;
  try {
    post<Dashboard>('/api/dashboards', {
      name: 'New Dashboard',
      query: '?size=100'
    } as Dashboard)
      .then((json: Dashboard) => {
        dashboards.value.push(json)
        selectDashboard(json)
      })
  } finally {
    state.addDashboardDisabled = false
  }

}

onMounted(() => {
  Promise.all([
    get<User>('/api/users/identify'),
    get<Dashboard[]>('/api/dashboards')
  ]).then(([identified, dbs]) => {
    user.is_admin = identified.is_admin ? true : false // is_admin is 0 or 1
    user.name = identified.name
    dashboards.value = dbs
    if (dashboards.value.length) {
      selectDashboard(dashboards.value[0])
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
              <v-list-item v-for="db in dashboards.value" @click="() => selectDashboard(db)" :title="db.name"
                :value="db.query" :active="selectedDashboard.value?.id === db.id"
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
                <RouterLink to="/admin" class="block mr-8 underline text-primary" v-if="user.is_admin">
                  Admin Zone
                </RouterLink>
                <a href="https://github.com/mollusc-labs/clark" class="block underline text-primary">Help</a>
              </div>
            </v-list-item>
          </div>
        </v-list>
      </v-navigation-drawer>
      <v-main>
        <v-container v-if="!state.loading" class="w-full h-screen overflow-auto align-center m-0" fluid>
          <v-content v-if="dashboards.value.length">
            <RouterView />
          </v-content>
          <v-content v-if="!dashboards.value.length" class="block w-full h-100">
            <p class="gray-500">
              Please create a new dashboard using the (+) on the left side of your screen.
            </p>
          </v-content>
        </v-container>
        <v-container v-if="state.loading" class="w-fill h-screen align-center m-0 flex">
          <center class="m-auto self-center">
            <v-progress-circular indeterminate color="primary" size="70"></v-progress-circular>
          </center>
        </v-container>
        <v-snackbar color="red" v-model="error.show">
          {{ error.value }}
          <template v-slot:actions>
            <v-btn color="pink" variant="text" @click="() => error.value = undefined">
              Close
            </v-btn>
          </template>
        </v-snackbar>
        <v-snackbar color="primary" v-model="notice.show">
          {{ notice.value }}
          <template v-slot:actions>
            <v-btn variant="text" @click="() => notice.value = ''">
              Dismiss
            </v-btn>
          </template>
        </v-snackbar>
      </v-main>
    </v-layout>
  </v-card>
</template>

<style scoped></style>
