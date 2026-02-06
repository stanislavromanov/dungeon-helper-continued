local addonName, ns = ...

local function CreateOptionsFrame()
    local panel = CreateFrame("Frame")
    panel.name = "Dungeon Helper Continued"
    panel:Hide()

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Dungeon Helper Continued")

    -- Greeting Message
    local greetingLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    greetingLabel:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -24)
    greetingLabel:SetText("Greeting Message:")

    local greetingBox = CreateFrame("EditBox", "DHCGreetingEditBox", panel, "InputBoxTemplate")
    greetingBox:SetSize(200, 20)
    greetingBox:SetPoint("TOPLEFT", greetingLabel, "BOTTOMLEFT", 6, -4)
    greetingBox:SetAutoFocus(false)
    greetingBox:SetScript("OnEnterPressed", function(self)
        DungeonHelperContinuedDB.greetingMessage = self:GetText()
        self:ClearFocus()
    end)
    greetingBox:SetScript("OnEscapePressed", function(self)
        self:SetText(DungeonHelperContinuedDB.greetingMessage)
        self:ClearFocus()
    end)

    -- Goodbye Message
    local goodbyeLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    goodbyeLabel:SetPoint("TOPLEFT", greetingBox, "BOTTOMLEFT", -6, -16)
    goodbyeLabel:SetText("Goodbye Message:")

    local goodbyeBox = CreateFrame("EditBox", "DHCGoodbyeEditBox", panel, "InputBoxTemplate")
    goodbyeBox:SetSize(200, 20)
    goodbyeBox:SetPoint("TOPLEFT", goodbyeLabel, "BOTTOMLEFT", 6, -4)
    goodbyeBox:SetAutoFocus(false)
    goodbyeBox:SetScript("OnEnterPressed", function(self)
        DungeonHelperContinuedDB.goodbyeMessage = self:GetText()
        self:ClearFocus()
    end)
    goodbyeBox:SetScript("OnEscapePressed", function(self)
        self:SetText(DungeonHelperContinuedDB.goodbyeMessage)
        self:ClearFocus()
    end)

    -- Report Time Checkbox
    local reportCheck = CreateFrame("CheckButton", "DHCReportCheckButton", panel, "UICheckButtonTemplate")
    reportCheck:SetPoint("TOPLEFT", goodbyeBox, "BOTTOMLEFT", -8, -16)
    reportCheck.text = reportCheck.text or reportCheck:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    reportCheck.text:SetPoint("LEFT", reportCheck, "RIGHT", 4, 0)
    reportCheck.text:SetText("Report time to party")
    reportCheck:SetScript("OnClick", function(self)
        DungeonHelperContinuedDB.reportTimeToParty = self:GetChecked()
    end)

    -- Refresh values when panel is shown
    panel:SetScript("OnShow", function()
        greetingBox:SetText(DungeonHelperContinuedDB.greetingMessage or "Hi")
        goodbyeBox:SetText(DungeonHelperContinuedDB.goodbyeMessage or "thanks, bb")
        reportCheck:SetChecked(DungeonHelperContinuedDB.reportTimeToParty)
    end)

    return panel
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, loadedAddon)
    if loadedAddon ~= addonName then return end
    self:UnregisterEvent("ADDON_LOADED")

    local panel = CreateOptionsFrame()

    local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    category.ID = addonName
    Settings.RegisterAddOnCategory(category)

    SLASH_DUNGEONHELPERCONTINUED1 = "/dhc"
    SlashCmdList["DUNGEONHELPERCONTINUED"] = function()
        Settings.OpenToCategory(category:GetID())
    end
end)
