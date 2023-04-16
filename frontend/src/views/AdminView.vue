<script setup lang="ts">
import type { Key } from '@/lib/model/key';
import { redirectToLogin } from '@/lib/util/redirect';
import { user } from '@/lib/util/store';
import { reactive } from 'vue';
import { onMounted } from 'vue';
import Table from '../components/admin/keys/Table.vue'

const state = reactive<{ tab: string }>({
    tab: "keys"
})

onMounted(() => {
    if (!user.is_admin) {
        redirectToLogin()
    }
})
</script>
<template>
    <v-card>
        <v-card-title>Admin Zone</v-card-title>
        <v-content class="h-screen">
            <v-tabs v-model="state.tab" bg-color="primary">
                <v-tab value="keys">Api Keys</v-tab>
                <v-tab value="users">Users</v-tab>
            </v-tabs>

            <v-card-text>
                <v-window v-model="state.tab">
                    <v-window-item value="keys">
                        <Table></Table>
                    </v-window-item>
                    <v-window-item value="users">
                        <b>TODO: Implement me</b>
                    </v-window-item>
                </v-window>
            </v-card-text>
        </v-content>
    </v-card>
</template>