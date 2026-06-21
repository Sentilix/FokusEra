-- Catch the shared addon namespace parameter from the WoW engine
local addonName, FokusEraNS = ...

-------------------------------------------------------------------------------
-- AUTOMATED CLASS DISPEL AUDIT ENGINE (Isolated Module)
-------------------------------------------------------------------------------
local _, myClass = UnitClass("player")
local dispelPriority = {}

if myClass == "PRIEST" then
    dispelPriority = { ["Magic"] = 2, ["Disease"] = 1 }
elseif myClass == "PALADIN" then
    dispelPriority = { ["Magic"] = 3, ["Poison"] = 2, ["Disease"] = 1 }
elseif myClass == "DRUID" then
    dispelPriority = { ["Curse"] = 2, ["Poison"] = 1 }
elseif myClass == "SHAMAN" then
    dispelPriority = { ["Poison"] = 2, ["Disease"] = 1 }
elseif myClass == "MAGE" then
    dispelPriority = { ["Curse"] = 1 }
end

local defaultPriority = { ["Magic"] = 4, ["Curse"] = 3, ["Disease"] = 2, ["Poison"] = 1 }

local debuffColors = {
    ["Magic"]   = { r = 0.2, g = 0.6, b = 1.0 }, 
    ["Curse"]   = { r = 0.6, g = 0.0, b = 1.0 }, 
    ["Disease"] = { r = 0.6, g = 0.4, b = 0.0 }, 
    ["Poison"]  = { r = 0.0, g = 0.6, b = 0.0 }, 
}

-- Global function exposed to the core loop to audit debuff weights dynamically
function FokusEra_ScanUnitDebuffsAndGetBorderColor(unitToken)
    if not UnitExists(unitToken) then return 0.4, 0.4, 0.4 end 
    
    local maxPoints = 0
    local leadingDebuffType = nil
    
    for i = 1, 40 do
        local name, _, _, debuffType = UnitDebuff(unitToken, i)
        if not name then break end 
        
        if debuffType then
            local currentPoints = dispelPriority[debuffType] or defaultPriority[debuffType] or 0
            if currentPoints > maxPoints then
                maxPoints = currentPoints
                leadingDebuffType = debuffType
            end
        end
    end
    
    if leadingDebuffType and debuffColors[leadingDebuffType] then
        local color = debuffColors[leadingDebuffType]
        return color.r, color.g, color.b
    else
        return 0.4, 0.4, 0.4 
    end
end
