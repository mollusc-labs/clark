<script setup lang="ts">
import type { Key } from '@/lib/model/key'
import { reactive } from 'vue'
import { post } from '@/lib/util/http'
import { notice } from '@/lib/util/store';

const props = defineProps<{ keys: Key[], loading: boolean }>()

const headers = [
    { title: 'Key', align: 'start', key: 'value' },
    { title: 'Matches', align: 'start', key: 'matcher' }
]

const newKey = reactive<{ matcher: string | undefined }>({
    matcher: undefined
})

const state = reactive({
    showDialog: false,
    lockDialog: false,
    loading: false
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


const copyText = (text: string) => {
    navigator.clipboard.writeText(text)
        .then(() => {
            notice.value = "Copied API key to clipboard"
        })
}

</script>
<template>
    <v-card class="mt-2 p0">
        <v-content height="inherit">
            <v-data-table class="elevation-1" :loading="props.loading" :headers="headers" :items="props.keys"
                items-per-page="15" fixed-header fixed-footer height="100%">
                <template v-slot:top>
                    <v-toolbar class="bg-white">
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
                        <v-btn color="bg-primary" dark class="mb-2" @click="() => state.showDialog = true">
                            New API Key
                        </v-btn>
                    </v-toolbar>
                </template>
                <template @click.stop v-slot:item.value="{ item }">
                    <v-hover>
                        <template v-slot:default="{ isHovering, props }">
                            <p v-bind="props" class="overflow-auto" :class="isHovering ? 'text-primary' : ''"
                                @click="() => copyText(item.raw.value)">
                                {{ item.raw.value }}
                                <v-icon v-show="isHovering" icon="mdi-content-copy" size="sm"></v-icon>
                            </p>
                        </template>
                    </v-hover>
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