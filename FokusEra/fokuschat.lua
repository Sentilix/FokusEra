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

-- 1. CONSOLE SYSTEM COMMAND: /fokus
SLASH_FOKUS1 = "/fokus"
SlashCmdList["FOKUS"] = function(msg)
    if InCombatLockdown() then return end
    if not UnitExists("target") then return end
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
                local token = "party" .. i
                if UnitExists(token) and UnitGUID(token) == targetGUID then foundToken = token; break end
            end
        end
    end

    if foundToken then FokusEraNS.FokusEra_SetGroupFocus(foundToken) end
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
    
    if FokusFrame and FokusTargetFrame then
        -- Nulstil Hovedrammen på skærmen
        FokusFrame:ClearAllPoints()
        FokusFrame:SetPoint("CENTER", UIParent, "CENTER", -65, -150) 
        
        -- FIX: Vi nulstiller de relative database-afstande til standard Z-Perl værdier!
        FokusEra_OffsetX = 4
        FokusEra_OffsetY = -7
        
        -- Tving målrammen tilbage på sin faste plads relativt til hovedrammen
        FokusTargetFrame:ClearAllPoints()
        FokusTargetFrame:SetPoint("LEFT", FokusFrame, "RIGHT", FokusEra_OffsetX, FokusEra_OffsetY)
        
        print("|cff00ff00[FokusEra]|r Interface layout coordinates and offsets successfully reset to default parameters.")
        
        if not FokusEraNS.FokusEra_CT then
            print("|cffffaa00[FokusEra]|r Temporarily rendering sandbox test layout. Type /clearfokus to conceal.")
            
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
    print("|cffffaa00/fokus|r - Sets your currently selected friendly group target to the focus framework (Out of combat).")
    print("|cffffaa00/clearfokus|r - Clears your tracked focus target and completely conceals the frame template.")
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