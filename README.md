What this does:

Downloads and installs required fonts.
Downloads Arc.
Changes registry to allow Arc to be installed on Windows 10.
Installs Arc.
Deletes all temp files, restores original registry settings.

------------------------------------------------------------------

Download and install the latest Windows App SDK from here: https://learn.microsoft.com/en-us/windows/apps/windows-app-sdk/downloads

Download both arcwin10-1.1.ps1 & arcwin10-1.1.bat to the same directory. Right click and run arcwin10-1.1.bat as Administrator.

Note: The auto updater in Arc does not work in Windows 10. You will need to run (from a command prompt) "taskkill /f /t /im arc.exe", and re-run arcwin10-1.1.bat as Administrator to update it.
