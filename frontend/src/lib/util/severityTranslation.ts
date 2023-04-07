import type { Severity } from "../model/severity"

const severityMap = new Map<Severity, string>([
    [0, "Emerg"],
    [1, "Alert"],
    [2, "Crit"],
    [3, "Error"],
    [4, "Warn"],
    [5, "Notice"],
    [6, "Info"],
    [7, "Debug"]
]);

export function translateSeverity(severity: Severity): string {
    return severityMap.get(severity) || 'Unknown'
}