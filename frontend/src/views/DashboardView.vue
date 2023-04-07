<script setup lang="ts">
import { onMounted, reactive } from 'vue'
import { latestLogWebSocket } from '@/lib/util/webSocket.js'
import { time } from '@/lib/util/time.js'

const state = reactive({
  matcher: "",
  logs: "",
  latestLogDate: time()
})

const request = () => {
  fetch('/api/test/logs/latest')
    .then(res => {
      return res.json();
    })
    .then(json => {
      state.logs = JSON.stringify(json);
    })
    .catch(() => state.logs = 'It went wrong')
}

onMounted(() => {
  latestLogWebSocket.addEventListener('message', (message) => {
    state.logs = message.data
  })

  setInterval(() => {
    latestLogWebSocket.send(JSON.stringify({ date: state.latestLogDate }))
    state.latestLogDate = time()
  }, 2500);
});
</script>

<template>
  <main>
    <input type="text" v-model="state.matcher" />
    <button class="btn" @click="() => request()">Fire away</button>
    <div class="text-white">
      {{ state.logs }}
    </div>
  </main>
</template>
