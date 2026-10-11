-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

xLib.callback.register('xLib:validateModel', function(model)
    return IsModelValid(model)
end)
