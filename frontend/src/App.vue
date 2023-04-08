<script setup lang="ts">
import { reactive } from 'vue';
import { dashboard } from '@/lib/util/store'
import type { Dashboard } from './lib/model/dashboard';

const DEFAULT_DASHBOARD: string = 'default'

const state = reactive<{ dashboards: Dashboard[], selectDashboard: string }>({
  selectDashboard: DEFAULT_DASHBOARD,
  dashboards: [{
    id: DEFAULT_DASHBOARD,
    name: 'Overview',
    query: ''
  }]
})

const selectDashboard = ({ query, id }: Dashboard) => {
  dashboard.selected = query
  state.selectDashboard = id
}
</script>

<template>
  <div class="flex flex-row">
    <v-card>
      <v-layout>
        <v-navigation-drawer permanent>
          <v-list nav>
            <v-list-item>Your Dashboards</v-list-item>
            <v-list-item v-for="db in state.dashboards" @click="() => selectDashboard(db)" :title="db.name"
              :value="db.query"></v-list-item>
          </v-list>
        </v-navigation-drawer>
        <v-main style="height: 250px"></v-main>
      </v-layout>
    </v-card>
    <RouterView />
  </div>
</template>

<style scoped></style>
