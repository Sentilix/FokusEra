-- Catch the shared addon namespace parameter from the WoW engine
local addonName, FokusEraNS = ...

-- INSTANTIATION OF THE 5 CLICK-TO-CAST ACTION SLOTS (Now with jet-black borders)
FokusFrame.spellButtons = {}

for i = 1, 5 do
    local btn = CreateFrame("Button", "FokusEraSpellBtn"..i, FokusFrame, "SecureActionButtonTemplate, BackdropTemplate")
    btn:SetSize(16, 16)
    
    if i == 1 then
        btn:SetPoint("BOTTOMLEFT", FokusFrame.hpBar, "TOPLEFT", 0, 14)
    else
        btn:SetPoint("LEFT", FokusFrame.spellButtons[i-1], "RIGHT", 3, 0) 
    end
    
    -- Design of the solid jet-black background layout border frames
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8", 
        tile = false, tileSize = 0, edgeSize = 1, 
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    btn:SetBackdropColor(0, 0, 0, 1) 
    btn:SetBackdropBorderColor(0, 0, 0, 1) -- FIXED: Changed completely to clean jet-black!
    
    -- Instantiate spell bar icon texture layers within a safe margin offset frame
    btn.tex = btn:CreateTexture(nil, "BORDER")
    btn.tex:SetPoint("TOPLEFT", btn, "TOPLEFT", 1, -1) 
    btn.tex:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -1, 1)
    btn.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92) 
    
    btn:RegisterForClicks("AnyUp")
    btn:Hide() 
    
    FokusFrame.spellButtons[i] = btn
end

-- FUNCTION: Re-renders and updates active spell allocations from account character logs
function FokusEra_RefreshSpellBar()
    if InCombatLockdown() then return end 
    
    FokusEra_Spells = FokusEra_Spells or {}
    
    for i = 1, 5 do
        local btn = FokusFrame.spellButtons[i]
        local spellID = FokusEra_Spells[i]
        
        if spellID then
            -- Convert to numeric type if possible to preserve downranking support
            local numericID = tonumber(spellID)
            local name, _, texture = GetSpellInfo(numericID)
            
            if texture then
                btn.tex:SetTexture(texture)
                
                btn:SetAttribute("type", "spell")
                btn:SetAttribute("spell", name or numericID) 
                btn:SetAttribute("unit", FokusFrame:GetAttribute("unit")) 
                
                btn:Show()
            else
                btn:Hide()
            end
        else
            btn:Hide()
        end
    end
end

-- Wire an automatic callback interface hook routine during character boot validation cycles
local spellBootLoader = CreateFrame("Frame")
spellBootLoader:RegisterEvent("PLAYER_LOGIN")
spellBootLoader:SetScript("OnEvent", function(self)
    FokusEra_RefreshSpellBar()
    spellBootLoader:UnregisterEvent("PLAYER_LOGIN")
end)
