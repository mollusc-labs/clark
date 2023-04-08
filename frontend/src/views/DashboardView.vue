<script setup lang="ts">
import { onMounted, reactive } from 'vue'
import { latestLogWebSocket } from '@/lib/util/webSocket'
import { time } from '@/lib/util/time'
import { dashboard } from '@/lib/util/store'
import Table from '@/components/logging/Table.vue'
import type { Log } from '@/lib/model/log'

const SIZE = 100

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

      latestLogWebSocket.removeEventListener('message', () => { });
      latestLogWebSocket.addEventListener('message', (message) => {
        const newLogs: Log[] = JSON.parse(message.data) || []
        if (!newLogs.length) {
          return
        }

        const logs: Log[] = [...state.logs, ...newLogs];

        if (logs.length > state.logs.length) {
          state.logs = logs.slice(logs.length - state.logs.length, logs.length);
        } else {
          state.logs = logs
        }
      })

      state.loading = false;
    })
    .catch(() => console.error('Something went wrong loading logs'))
}

const getLogsAndRunSocket = () => {
  update();

  setInterval(() => {
    if (!state.loading) {
      latestLogWebSocket.send(JSON.stringify({ date: state.latestLogDate }))
      state.latestLogDate = time()
    }
  }, 2500)
}

onMounted(getLogsAndRunSocket);
</script>

<template>
  <main>
    <Table :page-func="update" :loading="state.loading" :logs="state.logs"></Table>
  </main>
</template>
