-- Catch the shared addon namespace parameter from the WoW engine
local addonName, FokusEraNS = ...

-- 1. MAIN FOCUS NPC FRAME (FokusNPCFrame)
FokusNPCFrame = CreateFrame("Button", "FokusNPCFrame", UIParent, "BackdropTemplate")
FokusNPCFrame:SetSize(210, 48)
FokusNPCFrame:Hide()

FokusNPCFrame:SetMovable(false)
FokusNPCFrame:EnableMouse(true)
FokusNPCFrame:RegisterForDrag("LeftButton")

FokusNPCFrame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 8, edgeSize = 12,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
FokusNPCFrame:SetBackdropColor(0, 0, 0, 0.85)
FokusNPCFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

-- Layout replication matching the core framework
FokusNPCFrame.portrait = CreateFrame("PlayerModel", nil, FokusNPCFrame)
FokusNPCFrame.portrait:SetSize(40, 38)
FokusNPCFrame.portrait:SetPoint("TOPLEFT", FokusNPCFrame, "TOPLEFT", 6, -5)

local portBG = FokusNPCFrame:CreateTexture(nil, "BACKGROUND")
portBG:SetAllPoints(FokusNPCFrame.portrait)
portBG:SetColorTexture(0.05, 0.05, 0.05, 1)

FokusNPCFrame.nameText = FokusNPCFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
FokusNPCFrame.nameText:SetPoint("TOPLEFT", FokusNPCFrame, "TOPLEFT", 52, -6)
FokusNPCFrame.nameText:SetJustifyH("LEFT")

FokusNPCFrame.levelText = FokusNPCFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
FokusNPCFrame.levelText:SetPoint("TOPRIGHT", FokusNPCFrame, "TOPRIGHT", -38, -6)
FokusNPCFrame.levelText:SetJustifyH("RIGHT")

FokusNPCFrame.hpBar = CreateFrame("StatusBar", nil, FokusNPCFrame)
FokusNPCFrame.hpBar:SetSize(148, 14) 
FokusNPCFrame.hpBar:SetPoint("TOPLEFT", FokusNPCFrame, "TOPLEFT", 52, -18)
FokusNPCFrame.hpBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
FokusNPCFrame.hpBar:SetStatusBarColor(1, 0, 0) 

FokusNPCFrame.hpText = FokusNPCFrame.hpBar:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
FokusNPCFrame.hpText:SetPoint("CENTER", FokusNPCFrame.hpBar, "CENTER", 0, 0)

FokusNPCFrame.manaBar = CreateFrame("StatusBar", nil, FokusNPCFrame)
FokusNPCFrame.manaBar:SetSize(148, 6) 
FokusNPCFrame.manaBar:SetPoint("TOPLEFT", FokusNPCFrame.hpBar, "BOTTOMLEFT", 0, -2)
FokusNPCFrame.manaBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
FokusNPCFrame.manaBar:SetStatusBarColor(0, 0, 1)

-- Redirect drag script inputs from the active template canvas to the shadow root node
FokusNPCFrame:SetScript("OnDragStart", function(self)
    if not InCombatLockdown() and not FokusEraNS.FokusEra_IsLocked and IsAltKeyDown() then
        FokusShadowFrame:StartMoving()
    end
end)
FokusNPCFrame:SetScript("OnDragStop", function(self)
    FokusShadowFrame:StopMovingOrSizing()
    local mainX, mainY = FokusShadowFrame:GetCenter()
    local parentX, parentY = UIParent:GetCenter()
    if mainX and mainY and parentX and parentY then
        FokusEra_OffsetX = math.floor(mainX - parentX)
        FokusEra_OffsetY = math.floor(mainY - parentY)
    end
    if FokusEra_AlignNPCLayouts then FokusEra_AlignNPCLayouts() end
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

FokusTargetNPCFrame.portrait = CreateFrame("PlayerModel", nil, FokusTargetNPCFrame)
FokusTargetNPCFrame.portrait:SetSize(40, 38)
FokusTargetNPCFrame.portrait:SetPoint("TOPRIGHT", FokusTargetNPCFrame, "TOPRIGHT", -6, -5)
FokusTargetNPCFrame.portrait:SetScript("OnModelLoaded", function(self) self:SetCamera(0) end)

local targetPortBG = FokusTargetNPCFrame:CreateTexture(nil, "BACKGROUND")
targetPortBG:SetAllPoints(FokusTargetNPCFrame.portrait)
targetPortBG:SetColorTexture(0.05, 0.05, 0.05, 1)

FokusTargetNPCFrame.nameText = FokusTargetNPCFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
FokusTargetNPCFrame.nameText:SetPoint("TOPLEFT", FokusTargetNPCFrame, "TOPLEFT", 8, -6)
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

-- FIX v1.4.0: MASTER DYNAMIC ALIGNMENT ENGINE (TALKS EXCLUSIVELY TO SHADOW FRAME)
function FokusEra_AlignNPCLayouts()
    if not FokusShadowFrame then return end
    
    local width = FokusShadowFrame:GetWidth()
    local barWidth = width - 62
    
    -- Sync non-secure boss frame structures with the single source of truth coordinates
    FokusNPCFrame:SetSize(width, 48)
    FokusNPCFrame:ClearAllPoints()
    FokusNPCFrame:SetPoint("CENTER", FokusShadowFrame, "CENTER", 0, 0)
    
    FokusNPCFrame.hpBar:SetWidth(barWidth)
    FokusNPCFrame.manaBar:SetWidth(barWidth)
    
    FokusTargetNPCFrame:ClearAllPoints()
    FokusTargetNPCFrame:SetPoint("LEFT", FokusNPCFrame, "RIGHT", FokusEra_OffsetX, FokusEra_OffsetY)
end

-- end fokusnpcui.lua