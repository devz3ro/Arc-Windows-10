This repository is now deprecated and will not be receiving any further updates. The Arc team has released a new version that is fully compatible with Windows 10, eliminating the need for any workarounds.

The files in this repository are retained for historical reference only.

For the latest version, please visit: [https://releases.arc.net/windows/ArcInstaller.exe](https://releases.arc.net/windows/ArcInstaller.exe)

------------------------------------------------------------------

What this does:

1. Downloads and installs required fonts & Arc dependencies.
2. Downloads Arc.
3. Changes registry to allow Arc to be installed on Windows 10.
4. Installs / upgrades Arc.
5. Deletes all temp files, restores original registry settings.
6. Log file saved with timestamp of execution.

   1.2.3 to 1.2.4 changes: Added existing font check.

------------------------------------------------------------------

Installation Instructions:

Download both arcwin10-1.2.4.ps1 & arcwin10-1.2.4.bat to the same directory. Right click and run arcwin10-1.2.4.bat as Administrator.

Note: The auto updater in Arc does not work in Windows 10. You will need to run (from a command prompt) "taskkill /f /t /im arc.exe", and re-run arcwin10-1.2.4.bat as Administrator to update it.

------------------------------------------------------------------

YouTuber Quantum_Cipher was kind enough to make an installation video:

[![How to install Arc Browser on Windows 10](https://img.youtube.com/vi/46B4v7bhkYI/0.jpg)](https://www.youtube.com/watch?v=46B4v7bhkYI "How to install Arc Browser on Windows 10")

------------------------------------------------------------------

Have spare change? If this has helped you in anyway and you are feeling generous, my eth address is below for donations (eth, erc-20 + side chain tokens of any kind is appreciated). Thanks in advance:

0xc8A10b4Bc41815fD29C701fD5252faf94802B994

![image](https://github.com/devz3ro/Arc-Windows-10/assets/6265569/6c8b79e7-bc50-419c-a529-9fdea1b79cec)

