<script setup lang="ts">
import { onMounted, reactive } from 'vue'
import { latestLogWebSocket } from '@/lib/util/webSocket'
import { time } from '@/lib/util/time'
import { dashboard } from '@/lib/util/store'
import Table from '@/components/logging/Table.vue'
import type { Log } from '@/lib/model/log'
import { watch } from 'vue'
import { ref } from 'vue'
import TimeGraph from '@/components/logging/TimeGraph.vue'
import { get } from '@/lib/util/http'
import type { Query } from '@/lib/model/query'
import { severityMap } from '@/lib/util/severityTranslation'

const realtime = ref(false)
const interval = ref();

const state = reactive({
  matcher: "",
  logs: [] as Log[],
  latestLogDate: time(),
  loading: true,
  service_names: [] as string[],
  hostnames: [] as string[],
})

const query = reactive<Query>({
  size: 100,
  service_name: undefined,
  text: undefined,
  hostname: undefined,
  process_id: undefined,
  date: undefined,
  severity: undefined
})

const update = () => {
  state.loading = true;
  Promise.all([
    get<Log[]>('/api/logs' + dashboard.selected),
    get<string[]>('/api/logs/services'),
    get<string[]>('/api/logs/hosts')
  ]).then(([logs, services, hosts]) => {
    state.logs = logs
    state.service_names = services.filter(t => t)
    state.hostnames = hosts
    state.loading = false
  }).catch(console.error)
}

const updateQuery = () => {
  const q = Object.keys(query).map(key => {
    if (query[key]) {

    }
  }).join('&');

}

const reset = () => {
  query.process_id = '';
  query.hostname = '';
  updateQuery()
}

const realtimeUpdateSocket = (message: any) => {
  const newLogs: Log[] = JSON.parse(message.data) || []
  if (!newLogs.length) {
    return
  }

  const logs: Log[] = [...state.logs, ...newLogs];

  if (logs.length >= state.logs.length) {
    state.logs = logs.slice(logs.length - state.logs.length, logs.length)
  } else {
    state.logs = logs
  }
}

const realtimeUpdate = () => {
  latestLogWebSocket.addEventListener('message', realtimeUpdateSocket, false)
  interval.value = setInterval(() => {
    if (!state.loading) {
      latestLogWebSocket.send(JSON.stringify({ date: state.latestLogDate }))
      state.latestLogDate = time()
    }
  }, 2500)
}

const realtimeCancel = () => {
  latestLogWebSocket.removeEventListener('message', realtimeUpdateSocket, false)
  clearInterval(interval.value);
}

onMounted(update);
watch(realtime, (value, old) => {
  if (value) {
    realtimeUpdate()
  } else {
    realtimeCancel()
  }
})

watch(() => dashboard.selected, (value, old) => {
  if (value) {
    update()
  }
})
</script>

<template>
  <v-card title="Filters and Options">
    <v-content>
      <v-container>
        <v-switch @click.stop label="Real-time updates" v-model="realtime" color="blue"></v-switch>
        <v-row>
          <v-col cols="16" md="2">
            <v-autocomplete :items="state.service_names" v-model="query.service_name" density="compact"
              label="Service Name"></v-autocomplete>
          </v-col>
          <v-col cols="16" md="2">
            <v-autocomplete :items="state.hostnames" v-model="query.hostname" density="compact"
              label="Hostname"></v-autocomplete>
          </v-col>
          <v-col cols="16" md="2">
            <v-text-field density="compact" v-model="query.process_id" label="Process ID"></v-text-field>
          </v-col>
          <v-col cols="16" md="2">
            <v-autocomplete density="compact" :items="[...severityMap].map(t => t[1])" v-model="query.process_id"
              label="Severity"></v-autocomplete>
          </v-col>
        </v-row>
        <v-row>
          <v-col cols="16" md="4">
            <v-text-field label="Search" density="compact"></v-text-field>
          </v-col>
        </v-row>
        <v-row>
          <v-col>
            <v-btn color="primary" class="mr-2" @click="() => updateQuery()">Query</v-btn>
            <v-btn color="teal" class="mr-2">Save</v-btn>
            <v-btn>Reset</v-btn>
          </v-col>
        </v-row>
      </v-container>
    </v-content>
  </v-card>
  <v-card class="mb-2">
    <v-content>
      <TimeGraph :logs="state.logs" :loading="state.loading"></TimeGraph>
    </v-content>
  </v-card>
  <Table class="flex-grow" :loading="state.loading" :logs="state.logs"></Table>
</template>
