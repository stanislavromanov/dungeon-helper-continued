local addonName, ns = ...

local defaults = {
    greetingMessage = "hi",
    goodbyeMessage = "thanks, bb",
    reportTimeToParty = true,
}

local startTime = nil
local lastTimeStr = nil

local function GetCurrentTime()
    if type(GetServerTime) == "function" then
        return GetServerTime()
    end

    return time()
end

local function IsTrackedInstance()
    if not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        return false
    end

    local _, instanceType = GetInstanceInfo()
    return instanceType == "party" or instanceType == "raid"
end

local function RestoreRun()
    local activeRun = DungeonHelperContinuedDB and DungeonHelperContinuedDB.activeRun
    if activeRun and type(activeRun.startTime) == "number" then
        startTime = activeRun.startTime
    else
        startTime = nil
    end
end

local function StartRun(sendGreeting)
    local instanceName, _, _, _, _, _, _, instanceID = GetInstanceInfo()

    DungeonHelperContinuedDB.activeRun = {
        startTime = GetCurrentTime(),
        instanceName = instanceName,
        instanceID = instanceID,
    }

    RestoreRun()

    if sendGreeting then
        C_ChatInfo.SendChatMessage(DungeonHelperContinuedDB.greetingMessage, "INSTANCE_CHAT")
    end
end

local function ClearRun()
    startTime = nil

    if DungeonHelperContinuedDB then
        DungeonHelperContinuedDB.activeRun = nil
    end
end

local function FormatTime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)

    if h > 0 then
        return string.format("%dh %dm %ds", h, m, s)
    elseif m > 0 then
        return string.format("%dm %ds", m, s)
    else
        return string.format("%ds", s)
    end
end

StaticPopupDialogs["DUNGEONHELPER_LEAVE_CONFIRM"] = {
    text = "Do you want to leave the instance?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        C_ChatInfo.SendChatMessage(DungeonHelperContinuedDB.goodbyeMessage, "INSTANCE_CHAT")
        C_Timer.After(1, function()
            C_PartyInfo.LeaveParty(LE_PARTY_CATEGORY_INSTANCE)
        end)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("LFG_COMPLETION_REWARD")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon ~= addonName then return end

        if DungeonHelperContinuedDB == nil then
            DungeonHelperContinuedDB = {}
        end
        for k, v in pairs(defaults) do
            if DungeonHelperContinuedDB[k] == nil then
                DungeonHelperContinuedDB[k] = v
            end
        end

        self:UnregisterEvent("ADDON_LOADED")

    elseif event == "PLAYER_ENTERING_WORLD" then
        local isInitialLogin, isReloadingUi = ...

        if not IsTrackedInstance() then
            ClearRun()
            return
        end

        RestoreRun()
        if startTime then return end

        StartRun(not isInitialLogin and not isReloadingUi)

    elseif event == "LFG_COMPLETION_REWARD" then
        local elapsed = 0
        if startTime then
            elapsed = math.max(0, GetCurrentTime() - startTime)
        end

        lastTimeStr = FormatTime(elapsed)
        print("Dungeon completed in: " .. lastTimeStr)
        ClearRun()

        if lastTimeStr and DungeonHelperContinuedDB.reportTimeToParty then
            C_Timer.After(1, function()
                C_ChatInfo.SendChatMessage("Dungeon completed in: " .. lastTimeStr, "INSTANCE_CHAT")
            end)
        end

        StaticPopup_Show("DUNGEONHELPER_LEAVE_CONFIRM")
    end
end)
