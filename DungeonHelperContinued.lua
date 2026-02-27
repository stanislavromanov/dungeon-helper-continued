local addonName, ns = ...

local defaults = {
    greetingMessage = "hi",
    goodbyeMessage = "thanks, bb",
    reportTimeToParty = true,
}

local startTime = nil
local lastTimeStr = nil

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
        if isInitialLogin or isReloadingUi then return end

        if not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then return end

        local _, instanceType = GetInstanceInfo()
        if instanceType ~= "party" and instanceType ~= "raid" then return end

        startTime = GetTime()
        C_ChatInfo.SendChatMessage(DungeonHelperContinuedDB.greetingMessage, "INSTANCE_CHAT")

    elseif event == "LFG_COMPLETION_REWARD" then
        local elapsed = 0
        if startTime then
            elapsed = GetTime() - startTime
        end

        lastTimeStr = FormatTime(elapsed)
        print("Dungeon completed in: " .. lastTimeStr)

        if lastTimeStr and DungeonHelperContinuedDB.reportTimeToParty then
            C_Timer.After(1, function()
                C_ChatInfo.SendChatMessage("Dungeon completed in: " .. lastTimeStr, "INSTANCE_CHAT")
            end)
        end

        StaticPopup_Show("DUNGEONHELPER_LEAVE_CONFIRM")
    end
end)
