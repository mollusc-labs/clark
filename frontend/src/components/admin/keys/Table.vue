<script setup lang="ts">
import type { Key } from '@/lib/model/key'
import { reactive } from 'vue'
import { get, post } from '@/lib/util/http'

const props = defineProps<{ keys: Key[], loading: boolean }>()

const headers = [
    { title: 'Key', align: 'start', key: 'value' },
    { title: 'Matches', align: 'start', key: 'matcher' },
    { title: 'Created By', align: 'start', key: 'created_by' }
]

const newKey = reactive<{ matcher: string | undefined }>({
    matcher: undefined
})

const state = reactive({
    showDialog: false,
    lockDialog: false
})

const closeDialog = () => {
    state.showDialog = false;
}

const saveKey = () => {
    state.lockDialog = true;
    try {
        post<Key>('/api/keys', { matcher: newKey.matcher })
            .then(key => {
                props.keys.push(key)
            })
    } finally {
        state.lockDialog = false;
    }
}

</script>
<template>
    <v-card class="mt-2 p0">
        <v-content height="inherit">
            <v-data-table class="elevation-1" :loading="props.loading" :headers="headers" :items="props.keys"
                items-per-page="15" fixed-header fixed-footer height="100%">
                <template v-slot:top>
                    <v-toolbar class="bg-white">
                        <v-toolbar-title>
                            API Keys
                        </v-toolbar-title>
                        <v-dialog v-model="state.showDialog" max-width="500px">
                            <v-card>
                                <v-card-title>
                                    <span class="text-h5">Create a new API key</span>
                                </v-card-title>
                                <v-card-text>
                                    <v-container>
                                        <v-row>
                                            <v-col>
                                                <v-text-field v-model="newKey.matcher" label="Matcher"></v-text-field>
                                            </v-col>
                                        </v-row>
                                    </v-container>
                                </v-card-text>
                                <v-card-actions>
                                    <v-spacer></v-spacer>
                                    <v-btn color="blue-darken-1" :disabled="state.lockDialog" variant="text"
                                        @click="closeDialog">
                                        Cancel
                                    </v-btn>
                                    <v-btn color="blue-darken-1" :disabled="state.lockDialog || !newKey.matcher"
                                        variant="text" @click="saveKey">
                                        Save
                                    </v-btn>
                                </v-card-actions>
                            </v-card>
                        </v-dialog>
                        <v-btn color="primary" dark class="mb-2" @click="() => state.showDialog = true">
                            New API Key
                        </v-btn>
                    </v-toolbar>
                </template>
                <template v-slot:item.actions="{ item }">
                    <v-icon size="small">
                        mdi-delete
                    </v-icon>
                </template>
                <template v-slot:header="{ props }">
                    <th v-for="head in props.headers" class="font-bold">{{ head.text }}</th>
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