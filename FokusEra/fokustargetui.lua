-- Catch the shared addon namespace parameter from the WoW engine
local addonName, FokusEraNS = ...

-- UNIFIED GLOBAL NAMING Blueprints
FokusEraTargetFrame = CreateFrame("Button", "FokusEraTargetFrame", UIParent, "SecureUnitButtonTemplate, BackdropTemplate")
FokusTargetFrame = FokusEraTargetFrame

-- MAIN TARGET FRAME DESIGN (Width defaults to 170, Height: 48)
FokusTargetFrame:SetSize(170, 48)
FokusTargetFrame:SetMovable(false)
FokusTargetFrame:SetResizable(true) 
FokusTargetFrame:SetResizeBounds(120, 48, 400, 48) 
FokusTargetFrame:EnableMouse(true)
FokusTargetFrame:RegisterForClicks("AnyUp")
FokusTargetFrame:Hide()

FokusTargetFrame:SetFrameStrata("DIALOG")
FokusTargetFrame:SetFrameLevel(20)

FokusTargetFrame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 8, edgeSize = 12,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
FokusTargetFrame:SetBackdropColor(0, 0, 0, 0.85)
FokusTargetFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

-- FUNCTION: Updates the internal width profiles of the status bars dynamically
function FokusTarget_UpdateInternalWidths()
    if InCombatLockdown() then return end
    local newWidth = FokusTargetFrame:GetWidth()
    local barWidth = newWidth - 56 
    FokusTargetFrame.hpBar:SetWidth(barWidth)
    FokusTargetFrame.manaBar:SetWidth(barWidth)
end

-- Right-anchored mirrored portrait configuration
FokusTargetFrame.staticPortrait = CreateFrame("Frame", nil, FokusTargetFrame)
FokusTargetFrame.portrait = CreateFrame("PlayerModel", nil, FokusTargetFrame)
FokusTargetFrame.portrait:SetSize(40, 38)
FokusTargetFrame.portrait:SetPoint("TOPRIGHT", FokusTargetFrame, "TOPRIGHT", -6, -5)

local portBG = FokusTargetFrame:CreateTexture(nil, "BACKGROUND")
portBG:SetAllPoints(FokusTargetFrame.portrait)
portBG:SetColorTexture(0.05, 0.05, 0.05, 1)

-- Master Target Icon Overlay Frame Container
FokusTargetFrame.iconOverlay = CreateFrame("Frame", nil, FokusTargetFrame)
FokusTargetFrame.iconOverlay:SetAllPoints(FokusTargetFrame)
FokusTargetFrame.iconOverlay:SetFrameStrata("DIALOG")
FokusTargetFrame.iconOverlay:SetFrameLevel(FokusTargetFrame:GetFrameLevel() + 5)
FokusTargetFrame.iconOverlay:EnableMouse(false)
if FokusTargetFrame.iconOverlay.SetMouseClickEnabled then FokusTargetFrame.iconOverlay:SetMouseClickEnabled(false) end

-- Raid Target Mark Anchor
FokusTargetFrame.raidIcon = FokusTargetFrame.iconOverlay:CreateTexture(nil, "OVERLAY")
FokusTargetFrame.raidIcon:SetSize(14, 14)
FokusTargetFrame.raidIcon:SetPoint("TOPRIGHT", FokusTargetFrame, "TOPRIGHT", -2, -1)
FokusTargetFrame.raidIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
FokusTargetFrame.raidIcon:Hide()

-- Text row geometries
FokusTargetFrame.nameText = FokusTargetFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
FokusTargetFrame.nameText:SetPoint("TOPLEFT", FokusTargetFrame, "TOPLEFT", 8, -6)
FokusTargetFrame.nameText:SetJustifyH("LEFT")

-- Target Health Bar
FokusTargetFrame.hpBar = CreateFrame("StatusBar", nil, FokusTargetFrame)
FokusTargetFrame.hpBar:SetSize(114, 14)
FokusTargetFrame.hpBar:SetPoint("TOPLEFT", FokusTargetFrame, "TOPLEFT", 8, -18)
FokusTargetFrame.hpBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
FokusTargetFrame.hpBar:SetStatusBarColor(0, 0.8, 0)

-- Target Power Bar / Mana
FokusTargetFrame.manaBar = CreateFrame("StatusBar", nil, FokusTargetFrame)
FokusTargetFrame.manaBar:SetSize(114, 6)
FokusTargetFrame.manaBar:SetPoint("TOPLEFT", FokusTargetFrame, "TOPLEFT", 8, -34)
FokusTargetFrame.manaBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
FokusTargetFrame.manaBar:SetStatusBarColor(0, 0, 1)

-- INTERACTIVE RESIZE FRAME (FIX v1.4.0: Built in the absolute top TOOLTIP layer to break 3D depth!)
FokusTargetResizeFrame = CreateFrame("Button", "FokusTargetResizeFrame", UIParent)
FokusTargetResizeFrame:SetSize(12, 12)
FokusTargetResizeFrame:SetFrameStrata("TOOLTIP") -- Absolute forward layer fortress
FokusTargetResizeFrame:SetFrameLevel(100)
FokusTargetResizeFrame:Hide()

FokusTargetResizeFrame.tex = FokusTargetResizeFrame:CreateTexture(nil, "OVERLAY")
FokusTargetResizeFrame.tex:SetAllPoints()
FokusTargetResizeFrame.tex:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")

FokusTargetFrame.resizeBtn = FokusTargetResizeFrame -- Map references to clear out errors

FokusTargetResizeFrame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" and not InCombatLockdown() and not FokusEraNS.FokusEra_IsLocked then
        FokusTargetFrame:SetResizable(true)
        FokusTargetFrame:StartSizing("RIGHT")
        
        -- Live synchronization loop to dynamically scale layouts smoothly
        FokusTargetResizeFrame:SetScript("OnUpdate", function()
            if not InCombatLockdown() then
                FokusTarget_UpdateInternalWidths()
            end
        end)
    end
end)

FokusTargetResizeFrame:SetScript("OnMouseUp", function(self, button)
    FokusTargetResizeFrame:SetScript("OnUpdate", nil)
    FokusTargetFrame:StopMovingOrSizing()
    FokusEra_TargetWidth = FokusTargetFrame:GetWidth() 
    FokusTarget_UpdateInternalWidths()
end)

-- GLOBAL MAGNET-SNAP ALIGNMENT ENGINE
function ReanchorTargetFrame()
    if InCombatLockdown() or not FokusFrame or not FokusTargetFrame then return end
    
    if FokusEra_TargetWidth == nil then FokusEra_TargetWidth = 170 end
    FokusTargetFrame:SetWidth(FokusEra_TargetWidth)
    FokusTarget_UpdateInternalWidths()
    
    -- Sync the loose floating tooltip resize arrow onto the absolute corner of the frame
    FokusTargetResizeFrame:ClearAllPoints()
    FokusTargetResizeFrame:SetPoint("BOTTOMRIGHT", FokusTargetFrame, "BOTTOMRIGHT", -2, 2)
    
    if FokusEraNS.FokusEra_IsLocked then
        FokusTargetResizeFrame:Hide()
    else
        if FokusTargetFrame:IsShown() then FokusTargetResizeFrame:Show() else FokusTargetResizeFrame:Hide() end
    end
    
    FokusTargetFrame:ClearAllPoints()
    if FokusEra_OffsetX and FokusEra_OffsetY then
        FokusTargetFrame:SetPoint("LEFT", FokusFrame, "RIGHT", FokusEra_OffsetX, FokusEra_OffsetY)
    else
        FokusTargetFrame:SetPoint("LEFT", FokusFrame, "RIGHT", 4, 0)
    end
end

-- Hook visibility routines to ensure the floating handle collapses correctly
FokusTargetFrame:HookScript("OnShow", function() if not FokusEraNS.FokusEra_IsLocked then FokusTargetResizeFrame:Show() end end)
FokusTargetFrame:HookScript("OnHide", function() FokusTargetResizeFrame:Hide() end)

-- INITIALIZATION PROFILE LOADING ON BOOT
local targetLoader = CreateFrame("Frame")
targetLoader:RegisterEvent("PLAYER_LOGIN")
targetLoader:SetScript("OnEvent", function(self)
    ReanchorTargetFrame()
    targetLoader:UnregisterEvent("PLAYER_LOGIN")
end)

-- fokustgargetui.lua