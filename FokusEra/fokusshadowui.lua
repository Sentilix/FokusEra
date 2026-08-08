-- Catch the shared addon namespace parameter from the WoW engine
local addonName, FokusEraNS = ...

-- Create the master invisible single source of truth positioning anchor frame
FokusShadowFrame = CreateFrame("Frame", "FokusShadowFrame", UIParent, "BackdropTemplate")
FokusShadowFrame:SetSize(210, 48)
FokusShadowFrame:SetMovable(true)
FokusShadowFrame:EnableMouse(true)
FokusShadowFrame:Show()

-- FIX v1.4.0: 100% TRANSPARENT BALANCING!
-- Removed the green test background and border entirely. The shadow frame is now completely invisible!
FokusShadowFrame:SetBackdrop({
    bgFile = nil,
    edgeFile = nil,
    tile = false, tileSize = 0, edgeSize = 0,
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
        -- Save pure, absolute raw screen pixels from BOTTOMLEFT to eliminate center math drift forever!
        FokusEra_ShadowX = math.floor(self:GetLeft())
        FokusEra_ShadowY = math.floor(self:GetBottom())
    end
    -- Trigger chained domino update across layout alignment engines
    if FokusEra_AlignNPCLayouts then FokusEra_AlignNPCLayouts() end
    if ReanchorTargetFrame then ReanchorTargetFrame() end
end)

-- MASTER LIFECYCLE GATE PIPELINE (PLAYER_ENTERING_WORLD)
local shadowLoader = CreateFrame("Frame")
shadowLoader:RegisterEvent("PLAYER_ENTERING_WORLD")
shadowLoader:SetScript("OnEvent", function(self, event)
    -- Fallback positions matching original UI placement catalog geometry if no saved vars exist
    if FokusEra_ShadowX == nil then FokusEra_ShadowX = math.floor((GetScreenHeight() / 2) - 105) end
    if FokusEra_ShadowY == nil then FokusEra_ShadowY = math.floor((GetScreenHeight() / 3) - 24) end
    
    -- Absolute urokkelig bund-forankring, der er immun over for Blizzards midlertidige center-hukommelsestab!
    FokusShadowFrame:ClearAllPoints()
    FokusShadowFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", FokusEra_ShadowX, FokusEra_ShadowY)
    
    -- Fire up layout domino chains explicitly to lock structures oven på skyggerammen
    if FokusFrame and FokusFrame:GetWidth() then
        FokusFrame:ClearAllPoints()
        FokusFrame:SetPoint("CENTER", FokusShadowFrame, "CENTER", 0, 0)
    end
    
    if FokusEra_AlignNPCLayouts then FokusEra_AlignNPCLayouts() end
    if ReanchorTargetFrame then ReanchorTargetFrame() end
    
    shadowLoader:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)

-- end fokusshadowui.lua