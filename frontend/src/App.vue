<script setup lang="ts">
import { reactive } from 'vue'
import { dashboard, user } from '@/lib/util/store'
import { onMounted } from 'vue'
import { redirectToLogin } from './lib/util/redirect'
import type { User } from './lib/model/user'
import type { Dashboard } from './lib/model/dashboard'

const DEFAULT_DASHBOARD: string = 'default'

const state = reactive<{ dashboards: Dashboard[], selectedDashboard: string }>({
  selectedDashboard: DEFAULT_DASHBOARD,
  dashboards: [{
    id: DEFAULT_DASHBOARD,
    name: 'Overview',
    query: '?size=100'
  }]
})

const selectDashboard = ({ query, id }: Dashboard) => {
  dashboard.selected = query
  state.selectedDashboard = id
}

onMounted(() => {
  selectDashboard(state.dashboards[0]);
  fetch('/api/users/identify')
    .then(res => {
      return res.json()
    })
    .then((json: User) => {
      user.is_admin = json.is_admin ? true : false // is_admin is 0 or 1
      user.name = json.name
    })
    .catch(redirectToLogin)
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
              :value="db.query"></v-list-item>
          </v-list>
          <v-list-item class="align-center justify-center">
            <div class="m-3">
              <v-btn icon="mdi-plus" class="elevation-1" size="small">
                <v-icon icon="mdi-plus"></v-icon>
                <v-tooltip activator="parent" location="bottom" text="Add dashboard"></v-tooltip>
              </v-btn>
            </div>
          </v-list-item>
          <v-list-item></v-list-item>
        </v-list>
      </v-navigation-drawer>
      <v-main>
        <v-container class="w-fill max-h-screen align-center m-0">
          <RouterView />
        </v-container>
      </v-main>
    </v-layout>
  </v-card>
</template>

<style scoped></style>
