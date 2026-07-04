-- Catch the shared addon namespace parameter from the WoW engine
local addonName, FokusEraNS = ...

-- Allocate dedicated anchor frames for managing icons under the mana bar
FokusFrame.buffContainer = CreateFrame("Frame", nil, FokusFrame)
-- FIX v1.3.0: Shifted Y-offset from -3 to -7 to drop the row exactly 4 extra pixels down below the frame edge
FokusFrame.buffContainer:SetPoint("TOPLEFT", FokusFrame.manaBar, "BOTTOMLEFT", 0, -7)
FokusFrame.buffContainer:SetSize(1, 12) -- Adjusted container height to 12

FokusFrame.debuffContainer = CreateFrame("Frame", nil, FokusFrame)
FokusFrame.debuffContainer:SetPoint("TOPLEFT", FokusFrame.buffContainer, "BOTTOMLEFT", 0, -3)
FokusFrame.debuffContainer:SetSize(1, 12)

FokusFrame.buffButtons = {}
FokusFrame.debuffButtons = {}

-- Local helper engine to instantiate aura icon objects dynamically on demand
local function CreateAuraIcon(parent, index, namePrefix)
    local btn = CreateFrame("Frame", namePrefix .. index, parent)
    btn:SetSize(12, 12) -- FIX v1.3.0: Downscaled icon sizes to ultra-compact 12x12 pixels
    
    btn.tex = btn:CreateTexture(nil, "ARTWORK")
    btn.tex:SetAllPoints()
    btn.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Clean edge cropping
    
    -- Add mouseover tooltip validation support
    btn:SetScript("OnEnter", function(self)
        if not self.unit or not self.index then return end
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
        if namePrefix == "FokusEraBuff" then
            GameTooltip:SetUnitBuff(self.unit, self.index)
        else
            GameTooltip:SetUnitDebuff(self.unit, self.index)
        end
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    return btn
end

-- FUNCTION: Dynamically recalculates width capacity thresholds and renders all active focus auras
function FokusEra_RefreshAuras()
    local token = FokusFrame:GetAttribute("unit")
    if not token or not UnitExists(token) or not FokusFrame:IsShown() then return end
    
    local frameWidth = FokusFrame:GetWidth()
    local barWidth = frameWidth - 62 -- Mirrors our exact status bar widths logic
    
    -- Determine the absolute maximum number of 12x12 pixel icons that can fit horizontally (12 width + 1 spacing)
    local maxIconsPerRow = math.floor(barWidth / 13)
    if maxIconsPerRow < 1 then maxIconsPerRow = 1 end
    
    ---------------------------------------------------------------------------
    -- 1. PROCESS BENEFICIAL BUFFS LISTING
    ---------------------------------------------------------------------------
    local activeBuffCount = 0
    if FokusEra_ShowBuffs then
        for i = 1, 40 do
            local name, icon = UnitBuff(token, i)
            if not name then break end
            
            activeBuffCount = activeBuffCount + 1
            if activeBuffCount <= maxIconsPerRow then
                if not FokusFrame.buffButtons[activeBuffCount] then
                    FokusFrame.buffButtons[activeBuffCount] = CreateAuraIcon(FokusFrame.buffContainer, activeBuffCount, "FokusEraBuff")
                end
                
                local btn = FokusFrame.buffButtons[activeBuffCount]
                btn.tex:SetTexture(icon)
                btn.unit = token
                btn.index = i
                
                btn:ClearAllPoints()
                if activeBuffCount == 1 then
                    btn:SetPoint("TOPLEFT", FokusFrame.buffContainer, "TOPLEFT", 0, 0)
                else
                    btn:SetPoint("LEFT", FokusFrame.buffButtons[activeBuffCount - 1], "RIGHT", 1, 0) -- 1 pixel tight spacing
                end
                btn:Show()
            end
        end
    end
    
    -- Conceal unassigned layout frames
    for i = activeBuffCount + 1, #FokusFrame.buffButtons do
        if FokusFrame.buffButtons[i] then FokusFrame.buffButtons[i]:Hide() end
    end
    
    ---------------------------------------------------------------------------
    -- 2. PROCESS HARMFUL DEBUFFS LISTING
    ---------------------------------------------------------------------------
    -- Adjust debuff container baseline anchors dynamically depending on whether buffs row is active
    FokusFrame.debuffContainer:ClearAllPoints()
    if activeBuffCount > 0 and FokusEra_ShowBuffs then
        FokusFrame.debuffContainer:SetPoint("TOPLEFT", FokusFrame.buffContainer, "BOTTOMLEFT", 0, -3)
    else
        -- FIX v1.3.0: Also dropped the fallback debuff anchor to -7 if buffs are disabled
        FokusFrame.debuffContainer:SetPoint("TOPLEFT", FokusFrame.manaBar, "BOTTOMLEFT", 0, -7)
    end
    
    local activeDebuffCount = 0
    if FokusEra_ShowDebuffs then
        for i = 1, 40 do
            local name, icon = UnitDebuff(token, i)
            if not name then break end
            
            activeDebuffCount = activeDebuffCount + 1
            if activeDebuffCount <= maxIconsPerRow then
                if not FokusFrame.debuffButtons[activeDebuffCount] then
                    FokusFrame.debuffButtons[activeDebuffCount] = CreateAuraIcon(FokusFrame.debuffContainer, activeDebuffCount, "FokusEraDebuff")
                end
                
                local btn = FokusFrame.debuffButtons[activeDebuffCount]
                btn.tex:SetTexture(icon)
                btn.unit = token
                btn.index = i
                
                btn:ClearAllPoints()
                if activeDebuffCount == 1 then
                    btn:SetPoint("TOPLEFT", FokusFrame.debuffContainer, "TOPLEFT", 0, 0)
                else
                    btn:SetPoint("LEFT", FokusFrame.debuffButtons[activeDebuffCount - 1], "RIGHT", 1, 0)
                end
                btn:Show()
            end
        end
    end
    
    for i = activeDebuffCount + 1, #FokusFrame.debuffButtons do
        if FokusFrame.debuffButtons[i] then FokusFrame.debuffButtons[i]:Hide() end
    end
end
