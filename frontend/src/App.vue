<script setup lang="ts">
import { reactive } from 'vue'
import { dashboard, user } from '@/lib/util/store'
import { onMounted } from 'vue'
import { redirectToLogin } from './lib/util/redirect'
import type { User } from './lib/model/user'
import type { Dashboard } from './lib/model/dashboard'
import type { Log } from './lib/model/log'

const DEFAULT_DASHBOARD: string = 'default'

const state = reactive<{ dashboards: Dashboard[], selectedDashboard: string, loading: boolean }>({
  selectedDashboard: DEFAULT_DASHBOARD,
  dashboards: [],
  loading: true
})

const selectDashboard = ({ query, id }: Dashboard) => {
  dashboard.selected = query
  state.selectedDashboard = id
}

onMounted(() => {
  Promise.all([
    fetch('/api/users/identify')
      .then(res => {
        return res.json()
      })
      .then((json: User) => {
        user.is_admin = json.is_admin ? true : false // is_admin is 0 or 1
        user.name = json.name
      })
      .catch(redirectToLogin),
    fetch('/api/dashboards')
      .then(res => {
        return res.json()
      })
      .then((json: Dashboard[]) => {
        state.dashboards = json;
        if (state.dashboards.length)
          dashboard.selected = state.dashboards[0].query;
        state.loading = false;
      })
      .catch(console.error)
  ])
})
</script>

<template>
  <v-card>
    <v-layout wrap>
      <v-navigation-drawer>
        <v-list class="max-h-screen" nav>
          <v-list-item>{{ user.name }}'s Dashboards</v-list-item>
          <v-list class="overflow-y-auto" style="max-height: 80vh">
            <v-list-item v-for="db in state.dashboards" @click="() => selectDashboard(db)" :title="db.name"
              :value="db.query" :active="state.selectedDashboard === db.id"
              class="text-semibold overflow-ellipsis"></v-list-item>
          </v-list>
          <v-list-item class="align-center justify-center">
            <div class="m-3">
              <v-btn icon="mdi-plus" class="elevation-1" size="small">
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
        <v-container v-if="state.loading">
          <v-spinner></v-spinner>
        </v-container>
      </v-main>
    </v-layout>
  </v-card>
</template>

<style scoped></style>
