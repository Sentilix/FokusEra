-- Catch the shared addon namespace parameter from the WoW engine
local addonName, FokusEraNS = ...

-------------------------------------------------------------------------------
-- DYNAMIC RAID TARGET ICON SCANNING ENGINE (Isolated Module)
-------------------------------------------------------------------------------
-- Coordinates texture regions across a 4x2 texture map grid dynamically
function FokusEra_UpdateRaidTargetIcon(unitToken, iconTextureFrame)
    if not UnitExists(unitToken) or not iconTextureFrame then 
        if iconTextureFrame then iconTextureFrame:Hide() end
        return 
    end

    local raidIndex = GetRaidTargetIndex(unitToken)
    if raidIndex and raidIndex >= 1 and raidIndex <= 8 then
        local left = mod(raidIndex - 1, 4) * 0.25
        local right = left + 0.25
        local top = floor((raidIndex - 1) / 4) * 0.25
        local bottom = top + 0.25
        
        iconTextureFrame:SetTexCoord(left, right, top, bottom)
        iconTextureFrame:Show()
    else
        iconTextureFrame:Hide()
    end
end
