<script setup lang="ts">
import { reactive } from 'vue'
import Table from './Table.vue'
import Overview from './Overview.vue'
import type { User } from '@/lib/model/user';

const state = reactive<{ selectedUser: User | undefined }>({
    selectedUser: undefined
})
</script>
<template>
    <v-card>
        <Overview :user="state.selectedUser"></Overview>
    </v-card>
    <v-card class="mt-2">
        <Table :selectFunc="(user: User) => state.selectedUser = user"></Table>
    </v-card>
</template>