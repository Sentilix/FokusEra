@echo off
set ADDONNAME=FokusEra
set SOURCE=%~dp0
set TARGET=C:\Program Files (x86)\World of Warcraft\_classic_era_\Interface\AddOns\

copy %SOURCE%\%ADDONNAME%\*.toc "%TARGET%\%ADDONNAME%\" /Y
copy %SOURCE%\%ADDONNAME%\*.lua "%TARGET%\%ADDONNAME%\" /Y

echo.
