local overloads <const> = {}

---@param name string
---@param ... unknown
local function getOverloadFunction(name, ...) 
    local params = {...}
    local params_count = #params
    local is_valid, overload, correct_type


    for i=1, #overloads[name] do
        overload = overloads[name][i]

        if not overload then
            goto continue
        end

        is_valid = #overload.valid_types == params_count

        if is_valid then
            for j = 1, #overload.valid_types do
                correct_type = overload.valid_types[j]
                if not xLib.verify(params[j], correct_type) then
                    is_valid = false
                    break
                end
            end

            if is_valid then
                return overload.cb(...)
            end
        end

        ::continue::
    end

    error('[xLib] Couldn\'t find a correct method to overload')
end

---Overloads a function
---@param name string
---@param valid_types CustomType | CustomType[]
---@param cb function
---@param obj? table
function xLib.overload(name, valid_types, cb, obj)
    xLib.verify(name, {'string'}, true)

    if not overloads[name] then
        overloads[name] = {}
    end
    
    overloads[name][#overloads[name] + 1] = {
        valid_types = valid_types,
        cb = cb
    }

    local env = obj and obj or _ENV

    if not env[name] then
        env[name] = function(...)
            return getOverloadFunction(name, ...)
        end
    end
end

return xLib.overload