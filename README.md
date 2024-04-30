What this does:

1. Downloads and installs required fonts.
2. Downloads Arc.
3. Changes registry to allow Arc to be installed on Windows 10.
4. Installs Arc.
5. Deletes all temp files, restores original registry settings.
6. Log file saved with timestamp of execution.

------------------------------------------------------------------

Download and install the latest Windows App SDK from here: https://learn.microsoft.com/en-us/windows/apps/windows-app-sdk/downloads

Download both arcwin10-1.1.ps1 & arcwin10-1.1.bat to the same directory. Right click and run arcwin10-1.1.bat as Administrator.

Note 1: If you are using a older version (1.0) of this script, you will need to uninstall and delete that version before you can use this.
Note 2: The auto updater in Arc does not work in Windows 10. You will need to run (from a command prompt) "taskkill /f /t /im arc.exe", and re-run arcwin10-1.1.bat as Administrator to update it.
