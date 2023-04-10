import { reactive, ref } from 'vue'
import type { Ref } from 'vue'
import type { User } from '../model/user'

export const user = reactive<User>({
    name: 'unknown',
    is_admin: false
})

export const selectedDashboard = reactive<{ selected: string | undefined, id: string | undefined }>({
    selected: undefined,
    id: undefined
})


export const error = reactive<{ value: any | undefined }>({
    value: undefined
})
