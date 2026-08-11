-- Catch the shared addon namespace parameter from the WoW engine
local addonName, FokusEraNS = ...

-- UNIFIED GLOBAL NAMING Blueprints
FokusEraTargetFrame = CreateFrame("Button", "FokusEraTargetFrame", UIParent, "SecureUnitButtonTemplate, BackdropTemplate")
FokusTargetFrame = FokusEraTargetFrame

-- MAIN TARGET FRAME DESIGN (Width defaults to 170, Height: 48)
FokusTargetFrame:SetSize(170, 48)
FokusTargetFrame:SetMovable(true) -- FIX v1.4.0: Allow cursor tracking hardware link out of combat
FokusTargetFrame:SetResizable(true) 
FokusTargetFrame:SetResizeBounds(120, 48, 400, 48) 
FokusTargetFrame:EnableMouse(true)
FokusTargetFrame:RegisterForClicks("AnyUp")
FokusTargetFrame:Hide()

-- Place frame layout in the exact secure DIALOG strata fortress
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

-- Redirect drag script inputs from the active template canvas to track target offsets
FokusTargetFrame:RegisterForDrag("LeftButton")
FokusTargetFrame:SetScript("OnDragStart", function(self)
    if not InCombatLockdown() and not FokusEraNS.FokusEra_IsLocked and IsAltKeyDown() then
        -- Lift the frame element directly to follow cursor paths smoothly
        self:StartMoving()
        
        -- FIX v1.4.0: REAL-TIME OFFSET SYNCHRONIZATION LOOP!
        -- Continuously measures the exact spacing layout gap between the main frame right edge 
        -- and the target frame left edge, preventing recursive anchor crashes instantly!
        self:SetScript("OnUpdate", function()
            if not InCombatLockdown() and FokusFrame and FokusFrame:GetRight() then
                local fRight = FokusFrame:GetRight()
                local fTop = FokusFrame:GetBottom() + (FokusFrame:GetHeight() / 2)
                local tLeft = self:GetLeft()
                local tTop = self:GetBottom() + (self:GetHeight() / 2)
                
                if fRight and fTop and tLeft and tTop then
                    FokusEra_OffsetX = math.floor(tLeft - fRight)
                    FokusEra_OffsetY = math.floor(tTop - fTop)
                end
            end
        end)
    end
end)

FokusTargetFrame:SetScript("OnDragStop", function(self)
    -- Terminate the execution loop to completely save hardware cycles
    self:SetScript("OnUpdate", nil)
    self:StopMovingOrSizing()
    
    -- Recalculate and solidify final placement matrix
    if ReanchorTargetFrame then ReanchorTargetFrame() end
end)

-- Right-anchored mirrored portrait configuration
FokusTargetFrame.staticPortrait = CreateFrame("Frame", nil, FokusTargetFrame)
FokusTargetFrame.portrait = CreateFrame("PlayerModel", nil, FokusTargetFrame)
FokusTargetFrame.portrait:SetSize(40, 38)
FokusTargetFrame.portrait:SetPoint("TOPRIGHT", FokusTargetFrame, "TOPRIGHT", -6, -5)

local targetPortBG = FokusTargetFrame:CreateTexture(nil, "BACKGROUND")
targetPortBG:SetAllPoints(FokusTargetFrame.portrait)
targetPortBG:SetColorTexture(0.05, 0.05, 0.05, 1)

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

-- FIX v1.4.0: RESTORE CLASSIC TEXTURE BLUPRINT!
-- Replaced the flat WHITE8X8 override. Re-engages Blizzard's native 3D statusbar texture 
-- so the target layout meshes flawlessly with the player and NPC design frameworks.
FokusTargetFrame.hpBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
if FokusTargetFrame.hpBar:GetStatusBarTexture() then
    FokusTargetFrame.hpBar:GetStatusBarTexture():SetDrawLayer("BORDER")
end
FokusTargetFrame.hpBar:SetStatusBarColor(0, 0.8, 0) -- Solid Healer Green birth color

-- Target Power Bar / Mana
FokusTargetFrame.manaBar = CreateFrame("StatusBar", nil, FokusTargetFrame)
FokusTargetFrame.manaBar:SetSize(114, 6)
FokusTargetFrame.manaBar:SetPoint("TOPLEFT", FokusTargetFrame, "TOPLEFT", 8, -34)
FokusTargetFrame.manaBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
if FokusTargetFrame.manaBar:GetStatusBarTexture() then
    FokusTargetFrame.manaBar:GetStatusBarTexture():SetDrawLayer("BORDER")
end
FokusTargetFrame.manaBar:SetStatusBarColor(0, 0, 1)

-- INTERACTIVE RESIZE BUTTON
FokusTargetFrame.resizeBtn = CreateFrame("Button", nil, FokusTargetFrame.iconOverlay)
FokusTargetFrame.resizeBtn:SetSize(12, 12)
FokusTargetFrame.resizeBtn:SetPoint("BOTTOMRIGHT", FokusTargetFrame, "BOTTOMRIGHT", -2, 2)
FokusTargetFrame.resizeBtn.tex = FokusTargetFrame.resizeBtn:CreateTexture(nil, "OVERLAY")
FokusTargetFrame.resizeBtn.tex:SetAllPoints()
FokusTargetFrame.resizeBtn.tex:SetTexture("Interface\\ChatFrame\\UI-SizeGrabber")

FokusTargetFrame.resizeBtn:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" and not InCombatLockdown() and not FokusEraNS.FokusEra_IsLocked then
        FokusTargetFrame:SetResizable(true)
        FokusTargetFrame:StartSizing("RIGHT") 
    end
end)

FokusTargetFrame.resizeBtn:SetScript("OnMouseUp", function(self, button)
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
    
    if FokusEraNS.FokusEra_IsLocked then
        FokusTargetFrame.resizeBtn:Hide()
    else
        FokusTargetFrame.resizeBtn:Show()
    end
    
    if not FokusTargetFrame:IsMovable() or FokusEraNS.FokusEra_IsLocked or not IsAltKeyDown() then
        FokusTargetFrame:ClearAllPoints()
        if FokusEra_OffsetX and FokusEra_OffsetY then
            FokusTargetFrame:SetPoint("LEFT", FokusFrame, "RIGHT", FokusEra_OffsetX, FokusEra_OffsetY)
        else
            FokusTargetFrame:SetPoint("LEFT", FokusFrame, "RIGHT", 4, 0)
        end
    end
end

-- INITIALIZATION PROFILE LOADING ON BOOT
local targetLoader = CreateFrame("Frame")
targetLoader:RegisterEvent("PLAYER_LOGIN")
targetLoader:SetScript("OnEvent", function(self)
    FokusTargetFrame.resizeBtn:SetParent(FokusTargetFrame.iconOverlay)
    ReanchorTargetFrame()
    targetLoader:UnregisterEvent("PLAYER_LOGIN")
end)

-- fokustgargetui.lua