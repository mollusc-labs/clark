export interface Log {
    id: string,
    service_name: string,
    hostname: string,
    process_id: string,
    severity: number,
    message: string,
    created_at: Date
}