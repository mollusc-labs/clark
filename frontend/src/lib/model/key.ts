import type { User } from "./user";

export interface Key {
    created_by: User,
    value: string,
    id: string,
    matcher: string
}