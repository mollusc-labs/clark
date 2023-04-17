<script setup lang="ts">
import { getColor } from '@/lib/util/severityColor'
import { translateSeverity } from '@/lib/util/severityTranslation'
import type { Log } from '@/lib/model/log'
import { reactive } from 'vue';

const state = reactive({
    expanded: [] as string[]
});

const props = defineProps<{ logs: Log[], loading: boolean }>()
const headers = [
    { title: 'Service', align: 'start', key: 'service_name' },
    { title: 'Hostname', align: 'start', key: 'hostname' },
    { title: 'Process ID', align: 'start', key: 'process_id' },
    { title: 'Severity', align: 'start', key: 'severity' },
    { title: 'Date', align: 'start', key: 'created_at' },
    { title: '', key: 'data-table-expand' }
]

const clicked = (value: string) => {
    const index = state.expanded.indexOf(value)
    if (index === -1) {
        state.expanded.push(value)
    } else {
        state.expanded.splice(index, 1)
    }
}
</script>
<template>
    <v-card class="mt-2 p0" style="height: calc(100% - 373px)">
        <v-content height="inherit">
            <v-data-table @click:row="clicked" class="elevation-1" :headers="headers" :items="props.logs"
                items-per-page="15" fixed-header fixed-footer v-model:expanded="state.expanded" show-expand height="50vh">
                <template v-slot:header="{ props }">
                    <th v-for="head in props.headers" class="font-bold">{{ head.text }}</th>
                </template>
                <template @click.stop v-slot:item.severity="{ item }">
                    <v-chip :color="getColor(item.raw.severity)" class="w-full">
                        <div class="w-full text-center">{{ translateSeverity(item.raw.severity) }}</div>
                    </v-chip>
                </template>
                <template @click.stop v-slot:expanded-row="{ columns, item }">
                    <tr>
                        <td :colspan="columns.length">
                            <p class="text-gray-600">{{ item.raw.message }}</p>
                        </td>
                    </tr>
                </template>
            </v-data-table>
        </v-content>
    </v-card>
</template>
