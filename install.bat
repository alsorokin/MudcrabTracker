@echo off
setlocal

set "sourceDir=%~dp0"
set "targetDir=%USERPROFILE%\Documents\Elder Scrolls Online\live\AddOns\MudcrabTracker"

if not exist "%targetDir%" (
    mkdir "%targetDir%"
)

xcopy "%sourceDir%*.lua" "%targetDir%" /E /H /C /I /Y
xcopy "%sourceDir%*.txt" "%targetDir%" /E /H /C /I /Y
xcopy "%sourceDir%*.xml" "%targetDir%" /E /H /C /I /Y

echo Files copied successfully.
endlocal
pause