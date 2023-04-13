import { reactive } from 'vue'
import type { User } from '../model/user'
import type { Dashboard } from '../model/dashboard'
import type { ClarkError } from '../model/error'
import { watch } from 'vue'

export const user = reactive<User>({
    name: 'unknown',
    is_admin: false
})

export const selectedDashboard = reactive<{ value: Dashboard | undefined }>({
    value: undefined
})

export const dashboards = reactive<{ value: Dashboard[] }>({
    value: []
})

export const error = reactive<{ value: ClarkError | undefined, show: boolean | undefined }>({
    value: undefined,
    show: false
})

watch(() => error.value, (val, old) => {
    error.show = val ? true : false
})
