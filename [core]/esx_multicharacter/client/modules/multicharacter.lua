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

local function HideComponents()
    local components = {11, 12, 21}
    for i = 1, #components do
        HideHudComponentThisFrame(components[i])
    end
    ThefeedHideThisFrame()
    HideHudAndRadarThisFrame()
end

function Multicharacter:ResetHideActivePlayer()
    self.playerPed = PlayerPedId()

    MumbleSetVolumeOverride(ESX.playerId, -1.0)
    SetEntityVisible(self.playerPed, true, false)
    SetPlayerInvincible(self.playerPed, true)
    FreezeEntityPosition(self.playerPed, false)
end

function Multicharacter:HideActivePlayerLoop()
    CreateThread(function()
        local keys = { 18, 27, 172, 173, 174, 175, 176, 177, 187, 188, 191, 201, 108, 109, 209, 19 }
        while self.hidePlayers do

            DisableAllControlActions(0)
            for i = 1, #keys do
                EnableControlAction(0, keys[i], true)
            end

            SetEntityVisible(self.playerPed, false, false)
            SetLocalPlayerVisibleLocally(true)
            SetPlayerInvincible(ESX.playerId, true)

            HideComponents()

            local vehicles = GetGamePool("CVehicle")
            for i = 1, #vehicles do
                SetEntityLocallyInvisible(vehicles[i])
            end

            Wait(0)
        end
        self:ResetHideActivePlayer()

        SetTimeout(10000, function()
            self.canRelog = true
        end)
    end)
end

function Multicharacter:ConcealLoop()
    CreateThread(function()
        local playerPool = {}
        while self.hidePlayers do
            local players = GetActivePlayers()

            for i = 1, #players do
                local player = players[i]
                if player ~= ESX.playerId and not playerPool[player] then
                    playerPool[player] = true
                    NetworkConcealPlayer(player, true, true)
                end
            end

            Wait(500)
        end

        for k in pairs(playerPool) do
            NetworkConcealPlayer(k, false, false)
        end

    end)
end

function Multicharacter:StartLoops()
    self.hidePlayers = true

    MumbleSetVolumeOverride(ESX.playerId, 0.0)
    self:HideActivePlayerLoop()
    self:ConcealLoop()
end

function Multicharacter:SetupCharacters()
    ESX.PlayerLoaded = false
    ESX.PlayerData = {}

    self.spawned = false
    self.cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

    self.playerPed = PlayerPedId()
    self.spawnCoords = Config.Spawn[ESX.Math.Random(1,#Config.Spawn)]

    SetEntityCoords(self.playerPed, self.spawnCoords.x, self.spawnCoords.y, self.spawnCoords.z, true, false, false, false)
    SetEntityHeading(self.playerPed, self.spawnCoords.w)

    self:SetupCamera()
    self:StartLoops()

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
end

function Multicharacter:Spawn()
    local esxSpawns = ESX.GetConfig().DefaultSpawns
    local spawn = esxSpawns[math.random(1, #esxSpawns)]

    RequestCollisionAtCoord(spawn.x, spawn.y, spawn.z)

    FreezeEntityPosition(self.playerPed, true)
    SetEntityCoordsNoOffset(self.playerPed, spawn.x, spawn.y, spawn.z, false, false, true)
    SetEntityHeading(self.playerPed, spawn.heading or spawn.w or 0.0)

    while not HasCollisionLoadedAroundEntity(self.playerPed) do
        Wait(0)
    end

    NetworkResurrectLocalPlayer(spawn.x, spawn.y, spawn.z, spawn.heading, 0, true)
end

function Multicharacter:PlayerLoaded(playerData, isNew, skin)
    DoScreenFadeOut(750)
    self:AwaitFadeOut()

    if not isNew and playerData.coords then
        spawn = playerData.coords
    end

    if isNew or not skin or #skin == 1 then
        self.finishedCreation = false
        self:SetDefaultSkin(playerData)

        while not self.finishedCreation do
            Wait(200)
        end

        DoScreenFadeOut(500)
        self:AwaitFadeOut()

    elseif not isNew then
        TriggerEvent("skinchanger:loadSkin", skin or self.Characters[self.spawned].skin)
    end

    self:DestoryCamera()
    self:Spawn()
    Wait(500)

    DoScreenFadeIn(750)
    self:AwaitFadeIn()

    TriggerServerEvent("esx:onPlayerSpawn")
    TriggerEvent("esx:onPlayerSpawn")
    TriggerEvent("playerSpawned")
    TriggerEvent("esx:restoreLoadout")

    self:Reset()
end
