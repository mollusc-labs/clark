<script setup lang="ts">
import { reactive } from 'vue';

const state = reactive({
  matcher: "",
  result: ""
})

const request = () => {
  fetch('/api/test/keys', {
    method: 'POST',
    body: JSON.stringify({ matcher: state.matcher }),
    headers: {
      'Content-Type': 'application/json'
    }
  })
    .then(res => {
      return res.json();
    })
    .then(json => {
      state.result = json.toString();
    })
    .catch(() => state.result = 'It went wrong')
}
</script>

<template>
  <main>
    <input type="text" v-model="state.matcher" />
    <button @click="() => request()">Fire away</button>
    <div>
      {{ state.result }}
    </div>
  </main>
</template>
