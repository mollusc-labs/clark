<script setup lang="ts">
import type { Log } from '@/lib/model/log';
import { computed } from 'vue';
import { reactive } from 'vue';

const props = defineProps<{ logs: Log[], loading: boolean }>();

const state = reactive({
    labels: [...new Set(props.logs.map(({ created_at }) => created_at.toString().split(' ')[1]))],
});

const values = computed(() => {
    return state.labels.reduce((acc: number[], curr: string) => {
        return [...acc, props.logs.filter(({ created_at }) => created_at.toString().split(' ')[0] === curr).length];
    }, [] as number[])
});

</script>
<template>
    <div class="align-center justify-center flex">
        <v-progress-circular indeterminate color="primary" v-if="loading"></v-progress-circular>
    </div>
    <v-sheet class="v-sheet--offset" max-width="calc(100% - 32px)" v-if="!loading">
        <v-sparkline :labels="state.labels" :value="values" :gradient="['blue', 'green', 'yellow', 'orange', 'red']"
            color="white" type="trend" line-width="2" padding="16" line-cap="round" width="2" auto-draw></v-sparkline>
    </v-sheet>
</template>