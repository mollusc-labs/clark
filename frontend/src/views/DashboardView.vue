<script setup lang="ts">
import { onMounted, reactive } from 'vue'
import { latestLogWebSocket } from '@/lib/webSocket'
import { time } from '@/lib/time'

const state = reactive({
  matcher: "",
  result: "",
  latestLogDate: time()
})

const request = () => {
  fetch('/api/test/logs/latest')
    .then(res => {
      return res.json();
    })
    .then(json => {
      state.result = JSON.stringify(json);
    })
    .catch(() => state.result = 'It went wrong')
}

onMounted(() => {
  latestLogWebSocket.addEventListener('message', (message) => {
    state.result = message.data
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
      {{ state.result }}
    </div>
  </main>
</template>
