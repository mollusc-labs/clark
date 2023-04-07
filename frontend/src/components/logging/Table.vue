<script setup lang="ts">
import { getColor } from '@/lib/util/severityColor'
import { translateSeverity } from '@/lib/util/severityTranslation'
import type { Log } from '@/lib/model/log'

const props = defineProps<{ logs: Log[] }>()
const headers = [
    { title: 'Service', align: 'start', key: 'service_name' },
    { title: 'Hostname', align: 'start', key: 'hostname' },
    { title: 'Process ID', align: 'start', key: 'process_id' },
    { title: 'Severity', align: 'start', key: 'severity' },
    { title: 'Date', align: 'start', key: 'created_at' },
]
</script>
<template>
    <v-data-table :headers="headers" :items="props.logs" :sort-by.sync="[{ key: 'created_at', order: 'desc' }]">
        <template v-slot:item.severity="{ item }">
            <v-chip :color="getColor(item.raw.severity)" class="w-100">
                <div class="w-100 text-center">{{ translateSeverity(item.raw.severity) }}</div>
            </v-chip>
        </template>
    </v-data-table>
</template>
