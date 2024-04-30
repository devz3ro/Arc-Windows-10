What this does:

1. Downloads and installs required fonts.
2. Downloads Arc.
3. Extracts Arc, deletes files and folders related to Windows 11.
4. Replaces minimum version required.
5. Installs Arc.

------------------------------------------------------------------

Download and install the latest Windows App SDK from here: https://learn.microsoft.com/en-us/windows/apps/windows-app-sdk/downloads

Download both (v1.1) arcwin10.ps1 & arcwin10.bat to the same directory. Right click and run arcwin10.bat as Administrator.

Note: The auto updater in Arc does not work in Windows 10. You will need to "taskkill /f /t /im arc.exe", and re-run arcwin10.bat as Administrator to update it.
