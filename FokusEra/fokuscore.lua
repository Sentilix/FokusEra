-- Catch the shared addon namespace parameter from the WoW engine
local addonName, FokusEraNS = ...

-- Heartbeat Update Loop execution (Fires exactly 10 times a second)
FokusFrame.timeSinceLastUpdate = 0
FokusFrame.lastRenderedGUID = nil
FokusTargetFrame.lastRenderedTargetGUID = nil 

FokusFrame:SetScript("OnUpdate", function(self, elapsed)
    if not FokusEraNS.FokusEra_CT then 
        self:Hide()
        FokusEraTargetFrame:Hide()
        return 
    end

    self.timeSinceLastUpdate = self.timeSinceLastUpdate + elapsed
    if self.timeSinceLastUpdate >= 0.1 then
        local token = FokusEraNS.FokusEra_CT

        -- DYNAMIC TOKEN VERIFICATION (Monitors group re-shuffles across grid maps)
        if not UnitExists(token) or UnitGUID(token) ~= FokusEraNS.FokusEra_CurrentGUID then
            local remapped = false
            if IsInRaid() then
                for i = 1, 40 do
                    if UnitGUID("raid"..i) == FokusEraNS.FokusEra_CurrentGUID then
                        FokusEraNS.FokusEra_CT = "raid"..i; token = "raid"..i; remapped = true; break
                    end
                end
            else
                if UnitGUID("player") == FokusEraNS.FokusEra_CurrentGUID then FokusEraNS.FokusEra_CT = "player"; token = "player"; remapped = true
                else
                    for i = 1, 4 do
                        if UnitGUID("party"..i) == FokusEraNS.FokusEra_CurrentGUID then
                            FokusEraNS.FokusEra_CT = "party"..i; token = "party"..i; remapped = true; break
                        end
                    end
                end
            end
            if not remapped then return end
        end

        if not UnitExists(token) then return end

        if FokusEra_UpdateInternalWidths then FokusEra_UpdateInternalWidths() end

        -- 1. RE-RENDER MAIN FOCUS METRICS
        self.nameText:SetText(FokusEraNS.FokusEra_CurrentName)
        local level = UnitLevel(token)
        self.levelText:SetText(level and level > 0 and "Lvl " .. level or "")

        local currentHP = UnitHealth(token)
        local maxHP = UnitHealthMax(token)
        self.hpBar:SetMinMaxValues(0, maxHP); self.hpBar:SetValue(currentHP)
        self.hpText:SetText(currentHP .. " / " .. maxHP)

        local _, class = UnitClass(token)
        if class and RAID_CLASS_COLORS[class] then
            local c = RAID_CLASS_COLORS[class]; self.nameText:SetTextColor(c.r, c.g, c.b)
        else self.nameText:SetTextColor(1, 0.82, 0) end

        local powerType = UnitPowerType(token)
        local currentPower = UnitPower(token, powerType)
        local maxPower = UnitPowerMax(token, powerType)
        self.manaBar:SetMinMaxValues(0, maxPower); self.manaBar:SetValue(currentPower)

        if powerType == 0 then self.manaBar:SetStatusBarColor(0, 0.4, 1) 
        elseif powerType == 1 then self.manaBar:SetStatusBarColor(1, 0, 0) 
        elseif powerType == 3 then self.manaBar:SetStatusBarColor(1, 1, 0) 
        else self.manaBar:SetStatusBarColor(0, 0.8, 0.8) end

        if self.portrait then
            self.portrait:Show()
            if self.lastRenderedGUID ~= FokusEraNS.FokusEra_CurrentGUID then
                self.portrait:SetUnit(token); self.portrait:SetCamera(0); self.lastRenderedGUID = FokusEraNS.FokusEra_CurrentGUID
            end
        end

        -- Call isolated engine modules to update raid markings and border colors for Main Focus
        if FokusEra_UpdateRaidTargetIcon then FokusEra_UpdateRaidTargetIcon(token, self.raidIcon) end
        
        if FokusEra_ScanUnitDebuffsAndGetBorderColor then
            local mainR, mainG, mainB = FokusEra_ScanUnitDebuffsAndGetBorderColor(token)
            self:SetBackdropBorderColor(mainR, mainG, mainB, 1)
        end

        -- 2. RE-RENDER FOCUS TARGET METRICS
        local targetToken = token .. "target"
        
        if UnitExists(targetToken) then
            FokusEraTargetFrame.nameText:SetText(UnitName(targetToken))
            
            local tCurrentHP = UnitHealth(targetToken)
            local tMaxHP = UnitHealthMax(targetToken)
            FokusEraTargetFrame.hpBar:SetMinMaxValues(0, tMaxHP)
            FokusEraTargetFrame.hpBar:SetValue(tCurrentHP)
            
            local _, tClass = UnitClass(targetToken)
            if tClass and RAID_CLASS_COLORS[tClass] then
                local c = RAID_CLASS_COLORS[tClass]; FokusEraTargetFrame.nameText:SetTextColor(c.r, c.g, c.b)
            elseif UnitIsEnemy("player", targetToken) then
                FokusEraTargetFrame.nameText:SetTextColor(1, 0.2, 0.2) 
            else
                FokusEraTargetFrame.nameText:SetTextColor(1, 0.82, 0) 
            end
            
            local tPowerType = UnitPowerType(targetToken)
            local tCurrentPower = UnitPower(targetToken, tPowerType)
            local tMaxPower = UnitPowerMax(targetToken, tPowerType)
            FokusEraTargetFrame.manaBar:SetMinMaxValues(0, tMaxPower)
            FokusEraTargetFrame.manaBar:SetValue(tCurrentPower)

            if tPowerType == 0 then FokusEraTargetFrame.manaBar:SetStatusBarColor(0, 0.4, 1) 
            elseif tPowerType == 1 then FokusEraTargetFrame.manaBar:SetStatusBarColor(1, 0, 0) 
            elseif tPowerType == 3 then FokusEraTargetFrame.manaBar:SetStatusBarColor(1, 1, 0) 
            else FokusTargetFrame.manaBar:SetStatusBarColor(0, 0.8, 0.8) end
            
            if FokusEraTargetFrame.portrait then
                FokusEraTargetFrame.portrait:Show()
                local currentTargetGUID = UnitGUID(targetToken)
                
                if FokusTargetFrame.lastRenderedTargetGUID ~= currentTargetGUID then
                    local renderToken = targetToken
                    if targetToken == "playertarget" and currentTargetGUID == UnitGUID("player") then
                        renderToken = "player"
                    end
                    
                    FokusEraTargetFrame.portrait:SetUnit(renderToken)
                    FokusEraTargetFrame.portrait:SetCamera(0)
                    FokusTargetFrame.lastRenderedTargetGUID = currentTargetGUID
                end
            end

            if FokusEra_UpdateRaidTargetIcon then FokusEra_UpdateRaidTargetIcon(targetToken, FokusEraTargetFrame.raidIcon) end
            
            FokusEraTargetFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
            
            FokusEraTargetFrame:Show()
        else
            FokusEraTargetFrame:Hide() 
        end

        self:Show()
        self.timeSinceLastUpdate = 0
    end
end)

-- CORE DATA ASSIGNMENT (Shared into Namespace array table)
function FokusEraNS.FokusEra_SetGroupFocus(unitToken)
    if InCombatLockdown() then return end
    if unitToken and FokusFrame then
        FokusEraNS.FokusEra_CT = unitToken
        FokusEraNS.FokusEra_CurrentGUID = UnitGUID(unitToken)
        FokusEraNS.FokusEra_CurrentName = UnitName(unitToken)
        print("|cff00ff00[FokusEra]|r Focus target set to: " .. FokusEraNS.FokusEra_CurrentName)
        
        -- FIX: Assign the raw unit string metadata straight onto the frame engine properties!
        -- This alerts external aura engines to parse the core target's buffs instead of falling back to default viewports.
        FokusFrame.unit = unitToken
        FokusFrame:SetAttribute("unit", unitToken)
        FokusFrame:SetAttribute("*unit", unitToken)
        
        if FokusTargetFrame then
            FokusTargetFrame.unit = unitToken .. "target"
            FokusTargetFrame:SetAttribute("unit", unitToken .. "target")
            FokusTargetFrame:SetAttribute("*unit", unitToken .. "target")
        end
        
        FokusFrame.lastRenderedGUID = nil
        FokusTargetFrame.lastRenderedTargetGUID = nil 
        FokusFrame:Show()
    end
end

-- DATA DE-ALLOCATION MANAGEMENT ROUTINE (Shared into Namespace array table)
function FokusEraNS.FokusEra_ClearGroupFocusLogic()
    FokusEraNS.FokusEra_CT = nil; FokusEraNS.FokusEra_CurrentGUID = nil; FokusEraNS.FokusEra_CurrentName = nil
    if FokusFrame then
        FokusFrame.unit = nil
        FokusFrame:SetAttribute("unit", nil); FokusFrame:SetAttribute("*unit", nil)
        
        if FokusTargetFrame then
            FokusTargetFrame.unit = nil
            FokusTargetFrame:SetAttribute("unit", nil); FokusTargetFrame:SetAttribute("*unit", nil)
        end
        
        FokusFrame.lastRenderedGUID = nil; FokusTargetFrame.lastRenderedTargetGUID = nil
        FokusFrame:Hide(); FokusEraTargetFrame:Hide()
    end
    print("|cff00ff00[FokusEra]|r Focus target cleared.")
end

---------------------------------------------------------
-- BUGFIX: AUTOMATIC PURGE ON ROSTER CHANGES
---------------------------------------------------------
local groupCheckFrame = CreateFrame("Frame")
groupCheckFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
groupCheckFrame:SetScript("OnEvent", function(self, event)
    if FokusEraNS.FokusEra_CT then
        if FokusEraNS.FokusEra_CT == "player" then return end

        local targetStillInGroup = false
        
        if IsInRaid() then
            for i = 1, 40 do
                if UnitGUID("raid"..i) == FokusEraNS.FokusEra_CurrentGUID then
                    targetStillInGroup = true
                    break
                end
            end
        else
            for i = 1, 4 do
                if UnitGUID("party"..i) == FokusEraNS.FokusEra_CurrentGUID then
                    targetStillInGroup = true
                    break
                end
            end
        end
        
        if not targetStillInGroup then
            FokusEraNS.FokusEra_ClearGroupFocusLogic()
            if FokusEra_RefreshSpellBar then FokusEra_RefreshSpellBar() end
        end
    end
end)
