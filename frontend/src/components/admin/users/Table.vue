<script setup lang="ts">
import type { User } from '@/lib/model/user';
import { defineProps } from 'vue'

const props = defineProps<{ selectFunc: (a: User) => void }>();
</script>
<template></template>
