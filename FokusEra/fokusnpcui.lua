-- Catch the shared addon namespace parameter from the WoW engine
local addonName, FokusEraNS = ...

-- 1. MAIN FOCUS NPC FRAME (FokusNPCFrame)
FokusNPCFrame = CreateFrame("Button", "FokusNPCFrame", UIParent, "BackdropTemplate")
FokusNPCFrame:SetSize(210, 48)
FokusNPCFrame:Hide()

FokusNPCFrame:SetMovable(false)
FokusNPCFrame:EnableMouse(true)
FokusNPCFrame:RegisterForClicks("AnyUp")

FokusNPCFrame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 8, edgeSize = 12,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
FokusNPCFrame:SetBackdropColor(0, 0, 0, 0.85)
FokusNPCFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

-- Portrait sub-frames configuration
FokusNPCFrame.staticPortrait = CreateFrame("Frame", nil, FokusNPCFrame)
FokusNPCFrame.portrait = CreateFrame("PlayerModel", nil, FokusNPCFrame)
FokusNPCFrame.portrait:SetSize(40, 38)
FokusNPCFrame.portrait:SetPoint("TOPLEFT", FokusNPCFrame, "TOPLEFT", 6, -5)

local portBG = FokusNPCFrame:CreateTexture(nil, "BACKGROUND")
portBG:SetAllPoints(FokusNPCFrame.portrait)
portBG:SetColorTexture(0.05, 0.05, 0.05, 1)

-- Master NPC Icon Overlay Frame Container
FokusNPCFrame.iconOverlay = CreateFrame("Frame", nil, FokusNPCFrame)
FokusNPCFrame.iconOverlay:SetAllPoints(FokusNPCFrame)
FokusNPCFrame.iconOverlay:SetFrameStrata("DIALOG")
FokusNPCFrame.iconOverlay:SetFrameLevel(FokusNPCFrame.portrait:GetFrameLevel() + 10)
FokusNPCFrame.iconOverlay:EnableMouse(false)
if FokusNPCFrame.iconOverlay.SetMouseClickEnabled then FokusNPCFrame.iconOverlay:SetMouseClickEnabled(false) end

-- NPC Portrait Icon Textures (Raid Mark stays clean on the top edge)
FokusNPCFrame.raidIcon = FokusNPCFrame.iconOverlay:CreateTexture(nil, "OVERLAY")
FokusNPCFrame.raidIcon:SetSize(14, 14)
FokusNPCFrame.raidIcon:SetPoint("TOPLEFT", FokusNPCFrame, "TOPLEFT", 2, -1)
FokusNPCFrame.raidIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
FokusNPCFrame.raidIcon:Hide()

-- Shrunken NPC Skull icon placed right before the header text block
FokusNPCFrame.statusIcon = FokusNPCFrame:CreateTexture(nil, "OVERLAY")
FokusNPCFrame.statusIcon:SetSize(10, 10)
FokusNPCFrame.statusIcon:SetPoint("TOPLEFT", FokusNPCFrame, "TOPLEFT", 52, -6)
FokusNPCFrame.statusIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
FokusNPCFrame.statusIcon:SetTexCoord(0.75, 1, 0.25, 0.5)
FokusNPCFrame.statusIcon:SetVertexColor(0.8, 0.8, 0.8)
FokusNPCFrame.statusIcon:Show()

-- Text header pushed 14px right to align flawlessly with the skull icon
FokusNPCFrame.nameText = FokusNPCFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
FokusNPCFrame.nameText:SetPoint("TOPLEFT", FokusNPCFrame, "TOPLEFT", 66, -6)
FokusNPCFrame.nameText:SetJustifyH("LEFT")

FokusNPCFrame.levelText = FokusNPCFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
FokusNPCFrame.levelText:SetPoint("TOPRIGHT", FokusNPCFrame, "TOPRIGHT", -38, -6)
FokusNPCFrame.levelText:SetJustifyH("RIGHT")

-- Main Health Bar
FokusNPCFrame.hpBar = CreateFrame("StatusBar", nil, FokusNPCFrame)
FokusNPCFrame.hpBar:SetSize(148, 14) 
FokusNPCFrame.hpBar:SetPoint("TOPLEFT", FokusNPCFrame, "TOPLEFT", 52, -18)
FokusNPCFrame.hpBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
FokusNPCFrame.hpBar:SetStatusBarColor(0, 0.8, 0) 

FokusNPCFrame.hpText = FokusNPCFrame.hpBar:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
FokusNPCFrame.hpText:SetPoint("CENTER", FokusNPCFrame.hpBar, "CENTER", 0, 0)

-- Main Power Bar / Mana
FokusNPCFrame.manaBar = CreateFrame("StatusBar", nil, FokusNPCFrame)
FokusNPCFrame.manaBar:SetSize(148, 6) 
FokusNPCFrame.manaBar:SetPoint("TOPLEFT", FokusNPCFrame.hpBar, "BOTTOMLEFT", 0, -2)
FokusNPCFrame.manaBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
FokusNPCFrame.manaBar:SetStatusBarColor(0, 0, 1)

-- INTERACTIVE CONTROL BUTTONS FOR NPC FRAME
FokusNPCFrame.clearBtn = CreateFrame("Button", nil, FokusNPCFrame.iconOverlay)
FokusNPCFrame.clearBtn:SetSize(12, 12)
FokusNPCFrame.clearBtn:SetPoint("TOPRIGHT", FokusNPCFrame, "TOPRIGHT", -6, -4)
FokusNPCFrame.clearBtn.tex = FokusNPCFrame.clearBtn:CreateTexture(nil, "OVERLAY")
FokusNPCFrame.clearBtn.tex:SetAllPoints()
FokusNPCFrame.clearBtn.tex:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
FokusNPCFrame.clearBtn:Show()

FokusNPCFrame.clearBtn:SetScript("OnClick", function()
    if not InCombatLockdown() then FokusEraNS.FokusEra_ClearGroupFocusLogic() end
end)

FokusNPCFrame.lockBtn = CreateFrame("Button", nil, FokusNPCFrame.iconOverlay)
FokusNPCFrame.lockBtn:SetSize(12, 12)
FokusNPCFrame.lockBtn:SetPoint("RIGHT", FokusNPCFrame.clearBtn, "LEFT", -4, 0)
FokusNPCFrame.lockBtn.tex = FokusNPCFrame.lockBtn:CreateTexture(nil, "OVERLAY")
FokusNPCFrame.lockBtn.tex:SetAllPoints()
FokusNPCFrame.lockBtn.tex:SetTexture("Interface\\Buttons\\UI-OptionsButton")
FokusNPCFrame.lockBtn:Show()

FokusNPCFrame.lockBtn:SetScript("OnClick", function()
    if not InCombatLockdown() and FokusFrame and FokusFrame.lockBtn then
        local masterScript = FokusFrame.lockBtn:GetScript("OnClick")
        if masterScript then masterScript() end
        if FokusEra_AlignNPCLayouts then FokusEra_AlignNPCLayouts() end
    end
end)

-- Redirect drag script inputs from the active template canvas to the shadow root node
FokusNPCFrame:RegisterForDrag("LeftButton")
FokusNPCFrame:SetScript("OnDragStart", function(self)
    if not InCombatLockdown() and not FokusEraNS.FokusEra_IsLocked and IsAltKeyDown() then
        FokusShadowFrame:StartMoving()
    end
end)
FokusNPCFrame:SetScript("OnDragStop", function(self)
    FokusShadowFrame:StopMovingOrSizing()
    if not InCombatLockdown() then
        FokusEra_ShadowX = math.floor(FokusShadowFrame:GetLeft())
        FokusEra_ShadowY = math.floor(FokusShadowFrame:GetBottom())
    end
    if FokusEra_AlignNPCLayouts then FokusEra_AlignNPCLayouts() end
    if ReanchorTargetFrame then ReanchorTargetFrame() end
end)

-- 2. FOCUS TARGET NPC FRAME (FokusTargetNPCFrame)
FokusTargetNPCFrame = CreateFrame("Button", "FokusTargetNPCFrame", FokusNPCFrame, "BackdropTemplate")
FokusTargetNPCFrame:SetSize(170, 48)
FokusTargetNPCFrame:Hide()

FokusTargetNPCFrame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 8, edgeSize = 12,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
FokusTargetNPCFrame:SetBackdropColor(0, 0, 0, 0.85)
FokusTargetNPCFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

FokusTargetNPCFrame.staticPortrait = CreateFrame("Frame", nil, FokusTargetNPCFrame)
FokusTargetNPCFrame.portrait = CreateFrame("PlayerModel", nil, FokusTargetNPCFrame)
FokusTargetNPCFrame.portrait:SetSize(40, 38)
FokusTargetNPCFrame.portrait:SetPoint("TOPRIGHT", FokusTargetNPCFrame, "TOPRIGHT", -6, -5)
FokusTargetNPCFrame.portrait:SetScript("OnModelLoaded", function(self) self:SetCamera(1) end)

local targetPortBG = FokusTargetNPCFrame:CreateTexture(nil, "BACKGROUND")
targetPortBG:SetAllPoints(FokusTargetNPCFrame.portrait)
targetPortBG:SetColorTexture(0.05, 0.05, 0.05, 1)

FokusTargetNPCFrame.iconOverlay = CreateFrame("Frame", nil, FokusTargetNPCFrame)
FokusTargetNPCFrame.iconOverlay:SetAllPoints(FokusTargetNPCFrame)
FokusTargetNPCFrame.iconOverlay:SetFrameStrata("DIALOG")
FokusTargetNPCFrame.iconOverlay:SetFrameLevel(FokusTargetNPCFrame.portrait:GetFrameLevel() + 10)
FokusTargetNPCFrame.iconOverlay:EnableMouse(false)
if FokusTargetNPCFrame.iconOverlay.SetMouseClickEnabled then FokusTargetNPCFrame.iconOverlay:SetMouseClickEnabled(false) end

-- Target NPC Raid Mark Icon
FokusTargetNPCFrame.raidIcon = FokusTargetNPCFrame.iconOverlay:CreateTexture(nil, "OVERLAY")
FokusTargetNPCFrame.raidIcon:SetSize(14, 14)
FokusTargetNPCFrame.raidIcon:SetPoint("TOPRIGHT", FokusTargetNPCFrame, "TOPRIGHT", -2, -1)
FokusTargetNPCFrame.raidIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
FokusTargetNPCFrame.raidIcon:Hide()

FokusTargetNPCFrame.statusIcon = FokusTargetNPCFrame:CreateTexture(nil, "OVERLAY")
FokusTargetNPCFrame.statusIcon:SetSize(10, 10)
FokusTargetNPCFrame.statusIcon:SetPoint("TOPLEFT", FokusTargetNPCFrame, "TOPLEFT", 8, -6)
FokusTargetNPCFrame.statusIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
FokusTargetNPCFrame.statusIcon:SetTexCoord(0.75, 1, 0.25, 0.5)
FokusTargetNPCFrame.statusIcon:SetVertexColor(0.8, 0.8, 0.8)
FokusTargetNPCFrame.statusIcon:Hide() 

FokusTargetNPCFrame.nameText = FokusTargetNPCFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
FokusTargetNPCFrame.nameText:SetPoint("TOPLEFT", FokusTargetNPCFrame, "TOPLEFT", 22, -6)
FokusTargetNPCFrame.nameText:SetSize(114, 12)
FokusTargetNPCFrame.nameText:SetJustifyH("LEFT")

FokusTargetNPCFrame.hpBar = CreateFrame("StatusBar", nil, FokusTargetNPCFrame)
FokusTargetNPCFrame.hpBar:SetSize(114, 14) 
FokusTargetNPCFrame.hpBar:SetPoint("TOPLEFT", FokusTargetNPCFrame, "TOPLEFT", 8, -18)
FokusTargetNPCFrame.hpBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")

FokusTargetNPCFrame.manaBar = CreateFrame("StatusBar", nil, FokusTargetNPCFrame)
FokusTargetNPCFrame.manaBar:SetSize(114, 6) 
FokusTargetNPCFrame.manaBar:SetPoint("TOPLEFT", FokusTargetNPCFrame.hpBar, "BOTTOMLEFT", 0, -2)
FokusTargetNPCFrame.manaBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")


-- MASTER DYNAMIC ALIGNMENT ENGINE (TALKS EXCLUSIVELY TO SHADOW FRAME)
function FokusEra_AlignNPCLayouts()
    if not FokusShadowFrame then return end
    local width = FokusShadowFrame:GetWidth()
    local barWidth = width - 62
    
    FokusNPCFrame:SetSize(width, 48)
    FokusNPCFrame:ClearAllPoints()
    FokusNPCFrame:SetPoint("CENTER", FokusShadowFrame, "CENTER", 0, 0)
    
    FokusNPCFrame.hpBar:SetWidth(barWidth)
    FokusNPCFrame.manaBar:SetWidth(barWidth)
    
    -- FIX v1.4.0: ELIMINATED HIDE/SHOW ERRORS ON INTERACTIVE HANDLING!
    -- Replaced obsolete hidden status gates. Both buttons remain natively exposed and active at all times.
    -- The clear pass-cross is permanently available, and the lock texture toggles pure color nodes seamlessly.
    if FokusEraNS.FokusEra_IsLocked then
        if FokusNPCFrame.lockBtn.tex then
            FokusNPCFrame.lockBtn.tex:SetVertexColor(1, 0, 0) -- Pure Red when locked
        end
    else
        if FokusNPCFrame.lockBtn.tex then
            FokusNPCFrame.lockBtn.tex:SetVertexColor(1, 0.82, 0) -- Golden Yellow when unlocked
        end
    end
    
    FokusTargetNPCFrame:ClearAllPoints()
    if FokusEra_OffsetX and FokusEra_OffsetY then
        FokusTargetNPCFrame:SetPoint("LEFT", FokusNPCFrame, "RIGHT", FokusEra_OffsetX, FokusEra_OffsetY)
    else
        FokusTargetNPCFrame:SetPoint("LEFT", FokusNPCFrame, "RIGHT", 4, 0)
    end
end

-- end fokusnpcui.lua