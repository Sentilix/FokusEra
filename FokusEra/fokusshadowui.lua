-- Catch the shared addon namespace parameter from the WoW engine
local addonName, FokusEraNS = ...

-- Create the master invisible single source of truth positioning anchor frame
FokusShadowFrame = CreateFrame("Frame", "FokusShadowFrame", UIParent, "BackdropTemplate")
FokusShadowFrame:SetSize(210, 48)
FokusShadowFrame:SetMovable(true)
FokusShadowFrame:EnableMouse(true)
FokusShadowFrame:Show()

-- MASTER TRANSPARENT VIEWPORT BALANCING
FokusShadowFrame:SetBackdrop({
    bgFile = nil, edgeFile = nil, tile = false, tileSize = 0, edgeSize = 0,
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
})

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
        FokusEra_ShadowX = math.floor(self:GetLeft())
        FokusEra_ShadowY = math.floor(self:GetBottom())
    end
    if FokusEra_AlignNPCLayouts then FokusEra_AlignNPCLayouts() end
    if ReanchorTargetFrame then ReanchorTargetFrame() end
end)

-- MASTER LIFECYCLE GATE PIPELINE (PLAYER_ENTERING_WORLD)
local shadowLoader = CreateFrame("Frame")
shadowLoader:RegisterEvent("PLAYER_ENTERING_WORLD")
shadowLoader:SetScript("OnEvent", function(self, event)
    if FokusEra_ShadowX == nil then FokusEra_ShadowX = math.floor((GetScreenHeight() / 2) - 105) end
    if FokusEra_ShadowY == nil then FokusEra_ShadowY = math.floor((GetScreenHeight() / 3) - 24) end
    
    -- Absolute urokkelig bund-forankring for skyggen per karakter
    FokusShadowFrame:ClearAllPoints()
    FokusShadowFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", FokusEra_ShadowX, FokusEra_ShadowY)
    
    -- FIX v1.4.0: Vi rører OVERHOVEDET ikke ved FokusFrame under opstarten! 
    -- Dens klik-areal forbliver snorlige og urokkeligt, nøjagtig som i Version 1.3.0!
    
    if FokusEra_AlignNPCLayouts then FokusEra_AlignNPCLayouts() end
    if ReanchorTargetFrame then ReanchorTargetFrame() end
    
    shadowLoader:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)

-- end fokusshadowui.lua