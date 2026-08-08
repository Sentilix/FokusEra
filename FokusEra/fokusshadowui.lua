-- Catch the shared addon namespace parameter from the WoW engine
local addonName, FokusEraNS = ...

-- Create the master invisible single source of truth positioning anchor frame
FokusShadowFrame = CreateFrame("Frame", "FokusShadowFrame", UIParent, "BackdropTemplate")
FokusShadowFrame:SetSize(210, 48)
FokusShadowFrame:SetMovable(true)
FokusShadowFrame:EnableMouse(true)
FokusShadowFrame:Show()

-- DESIGN: Semi-transparent dark green backdrop indicator layer exclusively for layout testing
FokusShadowFrame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 8, edgeSize = 12,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
FokusShadowFrame:SetBackdropColor(0.1, 0.4, 0.1, 0.25) -- 75% transparent green (Alpha = 0.25)
FokusShadowFrame:SetBackdropBorderColor(0.2, 0.8, 0.2, 0.4)

-- Move handling: Dragging either active focus frame shifts the shadow root layer instead!
FokusShadowFrame:RegisterForDrag("LeftButton")
FokusShadowFrame:SetScript("OnDragStart", function(self)
    if not InCombatLockdown() and not FokusEraNS.FokusEra_IsLocked and IsAltKeyDown() then
        self:StartMoving()
    end
end)

FokusShadowFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    if not InCombatLockdown() then
        -- Grab the precise absolute coordinates mapping from the screen center topology
        local mainX, mainY = self:GetCenter()
        local parentX, parentY = UIParent:GetCenter()
        if mainX and mainY and parentX and parentY then
            FokusEra_OffsetX = math.floor(mainX - parentX)
            FokusEra_OffsetY = math.floor(mainY - parentY)
        end
    end
    -- Dynamically trigger alignment updates across all active sub-frame modules inline
    if FokusEra_AlignNPCLayouts then FokusEra_AlignNPCLayouts() end
end)

-- INITIALIZATION LIFECYCLE ROUTINE
local shadowLoader = CreateFrame("Frame")
shadowLoader:RegisterEvent("PLAYER_LOGIN")
shadowLoader:SetScript("OnEvent", function(self)
    if FokusEra_OffsetX == nil then FokusEra_OffsetX = -65 end
    if FokusEra_OffsetY == nil then FokusEra_OffsetY = -150 end
    
    -- Snap the shadow anchor to your exact saved configurations immediately on boot
    FokusShadowFrame:ClearAllPoints()
    FokusShadowFrame:SetPoint("CENTER", UIParent, "CENTER", FokusEra_OffsetX, FokusEra_OffsetY)
    
    shadowLoader:UnregisterEvent("PLAYER_LOGIN")
end)

-- end fokusshadowui.lua