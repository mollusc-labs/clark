<script setup lang="ts">
import { onMounted, reactive } from 'vue'
import { latestLogWebSocket } from '@/lib/util/webSocket'
import { time } from '@/lib/util/time'
import { dashboard } from '@/lib/util/store'
import Table from '@/components/logging/Table.vue'
import type { Log } from '@/lib/model/log'
import { onUpdated } from 'vue'
import { watch } from 'vue'
import { ref } from 'vue'

const SIZE = 100

const realtime = ref(false)
const interval = ref();

const state = reactive({
  matcher: "",
  logs: [] as Log[],
  latestLogDate: time(),
  loading: true
})

const update = () => {
  state.loading = true;
  fetch('/api/logs' + dashboard.selected) // Apply query params
    .then(res => {
      return res.json()
    })
    .then((json: Log[]) => {
      state.logs = json
      state.loading = false;
    })
    .catch(() => console.error('Something went wrong loading logs'))
}

const getLogs = () => {
  if (!state.logs.length) {
    update()
  }
}

const realtimeUpdateSocket = (message: any) => {
  const newLogs: Log[] = JSON.parse(message.data) || []
  if (!newLogs.length) {
    return
  }

  const logs: Log[] = [...state.logs, ...newLogs];

  if (logs.length > state.logs.length) {
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

onMounted(getLogs);
watch(realtime, (value, old) => {
  if (value) {
    realtimeUpdate()
  } else {
    realtimeCancel()
  }
})
</script>

<template>
  <main class="max-h-screen">
    <v-card>
      <v-switch label="Realtime Update" v-model="realtime"></v-switch>
    </v-card>
    <Table :page-func="update" :loading="state.loading" :logs="state.logs"></Table>
  </main>
</template>
