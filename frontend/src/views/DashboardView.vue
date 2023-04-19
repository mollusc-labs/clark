<script setup lang="ts">
import { time } from '@/lib/util/time'
import { dashboards, selectedDashboard } from '@/lib/util/store'
import Table from '@/components/logging/Table.vue'
import type { Log } from '@/lib/model/log'
import { watch, ref, onMounted, reactive } from 'vue'
import { get, del, put } from '@/lib/util/http'
import type { Query } from '@/lib/model/query'
import { severityMap, invertedSeverityMap } from '@/lib/util/severityTranslation'
import type { Dashboard } from '@/lib/model/dashboard'

const realtime = ref(false)
const interval = ref();
const tempSeverity = ref('Any');

const severities = [[undefined, 'Any'], ...severityMap].map(t => t[1]);

const state = reactive({
  logs: [] as Log[],
  latestLogDate: time(),
  loading: true,
  service_names: [] as string[],
  hostnames: [] as string[],
  saving: false,
  showEditName: false,
  editingName: false,
  newName: '' as string | undefined,
})

const timeQuery = reactive({
  toDate: undefined as string | undefined,
  toTime: undefined as string | undefined,
  fromDate: undefined as string | undefined,
  fromTime: undefined as string | undefined
})

const query = reactive<Query>({
  size: 100,
  service_name: undefined,
  text: undefined,
  hostname: undefined,
  process_id: undefined,
  severity: undefined,
  to: undefined,
  from: undefined
})

const executeUpdate = async () => {
  const [logs, services, hosts] = await Promise.all([
    get<Log[]>('/api/logs' + selectedDashboard.value?.query),
    get<string[]>('/api/logs/services'),
    get<string[]>('/api/logs/hosts')
  ])

  state.logs = logs
  state.service_names = services.filter(t => t)
  state.hostnames = hosts
  state.loading = false
}

const update = () => {
  state.loading = true
  state.newName = selectedDashboard.value?.name

  const newQuery: Query = degenerateQuery();
  query.to = newQuery.to
  query.from = newQuery.from
  query.hostname = newQuery.hostname
  query.process_id = newQuery.process_id
  query.service_name = newQuery.service_name
  query.size = newQuery.size
  query.text = newQuery.text

  if (query.severity)
    tempSeverity.value = severityMap.get(query.severity) as string;

  if (query.to !== undefined) {
    const [date, time] = query.to.split(/\s/)
    timeQuery.toDate = date
    timeQuery.toTime = time
  } else {
    timeQuery.toDate = undefined
    timeQuery.toTime = undefined
  }

  if (query.from !== undefined) {
    const [date, time] = query.from.split(/\s/)
    timeQuery.fromDate = date
    timeQuery.fromTime = time
  } else {
    timeQuery.fromDate = undefined
    timeQuery.fromTime = undefined
  }

  executeUpdate()
}

const generateTime = () => {
  // NOTE: Perl's time goes in unix sec not unix ms
  if (timeQuery.fromDate) {
    const from = timeQuery.fromDate + ' ' + (timeQuery.fromTime || '00:00')
    if (from)
      query.from = from
  } else {
    query.from = undefined
  }

  if (timeQuery.toDate) {
    const to = timeQuery.toDate + ' ' + (timeQuery.toTime || '00:00')
    if (to)
      query.to = to
  } else {
    query.to = undefined
  }
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
      acc[key as keyof Query] = val
    }
    return acc;
  }, {} as Query);
}

const updateQuery = () => {
  const q = generateQuery()
  if (selectedDashboard.value
    && q !== selectedDashboard.value?.query) {
    selectedDashboard.value.query = '?' + q
    update()
  }
}

const reset = () => {
  query.process_id = undefined
  query.service_name = undefined
  query.hostname = undefined
  query.severity = undefined
  query.text = undefined
  query.to = undefined
  query.from = undefined
  query.size = 100
  tempSeverity.value = 'Any'
}

const realtimeUpdate = () => {
  interval.value = setInterval(executeUpdate, 2500)
}

const realtimeCancel = () => {
  clearInterval(interval.value);
}

const saveDashboard = () => {
  state.saving = true;
  put<Dashboard>(`/api/dashboards/${selectedDashboard.value?.id}`, { name: state.newName, query: '?' + generateQuery() })
    .then(dash => {
      selectedDashboard.value = dash
      dashboards.value.forEach(async t => {
        if (t.id === dash.id) {
          t.query = dash.query
          t.name = dash.name
        }
        state.saving = false;
      })
      state.editingName = false;
      state.showEditName = false;
    }).catch(() => state.saving = false)
}

const deleteDashboard = () => {
  console.log(selectedDashboard.value)
  del(`/api/dashboards/${selectedDashboard.value?.id}`)
    .then(() => {
      dashboards.value = dashboards.value.filter(t => t.id !== selectedDashboard.value?.id)
      selectedDashboard.value = dashboards.value[0] || undefined
    })
}

onMounted(() => {
  if (selectedDashboard.value)
    update()

  watch(realtime, (value, old) => {
    if (value) {
      realtimeUpdate()
    } else {
      realtimeCancel()
    }
  })

  watch(() => selectedDashboard.value, () => {
    state.logs = []
    reset()
    update()
  })

  watch(tempSeverity, val => {
    query.severity = invertedSeverityMap.get(val);
  })

  watch(() => state.editingName, () => {
    if (selectedDashboard.value) {
      selectedDashboard.value.name = state.newName || ''
    }
  })

  watch(() => timeQuery, generateTime, { deep: true })
});
</script>

<template>
  <v-card style="">
    <v-card-title class="flex flex-row justify-between w-full">
      <div v-show="!state.editingName" @mouseover="state.showEditName = true" @mouseleave="state.showEditName = false"
        @click="state.editingName = true" :color="state.showEditName ? 'primary' : 'black'" class="cursor-pointer w-fit">
        {{ selectedDashboard.value?.name }}
        <v-icon :color="state.showEditName ? 'primary' : 'disabled'" icon="mdi-pencil" size="sm"></v-icon>
      </div>
      <div v-show="state.editingName && selectedDashboard.value">
        <v-text-field density="compact" v-model="state.newName"
          v-on:keyup.enter="() => state.editingName = false"></v-text-field>
      </div>
    </v-card-title>
    <v-container @click="state.editingName = false">
      <v-row>
        <v-col cols="16" md="2">
          <v-switch @click.stop label="Real-time updates" v-model="realtime" color="blue"></v-switch>
        </v-col>
      </v-row>
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
          <v-select density="compact" item-text="name" item-value="severity" :items="severities" v-model="tempSeverity"
            label="Severity"></v-select>
        </v-col>
        <v-col cols="16" md="2">
          <v-text-field v-model="timeQuery.fromDate" density="compact" type="date" label="From"
            class="w-fill"></v-text-field>
        </v-col>
        <v-col cols="16" md="2">
          <v-text-field :disabled="!timeQuery.fromDate" v-model="timeQuery.fromTime" density="compact" type="time"
            class="w-fill"></v-text-field>
        </v-col>
      </v-row>
      <v-row>
        <v-col cols="16" md="6">
          <v-text-field label="Search" density="compact" v-model="query.text"></v-text-field>
        </v-col>
        <v-col cols="16" md="2">
          <v-text-field density="compact" v-model="query.size" type="number" label="Query Size"></v-text-field>
        </v-col>
        <v-col cols="16" md="2">
          <v-text-field v-model="timeQuery.toDate" density="compact" type="date" label="To" class="w-fill"></v-text-field>
        </v-col>
        <v-col cols="16" md="2">
          <v-text-field :disabled="!timeQuery.toDate" v-model="timeQuery.toTime" density="compact" type="time"
            class="w-fill"></v-text-field>
        </v-col>
      </v-row>
      <v-row>
        <v-col class="flex flex-row justify-between">
          <div>
            <v-btn color="primary" :disabled="!!state.saving" class="mr-2" @click="() => updateQuery()">
              Query
              <v-tooltip activator="parent" location="bottom" text="Search for logs that meet the criteria"></v-tooltip>
            </v-btn>
            <v-btn color="teal" :disabled="!!state.saving" class="mr-2" @click="() => saveDashboard()">
              Save
              <v-tooltip activator="parent" location="bottom" text="Save this dashboard"></v-tooltip>
            </v-btn>
            <v-btn :disabled="!!state.saving" @click="() => { reset(); updateQuery() }">
              Clear
              <v-tooltip activator="parent" location="bottom" text="Clear all filters"></v-tooltip>
            </v-btn>
          </div>
          <v-btn @click="() => deleteDashboard()">
            <v-icon icon="mdi-trash-can" color="red" variant="flat"></v-icon>
            <v-tooltip activator="parent" location="bottom" text="Delete this dashboard"></v-tooltip>
          </v-btn>
        </v-col>
      </v-row>
    </v-container>
  </v-card>
  <div class="h-fit w-full">
    <Table v-if="!state.loading" :logs="state.logs"></Table>
    <v-progress-circular indeterminate color="primary" size="70" class="block m-auto"
      v-if="state.loading"></v-progress-circular>
  </div>
</template>
