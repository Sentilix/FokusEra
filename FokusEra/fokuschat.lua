-- Catch the shared addon namespace parameter from the WoW engine
local addonName, FokusEraNS = ...

---------------------------------------------------------
-- NETWORK COMMUNICATION PIPELINE (FokusEra Channel)
---------------------------------------------------------
local communicationFrame = CreateFrame("Frame")
communicationFrame:RegisterEvent("CHAT_MSG_ADDON")
communicationFrame:SetScript("OnEvent", function(self, event, prefix, message, channel, sender)
    if prefix ~= "FokusEra" then return end
    
    local playerUnitName = UnitName("player")
    local cleanSender = string.match(sender, "([^%-]+)")
    
    if message == "VERSION_REQUEST" then
        local targetChannel = IsInRaid() and "RAID" or "PARTY"
        if cleanSender ~= playerUnitName then
            C_ChatInfo.SendAddonMessage("FokusEra", "VERSION_RESPONSE:" .. FokusEra_Version, targetChannel)
        end
    elseif string.match(message, "^VERSION_RESPONSE:") then
        if cleanSender ~= playerUnitName then
            local remoteVersion = string.sub(message, 18)
            print("|cff00ff00[FokusEra Version Check]|r " .. cleanSender .. " is running: |cffffaa00" .. remoteVersion .. "|r")
        end
    end
end)

-- 1. CONSOLE SYSTEM COMMAND: /fokus (FIX v1.4.0 — Bypasses NPC filtration blocks!)
SLASH_FOKUS1 = "/fokus"
SlashCmdList["FOKUS"] = function(msg)
    if InCombatLockdown() then return end
    if not UnitExists("target") then return end
    
    -- Check if target is a real player or an NPC creature
    if UnitIsPlayer("target") then
        local targetGUID = UnitGUID("target")
        local foundToken = nil

        if IsInRaid() then
            for i = 1, 40 do
                local token = "raid" .. i
                if UnitExists(token) and UnitGUID(token) == targetGUID then foundToken = token; break end
            end
        else
            if UnitGUID("player") == targetGUID then foundToken = "player"
            else
                for i = 1, 4 do
                    if UnitGUID("party"..i) == targetGUID then foundToken = "party"..i; break end
                end
            end
        end

        -- If player is in group, pass their unique unit token (for Clique support)
        if foundToken then 
            FokusEraNS.FokusEra_SetGroupFocus(foundToken) 
        else
            -- If it's a friendly player outside group, treat as player focus via target token
            FokusEraNS.FokusEra_SetGroupFocus("target")
        end
    else
        -- FIX: Target is a Boss or Mob! Bypass group scanning entirely and pass "target" directly!
        FokusEraNS.FokusEra_SetGroupFocus("target")
    end
end

-- 2. CONSOLE SYSTEM COMMAND: /clearfokus
SLASH_CLEARFOKUS1 = "/clearfokus"
SlashCmdList["CLEARFOKUS"] = function(msg)
    if InCombatLockdown() then return end
    FokusEraNS.FokusEra_ClearGroupFocusLogic()
end

-- 3. CONSOLE SYSTEM COMMAND: /fokusversion
SLASH_FOKUSVERSION1 = "/fokusversion"
SlashCmdList["FOKUSVERSION"] = function(msg)
    if not (IsInRaid() or IsInGroup()) then
        print("|cffffaa00[FokusEra]|r You must be in a party or a raid group to execute a network version scan.")
        print("|cff00ff00[FokusEra Version Check]|r " .. UnitName("player") .. " (You) is running: |cffffaa00" .. FokusEra_Version .. "|r")
        return
    end
    
    local targetChannel = IsInRaid() and "RAID" or "PARTY"
    print("|cff00ff00[FokusEra Version Check]|r Scanning network for running FokusEra installations...")
    print("|cff00ff00[FokusEra Version Check]|r " .. UnitName("player") .. " (You) is running: |cffffaa00" .. FokusEra_Version .. "|r")
    C_ChatInfo.SendAddonMessage("FokusEra", "VERSION_REQUEST", targetChannel)
end

-- 4. CONSOLE SYSTEM COMMAND: /fokusreset
SLASH_FOKUSRESET1 = "/fokusreset"
SlashCmdList["FOKUSRESET"] = function(msg)
    if InCombatLockdown() then
        print("|cffff0000[FokusEra]|r Cannot reset interface layout while in combat lockdown!")
        return
    end
    
    if FokusFrame and FokusTargetFrame and FokusShadowFrame then
        -- Reset the master invisible shadow anchor frame back to base catalog standards
        FokusShadowFrame:ClearAllPoints()
        FokusShadowFrame:SetPoint("CENTER", UIParent, "CENTER", -65, -150)
        
        FokusEra_OffsetX = 4
        FokusEra_OffsetY = 0
        FokusEra_Width = 210
        
        FokusShadowFrame:SetWidth(FokusEra_Width)
        if FokusEra_AlignNPCLayouts then FokusEra_AlignNPCLayouts() end
        if FokusEra_UpdateInternalWidths then FokusEra_UpdateInternalWidths() end
        
        print("|cff00ff00[FokusEra]|r Interface layout coordinates, widths, and action slots successfully reset.")
        
        if not FokusEraNS.FokusEra_CT and not FokusEraNS.FokusEra_NPCGUID then
            print("|cffffaa00[FokusEra]|r Temporarily rendering sandbox test layout. Type /clearfokus to conceal.")
            
            FokusFrame:ClearAllPoints()
            FokusFrame:SetPoint("CENTER", FokusShadowFrame, "CENTER", 0, 0)
            FokusFrame.nameText:SetText("Sandbox Focus")
            FokusFrame.levelText:SetText("Lvl 60")
            FokusFrame.hpBar:SetMinMaxValues(0, 100); FokusFrame.hpBar:SetValue(100); FokusFrame.hpText:SetText("100 / 100")
            FokusFrame.manaBar:SetMinMaxValues(0, 100); FokusFrame.manaBar:SetValue(100)
            FokusFrame.portrait:SetUnit("player")
            FokusFrame:Show()
            
            FokusEraTargetFrame.nameText:SetText("Focus Target Test")
            FokusEraTargetFrame.nameText:SetTextColor(1, 0.2, 0.2) 
            FokusEraTargetFrame.hpBar:SetMinMaxValues(0, 100); FokusEraTargetFrame.hpBar:SetValue(75) 
            FokusEraTargetFrame:Show()
        end
    end
end

-- 5. CONSOLE SYSTEM COMMAND: /fokushelp
local function DisplayInGameHelp()
    print("|cff00ff00------------------ [FokusEra Help] ------------------|r")
    print("|cffffaa00/fokus|r - Sets your currently selected target (Player or NPC) to the focus framework.")
    print("|cffffaa00/clearfokus|r - Clears your tracked focus target and completely conceals the frame templates.")
    print("|cffffaa00/fokusreset|r - Resets frame layout screen coordinates safely back to the default bottom-third position.")
    print("|cffffaa00/fokusversion|r - Audits your active party or raid network for current FokusEra installation versions.")
    print("|cffffaa00/fokushelp|r - Prints this console command checklist overview directly onto your local chat frame.")
    print("|cff00ff00------------------------------------------------------|r")
    print("|cff00ff00Mouse Shortcuts:|r")
    print("|cffffaa00Alt + Left-Click + Drag|r - Repositions the interface frame across your viewport (Requires an unlocked gearwheel).")
    print("|cff00ff00------------------------------------------------------|r")
end
SLASH_FOKUSHELP1 = "/fokushelp"
SlashCmdList["FOKUSHELP"] = function(msg)
    DisplayInGameHelp()
end

-- end fokuschat.lua