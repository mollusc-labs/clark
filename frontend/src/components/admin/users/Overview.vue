<script setup lang="ts">
import type { User } from '@/lib/model/user';
import { defineProps } from 'vue'
const props = defineProps<{ user: User | undefined }>()
</script>
<template>
    <v-card :title="props.user ? props.user?.name : 'Please select a user.'">
    </v-card>
</template>