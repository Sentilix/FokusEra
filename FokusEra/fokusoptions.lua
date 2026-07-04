-- Catch the shared addon namespace parameter from the WoW engine
local addonName, FokusEraNS = ...

-- Create the main canvas frame for Blizzard's Settings layout catalog
local optionsFrame = CreateFrame("Frame", "FokusEraOptionsFrame", UIParent)
optionsFrame.name = "FokusEra"

-- Helper function to generate standardized modern Blizzard Checkboxes
local function CreateSettingCheckbox(parent, labelText, tooltipText, pointY, dbVariable)
    local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    cb:SetPoint("TOPLEFT", 16, pointY)
    cb.Text:SetText(labelText)
    
    cb:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(tooltipText, nil, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    cb:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    cb:SetScript("OnClick", function(self)
        _G[dbVariable] = self:GetChecked()
        -- Trigger an instant redraw of the aura layout frames if focus is active
        if FokusEra_RefreshAuras then FokusEra_RefreshAuras() end
    end)
    
    return cb
end

-- Initialize and register the category inside Blizzard's Addon options canvas
optionsFrame:RegisterEvent("ADDON_LOADED")
optionsFrame:SetScript("OnEvent", function(self, event, loadedAddon)
    if loadedAddon ~= addonName then return end
    
    -- Setup baseline configurations if database keys are non-existent
    if FokusEra_ShowBuffs == nil then FokusEra_ShowBuffs = true end
    if FokusEra_ShowDebuffs == nil then FokusEra_ShowDebuffs = true end
    
    -- Title interface text block layout
    local title = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("FokusEra Settings")
    
    local desc = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    desc:SetPoint("TOPLEFT", 16, -40)
    desc:SetText("Configure the visibility vectors for the standalone focus frame setup.")
    
    -- Instantiate our two functional config checkboxes
    self.buffCB = CreateSettingCheckbox(self, "Show Beneficial Buffs", "Toggle the display grid for active beneficial buffs tracking under the focus frame.", -70, "FokusEra_ShowBuffs")
    self.debuffCB = CreateSettingCheckbox(self, "Show Harmful Debuffs", "Toggle the display grid for harmful debuffs/status afflictions tracking under the focus frame.", -105, "FokusEra_ShowDebuffs")
    
    -- Force sync the checkboxes with saved character database profiles on startup
    self.buffCB:SetChecked(FokusEra_ShowBuffs)
    self.debuffCB:SetChecked(FokusEra_ShowDebuffs)
    
    -- Modern Classic Era Registration API pipeline handler
    if Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(self, "FokusEra")
        Settings.RegisterAddOnCategory(category)
    else
        -- Traditional backward-compatible callback fallback path
        InterfaceOptions_AddCategory(self)
    end
    
    self:UnregisterEvent("ADDON_LOADED")
end)
