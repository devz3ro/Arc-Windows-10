What this does:

1. Downloads and installs required fonts & Arc dependencies.
2. Downloads Arc.
3. Changes registry to allow Arc to be installed on Windows 10.
4. Installs Arc.
5. Deletes all temp files, restores original registry settings.
6. Log file saved with timestamp of execution.

   1.1 to 1.2 changes: Added checks for what's installed on the system already to speed up execution by skipping redundant downloading. Added Arc dependency installation.

------------------------------------------------------------------

Installation Instructions:

Download and install the latest Windows App SDK from here: https://learn.microsoft.com/en-us/windows/apps/windows-app-sdk/downloads

Download both arcwin10-1.2.ps1 & arcwin10-1.2.bat to the same directory. Right click and run arcwin10-1.2.bat as Administrator.

1. Note 1: If you are using v1.0 of this script, you will need to uninstall and delete that version before you can use v1.2. If you have used v1.1 you can use v1.2 without any changes.
2. Note 2: The auto updater in Arc does not work in Windows 10. You will need to run (from a command prompt) "taskkill /f /t /im arc.exe", and re-run arcwin10-1.2.bat as Administrator to update it.

------------------------------------------------------------------

Have spare change? If this has helped you in anyway and you are feeling generous, my eth address is below for donations (eth, erc-20 + side chain tokens of any kind is appreciated). Thanks in advance:

0xc8A10b4Bc41815fD29C701fD5252faf94802B994

![image](https://github.com/devz3ro/Arc-Windows-10/assets/6265569/6c8b79e7-bc50-419c-a529-9fdea1b79cec)

