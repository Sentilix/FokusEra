-- Catch the shared addon namespace parameter from the WoW engine
local addonName, FokusEraNS = ...

---------------------------------------------------------
-- CONSOLE CONFIGURATION MODULE: /fokusspell
---------------------------------------------------------
SLASH_FOKUSSPELL1 = "/fokusspell"
SlashCmdList["FOKUSSPELL"] = function(msg)
    if InCombatLockdown() then
        print("|cffff0000[FokusEra]|r Cannot configure action bar buttons during active combat lockdown!")
        return
    end
    
    FokusEra_Spells = FokusEra_Spells or {}
    
    msg = string.gsub(msg, "^%s*(.-)%s*$", "%1")
    
    local slotStr, spellName = string.match(msg, "^(%d+)%s*(.*)$")
    local slot = tonumber(slotStr)
    
    if not slot then
        spellName = msg
        if spellName == "" then
            print("|cffffaa00[FokusEra Setup]|r Specify a slot to clear, or type a spell name! Ex: |cff00ff00/fokusspell Flash Heal|r")
            return
        end
        
        for i = 1, 5 do
            if not FokusEra_Spells[i] or FokusEra_Spells[i] == "" then
                slot = i
                break
            end
        end
        
        if not slot then
            print("|cffff0000[FokusEra Error]|r All 5 spell slots are currently full! Clear a slot first using: |cffffaa00/fokusspell [1-5]|r")
            return
        end
    else
        spellName = string.gsub(spellName, "^%s*(.-)%s*$", "%1")
    end
    
    if slot < 1 or slot > 5 then
        print("|cffffaa00[FokusEra Setup]|r Invalid layout slot! Use a number between 1 and 5.")
        return
    end
    
    if not spellName or spellName == "" then
        print("|cff00ff00[FokusEra Setup]|r Action slot |cffffaa00" .. slot .. "|r has been completely cleared.")
        FokusEra_Spells[slot] = nil
    else
        local spellIdentifier = tonumber(spellName) or spellName
        local officialName, _, texture, _, _, _, spellID = GetSpellInfo(spellIdentifier)
        
        if not texture or not officialName or not spellID then
            print("|cffff0000[FokusEra Error]|r Unknown spell: |cffffaa00\"" .. spellName .. "\"|r. Check your spelling or use a valid SpellID!")
            return
        end
        
        FokusEra_Spells[slot] = tonumber(spellID)
        print("|cff00ff00[FokusEra Setup]|r Action slot |cffffaa00" .. slot .. "|r successfully bound to: |cffffaa00" .. officialName .. " (ID: " .. spellID .. ")|r")
    end
    
    if FokusEra_RefreshSpellBar then FokusEra_RefreshSpellBar() end
end
