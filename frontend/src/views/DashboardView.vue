<script setup lang="ts">
import { onMounted, reactive } from 'vue'
import { latestLogWebSocket } from '@/lib/util/webSocket'
import { time } from '@/lib/util/time'
import Table from '@/components/logging/Table.vue'
import type { Log } from '@/lib/model/log'

const state = reactive({
  matcher: "",
  logs: [] as Log[],
  latestLogDate: time(),
  pageSize: 20
})

onMounted(() => {
  fetch('/api/test/logs/latest')
    .then(res => {
      return res.json()
    })
    .then((json: Log[]) => {
      state.logs = json
    })
    .catch(() => console.error('Something went wrong loading logs'))

  latestLogWebSocket.addEventListener('message', (message) => {
    const newLogs: Log[] = JSON.parse(message.data)
    if (!newLogs.length) {
      return
    }

    const oldLogsLength: number = state.logs.length
    const logs: Log[] = [...state.logs, ...newLogs];

    if (logs.length > state.pageSize) {
      state.logs = logs.slice(logs.length - state.pageSize, logs.length);
    } else {
      state.logs = logs
    }
  })

  setInterval(() => {
    latestLogWebSocket.send(JSON.stringify({ date: state.latestLogDate, pageSize: state.pageSize }))
    state.latestLogDate = time()
  }, 2500)
});
</script>

<template>
  <main>
    <input type="text" v-model="state.matcher" />
    <Table :logs="state.logs"></Table>
  </main>
</template>
