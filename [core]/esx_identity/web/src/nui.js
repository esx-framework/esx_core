// SPDX-License-Identifier: GPL-3.0-only
export const inGame = typeof window.GetParentResourceName === "function";
export const isPreview = !inGame && new URLSearchParams(window.location.search).get("preview") === "1";

export async function postNui(event, data = {}) {
    if (isPreview) return { ok: true };
    if (!inGame) throw new Error("Abre esta interfaz desde el servidor.");
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 20000);
    try {
        // adamant uses HTTP; newer secure NUI contexts use HTTPS.
        const protocol = window.location.protocol === "https:" ? "https" : "http";
        const response = await fetch(`${protocol}://${window.GetParentResourceName()}/${event}`, {
            method: "POST",
            headers: { "Content-Type": "application/json; charset=UTF-8" },
            body: JSON.stringify(data),
            signal: controller.signal,
        });
        if (!response.ok) throw new Error("No se pudo conectar con el servidor. Inténtalo de nuevo.");
        return await response.json();
    } finally {
        clearTimeout(timeout);
    }
}
