import { reactive } from 'vue'
import type { User } from '../model/user'

export const user = reactive<User>({
    name: 'unknown',
    is_admin: false
})

export const dashboard = reactive({
    selected: '?size=100'
})
