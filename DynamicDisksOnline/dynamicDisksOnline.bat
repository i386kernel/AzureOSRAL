@echo off

rem powershell.exe -NonInteractive -NoProfile -NoLogo -Command "%~dpn0.ps1 '%1;%2'"
powershell.exe -NonInteractive -NoProfile -NoLogo -Command "& {&'%~dpn0.ps1' '%1;%2'}"