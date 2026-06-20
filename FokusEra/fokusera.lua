
local interfaceVersion = select(4, GetBuildInfo())
print("|cff00ff00[Z-Perl Focus Bridge]|r Addon indlæst korrekt på klient version: " .. interfaceVersion)

-- Global variables for tracked focus data (Matching the FocusEra namespace)
FocusEra_CurrentToken = nil
FocusEra_CurrentGUID = nil
FocusEra_CurrentName = nil
FocusEra_IsLocked = false -- Default layout toggle state on very first boot

-- Addon configuration references
local addonFolderName = "ZPerl_Focus_Era"
local addonVersion = C_AddOns.GetAddOnMetadata(addonFolderName, "Version") or "1.0.0"

-- Hardcoded clean ShortTitle combined with the dynamic version number
local FocusEra_Version = "FocusEra " .. addonVersion
local ADDON_PREFIX = "FocusEra" -- Hidden addon communication network channel

-- Instantiate global secure button frame cluster
MyCustomFocusEraFrame = CreateFrame("Button", "MyCustomFocusEraFrame", UIParent, "SecureUnitButtonTemplate, BackdropTemplate")
local FocusFrame = MyCustomFocusEraFrame

-- Print initialization confirmation string
local interfaceVersion = select(4, GetBuildInfo())
print("|cff00ff00[" .. FocusEra_Version .. "]|r Addon loaded successfully on client version: " .. interfaceVersion)

-- Register the secure addon communication prefix with the game engine
if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
    C_ChatInfo.RegisterAddonMessagePrefix(ADDON_PREFIX)
end

-- Layout structural proportions
FocusFrame:SetSize(210, 48)
FocusFrame:SetPoint("CENTER", UIParent, "CENTER", 0, -150) -- Anchored on the bottom-third of the viewport
FocusFrame:SetMovable(true)
FocusFrame:EnableMouse(true)
FocusFrame:RegisterForClicks("AnyUp")
FocusFrame:Hide()

-- Authentic Z-Perl design language: Solid dark-slate backdrop with light-grey borders
FocusFrame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 8, edgeSize = 12,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
FocusFrame:SetBackdropColor(0, 0, 0, 0.85)
FocusFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

-- Drag handling properties (Requires the ALT key modification and open anchor status)
FocusFrame:RegisterForDrag("LeftButton")
FocusFrame:SetScript("OnDragStart", function(self) 
    if not InCombatLockdown() and not FocusEra_IsLocked and IsAltKeyDown() then 
        self:StartMoving() 
    end 
end)
FocusFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

-- Portrait sub-frames configuration
FocusFrame.staticPortrait = CreateFrame("Frame", nil, FocusFrame)
FocusFrame.portrait = CreateFrame("PlayerModel", nil, FocusFrame)
FocusFrame.portrait:SetSize(40, 38)
FocusFrame.portrait:SetPoint("TOPLEFT", FocusFrame, "TOPLEFT", 6, -5)

local portBG = FocusFrame:CreateTexture(nil, "BACKGROUND")
portBG:SetAllPoints(FocusFrame.portrait)
portBG:SetColorTexture(0.05, 0.05, 0.05, 1)

-- Text strings layout geometry
FocusFrame.nameText = FocusFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
FocusFrame.nameText:SetPoint("TOPLEFT", FocusFrame, "TOPLEFT", 52, -6)
FocusFrame.nameText:SetJustifyH("LEFT")

FocusFrame.levelText = FocusFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
FocusFrame.levelText:SetPoint("TOPRIGHT", FocusFrame, "TOPRIGHT", -38, -6)
FocusFrame.levelText:SetJustifyH("RIGHT")

-- Health Bar status mapping elements
FocusFrame.hpBar = CreateFrame("StatusBar", nil, FocusFrame)
FocusFrame.hpBar:SetSize(148, 14)
FocusFrame.hpBar:SetPoint("TOPLEFT", FocusFrame, "TOPLEFT", 52, -18)
FocusFrame.hpBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
FocusFrame.hpBar:SetStatusBarColor(0, 0.8, 0) -- Traditional solid green Z-Perl texture profile

FocusFrame.hpText = FocusFrame.hpBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
FocusFrame.hpText:SetPoint("CENTER", FocusFrame.hpBar, "CENTER", 0, 0)

-- Power Bar / Mana metrics elements
FocusFrame.manaBar = CreateFrame("StatusBar", nil, FocusFrame)
FocusFrame.manaBar:SetSize(148, 6)
FocusFrame.manaBar:SetPoint("TOPLEFT", FocusFrame.hpBar, "BOTTOMLEFT", 0, -2)
FocusFrame.manaBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
FocusFrame.manaBar:SetStatusBarColor(0, 0, 1)

-- Click-cast communication bridge array configuration
ClickCastFrames = ClickCastFrames or {}
ClickCastFrames[FocusFrame] = true

-- INTERACTIVE CONTROL BUTTONS (Clear & Lock Anchors)
FocusFrame.clearBtn = CreateFrame("Button", nil, FocusFrame)
FocusFrame.clearBtn:SetSize(12, 12)
FocusFrame.clearBtn:SetPoint("TOPRIGHT", FocusFrame, "TOPRIGHT", -6, -4)
FocusFrame.clearBtn.tex = FocusFrame.clearBtn:CreateTexture(nil, "OVERLAY")
FocusFrame.clearBtn.tex:SetAllPoints()
FocusFrame.clearBtn.tex:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
FocusFrame.clearBtn:SetScript("OnClick", function()
    if not InCombatLockdown() then FocusEra_ClearGroupFocusLogic() end
end)

FocusFrame.lockBtn = CreateFrame("Button", nil, FocusFrame)
FocusFrame.lockBtn:SetSize(12, 12)
FocusFrame.lockBtn:SetPoint("RIGHT", FocusFrame.clearBtn, "LEFT", -4, 0)
FocusFrame.lockBtn.tex = FocusFrame.lockBtn:CreateTexture(nil, "OVERLAY")
FocusFrame.lockBtn.tex:SetAllPoints()
FocusFrame.lockBtn.tex:SetTexture("Interface\\Buttons\\UI-OptionsButton")

-- Dynamically handle structural canvas shading based on local database values
local function UpdateLockIconColor()
    if FocusEra_IsLocked then 
        FocusFrame.lockBtn.tex:SetVertexColor(1, 0, 0) -- Red (Locked state)
    else 
        FocusFrame.lockBtn.tex:SetVertexColor(1, 0.82, 0) -- Yellow (Open layout state)
    end
end

FocusFrame.lockBtn:SetScript("OnClick", function()
    FocusEra_IsLocked = not FocusEra_IsLocked
    FocusEra_SavedLockState = FocusEra_IsLocked -- Commits change directly to local WTF config file
    UpdateLockIconColor()
end)

-- Fetch character layout profiles on interface final load sequences
local saveLoader = CreateFrame("Frame")
saveLoader:RegisterEvent("PLAYER_LOGIN")
saveLoader:SetScript("OnEvent", function(self, event)
    if FocusEra_SavedLockState ~= nil then FocusEra_IsLocked = FocusEra_SavedLockState
    else FocusEra_SavedLockState = false end
    UpdateLockIconColor() -- Syncs control anchor layout rendering immediately upon logging in
    saveLoader:UnregisterEvent("PLAYER_LOGIN")
end)



-- Heartbeat Update Loop execution (Fires exactly 10 times a second to prevent CPU overhead)
FocusFrame.timeSinceLastUpdate = 0
FocusFrame.lastRenderedGUID = nil

FocusFrame:SetScript("OnUpdate", function(self, elapsed)
    if not FocusEra_CurrentToken then 
        self:Hide()
        return 
    end

    self.timeSinceLastUpdate = self.timeSinceLastUpdate + elapsed
    if self.timeSinceLastUpdate >= 0.1 then
        local token = FocusEra_CurrentToken

        -- DYNAMIC TOKEN VERIFICATION (Monitors group re-shuffles across grid maps)
        if not UnitExists(token) or UnitGUID(token) ~= FocusEra_CurrentGUID then
            local remapped = false
            if IsInRaid() then
                for i = 1, 40 do
                    if UnitGUID("raid"..i) == FocusEra_CurrentGUID then
                        FocusEra_CurrentToken = "raid"..i; token = "raid"..i; remapped = true; break
                    end
                end
            else
                if UnitGUID("player") == FocusEra_CurrentGUID then FocusEra_CurrentToken = "player"; token = "player"; remapped = true
                else
                    for i = 1, 4 do
                        if UnitGUID("party"..i) == FocusEra_CurrentGUID then
                            FocusEra_CurrentToken = "party"..i; token = "party"..i; remapped = true; break
                        end
                    end
                end
            end
            if not remapped then return end
        end

        if not UnitExists(token) then return end

        -- RE-RENDER METRICS ON VIEWPORT
        self.nameText:SetText(FocusEra_CurrentName)
        local level = UnitLevel(token)
        self.levelText:SetText(level and level > 0 and "Lvl " .. level or "")

        local currentHP = UnitHealth(token)
        local maxHP = UnitHealthMax(token)
        self.hpBar:SetMinMaxValues(0, maxHP); self.hpBar:SetValue(currentHP)
        self.hpText:SetText(currentHP .. " / " .. maxHP)

        -- Class color string compilation (Applies exclusively to text strings to preserve Z-Perl layout design)
        local _, class = UnitClass(token)
        if class and RAID_CLASS_COLORS[class] then
            local c = RAID_CLASS_COLORS[class]; self.nameText:SetTextColor(c.r, c.g, c.b)
        else self.nameText:SetTextColor(1, 0.82, 0) end

        -- Power type color processing (Mana vs Rage vs Energy mapping loops)
        local powerType = UnitPowerType(token)
        local currentPower = UnitPower(token, powerType)
        local maxPower = UnitPowerMax(token, powerType)
        self.manaBar:SetMinMaxValues(0, maxPower); self.manaBar:SetValue(currentPower)

        if powerType == 0 then self.manaBar:SetStatusBarColor(0, 0.4, 1) -- Blue Mana
        elseif powerType == 1 then self.manaBar:SetStatusBarColor(1, 0, 0) -- Red Rage
        elseif powerType == 3 then self.manaBar:SetStatusBarColor(1, 1, 0) -- Yellow Energy
        else self.manaBar:SetStatusBarColor(0, 0.8, 0.8) end

        -- 3D Character portrait pipeline refresh handlers
        if self.portrait then
            self.portrait:Show()
            if self.lastRenderedGUID ~= FocusEra_CurrentGUID then
                self.portrait:SetUnit(token); self.portrait:SetCamera(0); self.lastRenderedGUID = FocusEra_CurrentGUID
            end
        end

        self:Show()
        self.timeSinceLastUpdate = 0
    end
end)

-- CORE DATA WRAPPER ASSIGNMENT
function FocusEra_SetGroupFocus(unitToken)
    if InCombatLockdown() then return end
    if unitToken and FocusFrame then
        FocusEra_CurrentToken = unitToken
        FocusEra_CurrentGUID = UnitGUID(unitToken)
        FocusEra_CurrentName = UnitName(unitToken)
        print("|cff00ff00[Focus Era]|r Focus target set to: " .. FocusEra_CurrentName)
        
        -- Bind data straight onto the underlying secure execution button pipeline
        FocusFrame:SetAttribute("unit", unitToken)
        FocusFrame:SetAttribute("*unit", unitToken)
        FocusFrame.lastRenderedGUID = nil
        FocusFrame:Show()
    end
end

-- DATA DE-ALLOCATION MANAGEMENT ROUTINE
function FocusEra_ClearGroupFocusLogic()
    FocusEra_CurrentToken = nil; FocusEra_CurrentGUID = nil; FocusEra_CurrentName = nil
    if FocusFrame then
        FocusFrame:SetAttribute("unit", nil); FocusFrame:SetAttribute("*unit", nil)
        FocusFrame.lastRenderedGUID = nil; FocusFrame:Hide()
    end
    print("|cff00ff00[Focus Era]|r Focus target cleared.")
end

---------------------------------------------------------
-- HIDDEN DATA BROADCAST NETWORK (Version verification)
---------------------------------------------------------
local communicationFrame = CreateFrame("Frame")
communicationFrame:RegisterEvent("CHAT_MSG_ADDON")
communicationFrame:SetScript("OnEvent", function(self, event, prefix, message, channel, sender)
    if prefix ~= "FocusEra" then return end
    
    local playerUnitName = UnitName("player")
    local cleanSender = string.match(sender, "([^%-]+)") -- Strips server realm names from data string
    
    -- Evaluate received network messages
    if message == "VERSION_REQUEST" then
        local targetChannel = IsInRaid() and "RAID" or "PARTY"
        if cleanSender ~= playerUnitName then
            C_ChatInfo.SendAddonMessage("FocusEra", "VERSION_RESPONSE:" .. FocusEra_Version, targetChannel)
        end
    elseif string.match(message, "^VERSION_RESPONSE:") then
        if cleanSender ~= playerUnitName then
            local remoteVersion = string.sub(message, 18)
            print("|cff00ff00[Focus Era Version Check]|r " .. cleanSender .. " is running: |cffffaa00" .. remoteVersion .. "|r")
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

    if foundToken then FocusEra_SetGroupFocus(foundToken) end
end

-- 2. CONSOLE SYSTEM COMMAND: /clearfokus
SLASH_CLEARFOKUS1 = "/clearfokus"
SlashCmdList["CLEARFOKUS"] = function(msg)
    if InCombatLockdown() then return end
    FocusEra_ClearGroupFocusLogic()
end

-- 3. CONSOLE SYSTEM COMMAND: /fokusversion
SLASH_FOKUSVERSION1 = "/fokusversion"
SlashCmdList["FOKUSVERSION"] = function(msg)
    if not (IsInRaid() or IsInGroup()) then
        print("|cffffaa00[Focus Era]|r You must be in a party or a raid group to execute a network version scan.")
        print("|cff00ff00[Focus Era Version Check]|r " .. UnitName("player") .. " (You) is running: |cffffaa00" .. FocusEra_Version .. "|r")
        return
    end
    
    local targetChannel = IsInRaid() and "RAID" or "PARTY"
    print("|cff00ff00[Focus Era Version Check]|r Scanning network for running FocusEra installations...")
    print("|cff00ff00[Focus Era Version Check]|r " .. UnitName("player") .. " (You) is running: |cffffaa00" .. FocusEra_Version .. "|r")
    C_ChatInfo.SendAddonMessage("FocusEra", "VERSION_REQUEST", targetChannel)
end

-- 4. CONSOLE SYSTEM COMMAND: /fokusreset
SLASH_FOKUSRESET1 = "/fokusreset"
SlashCmdList["FOKUSRESET"] = function(msg)
    if InCombatLockdown() then
        print("|cffff0000[Focus Era]|r Cannot reset interface layout while in combat lockdown!")
        return
    end
    
    if FocusFrame then
        FocusFrame:ClearAllPoints()
        FocusFrame:SetPoint("CENTER", UIParent, "CENTER", 0, -150) -- Resets layout safely onto the default bottom-third position
        print("|cff00ff00[Focus Era]|r Interface layout coordinates successfully reset to the default lower-third grid.")
        
        -- Render an explicit sandboxed layout test profile if no data unit token is active
        if not FocusEra_CurrentToken then
            print("|cffffaa00[Focus Era]|r Temporarily rendering sandbox test layout. Type /clearfokus to conceal.")
            FocusFrame.nameText:SetText("Sandbox Layout Test")
            FocusFrame.levelText:SetText("Lvl 60")
            FocusFrame.hpBar:SetMinMaxValues(0, 100); FocusFrame.hpBar:SetValue(100); FocusFrame.hpText:SetText("100 / 100")
            FocusFrame.manaBar:SetMinMaxValues(0, 100); FocusFrame.manaBar:SetValue(100)
            FocusFrame.portrait:SetUnit("player")
            FocusFrame:Show()
        end
    end
end

-- 5. CONSOLE SYSTEM COMMAND: /fokushelp
local function DisplayInGameHelp()
    print("|cff00ff00------------------ [FocusEra Help] ------------------|r")
    print("|cffffaa00/fokus|r - Sets your currently selected friendly group target to the focus framework (Out of combat).")
    print("|cffffaa00/clearfokus|r - Clears your tracked focus target and completely conceals the frame template.")
    print("|cffffaa00/fokusreset|r - Resets frame layout screen coordinates safely back to the default bottom-third position.")
    print("|cffffaa00/fokusversion|r - Audits your active party or raid network for current FocusEra installation versions.")
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
