<script setup lang="ts">
import { onMounted, reactive } from 'vue'
import { latestLogWebSocket } from '@/lib/util/webSocket'
import { time } from '@/lib/util/time'
import { dashboards, selectedDashboard } from '@/lib/util/store'
import Table from '@/components/logging/Table.vue'
import type { Log } from '@/lib/model/log'
import { watch } from 'vue'
import { ref } from 'vue'
import TimeGraph from '@/components/logging/TimeGraph.vue'
import { get, post, put } from '@/lib/util/http'
import type { Query } from '@/lib/model/query'
import { severityMap, invertedSeverityMap } from '@/lib/util/severityTranslation'
import type { Dashboard } from '@/lib/model/dashboard'

const realtime = ref(false)
const interval = ref();
const temp_severity = ref('Any');

const severities = [[undefined, 'Any'], ...severityMap].map(t => t[1]);

const state = reactive({
  logs: [] as Log[],
  latestLogDate: time(),
  loading: true,
  service_names: [] as string[],
  hostnames: [] as string[],
  saving: false
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
    get<Log[]>('/api/logs' + selectedDashboard.selected),
    get<string[]>('/api/logs/services'),
    get<string[]>('/api/logs/hosts')
  ]).then(([logs, services, hosts]) => {
    state.logs = logs
    state.service_names = services.filter(t => t)
    state.hostnames = hosts
    state.loading = false
  })
}

const generateQuery = () => {
  return ((Object.keys(query) as Array<keyof Query>)
    .filter(k => query[k]) as Array<keyof Query>)
    .map(key => `${encodeURIComponent(key)}=${encodeURIComponent(query[key] as string)}`
    ).join('&')
}

const degenerateQuery = () => {
  const keys = [...new URLSearchParams(selectedDashboard.selected).entries()] as Array<[string, any]>;
  return keys.reduce((acc, [key, val]) => {
    if (key in query) {
      acc[key as keyof Query] = val;
    }
    return acc;
  }, {} as Query);
}

const updateQuery = () => {
  const q = generateQuery()
  if (q !== selectedDashboard.selected)
    selectedDashboard.selected = '?' + q
}

const reset = () => {
  query.process_id = undefined
  query.service_name = undefined
  query.hostname = undefined
  query.severity = undefined
  query.text = undefined
  query.date = undefined
  query.size = 100
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
    update()
  }, 2500)
}

const realtimeCancel = () => {
  latestLogWebSocket.removeEventListener('message', realtimeUpdateSocket, false)
  clearInterval(interval.value);
}

const saveDashboard = () => {
  put<Dashboard>(`/api/dashboards/${selectedDashboard.id}`, { name: 'dashboard', query: '?' + generateQuery() })
    .then(dash => {
      selectedDashboard.selected = dash.query
      selectedDashboard.id = dash.id
      dashboards.value.forEach(async t => {
        if (t.id === dash.id) {
          t.query = dash.query
          t.name = dash.name
        }
      })
    })
}

// TODO: Don't do this if there is no dashboard selected
onMounted(update);

watch(realtime, (value, old) => {
  if (value) {
    realtimeUpdate()
  } else {
    realtimeCancel()
  }
})

watch(() => selectedDashboard.selected, (value, old) => {
  if (value) {
    update()
    const newQuery: Query = degenerateQuery();
    query.date = newQuery.date;
    query.hostname = newQuery.hostname;
    query.process_id = newQuery.process_id;
    query.service_name = newQuery.service_name;
    query.severity = newQuery.severity;
    query.size = newQuery.size;
    query.text = newQuery.text;
  }
})

watch(temp_severity, (val, old) => {
  query.severity = invertedSeverityMap.get(val);
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
              label="Service Name"></v-autocomplete> </v-col>
          <v-col cols="16" md="2">
            <v-autocomplete :items="state.hostnames" v-model="query.hostname" density="compact"
              label="Hostname"></v-autocomplete>
          </v-col>
          <v-col cols="16" md="2">
            <v-text-field density="compact" v-model="query.process_id" label="Process ID"></v-text-field>
          </v-col>
          <v-col cols="16" md="2">
            <v-select density="compact" item-text="name" item-value="severity" :items="severities" v-model="temp_severity"
              label="Severity"></v-select>
          </v-col>
        </v-row>
        <v-row>
          <v-col cols="16" md="4">
            <v-text-field label="Search" density="compact" v-model="query.text"></v-text-field>
          </v-col>
          <v-col cols="16" md="2">
            <v-text-field density="compact" v-model="query.size" type="number" label="Query Size"></v-text-field>
          </v-col>
        </v-row>
        <v-row>
          <v-col>
            <v-btn color="primary" class="mr-2" @click="() => updateQuery()">Query</v-btn>
            <v-btn color="teal" class="mr-2" @click="() => saveDashboard()">Save</v-btn>
            <v-btn @click="() => { reset(); updateQuery() }">Reset</v-btn>
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
