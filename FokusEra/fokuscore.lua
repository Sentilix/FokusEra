-- Catch the shared addon namespace parameter from the WoW engine
local addonName, FokusEraNS = ...

-- Initialize core heartbeat frame if not already created
local coreHeartbeat = _G["FokusEraHeartbeatFrame"] or CreateFrame("Frame", "FokusEraHeartbeatFrame", UIParent)
coreHeartbeat.elapsed = 0

-- Ensure the current focus state tracking variable exists inside the namespace
if FokusEraNS.CurrentFocusState == nil then
    FokusEraNS.CurrentFocusState = "NIL"
end

-- Global or local namespace definition for Power Type Colors (Classic Era fallback)
local POWER_TYPE_COLORS = {
    [0] = { r = 0.0, g = 0.0, b = 1.0 }, -- Mana (Blue)
    [1] = { r = 1.0, g = 0.0, b = 0.0 }, -- Rage (Red)
    [3] = { r = 1.0, g = 1.0, b = 0.0 }, -- Energy (Yellow)
}

-- MAIN MONITORING UPDATE LOOP (Ticking 10 times per second for clean CPU profiles)
coreHeartbeat:SetScript("OnUpdate", function(self, elapsed)
    self.elapsed = self.elapsed + elapsed
    if self.elapsed < 0.1 then return end
    self.elapsed = 0

    -- 1. FRIENDLY PLAYER STATE MONITORING PIPELINE
    if FokusEraNS.CurrentFocusState == "PLAYER" and FokusEraNS.FokusEra_CT then
        local token = FokusEraNS.FokusEra_CT
        local targetToken = token .. "target"

        -- Force hide the non-secure NPC target overlay to clear visual pollution
        if FokusTargetNPCFrame and FokusTargetNPCFrame:IsShown() and not InCombatLockdown() then
            FokusTargetNPCFrame:Hide()
        end

        -- Safety Guard: If focus unit data collapses unexpectedly, clear out
        if not UnitExists(token) or UnitGUID(token) ~= FokusEraNS.FokusEra_CurrentGUID then
            if FokusEraNS.FokusEra_ClearGroupFocusLogic then FokusEraNS.FokusEra_ClearGroupFocusLogic() end
            return
        end

        -- Main frame text data mapping
        FokusFrame.nameText:SetText(UnitName(token) or "Unknown")
        FokusFrame.levelText:SetText(UnitLevel(token) or "??")
        
        -- Health synchronization for the main frame
        local currentHP, maxHP = UnitHealth(token), UnitHealthMax(token)
        FokusFrame.hpBar:SetMinMaxValues(0, maxHP)
        FokusFrame.hpBar:SetValue(currentHP)
        FokusFrame.hpText:SetText(currentHP .. " / " .. maxHP)
        
        -- Mana/Power synchronization for the main frame with dynamic type coloring
        if FokusFrame.manaBar then
            local currentMana = UnitPower(token) or 0
            local maxMana = UnitPowerMax(token) or 100
            if maxMana <= 0 then maxMana = 100 end
            
            -- Fetch the native power type token index (0: Mana, 1: Rage, 3: Energy)
            local powerType, powerToken = UnitPowerType(token)
            local color = POWER_TYPE_COLORS[powerType] or { r = 0.0, g = 0.5, b = 1.0 } -- Fallback to light blue
            
            FokusFrame.manaBar:SetStatusBarColor(color.r, color.g, color.b)
            FokusFrame.manaBar:SetMinMaxValues(0, maxMana)
            FokusFrame.manaBar:SetValue(currentMana)
            
            if FokusFrame.manaText then
                FokusFrame.manaText:SetText(currentMana .. " / " .. maxMana)
            end
        end
        
        -- Main player frame 3D portrait cache guard
        local currentFocusGUID = UnitGUID(token)
        if currentFocusGUID and currentFocusGUID ~= FokusFrame.lastRenderedGUID then
            FokusFrame.lastRenderedGUID = currentFocusGUID
            if FokusFrame.portrait and FokusFrame.portrait.SetUnit then
                FokusFrame.portrait:SetUnit(token)
                FokusFrame.portrait:SetCamera(0)
            end
        end

        -- Consolidated target-of-focus tracking module
        if UnitExists(targetToken) then
            local targetGUID = UnitGUID(targetToken)

            -- Handle frame visibility safely outside combat lockdown
            if FokusTargetFrame and not FokusTargetFrame:IsShown() and not InCombatLockdown() then
                FokusTargetFrame.lastRenderedTargetGUID = nil
                FokusTargetFrame:Show()
            end

            -- Identity cache check: Refresh static strings and portrait layouts
            if targetGUID and targetGUID ~= FokusTargetFrame.lastRenderedTargetGUID then
                FokusTargetFrame.lastRenderedTargetGUID = targetGUID
                FokusTargetFrame.nameText:SetText(UnitName(targetToken) or "Target")
                
                if FokusTargetFrame.portrait and FokusTargetFrame.portrait.SetUnit then
                    FokusTargetFrame.portrait:SetUnit(targetToken)
                    FokusTargetFrame.portrait:SetCamera(0)
                end
            end

            -- Live Status Bar Taxonomical Coloring
            if FokusTargetFrame and FokusTargetFrame.hpBar then
                if UnitIsPlayer(targetToken) then
                    FokusTargetFrame.hpBar:SetStatusBarColor(0, 0.8, 0) -- Green
                elseif UnitReaction(targetToken, "player") >= 5 then
                    FokusTargetFrame.hpBar:SetStatusBarColor(0.8, 0.8, 0) -- Yellow
                else
                    FokusTargetFrame.hpBar:SetStatusBarColor(0.8, 0, 0) -- Red
                end
            end -- Note: We close the coloring block explicitly here to un-nest the data mapping cleanly
                
            -- CORE FIX FOR ERA API LIMITATION: Resolve exact source for live data values
            local dataSourceToken = targetToken
            if targetGUID then
                if targetGUID == UnitGUID("player") then
                    dataSourceToken = "player"
                elseif targetGUID == UnitGUID("target") then
                    dataSourceToken = "target"
                elseif targetGUID == UnitGUID("mouseover") then
                    dataSourceToken = "mouseover"
                else
                    for i = 1, 40 do
                        if UnitGUID("raid" .. i) == targetGUID then dataSourceToken = "raid" .. i; break
                        elseif UnitGUID("party" .. i) == targetGUID then dataSourceToken = "party" .. i; break
                        elseif UnitGUID("nameplate" .. i) == targetGUID then dataSourceToken = "nameplate" .. i; break end
                    end
                end
            end

            -- Live execution with strict fallback boundaries to prevent 0-max engine locks
            local tCurrentHP = UnitHealth(dataSourceToken) or 0
            local tMaxHP = UnitHealthMax(dataSourceToken) or 100
            if tMaxHP <= 0 then tMaxHP = 100 end -- Prevent division by zero / 100% texture freeze

            if FokusTargetFrame and FokusTargetFrame.hpBar then
                FokusTargetFrame.hpBar:SetMinMaxValues(0, tMaxHP)
                FokusTargetFrame.hpBar:SetValue(tCurrentHP)
                
                local hpString = FokusTargetFrame.hpText or _G["FokusTargetFrameHPText"]
                if hpString then
                    hpString:SetText(tCurrentHP .. " / " .. tMaxHP)
                end
            end

            -- Live power/mana execution with strict fallback boundaries and dynamic type coloring
            if FokusTargetFrame and FokusTargetFrame.manaBar then
                local tCurrentMana = UnitPower(dataSourceToken) or 0
                local tMaxMana = UnitPowerMax(dataSourceToken) or 100
                if tMaxMana <= 0 then tMaxMana = 100 end

                local tPowerType = UnitPowerType(dataSourceToken)
                local tColor = POWER_TYPE_COLORS[tPowerType] or { r = 0.0, g = 0.5, b = 1.0 }

                FokusTargetFrame.manaBar:SetStatusBarColor(tColor.r, tColor.g, tColor.b)
                FokusTargetFrame.manaBar:SetMinMaxValues(0, tMaxMana)
                FokusTargetFrame.manaBar:SetValue(tCurrentMana)
                
                local manaString = FokusTargetFrame.manaText or _G["FokusTargetFrameManaText"]
                if manaString then
                    manaString:SetText(tCurrentMana .. " / " .. tMaxMana)
                end
            end

        else -- This else matches the "if UnitExists(targetToken) then" way up in the hierarchy
            if FokusTargetFrame then
                FokusTargetFrame.lastRenderedTargetGUID = nil
                if not InCombatLockdown() and FokusTargetFrame:IsShown() then 
                    FokusTargetFrame:Hide() 
                end
            end
        end

    -- 2. COMBAT NPC / BOSS MONITORING PIPELINE
    elseif FokusEraNS.CurrentFocusState == "NPC" and FokusEraNS.FokusEra_NPCGUID then
        local rawGUID = FokusEraNS.FokusEra_NPCGUID
        local matchedToken = nil

        if UnitGUID("target") == rawGUID then matchedToken = "target"
        elseif UnitGUID("mouseover") == rawGUID then matchedToken = "mouseover"
        else
            for i = 1, 40 do
                if UnitGUID("raid" .. i .. "target") == rawGUID then matchedToken = "raid" .. i .. "target"; break
                elseif UnitGUID("party" .. i .. "target") == rawGUID then matchedToken = "party" .. i .. "target"; break end
            end
        end

        if matchedToken then
            local currentHP, maxGUIDHP = UnitHealth(matchedToken), UnitHealthMax(matchedToken)
            FokusNPCFrame.hpBar:SetStatusBarColor(0, 0.8, 0)
            FokusNPCFrame.hpBar:SetMinMaxValues(0, maxGUIDHP)
            FokusNPCFrame.hpBar:SetValue(currentHP)
            FokusNPCFrame.hpText:SetText(currentHP .. " / " .. maxGUIDHP)
            FokusNPCFrame.nameText:SetText(UnitName(matchedToken) or "Unknown NPC")
            
            if FokusNPCFrame.lastRenderedNPCGUID ~= rawGUID then
                FokusNPCFrame.lastRenderedNPCGUID = rawGUID
                if FokusNPCFrame.portrait and FokusNPCFrame.portrait.SetUnit then
                    FokusNPCFrame.portrait:SetUnit(matchedToken)
                    FokusNPCFrame.portrait:SetCamera(0)
                end
            end

            local bossTargetToken = matchedToken .. "target"
            if UnitExists(bossTargetToken) then
                local bTargetGUID = UnitGUID(bossTargetToken)
                if bTargetGUID ~= FokusTargetNPCFrame.lastRenderedTargetGUID then
                    FokusTargetNPCFrame.lastRenderedTargetGUID = bTargetGUID
                    FokusTargetNPCFrame.nameText:SetText(UnitName(bossTargetToken) or "Target")
                    if not InCombatLockdown() then FokusTargetNPCFrame:Show() end
                end
                FokusTargetNPCFrame.hpBar:SetMinMaxValues(0, UnitHealthMax(bossTargetToken))
                FokusTargetNPCFrame.hpBar:SetValue(UnitHealth(bossTargetToken))
            else
                FokusTargetNPCFrame.lastRenderedTargetGUID = nil
                if not InCombatLockdown() then FokusTargetNPCFrame:Hide() end
            end
        else
            FokusNPCFrame.hpBar:SetStatusBarColor(0.8, 0.8, 0) 
            FokusNPCFrame.lastRenderedNPCGUID = nil 
            if FokusTargetNPCFrame and not InCombatLockdown() then FokusTargetNPCFrame:Hide() end
        end
    end
end)

-- CORE DATA ASSIGNMENT (Pipeline Routing for Secure UnitID vs Non-Secure GUID)
function FokusEraNS.FokusEra_SetGroupFocus(unitToken)
    if InCombatLockdown() then 
        print("|cffff0000[FokusEra]|r Cannot assign focus templates while in combat lockdown.")
        return 
    end
    
    if not (unitToken and FokusFrame and FokusShadowFrame) then return end

    local actualToken = unitToken
    local rawGUID = UnitGUID(actualToken) or "0x0"
    local rawName = UnitName(actualToken) or "Unknown Entity"        
    
    FokusEraNS.FokusEra_CurrentGUID = rawGUID
    FokusEraNS.FokusEra_CurrentName = rawName
    
    -- Evaluate target taxonomy: UnitID mode triggers ONLY for stable group tokens
    local isStableGroupUnit = (actualToken ~= "target" and actualToken ~= "mouseover")
    local nextState = (UnitIsPlayer(actualToken) and isStableGroupUnit) and "PLAYER" or "NPC"
    local previousState = FokusEraNS.CurrentFocusState
    
    if nextState == "PLAYER" then
        -- 1. SECURE INTERACTIVE UNITID FRAME CONFIGURATION
        FokusEraNS.FokusEra_CT = actualToken
        FokusEraNS.FokusEra_NPCGUID = nil 
        
        -- Bind secure attributes to the main focus template for execution (Clique support)
        FokusFrame.unit = actualToken
        FokusFrame:SetAttribute("unit", actualToken)
        FokusFrame:SetAttribute("*unit", actualToken)
        
        -- Mirror configuration down to the secure target-of-focus template
        if FokusTargetFrame then
            local targetToken = actualToken .. "target"
            FokusTargetFrame.unit = targetToken
            FokusTargetFrame:SetAttribute("unit", targetToken)
            FokusTargetFrame:SetAttribute("*unit", targetToken)
        end
        
        print("|cff00ff00[FokusEra]|r Friendly Player Focus securely mapped to UnitID: " .. actualToken .. " (" .. rawName .. ")")
        
        -- Handle visual layout positioning and transition animations out of combat
        if previousState == "NIL" or previousState == "NPC" then
            if previousState == "NPC" then 
                if FokusNPCFrame then FokusNPCFrame:Hide() end
                if FokusTargetNPCFrame then FokusTargetNPCFrame:Hide() end
            end
            
            FokusFrame:ClearAllPoints()
            local shadowLeft = FokusShadowFrame:GetLeft()
            local shadowBottom = FokusShadowFrame:GetBottom()
            if shadowLeft and shadowBottom then
                FokusFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", shadowLeft, shadowBottom)
            else
                FokusFrame:SetPoint("CENTER", UIParent, "CENTER", -65, -150)
            end
        end
        
        FokusFrame:Show()
        if FokusTargetFrame then FokusTargetFrame:Show() end
        if FokusNPCFrame then FokusNPCFrame:Hide() end
        if FokusTargetNPCFrame then FokusTargetNPCFrame:Hide() end
        
    else
        -- 2. NON-SECURE GUID EVENT TRACKING FRAME CONFIGURATION
        FokusEraNS.FokusEra_CT = nil
        FokusEraNS.FokusEra_NPCGUID = rawGUID
        
        -- Detach secure unit engine maps to prevent illegal proxy casting
        FokusFrame.unit = nil
        FokusFrame:SetAttribute("unit", nil)
        FokusFrame:SetAttribute("*unit", nil)
        
        if FokusTargetFrame then
            FokusTargetFrame.unit = nil
            FokusTargetFrame:SetAttribute("unit", nil)
            FokusTargetFrame:SetAttribute("*unit", nil)
        end
        
        print("|cff00ff00[FokusEra]|r External Entity Focus bound to GUID Tracker: " .. rawGUID)
        
        -- Reposition the secure interactive anchor way off-screen to clear visual space securely
        FokusFrame:ClearAllPoints()
        local shadowLeft = FokusShadowFrame:GetLeft()
        if shadowLeft then
            FokusFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", shadowLeft, -10000)
        else
            FokusFrame:SetPoint("CENTER", UIParent, "CENTER", -65, -10000)
        end
        
        -- Structural visibility toggles for the non-secure UI overlay modules
        if FokusFrame then FokusFrame:Show() end 
        if FokusNPCFrame then FokusNPCFrame:Show() end
        if FokusTargetNPCFrame then FokusTargetNPCFrame:Hide() end
        if FokusTargetFrame then FokusTargetFrame:Hide() end
        if FokusEraTargetFrame then FokusEraTargetFrame:Hide() end
        
        if FokusEra_AlignNPCLayouts then FokusEra_AlignNPCLayouts() end
    end
    
    FokusEraNS.CurrentFocusState = nextState 
    FokusFrame.lastRenderedGUID = nil
    if FokusTargetFrame then FokusTargetFrame.lastRenderedTargetGUID = nil end
    if FokusEraNS.FokusEra_RefreshAuras then FokusEraNS.FokusEra_RefreshAuras() end
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

-------------------------------------------------------------------------------
-- BUGFIX: AUTOMATIC PURGE ON ROSTER CHANGES (RAID COMBAT END FIX v1.4.0)
-------------------------------------------------------------------------------
local groupCheckFrame = CreateFrame("Frame")
-- FIX v1.4.0: Corrected the unknown event string string register block. 
-- Changed legacy "PARTY_LEAVE" to native Classic Era API standard "GROUP_LEFT"!
groupCheckFrame:RegisterEvent("GROUP_LEFT")
groupCheckFrame:SetScript("OnEvent", function(self, event)
    if FokusEraNS.FokusEra_CT then
        if FokusEraNS.FokusEra_CT == "player" then return end
        if not UnitExists(FokusEraNS.FokusEra_CT) then
            FokusEraNS.FokusEra_ClearGroupFocusLogic()
        end
    end
end)

-------------------------------------------------------------------------------
-- FIX v1.4.1: EVENT-DRIVEN AURA REFRESH ENGINE (UNIT_AURA)
-- Listens natively to Blizzard's aura delta event, completely avoiding heavy 
-- OnUpdate polling cycles and executing updates ONLY when an aura actively changes!
-------------------------------------------------------------------------------
local auraEventFrame = CreateFrame("Frame")
auraEventFrame:RegisterEvent("UNIT_AURA")
auraEventFrame:SetScript("OnEvent", function(self, event, unitToken)
    -- Verify that the aura update belongs to our current active friendly player focus
    if FokusEraNS.FokusEra_CT and unitToken == FokusEraNS.FokusEra_CT then
        if FokusEraNS.FokusEra_RefreshAuras then 
            FokusEraNS.FokusEra_RefreshAuras() 
        end
    end
end)

-- end fokuscore.lua