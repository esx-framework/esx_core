/*
 * SPDX-License-Identifier: GPL-3.0-only
 * Copyright (C) 2022-2026 ESX Framework
 */

const COLOR_VARIABLES = {
    primaryColor: "--brand",
    secondaryColor: "--panel",
    backgroundColor: "--surface",
    accentColor: "--line",
};

const isColor = (value) => typeof value === "string" && value.trim() !== "" && CSS.supports("color", value.trim());

function toRgb(color) {
    const probe = document.createElement("span");
    probe.style.color = color;
    document.body.appendChild(probe);
    const computed = getComputedStyle(probe).color;
    probe.remove();
    const channels = computed.startsWith("rgb") ? computed.match(/[\d.]+/g) : null;
    return channels && channels.length >= 3 ? channels.slice(0, 3).map((channel) => Math.round(Number(channel))) : null;
}

const mixWith = (rgb, target, amount) => `rgb(${rgb.map((channel) => Math.round(channel + (target - channel) * amount)).join(", ")})`;

export function applyTheme(theme) {
    if (!theme || typeof theme !== "object") return;
    const root = document.documentElement.style;
    for (const [key, variable] of Object.entries(COLOR_VARIABLES)) {
        if (isColor(theme[key])) root.setProperty(variable, theme[key].trim());
    }
    if (!isColor(theme.primaryColor)) return;
    const rgb = toRgb(theme.primaryColor.trim());
    if (!rgb) return;
    root.setProperty("--brand-rgb", rgb.join(", "));
    root.setProperty("--brand-bright", mixWith(rgb, 255, 0.2));
    root.setProperty("--brand-soft", mixWith(rgb, 255, 0.55));
}
