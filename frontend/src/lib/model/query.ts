import type { Severity } from "./severity";

export interface Query {
    size?: number,
    service_name?: string,
    hostname?: string,
    text?: string, // Full-text ftw
    process_id?: string,
    severity?: Severity,
    to?: string,
    from?: string
}