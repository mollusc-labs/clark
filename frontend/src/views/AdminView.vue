<script setup lang="ts">
import type { Key } from '@/lib/model/key';
import { redirectToLogin } from '@/lib/util/redirect';
import { user } from '@/lib/util/store';
import { reactive } from 'vue';
import { onMounted } from 'vue';
import KeyTable from '../components/admin/keys/Table.vue'
import Users from '../components/admin/users/View.vue'

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
        <v-container class="h-screen">
            <v-tabs v-model="state.tab" bg-color="primary">
                <v-tab value="keys">Api Keys</v-tab>
                <v-tab value="users">Users</v-tab>
            </v-tabs>
            <v-card-text>
                <v-window v-model="state.tab">
                    <v-window-item value="keys">
                        <KeyTable></KeyTable>
                    </v-window-item>
                    <v-window-item value="users">
                        <Users></Users>
                    </v-window-item>
                </v-window>
            </v-card-text>
        </v-container>
    </v-card>
</template>