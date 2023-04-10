import { reactive } from 'vue'
import type { User } from '../model/user'
import type { Dashboard } from '../model/dashboard'

export const user = reactive<User>({
    name: 'unknown',
    is_admin: false
})

export const selectedDashboard = reactive<{ selected: string | undefined, id: string | undefined }>({
    selected: undefined,
    id: undefined
})

export const dashboards = reactive<{ value: Dashboard[] }>({
    value: []
})

export const error = reactive<{ value: any | undefined }>({
    value: undefined
})
