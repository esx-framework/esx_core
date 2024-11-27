---@diagnostic disable: duplicate-set-field
Multicharacter = {}
Multicharacter._index = Multicharacter
Multicharacter.canRelog = true
Multicharacter.Characters = {}
Multicharacter.hidePlayers = false

function Multicharacter:SetupCamera()
    self.cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamActive(self.cam, true)
    RenderScriptCams(true, false, 1, true, true)

    local offset = GetOffsetFromEntityInWorldCoords(self.playerPed, 0, 1.7, 0.4)

    SetCamCoord(self.cam, offset.x, offset.y, offset.z)
    PointCamAtCoord(self.cam, self.spawnCoords.x, self.spawnCoords.y, self.spawnCoords.z + 1.3)
end

function Multicharacter:AwaitFadeIn()
    while IsScreenFadingIn() do
        Wait(200)
    end
end

function Multicharacter:AwaitFadeOut()
    while IsScreenFadingOut() do
        Wait(200)
    end
end

function Multicharacter:DestoryCamera()
    if self.cam then
        SetCamActive(self.cam, false)
        RenderScriptCams(false, false, 0, true, true)
        self.cam = nil
    end
end

local HiddenCompents = {}

local function HideComponents(hide)
    local components = {11, 12, 21}
    for i = 1, #components do
        if hide then
            local size = GetHudComponentSize(components[i])
            if size.x > 0 or size.y > 0 then
                HiddenCompents[components[i]] = size
                SetHudComponentSize(components[i], 0.0, 0.0)
            end
        else
            if HiddenCompents[components[i]] then
                local size = HiddenCompents[components[i]]
                SetHudComponentSize(components[i], size.x, size.z)
                HiddenCompents[components[i]] = nil
            end
        end
    end
    DisplayRadar(not hide)
end

function Multicharacter:HideHud(hide)
    self.hidePlayers = true

    MumbleSetVolumeOverride(ESX.PlayerId, 0.0)
    HideComponents(hide)
end

function Multicharacter:SetupCharacters()
    ESX.PlayerLoaded = false
    ESX.PlayerData = {}

    self.spawned = false

    self.playerPed = PlayerPedId()
    self.spawnCoords = Config.Spawn[ESX.Math.Random(1,#Config.Spawn)]

    SetEntityCoords(self.playerPed, self.spawnCoords.x, self.spawnCoords.y, self.spawnCoords.z, true, false, false, false)
    SetEntityHeading(self.playerPed, self.spawnCoords.w)

    SetPlayerControl(ESX.PlayerId, false, 0)
    self:SetupCamera()
    self:HideHud(true)

    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    TriggerEvent("esx:loadingScreenOff")

    SetTimeout(200, function()
        TriggerServerEvent("esx_multicharacter:SetupCharacters")
    end)
end

function Multicharacter:GetSkin()
    local character = self.Characters[self.tempIndex]
    local skin = character and character.skin or Config.Default
    if not character.model then
        if character.sex == TranslateCap("female") then
            skin.sex = 1
        else
            skin.sex = 0
        end
    end
    return skin
end

function Multicharacter:SpawnTempPed()
    self.canRelog = false
    local skin = self:GetSkin()
    ESX.SpawnPlayer(skin, self.spawnCoords, function()
        DoScreenFadeIn(600)
        self.playerPed = PlayerPedId()
    end)
end

function Multicharacter:ChangeExistingPed()
    local newCharacter = self.Characters[self.tempIndex]
    local spawnedCharacter = self.Characters[self.spawned]

    if spawnedCharacter and spawnedCharacter.model then
        local model = ESX.Streaming.RequestModel(newCharacter.model)
        if model then
            SetPlayerModel(ESX.playerId, newCharacter.model)
            SetModelAsNoLongerNeeded(newCharacter.model)
        end
    end

    TriggerEvent("skinchanger:loadSkin", newCharacter.skin)
end

function Multicharacter:PrepForUI()
    FreezeEntityPosition(self.playerPed, true)
    SetPedAoBlobRendering(self.playerPed, true)
    SetEntityAlpha(self.playerPed, 255, false)
end

function Multicharacter:CloseUI()
    SendNUIMessage({
        action = "closeui",
    })
end

function Multicharacter:SetupCharacter(index)
    local character = self.Characters[index]
    self.tempIndex = index

    if not self.spawned then
        self:SpawnTempPed()
    elseif character and character.skin then
        self:ChangeExistingPed()
    end

    self.spawned = index
    self.playerPed = PlayerPedId()
    self:PrepForUI()
    SendNUIMessage({
        action = "openui",
        character = character,
    })
end

function Multicharacter:SetupUI(characters, slots)
    DoScreenFadeOut(0)

    self.Characters = characters
    self.slots = slots

    local Character = next(self.Characters)
    if not Character then
        self.canRelog = false

        ESX.SpawnPlayer(Config.Default, self.spawnCoords, function()
            DoScreenFadeIn(400)
            self:AwaitFadeIn()

            self.playerPed = PlayerPedId()
            SetPedAoBlobRendering(self.playerPed, false)
            SetEntityAlpha(self.playerPed, 0, false)

            TriggerServerEvent("esx_multicharacter:CharacterChosen", 1, true)
            TriggerEvent("esx_identity:showRegisterIdentity")
        end)
    else
        Menu:SelectCharacter()
    end
end

function Multicharacter:LoadSkinCreator(skin)
    TriggerEvent("skinchanger:loadSkin", skin, function()
        DoScreenFadeIn(600)
        SetPedAoBlobRendering(self.playerPed, true)
        ResetEntityAlpha(self.playerPed)

        TriggerEvent("esx_skin:openSaveableMenu", function()
            Multicharacter.finishedCreation = true
        end, function()
            Multicharacter.finishedCreation = true
        end)
    end)
end

function Multicharacter:SetDefaultSkin(playerData)

    local skin = Config.Default[playerData.sex]
    skin.sex = playerData.sex == "m" and 0 or 1

    local model = skin.sex == 0 and `mp_m_freemode_01` or `mp_f_freemode_01`
    ---@diagnostic disable-next-line: cast-local-type
    model = ESX.Streaming.RequestModel(model)

    if not model then
        return
    end

    SetPlayerModel(ESX.playerId, model)
    SetModelAsNoLongerNeeded(model)
    self.playerPed = PlayerPedId()

    self:LoadSkinCreator(skin)
end

function Multicharacter:Reset()
    self.Characters = {}
    self.tempIndex = nil
    self.playerPed = PlayerPedId()
    self.hidePlayers = false
    self.slots = nil

    SetTimeout(10000, function()
        self.canRelog = true
    end)
end

function Multicharacter:PlayerLoaded(playerData, isNew, skin)
    DoScreenFadeOut(750)
    self:AwaitFadeOut()

    local esxSpawns = ESX.GetConfig().DefaultSpawns
    local spawn = esxSpawns[math.random(1, #esxSpawns)]

    if not isNew and playerData.coords then
        spawn = playerData.coords
    end

    if isNew or not skin or #skin == 1 then
        self.finishedCreation = false
        self:SetDefaultSkin(playerData)

        while not self.finishedCreation do
            Wait(200)
        end

        skin = exports["skinchanger"]:GetSkin()
        DoScreenFadeOut(500)
        self:AwaitFadeOut()

    elseif not isNew then
        TriggerEvent("skinchanger:loadSkin", skin or self.Characters[self.spawned].skin)
    end

    self:DestoryCamera()
    ESX.SpawnPlayer(skin, spawn, function()
        self:HideHud(false)
        SetPlayerControl(ESX.playerId, true, 0)

        self.playerPed = PlayerPedId()
        FreezeEntityPosition(self.playerPed, false)
        SetEntityCollision(self.playerPed, true, true)

        DoScreenFadeIn(750)

        self:AwaitFadeIn()

        TriggerServerEvent("esx:onPlayerSpawn")
        TriggerEvent("esx:onPlayerSpawn")
        TriggerEvent("esx:restoreLoadout")

        self:Reset()
    end)
end
