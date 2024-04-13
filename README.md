What this (arcwin10.ps1) does:

1. Downloads and installs required fonts.
2. Downloads Arc.
3. Extracts Arc, deletes files and folders related to Windows 11.
4. Replaces minimum version required.
5. Installs Arc.

------------------------------------------------------------------

Download and install the latest Windows App SDK from here: https://learn.microsoft.com/en-us/windows/apps/windows-app-sdk/downloads

Enable Developer Mode (temporarily, once the app is installed you can turn it off).
1. Open Settings: Press Win + I to open the Settings app.
2. Update & Security: Navigate to Update & Security > For developers.
3. Developer Mode: Select the "Developer Mode" radio button to enable Developer Mode. You might need to confirm and possibly wait for additional components to install.

Download both arcwin10.ps1 & arcwin10.bat to the same directory. Right click and run arcwin10.bat as Administrator.

It will create a directory named "working" which can be safely deleted after the installation has been verified. You may proceed to disable Developer Mode.

Note: The auto updater in Arc does not work in Windows 10. You will need to re-enable Developer Mode, delete the "working" directory (if you haven't already), and re-run arcwin10.bat as Administrator to update it.
