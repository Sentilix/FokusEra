-- Catch the shared addon namespace parameter from the WoW engine
local addonName, FokusEraNS = ...

-- Global frame names unified with the K format
FokusEraTargetFrame = CreateFrame("Button", "FokusEraTargetFrame", FokusFrame, "SecureUnitButtonTemplate, BackdropTemplate")
FokusTargetFrame = FokusEraTargetFrame

-- FOCUS TARGET FRAME DESIGN (Width 170)
FokusTargetFrame:SetSize(170, 48)
FokusTargetFrame:SetMovable(true) 
FokusTargetFrame:EnableMouse(true)
FokusTargetFrame:RegisterForClicks("AnyUp")
FokusTargetFrame:Hide()

FokusTargetFrame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 8, edgeSize = 12,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
FokusTargetFrame:SetBackdropColor(0, 0, 0, 0.85)
FokusTargetFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

-- FUNCTION: Dynamically anchors the target frame relative to the main frame
function ReanchorTargetFrame()
    FokusTargetFrame:ClearAllPoints()
    FokusTargetFrame:SetPoint("LEFT", FokusFrame, "RIGHT", FokusEra_OffsetX, FokusEra_OffsetY)
end

-- ADVANCED DRAG SCRIPT: "ALIGN TO GRID" WITH BALANCED MAGNET SNAP
FokusTargetFrame:RegisterForDrag("LeftButton")
FokusTargetFrame:SetScript("OnDragStart", function(self) 
    if not InCombatLockdown() and not FokusEraNS.FokusEra_IsLocked and IsAltKeyDown() then self:StartMoving() end 
end)

FokusTargetFrame:SetScript("OnDragStop", function(self) 
    self:StopMovingOrSizing()
    
    local mainX, mainY = FokusFrame:GetCenter()
    local targetX, targetY = self:GetCenter()
    
    if mainX and mainY and targetX and targetY then
        local currentMainWidth = FokusFrame:GetWidth() 
        local rawX = math.floor(targetX - mainX - (currentMainWidth / 2) - (170 / 2)) 
        local rawY = math.floor(targetY - mainY)
        
        if math.abs(rawY - (0)) <= 10 then rawY = 0 end 
        
        FokusEra_OffsetX = rawX
        FokusEra_OffsetY = rawY
        
        ReanchorTargetFrame()
    end
end)

-- Mirrored Target Portrait configuration (Anchored to upper-right bounds)
FokusTargetFrame.staticPortrait = CreateFrame("Frame", nil, FokusTargetFrame)
FokusTargetFrame.portrait = CreateFrame("PlayerModel", nil, FokusTargetFrame)
FokusTargetFrame.portrait:SetSize(40, 38)
FokusTargetFrame.portrait:SetPoint("TOPRIGHT", FokusTargetFrame, "TOPRIGHT", -6, -5)

FokusTargetFrame.portrait:SetScript("OnModelLoaded", function(self)
    self:SetCamera(0) 
end)

local targetPortBG = FokusTargetFrame:CreateTexture(nil, "BACKGROUND")
targetPortBG:SetAllPoints(FokusTargetFrame.portrait)
targetPortBG:SetColorTexture(0.05, 0.05, 0.05, 1)

-- NEW: Mirrored Raid Target Icon Texture (Placed on top-right corner of the target portrait)
FokusTargetFrame.raidIcon = FokusTargetFrame.staticPortrait:CreateTexture(nil, "OVERLAY")
FokusTargetFrame.raidIcon:SetSize(16, 16)
FokusTargetFrame.raidIcon:SetPoint("TOPRIGHT", FokusTargetFrame.portrait, "TOPRIGHT", 2, 2)
FokusTargetFrame.raidIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
FokusTargetFrame.raidIcon:Hide()

-- Target Frame Text & Health Bar Elements (Mirrored configuration boundaries)
FokusTargetFrame.nameText = FokusTargetFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
FokusTargetFrame.nameText:SetPoint("TOPLEFT", FokusTargetFrame, "TOPLEFT", 8, -6)
FokusTargetFrame.nameText:SetSize(114, 12)
FokusTargetFrame.nameText:SetJustifyH("LEFT")

FokusTargetFrame.hpBar = CreateFrame("StatusBar", nil, FokusTargetFrame)
FokusTargetFrame.hpBar:SetSize(114, 14) 
FokusTargetFrame.hpBar:SetPoint("TOPLEFT", FokusTargetFrame, "TOPLEFT", 8, -18)
FokusTargetFrame.hpBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
FokusTargetFrame.hpBar:SetStatusBarColor(0, 0.8, 0)

FokusTargetFrame.manaBar = CreateFrame("StatusBar", nil, FokusTargetFrame)
FokusTargetFrame.manaBar:SetSize(114, 6) 
FokusTargetFrame.manaBar:SetPoint("TOPLEFT", FokusTargetFrame.hpBar, "BOTTOMLEFT", 0, -2)
FokusTargetFrame.manaBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
FokusTargetFrame.manaBar:SetStatusBarColor(0, 0, 1)

-- Register target components into click-cast tracking bridge engines
ClickCastFrames = ClickCastFrames or {}
ClickCastFrames[FokusTargetFrame] = true

-- Hook an alignment enforcement handler onto character profile validation updates
local targetBootLoader = CreateFrame("Frame")
targetBootLoader:RegisterEvent("PLAYER_LOGIN")
targetBootLoader:SetScript("OnEvent", function(self)
    ReanchorTargetFrame()
    targetBootLoader:UnregisterEvent("PLAYER_LOGIN")
end)
