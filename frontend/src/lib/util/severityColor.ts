import type { Severity } from "../model/severity"

export function getColor(severity: Severity): string {
    switch (severity) {
        case 7:
            return 'gray'
        case 6:
            return 'blue'
        case 5:
            return 'green'
        case 4:
            return 'yellow'
        case 3:
            return 'orange'
        case 2:
            return 'red'
        case 1:
            return 'red'
        case 0:
            return 'purple'
    }
}