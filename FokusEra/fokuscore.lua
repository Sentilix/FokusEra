-- Catch the shared addon namespace parameter from the WoW engine
local addonName, FokusEraNS = ...

-- Heartbeat Update Loop execution (Fires exactly 10 times a second)
FokusFrame.timeSinceLastUpdate = 0
FokusFrame.lastRenderedGUID = nil

FokusFrame:SetScript("OnUpdate", function(self, elapsed)
    -- Exit routine if no active focus token data is registered inside the shared namespace
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

        -- Force active bar frames to preserve stretched dimensions across loop updates
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

        if powerType == 0 then self.manaBar:SetStatusBarColor(0, 0.4, 1) -- Blue Mana
        elseif powerType == 1 then self.manaBar:SetStatusBarColor(1, 0, 0) -- Red Rage
        elseif powerType == 3 then self.manaBar:SetStatusBarColor(1, 1, 0) -- Yellow Energy
        else self.manaBar:SetStatusBarColor(0, 0.8, 0.8) end

        if self.portrait then
            self.portrait:Show()
            if self.lastRenderedGUID ~= FokusEraNS.FokusEra_CurrentGUID then
                self.portrait:SetUnit(token); self.portrait:SetCamera(0); self.lastRenderedGUID = FokusEraNS.FokusEra_CurrentGUID
            end
        end

        -- 2. RE-RENDER FOCUS TARGET METRICS (Now with unified power bar loop)
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

            if tPowerType == 0 then FokusEraTargetFrame.manaBar:SetStatusBarColor(0, 0.4, 1) -- Blue Mana
            elseif tPowerType == 1 then FokusEraTargetFrame.manaBar:SetStatusBarColor(1, 0, 0) -- Red Rage
            elseif tPowerType == 3 then FokusEraTargetFrame.manaBar:SetStatusBarColor(1, 1, 0) -- Yellow Energy
            else FokusEraTargetFrame.manaBar:SetStatusBarColor(0, 0.8, 0.8) end
            
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
        
        FokusFrame:SetAttribute("unit", unitToken)
        FokusFrame:SetAttribute("*unit", unitToken)
        
        FokusEraTargetFrame:SetAttribute("unit", unitToken .. "target")
        FokusEraTargetFrame:SetAttribute("*unit", unitToken .. "target")
        
        FokusFrame.lastRenderedGUID = nil
        FokusFrame:Show()
    end
end

-- DATA DE-ALLOCATION MANAGEMENT ROUTINE (Shared into Namespace array table)
function FokusEraNS.FokusEra_ClearGroupFocusLogic()
    FokusEraNS.FokusEra_CT = nil; FokusEraNS.FokusEra_CurrentGUID = nil; FokusEraNS.FokusEra_CurrentName = nil
    if FokusFrame then
        FokusFrame:SetAttribute("unit", nil); FokusFrame:SetAttribute("*unit", nil)
        FokusEraTargetFrame:SetAttribute("unit", nil); FokusEraTargetFrame:SetAttribute("*unit", nil)
        FokusFrame.lastRenderedGUID = nil; FokusFrame:Hide(); FokusEraTargetFrame:Hide()
    end
    print("|cff00ff00[FokusEra]|r Focus target cleared.")
end

---------------------------------------------------------
-- BUGFIX: AUTOMATIC PURGE ON LEAVING GROUPS
---------------------------------------------------------
local groupCheckFrame = CreateFrame("Frame")
groupCheckFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
groupCheckFrame:SetScript("OnEvent", function(self, event)
    if FokusEraNS.FokusEra_CT and not IsInRaid() and not IsInGroup() then
        if FokusEraNS.FokusEra_CT ~= "player" then FokusEraNS.FokusEra_ClearGroupFocusLogic() end
    end
end)
