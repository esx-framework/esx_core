
SkinChanger = {}
SkinChanger._index = SkinChanger

SkinChanger.lastSex = -1
SkinChanger.character = {}
SkinChanger.components = Config.Components

function SkinChanger:RequestModel(model)
    if type(model) == "string" then
        model = joaat(model)
    end

    RequestModel(model)

    while not HasModelLoaded(model) do
        Wait(200)
    end

    return model
end

function SkinChanger:ModelLoaded()
    ClearPedProp(PlayerPedId(), 0)

    if self.loadSkin ~= nil then
        self:ApplySkin(self.loadSkin)
        self.loadSkin = nil
    end

    if self.loadClothes ~= nil then
        self:ApplySkin(self.loadClothes.playerSkin, self.loadClothes.clothesSkin)
        self.loadClothes = nil
    end
end

function SkinChanger:DefaultModel(male, cb)
    local characterModel = male and `mp_m_freemode_01` or `mp_f_freemode_01`

    if not IsModelInCdimage(characterModel) or not IsModelValid(characterModel) then
        return
    end
    local model = self:RequestModel(characterModel)

    SetPlayerModel(PlayerId(), model)
    SetPedDefaultComponentVariation(PlayerPedId())

    SetModelAsNoLongerNeeded(model)

    if cb then
        cb()
    end

    self:ModelLoaded()
end

function SkinChanger:MaxValues()
    local playerPed = PlayerPedId()
    local data = {}

    for i = 1, #self.components, 1 do
        local component = self.components[i]
        local max = type(component.max) == "function" and component.max(playerPed, self.character) or component.max
        data[component.name] = max
    end

    return data
end

function SkinChanger:DefaultFromSex(sex, cb)
    if sex == 0 then
        self:DefaultModel(true, cb)
    else
        self:DefaultModel(false, cb)
    end
end

function SkinChanger:LoadSkin(skin, cb)
    local sex = skin["sex"]
    if sex ~= self.lastSex then
        self.loadSkin = skin
        self:DefaultFromSex(sex, cb)

        self.lastSex = sex
    else
        self:ApplySkin(skin)

        if cb ~= nil then
            cb()
        else
            return
        end
    end
end

function SkinChanger:ValidClothes(key)
    local keys = {["sex"] = true, ["mom"] = true, ["dad"] = true, ["face_md_weight"] = true, ["skin_md_weight"] = true, ["nose_1"] = true, ["nose_2"] = true,
    ["nose_3"] = true, ["nose_4"] = true, ["nose_5"] = true, ["nose_6"] = true, ["cheeks_1"] = true, ["cheeks_2"] = true, ["cheeks_3"] = true,
    ["lip_thickness"] = true, ["jaw_1"] = true, ["jaw_2"] = true, ["chin_1"] = true, ["chin_2"] = true, ["chin_3"] = true, ["chin_4"] = true,
    ["neck_thickness"] = true, ["age_1"] = true, ["age_2"] = true, ["eye_color"] = true, ["eye_squint"] = true, ["beard_1"] = true, ["beard_2"] = true,
    ["beard_3"] = true, ["beard_4"] = true, ["hair_1"] = true, ["hair_2"] = true, ["hair_color_1"] = true, ["hair_color_2"] = true, ["eyebrows_1"] = true,
    ["eyebrows_2"] = true, ["eyebrows_3"] = true, ["eyebrows_4"] = true, ["eyebrows_5"] = true, ["eyebrows_6"] = true, ["makeup_1"] = true, ["makeup_2"] = true,
    ["makeup_3"] = true, ["makeup_4"] = true, ["lipstick_1"] = true, ["lipstick_2"] = true, ["lipstick_3"] = true, ["lipstick_4"] = true, ["blemishes_1"] = true,
    ["blemishes_2"] = true, ["blemishes_3"] = true, ["blush_1"] = true, ["blush_2"] = true, ["blush_3"] = true, ["complexion_1"] = true, ["complexion_2"] = true,
    ["sun_1"] = true, ["sun_2"] = true, ["moles_1"] = true, ["moles_2"] = true, ["chest_1"] = true, ["chest_2"] = true, ["chest_3"] = true, ["bodyb_1"] = true,
    ["bodyb_2"] = true, ["bodyb_3"] = true, ["bodyb_4"] = true}
    return keys[key] == nil
end

local function Normalise(weight, divison)
    return (weight / divison) + 0.0
end

function SkinChanger:SetHead()
    local face_weight = Normalise(self.character["face_md_weight"], 100)
    local skin_weight = Normalise(self.character["skin_md_weight"], 100)

    if not self.character["face_g_weight"] then
        self.character["face_g_weight"] = 0
    end

    local third_weight = Normalise(self.character["face_g_weight"], 100)

    if not self.character["grandparents"] then
        self.character["grandparents"] = 0
    end

    SetPedHeadBlendData(self.playerPed,
    self.character["mom"], self.character["dad"], self.character["grandparents"] , self.character["mom"],
    self.character["dad"], self.character["grandparents"], face_weight, skin_weight, third_weight, false)
end

function SkinChanger:SetFace()
    local features = {"nose_1", "nose_2", "nose_3", "nose_4", "nose_5", "nose_6", "eyebrows_5", "eyebrows_6", "cheeks_1", "cheeks_2", "cheeks_3", "eye_squint", "lip_thickness", "jaw_1", "jaw_2", "chin_1", "chin_2", "chin_3", "chin_4", "neck_thickness"}
    for i = 1, #features, 1 do
        local feature = features[i]
        SetPedFaceFeature(self.playerPed, i - 1, Normalise(self.character[feature], 10))
    end
    SetPedEyeColor(self.playerPed, self.character["eye_color"]) -- Eyes color
end

function SkinChanger:SetHeadOverlay()
    local features = {{"blemishes_1", "blemishes_2"}, {"beard_1", "beard_2"}, {"eyebrows_1", "eyebrows_2"}, {"age_1", "age_2"}, {"makeup_1", "makeup_2"}, {"blush_1", "blush_2"}, {"complexion_1", "complexion_2"}, {"sun_1", "sun_2"}, {"lipstick_1", "lipstick_2"}, {"moles_1", "moles_2"}, {"chest_1", "chest_2"}}
    for i = 1, #features, 1 do
        local feature = features[i]
        SetPedHeadOverlay(self.playerPed, i - 1, self.character[feature[1]], Normalise(self.character[feature[2]], 10))
    end
end

function SkinChanger:SetHeadOverlayColour()
    local features = {[1] = {"beard_3", "beard_4"}, [2] = {"eyebrows_3", "eyebrows_4"}, [4] = {"makeup_3", "makeup_4"}, [5] = {"blush_3", 0}, [8] = {"lipstick_3", "lipstick_4"}, [10] = {"chest_3", 0}}
    for i, feature in pairs(features) do
        SetPedHeadOverlayColor(self.playerPed, i, 1, self.character[feature[1]], self.character[feature[2]])
    end
    if self.character["bodyb_1"] == -1 then
        SetPedHeadOverlay(self.playerPed, 11, 255, (self.character["bodyb_2"] / 10) + 0.0) -- Body Blemishes + opacity
    else
        SetPedHeadOverlay(self.playerPed, 11, self.character["bodyb_1"], (self.character["bodyb_2"] / 10) + 0.0)
    end

    if self.character["bodyb_3"] == -1 then
        SetPedHeadOverlay(self.playerPed, 12, 255, (self.character["bodyb_4"] / 10) + 0.0)
    else
        SetPedHeadOverlay(self.playerPed, 12, self.character["bodyb_3"], (self.character["bodyb_4"] / 10) + 0.0) -- Blemishes 'added body effect' + opacity
    end
end

function SkinChanger:SetHair()
    SetPedComponentVariation(self.playerPed, 2, self.character["hair_1"], self.character["hair_2"], 2) -- Hair
    SetPedHairColor(self.playerPed, self.character["hair_color_1"], self.character["hair_color_2"]) -- Hair Color
end

function SkinChanger:SetComponents()
    local components = {{"tshirt_1", "tshirt_2", 8}, {"torso_1", "torso_2", 11}, {"decals_1", "decals_2", 10}, {"arms", "arms_2", 3}, {"pants_1", "pants_2", 4}, {"shoes_1", "shoes_2", 6}, {"mask_1", "mask_2", 1}, {"bproof_1", "bproof_2", 9}, {"chain_1", "chain_2", 7}, {"bags_1", "bags_2", 5}}
    for i = 1, #components, 1 do
        local component = components[i]
        SetPedComponentVariation(self.playerPed, component[3], self.character[component[1]], self.character[component[2]], 2)
    end
end

function SkinChanger:SetProps()
    local props = {{"helmet_1", "helmet_2", 0}, {"glasses_1", "glasses_2", 1}, {"ears_1", "ears_2", 2}, {"watches_1", "watches_2", 6}, {"bracelets_1", "bracelets_2", 7}}
    for i = 1, #props, 1 do
        local prop = props[i]
        local propVal = self.character[prop[1]]
        if propVal == -1 then
            ClearPedProp(self.playerPed, prop[3])
        else
            SetPedPropIndex(self.playerPed, prop[3], propVal, self.character[prop[2]], true)
        end
    end
end

function SkinChanger:ApplySkin(skin, clothes)
    self.playerPed = PlayerPedId()

    for k, v in pairs(skin) do
        self.character[k] = v
    end

    if clothes ~= nil then
        for k, v in pairs(clothes) do
            if self:ValidClothes(k) then
                self.character[k] = v
            end
        end
    end

    self:SetHead()
    self:SetHair()
    self:SetFace()
    self:SetHeadOverlay()
    self:SetHeadOverlayColour()
    self:SetComponents()
    self:SetProps()
    return true
end

function SkinChanger:LoadClothes(playerSkin, clothesSkin)
    local sex = playerSkin["sex"]
    if sex ~= self.lastSex then
        self.loadClothes = {
            playerSkin = playerSkin,
            clothesSkin = clothesSkin,
        }

        self:DefaultFromSex(sex)

        self.lastSex = sex
        return true
    else
        return self:ApplySkin(playerSkin, clothesSkin)
    end
end

function SkinChanger:Change(key, val)
    self.character[key] = val

    if key == "sex" then
        self:LoadSkin(self.character)
    else
        self:ApplySkin(self.character)
    end
end

function SkinChanger:Init()
    for i = 1, #self.components, 1 do
        local component = self.components[i]
        self.character[component.name] = component.value
    end
end

function SkinChanger:GetData(noMax)
    local components = SkinChanger.components
    for k, v in pairs(SkinChanger.character) do
        for i = 1, #components, 1 do
            if k == components[i].name then
                components[i].value = v
            end
        end
    end

    return components, noMax and nil or self:MaxValues()
end

--- exports

exports("GetSkin", function()
    return SkinChanger.character
end)

exports("GetMaxVals", function()
    return SkinChanger:MaxValues()
end)

exports("LoadSkin", function(skin)
    return SkinChanger:LoadSkin(skin)
end)

exports("GetData", function(noMax)
    return SkinChanger:GetData(noMax)
end)

exports("LoadClothes", function(playerSkin, clothesSkin)
    return SkinChanger:LoadClothes(playerSkin, clothesSkin)
end)

exports("Change", function(key, val)
    return SkinChanger:Change(key, val)
end)

--- Events

RegisterNetEvent("skinchanger:loadSkin", function(skin, cb)
    SkinChanger:LoadSkin(skin, cb)
end)

RegisterNetEvent("skinchanger:loadClothes", function(playerSkin, clothesSkin)
    SkinChanger:LoadClothes(playerSkin, clothesSkin)
end)

AddEventHandler("skinchanger:getSkin", function(cb)
    cb(SkinChanger.character)
end)

AddEventHandler("skinchanger:loadDefaultModel", function(loadMale, cb)
    SkinChanger:DefaultModel(loadMale, cb)
end)

AddEventHandler("skinchanger:change", function(key, val)
    SkinChanger:Change(key, val)
end)

AddEventHandler("skinchanger:modelLoaded", function()
    SkinChanger:ModelLoaded()
end)

AddEventHandler("skinchanger:getData", function(cb)
    cb(SkinChanger:GetData())
end)

SkinChanger:Init()
