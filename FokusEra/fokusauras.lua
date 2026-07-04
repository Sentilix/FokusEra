-- Catch the shared addon namespace parameter from the WoW engine
local addonName, FokusEraNS = ...

-- 1. MAIN FOCUS CONTAINERS
FokusFrame.buffContainer = CreateFrame("Frame", nil, FokusFrame)
FokusFrame.buffContainer:SetPoint("TOPLEFT", FokusFrame, "BOTTOMLEFT", 6, 1) 
FokusFrame.buffContainer:SetSize(1, 12) 

FokusFrame.debuffContainer = CreateFrame("Frame", nil, FokusFrame)
FokusFrame.debuffContainer:SetPoint("TOPLEFT", FokusFrame.buffContainer, "BOTTOMLEFT", 0, -3)
FokusFrame.debuffContainer:SetSize(1, 12)

FokusFrame.buffButtons = {}
FokusFrame.debuffButtons = {}

-- 2. NEW: FOCUS TARGET CONTAINER
FokusTargetFrame.auraContainer = CreateFrame("Frame", nil, FokusTargetFrame)
FokusTargetFrame.auraContainer:SetPoint("TOPLEFT", FokusTargetFrame, "BOTTOMLEFT", 6, 1) -- Synchronized Y-axis alignment
FokusTargetFrame.auraContainer:SetSize(1, 12)

FokusTargetFrame.auraButtons = {}

-- Local helper engine to instantiate aura icon objects dynamically on demand
local function CreateAuraIcon(parent, index, namePrefix)
    local btn = CreateFrame("Frame", namePrefix .. index, parent)
    btn:SetSize(12, 12) 
    
    btn.tex = btn:CreateTexture(nil, "ARTWORK")
    btn.tex:SetAllPoints()
    btn.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92) 
    
    btn:SetScript("OnEnter", function(self)
        if not self.unit or not self.index then return end
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
        if self.isDebuff then
            GameTooltip:SetUnitDebuff(self.unit, self.index)
        else
            GameTooltip:SetUnitBuff(self.unit, self.index)
        end
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    return btn
end

-- FUNCTION: Dynamically recalculates width capacity thresholds and renders all active focus and target auras
function FokusEraNS.FokusEra_RefreshAuras()
    ---------------------------------------------------------------------------
    -- SECTION 1: PRIMARY FOCUS FRAME AURAS
    ---------------------------------------------------------------------------
    local token = FokusFrame:GetAttribute("unit")
    if token and UnitExists(token) and FokusFrame:IsShown() then
        local frameWidth = FokusFrame:GetWidth()
        local usableWidth = frameWidth - 12 
        local maxIconsPerRow = math.floor(usableWidth / 13)
        if maxIconsPerRow < 1 then maxIconsPerRow = 1 end
        
        -- Beneficial Buffs
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
                    btn.isDebuff = false
                    btn:ClearAllPoints()
                    if activeBuffCount == 1 then
                        btn:SetPoint("TOPLEFT", FokusFrame.buffContainer, "TOPLEFT", 0, 0)
                    else
                        btn:SetPoint("LEFT", FokusFrame.buffButtons[activeBuffCount - 1], "RIGHT", 1, 0)
                    end
                    btn:Show()
                end
            end
        end
        for i = activeBuffCount + 1, #FokusFrame.buffButtons do
            if FokusFrame.buffButtons[i] then FokusFrame.buffButtons[i]:Hide() end
        end
        
        -- Harmful Debuffs
        FokusFrame.debuffContainer:ClearAllPoints()
        if activeBuffCount > 0 and FokusEra_ShowBuffs then
            FokusFrame.debuffContainer:SetPoint("TOPLEFT", FokusFrame.buffContainer, "BOTTOMLEFT", 0, -3)
        else
            FokusFrame.debuffContainer:SetPoint("TOPLEFT", FokusFrame, "BOTTOMLEFT", 6, 1)
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
                    btn.isDebuff = true
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
    else
        for _, btn in pairs(FokusFrame.buffButtons) do btn:Hide() end
        for _, btn in pairs(FokusFrame.debuffButtons) do btn:Hide() end
    end

    ---------------------------------------------------------------------------
    -- SECTION 2: NEW FOCUS TARGET FRAME AURAS (Combined linear list)
    ---------------------------------------------------------------------------
    local targetToken = token and (token .. "target")
    if targetToken and UnitExists(targetToken) and FokusEraTargetFrame:IsShown() and FokusEra_ShowTargetAuras then
        local targetWidth = FokusEraTargetFrame:GetWidth()
        local usableTargetWidth = targetWidth - 12
        local maxTargetIcons = math.floor(usableTargetWidth / 13)
        if maxTargetIcons < 1 then maxTargetIcons = 1 end
        
        local totalAurasCount = 0
        
        -- Extract Debuffs first (Healers want to see what is harming the target instantly!)
        for i = 1, 40 do
            local name, icon = UnitDebuff(targetToken, i)
            if not name then break end
            totalAurasCount = totalAurasCount + 1
            if totalAurasCount <= maxTargetIcons then
                if not FokusTargetFrame.auraButtons[totalAurasCount] then
                    FokusTargetFrame.auraButtons[totalAurasCount] = CreateAuraIcon(FokusTargetFrame.auraContainer, totalAurasCount, "FokusTargetAura")
                end
                local btn = FokusTargetFrame.auraButtons[totalAurasCount]
                btn.tex:SetTexture(icon)
                btn.unit = targetToken
                btn.index = i
                btn.isDebuff = true
                btn:ClearAllPoints()
                if totalAurasCount == 1 then
                    btn:SetPoint("TOPLEFT", FokusTargetFrame.auraContainer, "TOPLEFT", 0, 0)
                else
                    btn:SetPoint("LEFT", FokusTargetFrame.auraButtons[totalAurasCount - 1], "RIGHT", 1, 0)
                end
                btn:Show()
            end
        end
        
        -- Append Buffs right after the debuffs onto the same clean row
        for i = 1, 40 do
            local name, icon = UnitBuff(targetToken, i)
            if not name then break end
            totalAurasCount = totalAurasCount + 1
            if totalAurasCount <= maxTargetIcons then
                if not FokusTargetFrame.auraButtons[totalAurasCount] then
                    FokusTargetFrame.auraButtons[totalAurasCount] = CreateAuraIcon(FokusTargetFrame.auraContainer, totalAurasCount, "FokusTargetAura")
                end
                local btn = FokusTargetFrame.auraButtons[totalAurasCount]
                btn.tex:SetTexture(icon)
                btn.unit = targetToken
                btn.index = i
                btn.isDebuff = false
                btn:ClearAllPoints()
                if totalAurasCount == 1 then
                    btn:SetPoint("TOPLEFT", FokusTargetFrame.auraContainer, "TOPLEFT", 0, 0)
                else
                    btn:SetPoint("LEFT", FokusTargetFrame.auraButtons[totalAurasCount - 1], "RIGHT", 1, 0)
                end
                btn:Show()
            end
        end
        
        -- Hide trailing frames
        for i = totalAurasCount + 1, #FokusTargetFrame.auraButtons do
            if FokusTargetFrame.auraButtons[i] then FokusTargetFrame.auraButtons[i]:Hide() end
        end
    else
        for _, btn in pairs(FokusTargetFrame.auraButtons) do btn:Hide() end
    end
end
