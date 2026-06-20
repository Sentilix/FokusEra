-- Catch the shared addon namespace parameter from the WoW engine
local addonName, FokusEraNS = ...

-- Global frame names unified with the K format
FokusEraFrame = CreateFrame("Button", "FokusEraFrame", UIParent, "SecureUnitButtonTemplate, BackdropTemplate")
FokusFrame = FokusEraFrame

FokusEraTargetFrame = CreateFrame("Button", "FokusEraTargetFrame", FokusFrame, "SecureUnitButtonTemplate, BackdropTemplate")
FokusTargetFrame = FokusEraTargetFrame

-- MAIN FRAME DESIGN (FokusFrame - Height: 48)
FokusFrame:SetSize(210, 48)
FokusFrame:SetPoint("CENTER", UIParent, "CENTER", -65, -150)
FokusFrame:SetMovable(true)
FokusFrame:SetResizable(true) 
FokusFrame:SetResizeBounds(160, 48, 400, 48)
FokusFrame:EnableMouse(true)
FokusFrame:RegisterForClicks("AnyUp")
FokusFrame:Hide()

FokusFrame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 8, edgeSize = 12,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
FokusFrame:SetBackdropColor(0, 0, 0, 0.85)
FokusFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

-- FUNCTION: Dynamically anchors the target frame relative to the main frame
function ReanchorTargetFrame()
    FokusTargetFrame:ClearAllPoints()
    FokusTargetFrame:SetPoint("LEFT", FokusFrame, "RIGHT", FokusEra_OffsetX, FokusEra_OffsetY)
end

-- FUNCTION: Updates the width of the status bars inside the frame based on current frame width
function FokusEra_UpdateInternalWidths()
    local newWidth = FokusFrame:GetWidth()
    local barWidth = newWidth - 62 
    FokusFrame.hpBar:SetWidth(barWidth)
    FokusFrame.manaBar:SetWidth(barWidth)
end

-- Drag handling for Main Frame
FokusFrame:RegisterForDrag("LeftButton")
FokusFrame:SetScript("OnDragStart", function(self) 
    if not InCombatLockdown() and not FokusEraNS.FokusEra_IsLocked and IsAltKeyDown() then self:StartMoving() end 
end)
FokusFrame:SetScript("OnDragStop", function(self) 
    self:StopMovingOrSizing()
    ReanchorTargetFrame()
end)

-- FOCUS TARGET FRAME DESIGN (Height: 48 - Symmetrical boundary shell)
FokusTargetFrame:SetSize(130, 48)
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
        local rawX = math.floor(targetX - mainX - (currentMainWidth / 2) - (130 / 2))
        local rawY = math.floor(targetY - mainY)
        
        -- MAGNETIC SNAP: Forced snap mapping onto identical plane parameters
        if math.abs(rawY - (0)) <= 10 then rawY = 0 end 
        
        FokusEra_OffsetX = rawX
        FokusEra_OffsetY = rawY
        
        ReanchorTargetFrame()
    end
end)

-- Portrait sub-frames configuration
FokusFrame.staticPortrait = CreateFrame("Frame", nil, FokusFrame)
FokusFrame.portrait = CreateFrame("PlayerModel", nil, FokusFrame)
FokusFrame.portrait:SetSize(40, 38)
FokusFrame.portrait:SetPoint("TOPLEFT", FokusFrame, "TOPLEFT", 6, -5)

local portBG = FokusFrame:CreateTexture(nil, "BACKGROUND")
portBG:SetAllPoints(FokusFrame.portrait)
portBG:SetColorTexture(0.05, 0.05, 0.05, 1)

-- Text strings layout geometry
FokusFrame.nameText = FokusFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
FokusFrame.nameText:SetPoint("TOPLEFT", FokusFrame, "TOPLEFT", 52, -6)
FokusFrame.nameText:SetJustifyH("LEFT")

FokusFrame.levelText = FokusFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
FokusFrame.levelText:SetPoint("TOPRIGHT", FokusFrame, "TOPRIGHT", -38, -6)
FokusFrame.levelText:SetJustifyH("RIGHT")

-- Target Frame Text & Health Bar Elements
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

-- Main Health Bar
FokusFrame.hpBar = CreateFrame("StatusBar", nil, FokusFrame)
FokusFrame.hpBar:SetSize(148, 14) 
FokusFrame.hpBar:SetPoint("TOPLEFT", FokusFrame, "TOPLEFT", 52, -18)
FokusFrame.hpBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
FokusFrame.hpBar:SetStatusBarColor(0, 0.8, 0)

FokusFrame.hpText = FokusFrame.hpBar:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
FokusFrame.hpText:SetPoint("CENTER", FokusFrame.hpBar, "CENTER", 0, 0)

-- Main Power Bar / Mana
FokusFrame.manaBar = CreateFrame("StatusBar", nil, FokusFrame)
FokusFrame.manaBar:SetSize(148, 6) 
FokusFrame.manaBar:SetPoint("TOPLEFT", FokusFrame.hpBar, "BOTTOMLEFT", 0, -2)
FokusFrame.manaBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
FokusFrame.manaBar:SetStatusBarColor(0, 0, 1)

-- Click-cast communication bridge array configuration
ClickCastFrames = ClickCastFrames or {}
ClickCastFrames[FokusFrame] = true
ClickCastFrames[FokusTargetFrame] = true

-- INTERACTIVE CONTROL BUTTONS
FokusFrame.clearBtn = CreateFrame("Button", nil, FokusFrame)
FokusFrame.clearBtn:SetSize(12, 12)
FokusFrame.clearBtn:SetPoint("TOPRIGHT", FokusFrame, "TOPRIGHT", -6, -4)
FokusFrame.clearBtn.tex = FokusFrame.clearBtn:CreateTexture(nil, "OVERLAY")
FokusFrame.clearBtn.tex:SetAllPoints()
FokusFrame.clearBtn.tex:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
FokusFrame.clearBtn:SetScript("OnClick", function()
    if not InCombatLockdown() then FokusEraNS.FokusEra_ClearGroupFocusLogic() end
end)

FokusFrame.lockBtn = CreateFrame("Button", nil, FokusFrame)
FokusFrame.lockBtn:SetSize(12, 12)
FokusFrame.lockBtn:SetPoint("RIGHT", FokusFrame.clearBtn, "LEFT", -4, 0)
FokusFrame.lockBtn.tex = FokusFrame.lockBtn:CreateTexture(nil, "OVERLAY")
FokusFrame.lockBtn.tex:SetAllPoints()
FokusFrame.lockBtn.tex:SetTexture("Interface\\Buttons\\UI-OptionsButton")

-- INTERACTIVE RESIZE BUTTON
FokusFrame.resizeBtn = CreateFrame("Button", nil, FokusFrame)
FokusFrame.resizeBtn:SetSize(12, 12)
FokusFrame.resizeBtn:SetPoint("BOTTOMRIGHT", FokusFrame, "BOTTOMRIGHT", -2, 2)
FokusFrame.resizeBtn.tex = FokusFrame.resizeBtn:CreateTexture(nil, "OVERLAY")
FokusFrame.resizeBtn.tex:SetAllPoints()
FokusFrame.resizeBtn.tex:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")

FokusFrame.resizeBtn:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" and not InCombatLockdown() and not FokusEraNS.FokusEra_IsLocked then
        FokusFrame:StartSizing("RIGHT") 
    end
end)

FokusFrame.resizeBtn:SetScript("OnMouseUp", function(self, button)
    FokusFrame:StopMovingOrSizing()
    FokusEra_Width = FokusFrame:GetWidth()
    FokusEra_UpdateInternalWidths()
    ReanchorTargetFrame()
end)

function FokusEra_UpdateLockIconColor()
    if FokusEraNS.FokusEra_IsLocked then 
        FokusFrame.lockBtn.tex:SetVertexColor(1, 0, 0)
        FokusFrame.resizeBtn:Hide() 
    else 
        FokusFrame.lockBtn.tex:SetVertexColor(1, 0.82, 0)
        FokusFrame.resizeBtn:Show() 
    end
end

FokusFrame.lockBtn:SetScript("OnClick", function()
    FokusEraNS.FokusEra_IsLocked = not FokusEraNS.FokusEra_IsLocked
    FokusEra_SavedLockState = FokusEraNS.FokusEra_IsLocked 
    FokusEra_UpdateLockIconColor()
end)

-- INITIALIZATION PROFILE LOADING ON BOOT
local saveLoader = CreateFrame("Frame")
saveLoader:RegisterEvent("PLAYER_LOGIN")
saveLoader:SetScript("OnEvent", function(self, event)
    if FokusEra_SavedLockState ~= nil then FokusEraNS.FokusEra_IsLocked = FokusEra_SavedLockState
    else FokusEra_SavedLockState = false end
    
    if FokusEra_OffsetX == nil then FokusEra_OffsetX = 4 end
    if FokusEra_OffsetY == nil then FokusEra_OffsetY = 0 end 
    if FokusEra_Width == nil then FokusEra_Width = 210 end 
    
    FokusFrame:SetWidth(FokusEra_Width) 
    FokusEra_UpdateInternalWidths() 
    
    FokusEra_UpdateLockIconColor() 
    ReanchorTargetFrame()
    saveLoader:UnregisterEvent("PLAYER_LOGIN")
end)
