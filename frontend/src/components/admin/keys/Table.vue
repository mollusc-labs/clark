<script setup lang="ts">
import type { Key } from '@/lib/model/key'
import { reactive } from 'vue'
import { del, get, post } from '@/lib/util/http'
import { notice } from '@/lib/util/store';
import { onMounted } from 'vue';

const headers = [
    { title: 'Key', align: 'start', key: 'value' },
    { title: 'Matches', align: 'start', key: 'matcher' },
    { title: '', align: 'start', key: 'actions' }
]

const newKey = reactive<{ matcher: string | undefined }>({
    matcher: undefined
})

const state = reactive({
    showSaveDialog: false,
    showDeleteDialog: false,
    deleteItem: '',
    lockDialog: false,
    loading: true,
    keys: [] as Key[]
})

const closeDialog = () => {
    state.showSaveDialog = false
    state.showDeleteDialog = false
    state.deleteItem = ''
}

const saveKey = () => {
    state.lockDialog = true
    try {
        post<Key>('/api/keys', { matcher: newKey.matcher })
            .then(key => {
                state.keys.unshift(key)
            })
    } finally {
        state.lockDialog = false
        closeDialog()
    }
}

const deleteKey = () => {
    state.lockDialog = true
    const id = state.deleteItem;
    try {
        del('/api/keys/' + id)
            .then(() => {
                state.keys = state.keys.filter(t => t.id !== id)
            })
    } finally {
        state.lockDialog = false
        closeDialog()
    }
}

const copyText = (text: string) => {
    navigator.clipboard.writeText(text)
        .then(() => {
            notice.value = "Copied API key to clipboard"
        })
}

onMounted(() => {
    state.loading = true
    try {
        get<Key[]>('/api/keys')
            .then(ks => {
                state.keys = ks
            })
    } finally {
        state.loading = false
    }

})

</script>
<template>
    <v-card class="mt-2 p0">
        <v-content height="inherit">
            <v-data-table class="elevation-1" :loading="state.loading" :headers="headers" :items="state.keys"
                items-per-page="15" fixed-header fixed-footer height="100%">
                <template v-slot:top>
                    <v-toolbar class="bg-white">
                        <v-dialog v-model="state.showSaveDialog" max-width="500px">
                            <v-card class="p-3">
                                <v-card-title>
                                    Create a new API key
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
                                    <v-btn :disabled="state.lockDialog" variant="text" @click="closeDialog">
                                        Cancel
                                    </v-btn>
                                    <v-btn color="primary" :disabled="state.lockDialog || !newKey.matcher" variant="text"
                                        @click="saveKey">
                                        Save
                                    </v-btn>
                                </v-card-actions>
                            </v-card>
                        </v-dialog>
                        <v-btn color="primary" class="mb-2 primary" @click="() => state.showSaveDialog = true">
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
                    <div class="text-truncate hover:text-red-600">
                        <v-icon small @click="() => { state.deleteItem = item.raw.id; state.showDeleteDialog = true }">
                            mdi-delete
                        </v-icon>
                    </div>
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
            <v-dialog v-model="state.showDeleteDialog" max-width="500px">
                <v-card>
                    <v-card-title>Delete</v-card-title>
                    <v-card-text>Are you sure you'd like to delete this API key? This will cause all logging attempts using
                        it do be ignored.</v-card-text>
                    <v-card-actions>
                        <v-btn text :disabled="state.lockDialog" @click="state.showDeleteDialog = false">Close</v-btn>
                        <v-btn color="red" text :disabled="state.lockDialog || !state.deleteItem"
                            @click="deleteKey">Delete</v-btn>
                    </v-card-actions>
                </v-card>
            </v-dialog>
        </v-content>
    </v-card>
</template>