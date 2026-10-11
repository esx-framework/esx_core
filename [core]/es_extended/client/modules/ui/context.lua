-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local DISPLAY_FIELDS = {
    title = true,
    description = true,
    label = true,
    inputPlaceholder = true,
}

local function stripHtml(value)
    if type(value) ~= "string" then
        return value
    end

    return value
        :gsub("<.->", "")
        :gsub("&nbsp;", " ")
        :gsub("%s+", " ")
        :gsub("^%s*(.-)%s*$", "%1")
end

local function sanitizeContextElements(elements)
    if type(elements) ~= "table" then
        return elements
    end

    for i = 1, #elements do
        local element = elements[i]
        if type(element) == "table" then
            for key in pairs(DISPLAY_FIELDS) do
                element[key] = stripHtml(element[key])
            end
        end
    end

    return elements
end

function ESX.OpenContext(position, elements, ...)
    return Core.IsResourceFound("esx_context") and exports["esx_context"]:Open(position, sanitizeContextElements(elements), ...)
end

function ESX.PreviewContext(...)
    return Core.IsResourceFound("esx_context") and exports["esx_context"]:Preview(...)
end

function ESX.CloseContext(...)
    return Core.IsResourceFound("esx_context") and exports["esx_context"]:Close(...)
end

function ESX.RefreshContext(elements, ...)
    return Core.IsResourceFound("esx_context") and exports["esx_context"]:Refresh(sanitizeContextElements(elements), ...)
end
