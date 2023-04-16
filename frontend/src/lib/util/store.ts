import { reactive } from 'vue'
import type { User } from '../model/user'
import type { Dashboard } from '../model/dashboard'
import type { ClarkError } from '../model/error'
import { watch } from 'vue'
import type { Key } from '../model/key'

export const user = reactive<User>({
    name: 'unknown',
    is_admin: false
})

export const selectedDashboard = reactive<{ value: Dashboard | undefined, original: Dashboard | undefined }>({
    value: undefined,
    original: undefined
})

export const dashboards = reactive<{ value: Dashboard[] }>({
    value: []
})

export const error = reactive<{ value: ClarkError | undefined, show: boolean | undefined }>({
    value: undefined,
    show: false
})

export const notice = reactive<{ value: string | undefined, show: boolean }>({
    value: undefined,
    show: false
})

watch(() => error.value, (val) => {
    error.show = val ? true : false
})

watch(() => notice.value, (val) => {
    notice.show = val ? true : false
})
