<script setup lang="ts">
import { onMounted } from 'vue';
import { RouterLink, RouterView } from 'vue-router'
import { user } from './lib/store'

onMounted(() => {
  document.querySelector('.logo')?.setAttribute('src', '/assets/logo.svg')
  let user_name = document.querySelector('#user')?.getAttribute('value')
  if (!user_name && import.meta.env.PROD) {
    window.location.replace('/');
  } else {
    user.name = JSON.parse(user_name || '{ "name": "Unknown" }').name
  }
});

</script>

<template>
  <header>
    <img alt="Vue logo" class="logo" width="125" height="125" />
    <div class="wrapper">
      <nav>
        <RouterLink to="/dashboard">Home</RouterLink>
        <RouterLink to="/about">About</RouterLink>
      </nav>
    </div>
  </header>
  <RouterView />
</template>

<style scoped>
header {
  line-height: 1.5;
  max-height: 100vh;
}

.logo {
  display: block;
  margin: 0 auto 2rem;
}

nav {
  width: 100%;
  font-size: 12px;
  text-align: center;
  margin-top: 2rem;
}

nav a.router-link-exact-active {
  color: var(--color-text);
}

nav a.router-link-exact-active:hover {
  background-color: transparent;
}

nav a {
  display: inline-block;
  padding: 0 1rem;
  border-left: 1px solid var(--color-border);
}

nav a:first-of-type {
  border: 0;
}
</style>
