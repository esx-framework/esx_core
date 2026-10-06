export function validateAccessIdentifier(value: string, allowedTypes: string[]): string | null {
    const normalized = value.trim().toLowerCase()
    const match = /^([a-z0-9]+):[\w._-]+$/.exec(normalized)

    if (normalized.length > 128 || !match) {
        return 'Expected format "prefix:value", e.g. license2:abc...'
    }

    if (match[1] === 'ip' || !allowedTypes.includes(match[1]!)) {
        return 'Allowed identifier types: ' + allowedTypes.join(', ')
    }

    return null
}
