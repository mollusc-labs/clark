<script setup lang="ts">
import type { User } from '@/lib/model/user';
import { defineProps } from 'vue'
const props = defineProps<{ user: User | undefined }>()
</script>
<template>
    <v-card v-if="props.user">
    </v-card>
    <v-card v-if="!props.user" title="Please select a user">
    </v-card>
</template>