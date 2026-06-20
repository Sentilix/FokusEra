-- Catch the shared addon namespace parameter from the WoW engine
local addonName, FokusEraNS = ...

-- Safely initialize empty slots for functions so chat never hits a nil field crash
FokusEraNS.FokusEra_SetGroupFocus = FokusEraNS.FokusEra_SetGroupFocus or function() end
FokusEraNS.FokusEra_ClearGroupFocusLogic = FokusEraNS.FokusEra_ClearGroupFocusLogic or function() end

-- Store tracked focus data in the shared namespace safely without wiping existing functions
if FokusEraNS.FokusEra_IsLocked == nil then FokusEraNS.FokusEra_IsLocked = false end

-- Addon configuration references
local addonFolderName = "fokusera"
local addonVersion = C_AddOns.GetAddOnMetadata(addonFolderName, "Version") or "1.0.0"

-- Dynamically compiled Title string
FokusEra_Version = "FokusEra " .. addonVersion
local ADDON_PREFIX = "FokusEra" 

-- Print initialization confirmation string
local interfaceVersion = select(4, GetBuildInfo())
print("|cff00ff00[" .. FokusEra_Version .. "]|r Addon loaded successfully on client version: " .. interfaceVersion)

-- Register the secure addon communication prefix with the game engine
if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
    C_ChatInfo.RegisterAddonMessagePrefix(ADDON_PREFIX)
end