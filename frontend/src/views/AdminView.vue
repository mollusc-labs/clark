<script setup lang="ts">
import type { Key } from '@/lib/model/key';
import { redirectToLogin } from '@/lib/util/redirect';
import { user } from '@/lib/util/store';
import { reactive } from 'vue';
import { onMounted } from 'vue';
import Table from '../components/admin/keys/Table.vue'
import { get } from '@/lib/util/http';

const state = reactive<{ keys: Key[], loading: boolean }>({
    keys: [],
    loading: true
})

onMounted(() => {
    if (!user.is_admin) {
        redirectToLogin()
    }

    get<Key[]>('/api/keys')
        .then(keys => {
            state.keys = keys
            state.loading = false
        })
})
</script>
<template>
    <v-card>
        <v-card-title>Admin Zone</v-card-title>
        <v-content class="h-screen">
            <Table :keys="state.keys" :loading="state.loading"></Table>
        </v-content>
    </v-card>
</template>