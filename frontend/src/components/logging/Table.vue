<script setup lang="ts">
import { getColor } from '@/lib/util/severityColor'
import { translateSeverity } from '@/lib/util/severityTranslation'
import type { Log } from '@/lib/model/log'

const props = defineProps<{ logs: Log[], loading: boolean, pageFunc: (size: number) => void }>()
const headers = [
    { title: 'Service', align: 'start', key: 'service_name' },
    { title: 'Hostname', align: 'start', key: 'hostname' },
    { title: 'Process ID', align: 'start', key: 'process_id' },
    { title: 'Severity', align: 'start', key: 'severity' },
    { title: 'Date', align: 'start', key: 'created_at' },
    { title: '', key: 'data-table-expand' }
]
let expanded: string[] = []

const clicked = (value: string) => {
    const index = expanded.indexOf(value)
    if (index === -1) {
        expanded.push(value)
    } else {
        expanded.splice(index, 1)
    }
}
</script>
<template>
    <v-data-table class="elevation-1" :loading="props.loading" :headers="headers" :items="props.logs"
        :sort-by.sync="[{ key: 'created_at', order: 'desc' }]" items-per-page="15" :rows-per-page-items="[20, 30, 40, 50]"
        v-model:expanded="expanded" show-expand height="100%">
        <template v-slot:item.severity="{ item }">
            <v-chip :color="getColor(item.raw.severity)" class="w-100">
                <div class="w-100 text-center">{{ translateSeverity(item.raw.severity) }}</div>
            </v-chip>
        </template>
        <template v-slot:expanded-item="{ columns, item }">
            <tr>
                <td :colspan="columns.length">
                    <p class="text-gray-600">{{ item.raw.message }}</p>
                </td>
            </tr>
        </template>
    </v-data-table>
</template>
