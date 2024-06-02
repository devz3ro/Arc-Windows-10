@ECHO OFF
NET SESSION >NUL 2>&1
IF %ERRORLEVEL% NEQ 0 (
    ECHO Requesting administrative privileges...
    PowerShell -Command "Start-Process '%~f0' -Verb RunAs"
    EXIT /B
)

PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0arcwin10-1.2.4.1.ps1'"

ECHO Press Enter to exit ...
SET /P =
