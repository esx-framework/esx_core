declare global {
    interface Window {
        GetParentResourceName?: () => string
    }
}

export const isNui = typeof window.GetParentResourceName === 'function'

const resourceName =
    isNui && window.GetParentResourceName ? window.GetParentResourceName() : 'esx_whitelist'

/**
 * Posts to a client-side NUI callback. The callback name is passed
 * verbatim; the client only registers a small fixed set of names.
 */
export async function fetchNui<T = unknown>(event: string, data: unknown = {}): Promise<T> {
    if (!isNui) {
        return { ok: true } as T
    }

    const response = await fetch(`https://${resourceName}/${event}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data ?? {}),
    })

    try {
        return (await response.json()) as T
    } catch {
        return { ok: false } as T
    }
}
