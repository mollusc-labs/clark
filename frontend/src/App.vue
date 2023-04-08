<script setup lang="ts">
import { reactive } from 'vue';
import type { Dashboard } from './lib/model/dashboard';

const state = reactive<{ dashboards: Dashboard[] }>({
  dashboards: [{
    id: 'idempotent',
    name: 'Overview',
    query: ''
  }]
})
</script>

<template>
  <div class="flex flex-row">
    <v-card>
      <v-layout>
        <v-navigation-drawer permanent>
          <v-list nav>
            <v-list-item>Your Dashboards</v-list-item>
            <v-list-item v-for="db in state.dashboards" :title="db.name" :value="db.query"></v-list-item>
          </v-list>
        </v-navigation-drawer>
        <v-main style="height: 250px"></v-main>
      </v-layout>
    </v-card>
    <RouterView />
  </div>
</template>

<style scoped></style>
