<script setup lang="ts">
import { onMounted, reactive } from 'vue'
import { time } from '@/lib/util/time'
import { dashboards, selectedDashboard } from '@/lib/util/store'
import Table from '@/components/logging/Table.vue'
import type { Log } from '@/lib/model/log'
import { watch } from 'vue'
import { ref } from 'vue'
import TimeGraph from '@/components/logging/TimeGraph.vue'
import { get, del, put } from '@/lib/util/http'
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

const updateRaw = () => {
  state.loading = true;
  Promise.all([
    get<Log[]>('/api/logs' + selectedDashboard.value?.query),
    get<string[]>('/api/logs/services'),
    get<string[]>('/api/logs/hosts')
  ]).then(([logs, services, hosts]) => {
    state.logs = logs
    state.service_names = services.filter(t => t)
    state.hostnames = hosts
    state.loading = false
  })
}

const update = () => {
  const newQuery: Query = degenerateQuery();
  query.date = newQuery.date;
  query.hostname = newQuery.hostname;
  query.process_id = newQuery.process_id;
  query.service_name = newQuery.service_name;
  query.size = newQuery.size;
  query.text = newQuery.text;

  if (query.severity)
    temp_severity.value = severityMap.get(query.severity) as string;

  updateRaw()
}

const generateQuery = () => {
  return ((Object.keys(query) as Array<keyof Query>)
    .filter(k => query[k] !== undefined && query[k] !== '') as Array<keyof Query>)
    .map(key => `${encodeURIComponent(key)}=${encodeURIComponent(query[key] as string)}`
    ).join('&')
}

const degenerateQuery = () => {
  const keys = [...new URLSearchParams(selectedDashboard.value?.query).entries()] as Array<[string, any]>;
  return keys.reduce((acc, [key, val]) => {
    if (key in query) {
      acc[key as keyof Query] = val;
    }
    return acc;
  }, {} as Query);
}

const updateQuery = () => {
  const q = generateQuery()
  if (selectedDashboard.value
    && q !== selectedDashboard.value?.id)
    selectedDashboard.value.query = '?' + q
}

const reset = () => {
  query.process_id = undefined
  query.service_name = undefined
  query.hostname = undefined
  query.severity = undefined
  query.text = undefined
  query.date = undefined
  query.size = 100
  temp_severity.value = 'Any'
}

const realtimeUpdate = () => {
  interval.value = setInterval(updateRaw, 2500)
}

const realtimeCancel = () => {
  clearInterval(interval.value);
}

const saveDashboard = () => {
  state.saving = true;
  put<Dashboard>(`/api/dashboards/${selectedDashboard.value?.id}`, { name: selectedDashboard.value?.name, query: '?' + generateQuery() })
    .then(dash => {
      selectedDashboard.value = dash
      dashboards.value.forEach(async t => {
        if (t.id === dash.id) {
          t.query = dash.query
          t.name = dash.name
        }
        state.saving = false;
      })
    }).catch(() => state.saving = false)
}

const deleteDashboard = () => {
  del(`/api/dashboards/${selectedDashboard.value?.id}`)
    .then(() => {
      dashboards.value = dashboards.value.filter(t => t.id !== selectedDashboard.value?.id)
      selectedDashboard.value = dashboards.value[0] || undefined
    })
}



// TODO: Don't do this if there is no dashboard selected
onMounted(() => {
  update()
});

watch(realtime, (value, old) => {
  if (value) {
    realtimeUpdate()
  } else {
    realtimeCancel()
  }
})

watch(() => selectedDashboard.value, () => {
  update()
}, { deep: true })

watch(temp_severity, (val) => {
  query.severity = invertedSeverityMap.get(val);
})
</script>

<template>
  <v-card>
    <v-card-title class="flex flex-row justify-between w-full">
      <div>
        Filters and Options
      </div>
      <div>
        <v-btn>
          <v-icon @click="() => deleteDashboard()" icon="mdi-trash-can" color="red" variant="flat"></v-icon>
        </v-btn>
      </div>
    </v-card-title>
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
            <v-btn color="primary" :disabled="!!state.saving" class="mr-2" @click="() => updateQuery()">Query</v-btn>
            <v-btn color="teal" :disabled="!!state.saving" class="mr-2" @click="() => saveDashboard()">Save</v-btn>
            <v-btn :disabled="!!state.saving" @click="() => { reset(); updateQuery() }">Reset</v-btn>
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
