-- Catch the shared addon namespace parameter from the WoW engine
local addonName, FokusEraNS = ...

-- Central Memory Tracker explicitly tracking our active states (PLAYER, NPC, NIL)
FokusEraNS.CurrentFocusState = "NIL"

-- CREATE CORE BACKGROUND HEARTBEAT ENGINE FRAME
local coreHeartbeat = CreateFrame("Frame")
coreHeartbeat.elapsed = 0

-- MAIN MONITORING UPDATE LOOP (Ticking 10 times per second for clean CPU profiles)
coreHeartbeat:SetScript("OnUpdate", function(self, elapsed)
    self.elapsed = self.elapsed + elapsed
    if self.elapsed < 0.1 then return end
    self.elapsed = 0

    -- 1. FRIENDLY PLAYER STATE MONITORING PIPELINE
    if FokusEraNS.CurrentFocusState == "PLAYER" and FokusEraNS.FokusEra_CT then
        local token = FokusEraNS.FokusEra_CT
        local targetToken = token .. "target"

        -- Safety Guard: If focus unit layout data collapses unexpectedly, clear out
        if not UnitExists(token) or UnitGUID(token) ~= FokusEraNS.FokusEra_CurrentGUID then
            FokusEraNS.FokusEra_ClearGroupFocusLogic()
            return
        end

        -- Update main focus frame values smoothly
        local currentHP = UnitHealth(token)
        local maxHP = UnitHealthMax(token)
        FokusFrame.hpBar:SetMinMaxValues(0, maxHP)
        FokusFrame.hpBar:SetValue(currentHP)
        FokusFrame.hpText:SetText(currentHP .. " / " .. maxHP)
        
        -- Main player frame 3D portrait cache guard
        local currentFocusGUID = UnitGUID(token)
        if currentFocusGUID and currentFocusGUID ~= FokusFrame.lastRenderedGUID then
            FokusFrame.lastRenderedGUID = currentFocusGUID
            if FokusFrame.portrait and FokusFrame.portrait.SetUnit then
                FokusFrame.portrait:SetUnit(token)
                FokusFrame.portrait:SetCamera(0)
                FokusFrame.portrait:SetPosition(0, 0, 0)
            end
        end

        -- Handle target-of-focus frame rendering logic smoothly
        if UnitExists(targetToken) then
            local fallbackToken = targetToken
            local targetGUID = UnitGUID(targetToken)
            
            if not targetGUID and UnitIsUnit(token, "target") then
                targetGUID = UnitGUID(token)
                fallbackToken = token
            end

            if FokusTargetFrame and not FokusTargetFrame:IsShown() then
                FokusTargetFrame.lastRenderedTargetGUID = nil
            end

            -- Optimization block: Only refresh textures and strings if the target entity actually changed
            if targetGUID and targetGUID ~= FokusTargetFrame.lastRenderedTargetGUID then
                FokusTargetFrame.lastRenderedTargetGUID = targetGUID
                
                local targetName = UnitName(fallbackToken) or "Target"
                FokusTargetFrame.nameText:SetText(targetName)
                
                if FokusTargetFrame.portrait and FokusTargetFrame.portrait.SetUnit then
                    FokusTargetFrame.portrait:SetUnit(fallbackToken)
                    FokusTargetFrame.portrait:SetCamera(0)
                    FokusTargetFrame.portrait:SetPosition(0, 0, 0)
                end

                if not InCombatLockdown() then FokusTargetFrame:Show() end
            end

            if FokusTargetFrame and FokusTargetFrame.hpBar then
                if UnitIsPlayer(fallbackToken) then
                    FokusTargetFrame.hpBar:SetStatusBarColor(0, 0.8, 0) -- Solid Healer Green
                elseif UnitReaction(fallbackToken, "player") >= 5 then
                    FokusTargetFrame.hpBar:SetStatusBarColor(0.8, 0.8, 0) -- Yellow for friendly NPCs
                else
                    FokusTargetFrame.hpBar:SetStatusBarColor(0.8, 0, 0) -- Red for nonfriendly NPCs                    
                end
            end

            -- Continuous live health updates for the target of focus
            local tCurrentHP = UnitHealth(fallbackToken)
            local tMaxHP = UnitHealthMax(fallbackToken)
            FokusTargetFrame.hpBar:SetMinMaxValues(0, tMaxHP)
            FokusTargetFrame.hpBar:SetValue(tCurrentHP)
        else
            -- Target does not exist (Escape pressed or cleared)
            FokusTargetFrame.lastRenderedTargetGUID = nil
            if not InCombatLockdown() then FokusTargetFrame:Hide() end
        end

    -- 2. COMBAT NPC / BOSS MONITORING PIPELINE
    elseif FokusEraNS.CurrentFocusState == "NPC" and FokusEraNS.FokusEra_NPCGUID then
        local rawGUID = FokusEraNS.FokusEra_NPCGUID
        local matchedToken = nil

        -- Scan raid environments to track down an active token match for the boss GUID
        if UnitGUID("target") == rawGUID then matchedToken = "target"
        elseif UnitGUID("mouseover") == rawGUID then matchedToken = "mouseover"
        else
            for i = 1, 40 do
                if UnitGUID("raid" .. i .. "target") == rawGUID then
                    matchedToken = "raid" .. i .. "target"
                    break
                elseif UnitGUID("party" .. i .. "target") == rawGUID then
                    matchedToken = "party" .. i .. "target"
                    break
                end
            end
        end

        -- If an active token window is locked in, refresh real-time health data (GREEN STATE)
        if matchedToken then
            local currentHP = UnitHealth(matchedToken)
            local maxHP = UnitHealthMax(matchedToken)
            
            FokusNPCFrame.hpBar:SetStatusBarColor(0, 0.8, 0) -- Green feedback link
            FokusNPCFrame.hpBar:SetMinMaxValues(0, maxHP)
            FokusNPCFrame.hpBar:SetValue(currentHP)
            FokusNPCFrame.hpText:SetText(currentHP .. " / " .. maxHP)
            
            FokusNPCFrame.lastKnownHP = currentHP
            FokusNPCFrame.lastKnownMaxHP = maxHP

            -- Prevent constant 3D model resets on the NPC frame by verifying identity
            if FokusNPCFrame.lastRenderedNPCGUID ~= rawGUID then
                FokusNPCFrame.lastRenderedNPCGUID = rawGUID
                if FokusNPCFrame.portrait and FokusNPCFrame.portrait.SetUnit then
                    FokusNPCFrame.portrait:SetUnit(matchedToken)
                    FokusNPCFrame.portrait:SetCamera(0)
                    FokusNPCFrame.portrait:SetPosition(0, 0, 0)
                end
            end

            -- Track boss target changes dynamically
            local bossTargetToken = matchedToken .. "target"
            if UnitExists(bossTargetToken) then
                local bTargetGUID = UnitGUID(bossTargetToken)
                if bTargetGUID ~= FokusTargetNPCFrame.lastRenderedTargetGUID then
                    FokusTargetNPCFrame.lastRenderedTargetGUID = bTargetGUID
                    FokusTargetNPCFrame.nameText:SetText(UnitName(bossTargetToken) or "Target")
                    FokusTargetNPCFrame:Show()
                end
                FokusTargetNPCFrame.hpBar:SetMinMaxValues(0, UnitHealthMax(bossTargetToken))
                FokusTargetNPCFrame.hpBar:SetValue(UnitHealth(bossTargetToken))
            else
                FokusTargetNPCFrame.lastRenderedTargetGUID = nil
                FokusTargetNPCFrame:Hide()
            end
        else
            -- Signal temporarily drop out of group sight range (YELLOW CACHE STATE)
            FokusNPCFrame.hpBar:SetStatusBarColor(0.8, 0.8, 0) -- Warning Yellow cache alert
            FokusNPCFrame.lastRenderedNPCGUID = nil 
            FokusTargetNPCFrame:Hide()
        end
    end
end)

-- CORE DATA ASSIGNMENT (Shared into Namespace array table)
function FokusEraNS.FokusEra_SetGroupFocus(unitToken)
    if InCombatLockdown() then return end
    if unitToken and FokusFrame and FokusShadowFrame then
        local actualToken = unitToken
        local isForcedNPC = false
        if unitToken == "target_npc_override" then
            actualToken = "target"
            isForcedNPC = true
        end

        local rawGUID = UnitGUID(actualToken) or "0x0"
        local rawName = UnitName(actualToken) or "Unknown Entity"
        
        FokusEraNS.FokusEra_CurrentGUID = rawGUID
        FokusEraNS.FokusEra_CurrentName = rawName
        
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

-- end fokuscore.lua