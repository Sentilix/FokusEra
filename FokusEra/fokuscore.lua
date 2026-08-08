-- Catch the shared addon namespace parameter from the WoW engine
local addonName, FokusEraNS = ...

FokusFrame.timeSinceLastUpdate = 0
FokusFrame.lastRenderedGUID = nil
FokusTargetFrame.lastRenderedTargetGUID = nil

FokusEraNS.FokusEra_NPCGUID = nil
FokusEraNS.FokusEra_NPCTargetGUID = nil

-------------------------------------------------------------------------------
-- ENGINE HELPER: Scans entire raid environment to map a strict token onto a GUID
-------------------------------------------------------------------------------
local function FindValidTokenFromGUID(targetGUID)
    if not targetGUID then return nil end
    if UnitGUID("target") == targetGUID then return "target" end
    if UnitGUID("mouseover") == targetGUID then return "mouseover" end
    if UnitGUID("player") == targetGUID then return "player" end
    
    if IsInRaid() then
        for i = 1, 40 do
            local rToken = "raid" .. i
            if UnitGUID(rToken) == targetGUID then return rToken end
            if UnitGUID(rToken .. "target") == targetGUID then return rToken .. "target" end
        end
    else
        for i = 1, 4 do
            local pToken = "party" .. i
            if UnitGUID(pToken) == targetGUID then return pToken end
            if UnitGUID(pToken .. "target") == targetGUID then return pToken .. "target" end
        end
    end
    return nil
end

-------------------------------------------------------------------------------
-- MAIN CORE UPDATE ROUTINE (The Quad-Engine Heartbeat)
-------------------------------------------------------------------------------
FokusFrame:SetScript("OnUpdate", function(self, elapsed)
    if not FokusEraNS.FokusEra_CT and not FokusEraNS.FokusEra_NPCGUID then
        if not InCombatLockdown() then
            self:Hide(); FokusEraTargetFrame:Hide(); FokusNPCFrame:Hide(); FokusTargetNPCFrame:Hide()
        end
        return 
    end

    self.timeSinceLastUpdate = self.timeSinceLastUpdate + elapsed
    if self.timeSinceLastUpdate >= 0.1 then
        -- We no longer force full layout geometric re-alignment ticks inside combat loops!
        
        -----------------------------------------------------------------------
        -- ENGINE LAYER A: REGULAR PLAYER FOCUS ROUTINE
        -----------------------------------------------------------------------
        if FokusEraNS.FokusEra_CT then
            local token = FokusEraNS.FokusEra_CT
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

            self.nameText:SetText(FokusEraNS.FokusEra_CurrentName)
            local level = UnitLevel(token)
            self.levelText:SetText(level and level > 0 and "Lvl " .. level or "")

            local currentHP = UnitHealth(token); local maxHP = UnitHealthMax(token)
            self.hpBar:SetMinMaxValues(0, maxHP); self.hpBar:SetValue(currentHP); self.hpText:SetText(currentHP .. " / " .. maxHP)

            local _, class = UnitClass(token)
            if class and RAID_CLASS_COLORS[class] then
                local c = RAID_CLASS_COLORS[class]; self.nameText:SetTextColor(c.r, c.g, c.b)
            else self.nameText:SetTextColor(1, 0.82, 0) end

            local powerType = UnitPowerType(token)
            local currentPower = UnitPower(token, powerType); local maxPower = UnitPowerMax(token, powerType)
            self.manaBar:SetMinMaxValues(0, maxPower); self.manaBar:SetValue(currentPower)

            if powerType == 0 then self.manaBar:SetStatusBarColor(0, 0.4, 1) 
            elseif powerType == 1 then self.manaBar:SetStatusBarColor(1, 0, 0) 
            elseif powerType == 3 then self.manaBar:SetStatusBarColor(1, 1, 0) 
            else self.manaBar:SetStatusBarColor(0, 0.8, 0.8) end

            if self.portrait and self.lastRenderedGUID ~= FokusEraNS.FokusEra_CurrentGUID then
                self.portrait:Show(); self.portrait:SetUnit(token); self.portrait:SetCamera(0); self.lastRenderedGUID = FokusEraNS.FokusEra_CurrentGUID
            end

            if FokusEra_UpdateRaidTargetIcon then FokusEra_UpdateRaidTargetIcon(token, self.raidIcon) end
            if FokusEra_ScanUnitDebuffsAndGetBorderColor then
                local r, g, b = FokusEra_ScanUnitDebuffsAndGetBorderColor(token)
                self:SetBackdropBorderColor(r, g, b, 1)
            end
            if FokusEraNS.FokusEra_RefreshAuras then FokusEraNS.FokusEra_RefreshAuras() end

            local targetToken = token .. "target"
            if UnitExists(targetToken) then
                FokusEraTargetFrame.nameText:SetText(UnitName(targetToken))
                local tCurrentHP = UnitHealth(targetToken); local tMaxHP = UnitHealthMax(targetToken)
                FokusEraTargetFrame.hpBar:SetMinMaxValues(0, tMaxHP); FokusEraTargetFrame.hpBar:SetValue(tCurrentHP)
                
                local _, tClass = UnitClass(targetToken)
                if tClass and RAID_CLASS_COLORS[tClass] then
                    local c = RAID_CLASS_COLORS[tClass]; FokusEraTargetFrame.nameText:SetTextColor(c.r, c.g, c.b)
                elseif UnitIsEnemy("player", targetToken) then FokusEraTargetFrame.nameText:SetTextColor(1, 0.2, 0.2)
                else FokusEraTargetFrame.nameText:SetTextColor(1, 0.82, 0) end
                
                local tPowerType = UnitPowerType(targetToken)
                FokusEraTargetFrame.manaBar:SetMinMaxValues(0, UnitPowerMax(targetToken, tPowerType)); FokusEraTargetFrame.manaBar:SetValue(UnitPower(targetToken, tPowerType))
                
                if FokusEraTargetFrame.portrait and self.lastRenderedTargetGUID ~= UnitGUID(targetToken) then
                    FokusEraTargetFrame.portrait:Show(); FokusEraTargetFrame.portrait:SetUnit(targetToken); FokusEraTargetFrame.portrait:SetCamera(0); self.lastRenderedTargetGUID = UnitGUID(targetToken)
                end
            else
                if InCombatLockdown() then FokusEraTargetFrame.nameText:SetText(""); FokusEraTargetFrame.hpBar:SetValue(0) else FokusEraTargetFrame:Hide() end
            end

            -----------------------------------------------------------------------
            -- ENGINE LAYER B: ADVANCED UNIVERSAL NPC / BOSS FOCUS ROUTINE
            -----------------------------------------------------------------------
        elseif FokusEraNS.FokusEra_NPCGUID then
            -- NO MORE RUNTIME SHOW CALL OVERRIDES IN COMBAT UPDATES!
            
            local scanToken = FindValidTokenFromGUID(FokusEraNS.FokusEra_NPCGUID)
            if scanToken then
                FokusNPCFrame.nameText:SetText(FokusEraNS.FokusEra_CurrentName)
                FokusNPCFrame.hpBar:SetStatusBarColor(0, 0.8, 0)
                
                local level = UnitLevel(scanToken)
                FokusNPCFrame.levelText:SetText(level and level > 0 and "Lvl " .. level or "")
                
                local currentHP = UnitHealth(scanToken); local maxHP = UnitHealthMax(scanToken)
                FokusNPCFrame.hpBar:SetMinMaxValues(0, maxHP); FokusNPCFrame.hpBar:SetValue(currentHP)
                FokusNPCFrame.hpText:SetText(currentHP .. " / " .. maxHP)
                
                local _, scanClass = UnitClass(scanToken)
                if UnitIsPlayer(scanToken) and scanClass and RAID_CLASS_COLORS[scanClass] then
                    local c = RAID_CLASS_COLORS[scanClass]; FokusNPCFrame.nameText:SetTextColor(c.r, c.g, c.b)
                elseif UnitIsEnemy("player", scanToken) then FokusNPCFrame.nameText:SetTextColor(1, 0.2, 0.2)
                elseif UnitIsFriend("player", scanToken) then FokusNPCFrame.nameText:SetTextColor(0.2, 1, 0.2)
                else FokusNPCFrame.nameText:SetTextColor(1, 0.82, 0) end
                
                local maxPower = UnitPowerMax(scanToken)
                if maxPower and maxPower > 0 then
                    FokusNPCFrame.manaBar:Show()
                    FokusNPCFrame.hpBar:SetHeight(14)
                    FokusNPCFrame.manaBar:SetMinMaxValues(0, maxPower); FokusNPCFrame.manaBar:SetValue(UnitPower(scanToken))
                else
                    FokusNPCFrame.manaBar:Hide()
                    FokusNPCFrame.hpBar:SetHeight(22) 
                end
                
                if FokusNPCFrame.portrait and self.lastRenderedGUID ~= FokusEraNS.FokusEra_NPCGUID then
                    FokusNPCFrame.portrait:Show(); FokusNPCFrame.portrait:SetUnit(scanToken); FokusNPCFrame.portrait:SetCamera(0); self.lastRenderedGUID = FokusEraNS.FokusEra_NPCGUID
                end
                
                if FokusEra_UpdateRaidTargetIcon then 
                    FokusEra_UpdateRaidTargetIcon(scanToken, FokusNPCFrame.raidIcon) 
                end
                
                local bossTargetToken = scanToken .. "target"
                if UnitExists(bossTargetToken) then
                    FokusTargetNPCFrame:Show()
                    FokusTargetNPCFrame.nameText:SetText(UnitName(bossTargetToken))
                    
                    local btCurrentHP = UnitHealth(bossTargetToken); local btMaxHP = UnitHealthMax(bossTargetToken)
                    FokusTargetNPCFrame.hpBar:SetMinMaxValues(0, btMaxHP); FokusTargetNPCFrame.hpBar:SetValue(btCurrentHP)
                    
                    local _, btClass = UnitClass(bossTargetToken)
                    if btClass and RAID_CLASS_COLORS[btClass] then
                        local c = RAID_CLASS_COLORS[btClass]; FokusTargetNPCFrame.nameText:SetTextColor(c.r, c.g, c.b)
                    elseif UnitIsEnemy("player", bossTargetToken) then FokusTargetNPCFrame.nameText:SetTextColor(1, 0.2, 0.2)
                    else FokusTargetNPCFrame.nameText:SetTextColor(1, 0.82, 0) end
                    
                    local btMaxPower = UnitPowerMax(bossTargetToken)
                    if btMaxPower and btMaxPower > 0 then
                        FokusTargetNPCFrame.manaBar:Show()
                        FokusTargetNPCFrame.hpBar:SetHeight(14)
                        FokusTargetNPCFrame.manaBar:SetMinMaxValues(0, btMaxPower); FokusTargetNPCFrame.manaBar:SetValue(UnitPower(bossTargetToken))
                    else
                        FokusTargetNPCFrame.manaBar:Hide()
                        FokusTargetNPCFrame.hpBar:SetHeight(22)
                    end
                    
                    local currentBTGUID = UnitGUID(bossTargetToken)
                    if FokusTargetNPCFrame.portrait and self.lastRenderedTargetGUID ~= currentBTGUID then
                        FokusTargetNPCFrame.portrait:Show(); FokusTargetNPCFrame.portrait:SetUnit(bossTargetToken); FokusTargetNPCFrame.portrait:SetCamera(0); self.lastRenderedTargetGUID = currentBTGUID
                    end
                    
                    if FokusEra_UpdateRaidTargetIcon then 
                        FokusEra_UpdateRaidTargetIcon(bossTargetToken, FokusTargetNPCFrame.raidIcon) 
                    end
                else
                    FokusTargetNPCFrame:Hide()
                end
            else
                FokusNPCFrame.nameText:SetText(FokusEraNS.FokusEra_CurrentName)
                FokusNPCFrame.hpBar:SetStatusBarColor(1, 0.82, 0) -- Amber warning colors
                FokusTargetNPCFrame:Hide()
            end
        end
    end
end)

-- Central Memory Tracker explicitly tracking our active states (PLAYER, NPC, NIL)
FokusEraNS.CurrentFocusState = "NIL"

-- CORE DATA ASSIGNMENT (Shared into Namespace array table)
function FokusEraNS.FokusEra_SetGroupFocus(unitToken)
    if InCombatLockdown() then return end
    if unitToken and FokusFrame and FokusShadowFrame then
        -- Catch forced non-group player overrides string sequences cleanly
        local actualToken = unitToken
        local isForcedNPC = false
        if unitToken == "target_npc_override" then
            actualToken = "target"
            isForcedNPC = true
        end

        -- Defend against nil exceptions by providing safe engine fallbacks
        local rawGUID = UnitGUID(actualToken) or "0x0"
        local rawName = UnitName(actualToken) or "Unknown Entity"
        
        FokusEraNS.FokusEra_CurrentGUID = rawGUID
        FokusEraNS.FokusEra_CurrentName = rawName
        
        -- Route entity to PLAYER only if it's a Player AND not explicitly forced to NPC shell
        local nextState = (UnitIsPlayer(actualToken) and not isForcedNPC) and "PLAYER" or "NPC"
        local previousState = FokusEraNS.CurrentFocusState
        
        if nextState == "PLAYER" then
            FokusEraNS.FokusEra_CT = actualToken
            FokusEraNS.FokusEra_NPCGUID = nil 
            
            FokusFrame.unit = actualToken
            FokusFrame:SetAttribute("unit", actualToken)
            FokusFrame:SetAttribute("*unit", actualToken)
            
            if FokusTargetFrame then
                FokusTargetFrame.unit = actualToken .. "target"
                FokusTargetFrame:SetAttribute("unit", actualToken .. "target")
                FokusTargetFrame:SetAttribute("*unit", actualToken .. "target")
            end
            print("|cff00ff00[FokusEra]|r Friendly Player Focus set to: " .. FokusEraNS.FokusEra_CurrentName)
            
            -- SCENARIE 1 & 7: Pull player frame elevator back cleanly onto absolute screen coordinates!
            -- FIX v1.4.0: Anchored exclusively to UIParent to eliminate secure mouse-hit detection taints!
            if previousState == "NIL" or previousState == "NPC" then
                if previousState == "NPC" then FokusNPCFrame:Hide(); FokusTargetNPCFrame:Hide() end
                
                if not InCombatLockdown() then
                    FokusFrame:ClearAllPoints()
                    local shadowLeft = FokusShadowFrame:GetLeft()
                    local shadowBottom = FokusShadowFrame:GetBottom()
                    if shadowLeft and shadowBottom then
                        FokusFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", shadowLeft, shadowBottom)
                    else
                        FokusFrame:SetPoint("CENTER", UIParent, "CENTER", -65, -150)
                    end
                end
            end
            -- SCENARIE 2: PLAYER -> PLAYER (Do absolutely nothing to the layout anchors)
            
            FokusFrame:Show()
            if FokusTargetFrame then FokusTargetFrame:Show() end
            FokusNPCFrame:Hide(); FokusTargetNPCFrame:Hide()
            
        else
            -- NEXT STATE IS NPC
            FokusEraNS.FokusEra_CT = nil
            FokusEraNS.FokusEra_NPCGUID = rawGUID
            
            FokusFrame.unit = nil
            FokusFrame:SetAttribute("unit", nil); FokusFrame:SetAttribute("*unit", nil)
            print("|cff00ff00[FokusEra]|r Combat NPC/Boss Focus set to: " .. FokusEraNS.FokusEra_CurrentName)
            
            -- SCENARIE 3: PLAYER -> NPC (Drop Y-elevator relative to UIParent center topology)
            if previousState == "PLAYER" then
                if not InCombatLockdown() then
                    FokusFrame:ClearAllPoints()
                    local shadowLeft = FokusShadowFrame:GetLeft()
                    if shadowLeft then
                        FokusFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", shadowLeft, -10000)
                    else
                        FokusFrame:SetPoint("CENTER", UIParent, "CENTER", -65, -10000)
                    end
                    if FokusEraTargetFrame then FokusEraTargetFrame:Hide() end
                end
            end
            
            -- SCENARIE 4 & 5: Anchor NPC skaller straight to our single source of truth shadow frame
            FokusFrame:Show() 
            FokusNPCFrame:Show()
            if FokusTargetNPCFrame then FokusTargetNPCFrame:Hide() end
            if FokusEra_AlignNPCLayouts then FokusEra_AlignNPCLayouts() end
            FokusTargetFrame:Hide()
        end
        
        FokusEraNS.CurrentFocusState = nextState 
        FokusFrame.lastRenderedGUID = nil
        FokusTargetFrame.lastRenderedTargetGUID = nil 
        if FokusEraNS.FokusEra_RefreshAuras then FokusEraNS.FokusEra_RefreshAuras() end
    end
end

-- DATA DE-ALLOCATION MANAGEMENT ROUTINE (Shared into Namespace array table)
function FokusEraNS.FokusEra_ClearGroupFocusLogic()
    local previousState = FokusEraNS.CurrentFocusState
    
    FokusEraNS.FokusEra_CT = nil; FokusEraNS.FokusEra_NPCGUID = nil
    FokusEraNS.FokusEra_CurrentGUID = nil; FokusEraNS.FokusEra_CurrentName = nil
    FokusEraNS.CurrentFocusState = "NIL" 
    
    if FokusFrame then
        FokusFrame.unit = nil
        FokusFrame:SetAttribute("unit", nil)
        FokusFrame:SetAttribute("*unit", nil)
        
        if FokusTargetFrame then
            FokusTargetFrame.unit = nil
            FokusTargetFrame:SetAttribute("unit", nil)
            FokusTargetFrame:SetAttribute("*unit", nil)
        end
        
        FokusFrame.lastRenderedGUID = nil; FokusTargetFrame.lastRenderedTargetGUID = nil
        
        -- SCENARIE 4: PLAYER -> NIL (Drop Y-elevator out of sight relative to UIParent)
        if previousState == "PLAYER" then
            if not InCombatLockdown() then
                FokusFrame:ClearAllPoints()
                local shadowLeft = FokusShadowFrame:GetLeft()
                if shadowLeft then
                    FokusFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", shadowLeft, -10000)
                else
                    FokusFrame:SetPoint("CENTER", UIParent, "CENTER", -65, -10000)
                end
            end
        end
        
        -- SCENARIE 8: NPC -> NIL (Trigger Hide and collapse layouts instantly)
        if InCombatLockdown() then
            FokusFrame.nameText:SetText(""); FokusFrame.hpBar:SetValue(0)
            FokusNPCFrame.nameText:SetText(""); FokusNPCFrame.hpBar:SetValue(0)
            FokusTargetNPCFrame:Hide()
        else
            FokusFrame:Hide(); FokusEraTargetFrame:Hide(); FokusNPCFrame:Hide(); FokusTargetNPCFrame:Hide()
        end
    end
    print("|cff00ff00[FokusEra]|r Focus target cleared.")
    if FokusEraNS.FokusEra_RefreshAuras then FokusEraNS.FokusEra_RefreshAuras() end
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
                if UnitGUID("raid"..i) == FokusEraNS.FokusEra_CurrentGUID then targetStillInGroup = true; break end
            end
        else
            for i = 1, 4 do
                if UnitGUID("party"..i) == FokusEraNS.FokusEra_CurrentGUID then targetStillInGroup = true; break end
            end
        end
        
        if not targetStillInGroup then
            FokusEraNS.FokusEra_ClearGroupFocusLogic()
        end
    end
end)

-- end fokuscore.lua