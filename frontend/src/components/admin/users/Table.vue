<script setup lang="ts">
import type { User } from '@/lib/model/user';
import { get } from '@/lib/util/http';
import { onMounted, reactive } from 'vue';
import { defineProps } from 'vue'

const props = defineProps<{ selectFunc: (a: User) => void }>();
const state = reactive<{
    users: User[],
    loading: boolean
}>({
    users: [],
    loading: true
})

onMounted(() => {
    get<User[]>('/api/users')
        .then(users => {
            state.users = users
            state.loading = false
        })
})
</script>
<template></template>
