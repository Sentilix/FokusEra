-- Catch the shared addon namespace parameter from the WoW engine
local addonName, FokusEraNS = ...

local optionsFrame = CreateFrame("Frame", "FokusEraOptionsFrame", UIParent)
optionsFrame.name = "FokusEra"

local function CreateSecureCheckbox(parent, labelText, tooltipText, pointY, dbVariable)
    local cb = CreateFrame("Button", nil, parent, "BackdropTemplate")
    cb:SetSize(20, 20)
    cb:SetPoint("TOPLEFT", 16, pointY)
    
    cb:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = false, tileSize = 0, edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    cb:SetBackdropColor(0.05, 0.05, 0.05, 1)
    cb:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    
    cb.checkTex = cb:CreateTexture(nil, "OVERLAY")
    cb.checkTex:SetSize(14, 14)
    cb.checkTex:SetPoint("CENTER", cb, "CENTER", 0, 0)
    cb.checkTex:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    cb.checkTex:Hide()
    
    cb.text = cb:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    cb.text:SetPoint("LEFT", cb, "RIGHT", 8, 0)
    cb.text:SetText(labelText)
    
    cb.UpdateState = function()
        if _G[dbVariable] then cb.checkTex:Show() else cb.checkTex:Hide() end
    end
    
    cb:SetScript("OnClick", function(self)
        if InCombatLockdown() then return end
        _G[dbVariable] = not _G[dbVariable]
        self.UpdateState()
        if FokusEraNS.FokusEra_RefreshAuras then FokusEraNS.FokusEra_RefreshAuras() end
    end)
    
    cb:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(tooltipText, nil, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    cb:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    return cb
end

optionsFrame:RegisterEvent("ADDON_LOADED")
optionsFrame:SetScript("OnEvent", function(self, event, loadedAddon)
    if loadedAddon ~= addonName then return end
    
    if FokusEra_ShowBuffs == nil then FokusEra_ShowBuffs = true end
    if FokusEra_ShowDebuffs == nil then FokusEra_ShowDebuffs = true end
    if FokusEra_ShowTargetAuras == nil then FokusEra_ShowTargetAuras = true end -- Default to active
    
    local title = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("FokusEra Settings")
    
    local desc = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    desc:SetPoint("TOPLEFT", 16, -40)
    desc:SetText("Configure the visibility vectors for the standalone focus frame setup without risking memory taint.")
    
    self.buffCB = CreateSecureCheckbox(self, "Show Focus Buffs", "Toggle the display grid for active beneficial buffs tracking under the focus frame.", -70, "FokusEra_ShowBuffs")
    self.debuffCB = CreateSecureCheckbox(self, "Show Focus Debuffs", "Toggle the display grid for harmful debuffs/status afflictions tracking under the focus frame.", -105, "FokusEra_ShowDebuffs")
    -- NEW Checkbox for Focus Target frame
    self.targetCB = CreateSecureCheckbox(self, "Show Focus Target Auras", "Toggle the complete display grid (Both Buffs and Debuffs combined) under the Focus Target frame.", -140, "FokusEra_ShowTargetAuras")
    
    self.buffCB.UpdateState()
    self.debuffCB.UpdateState()
    self.targetCB.UpdateState()
    
    if Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(self, "FokusEra")
        Settings.RegisterAddOnCategory(category)
    else
        InterfaceOptions_AddCategory(self)
    end
    
    self:UnregisterEvent("ADDON_LOADED")
end)
