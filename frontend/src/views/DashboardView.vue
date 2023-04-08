<script setup lang="ts">
import { onMounted, reactive } from 'vue'
import { latestLogWebSocket } from '@/lib/util/webSocket'
import { time } from '@/lib/util/time'
import { dashboard } from '@/lib/util/store'
import Table from '@/components/logging/Table.vue'
import type { Log } from '@/lib/model/log'

const state = reactive({
  matcher: "",
  logs: [] as Log[],
  latestLogDate: time(),
  loading: true,
  pageSize: 20
})

const update = (size: number) => {
  state.loading = true;
  fetch('/api/test/logs/latest' + dashboard.selected) // Apply query params
    .then(res => {
      return res.json()
    })
    .then((json: Log[]) => {
      state.logs = json

      latestLogWebSocket.removeEventListener('message', () => { });
      latestLogWebSocket.addEventListener('message', (message) => {
        const newLogs: Log[] = JSON.parse(message.data)
        if (!newLogs.length) {
          return
        }

        const logs: Log[] = [...state.logs, ...newLogs];

        if (logs.length > size) {
          state.logs = logs.slice(logs.length - size, logs.length);
        } else {
          state.logs = logs
        }
      })

      state.loading = false;
    })
    .catch(() => console.error('Something went wrong loading logs'))
}

onMounted(() => {
  update(state.pageSize);
  setInterval(() => {
    if (!state.loading) {
      latestLogWebSocket.send(JSON.stringify({ date: state.latestLogDate, pageSize: state.pageSize }))
      state.latestLogDate = time()
    }
  }, 2500)
});
</script>

<template>
  <main>
    <Table :page-func="update" :loading="state.loading" :logs="state.logs"></Table>
  </main>
</template>
