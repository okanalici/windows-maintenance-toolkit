@echo off
chcp 65001 >nul
setlocal EnableExtensions

:: ANSI Renk kodlarini kullanabilmek icin ESC karakterini tanimliyoruz
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

set "VERSION=1.0.0"
set "CONSOLE_COLS=86"
set "CONSOLE_LINES=26"
title Ultimate OneDrive Kaldirma Araci v%VERSION%
color 0F

:: OneDrive kaldirma ve HKLM degisiklikleri icin yonetici yetkisi zorunludur
:: Konsol görünümü yetki kontrolünden bağımsızdır.
:: Böylece araç normal veya yönetici olarak açıldığında aynı kalın/kompakt tasarımla başlar.
call :KonsolBaslangic

call :YoneticiKontrol
if errorlevel 1 exit /b

:Menu
call :EkranYenile
call :ArayuzBaslik "ULTIMATE ONEDRIVE KALDIRMA ARACI"
call :BilgiKutusu "  OneDrive uygulamasını ve Explorer kalıntılarını kaldırır."
call :MenuKutusu "1" "DOSYALARI KORU" "  OneDrive'ı kaldırır; kullanıcı dosyalarını korur."
call :MenuKutusu "2" "DOSYALARI DA SİL" "  OneDrive'ı ve yerel kullanıcı klasörünü kalıcı siler."
call :MenuKutusu "0" "ÇIKIŞ" "  Aracı işlem yapmadan kapatır."
call :Ayirici
echo.

call :Secim "120" "Seçiminiz › "

if "%SECIM_SONUC%"=="3" goto Cikis
if "%SECIM_SONUC%"=="2" goto KaldirSil
if "%SECIM_SONUC%"=="1" goto KaldirKoru
goto Menu

:KaldirKoru
set "KORUMA=1"
goto IslemBaslat

:KaldirSil
call :EkranYenile
call :IslemBaslik "KRİTİK UYARI"
call :Uyari "OneDrive klasöründeki TÜM ŞAHSİ DOSYALAR silinecek."
call :Uyari "Fotoğraflar, belgeler ve diğer yerel dosyalar etkilenir."
call :Uyari "Bu işlem geri alınamaz."
echo.

call :Secim "EH" "Devam etmek istiyor musunuz? [E/H]: "
if "%SECIM_SONUC%"=="2" (
    call :Uyari "İşlem iptal edildi."
    call :Bekle
    goto Menu
)
set "KORUMA=0"
goto IslemBaslat

:IslemBaslat
call :EkranYenile
call :IslemBaslik "ONEDRIVE KALDIRMA BAŞLADI"
echo.

set "GENEL_HATA=0"

:: Kullanici OneDrive klasoru kaldirma islemleri registry temizlenmeden ONCE tespit edilir.
set "ONEDRIVE_USER_FOLDER="
for /f "tokens=2,*" %%A in ('reg query "HKCU\Software\Microsoft\OneDrive\Accounts" /s /v UserFolder 2^>nul ^| find /I "UserFolder"') do if not defined ONEDRIVE_USER_FOLDER set "ONEDRIVE_USER_FOLDER=%%B"
:: Ortam degiskenleri kullanilmaz; disaridan degistirilebildikleri icin guvenilir silme hedefi degildir.
:: Kayit bulunamazsa yalnizca Windows OneDrive bilinen klasorunun varsayilan yolu denenir.
if not defined ONEDRIVE_USER_FOLDER set "ONEDRIVE_USER_FOLDER=%UserProfile%\OneDrive"

:: 1. ONEDRIVE VE EXPLORER KAPATILIYOR
call :Bilgi "[1/8] Calisan islemler sonlandiriliyor..."
taskkill /f /im OneDrive.exe >nul 2>&1
if errorlevel 1 (
    call :Atlandi "OneDrive işlemi bulunamadı veya zaten kapalı."
) else (
    call :Basarili "OneDrive islemi sonlandirildi."
)

taskkill /f /im explorer.exe >nul 2>&1
if errorlevel 1 (
    call :Atlandi "Explorer zaten kapali veya sonlandirilamadi; islem devam ediyor."
) else (
    call :Basarili "Explorer islemi gecici olarak sonlandirildi."
)

:: 2. KALDIRMA KOMUTLARI - BASARILI OLAN ILK UYGUN SETUP KULLANILIR
echo.
call :Bilgi "[2/8] OneDrive kaldirma araci calistiriliyor..."
set "SETUP_BULUNDU=0"
set "SETUP_BASARILI=0"

if exist "%SystemRoot%\SysWOW64\OneDriveSetup.exe" (
    set "SETUP_BULUNDU=1"
    "%SystemRoot%\SysWOW64\OneDriveSetup.exe" /uninstall >nul 2>&1
    if errorlevel 1 (
        call :Uyari "SysWOW64 OneDrive kaldirma basarisiz; alternatif yol denenecek."
    ) else (
        set "SETUP_BASARILI=1"
        call :Basarili "SysWOW64 OneDrive kaldirma tamamlandi."
    )
)

if "%SETUP_BASARILI%"=="0" if exist "%SystemRoot%\System32\OneDriveSetup.exe" (
    set "SETUP_BULUNDU=1"
    "%SystemRoot%\System32\OneDriveSetup.exe" /uninstall >nul 2>&1
    if errorlevel 1 (
        call :Uyari "System32 OneDrive kaldirma basarisiz; alternatif yol denenecek."
    ) else (
        set "SETUP_BASARILI=1"
        call :Basarili "System32 OneDrive kaldirma tamamlandi."
    )
)

if "%SETUP_BASARILI%"=="0" if exist "%LOCALAPPDATA%\Microsoft\OneDrive\Update\OneDriveSetup.exe" (
    set "SETUP_BULUNDU=1"
    "%LOCALAPPDATA%\Microsoft\OneDrive\Update\OneDriveSetup.exe" /uninstall >nul 2>&1
    if errorlevel 1 (
        call :Uyari "AppData OneDrive kaldirma basarisiz."
    ) else (
        set "SETUP_BASARILI=1"
        call :Basarili "AppData OneDrive kaldirma tamamlandi."
    )
)

if "%SETUP_BULUNDU%"=="0" call :Atlandi "Klasik OneDrive kaldirma araci bulunamadi."
if "%SETUP_BULUNDU%"=="1" if "%SETUP_BASARILI%"=="0" (
    set "GENEL_HATA=1"
    call :Hata "Bulunan OneDrive kaldirma araclari basarisiz oldu."
)

:: 3. WINDOWS STORE SURUMUNU SILME (TUM KULLANICILAR)
echo.
call :Bilgi "[3/8] Windows Store versiyonu tum kullanicilar icin taranip siliniyor..."
PowerShell.exe -NoProfile -NonInteractive -Command "try { $p=@(Get-AppxPackage -AllUsers -Name '*OneDrive*' -ErrorAction Stop | Sort-Object -Property PackageFullName -Unique); if($p.Count -eq 0){exit 2}; $p | Remove-AppxPackage -AllUsers -ErrorAction Stop; exit 0 } catch { exit 1 }" >nul 2>&1
set "APPX_SONUC=%ERRORLEVEL%"
if "%APPX_SONUC%"=="2" (
    call :Atlandi "Store surumu bulunamadi veya zaten kaldirilmis."
) else if "%APPX_SONUC%"=="1" (
    set "GENEL_HATA=1"
    call :Hata "Store surumu tum kullanicilardan kaldirilamadi."
) else (
    call :Basarili "Store versiyonu tum kullanicilardan kaldirildi."
)

:: 4. ARTIK DOSYALARIN TEMIZLENMESI
echo.
call :Bilgi "[4/8] Sistemdeki artik dosyalar temizleniyor..."
set "ARTIK_HATA=0"
:: OneDriveTemp ortam degiskeni disaridan degistirilebildigi icin recursive silmede kullanilmaz.
call :KlasorSilIfExists "%LocalAppData%\Microsoft\OneDrive"
if errorlevel 1 set "ARTIK_HATA=1"
call :KlasorSilIfExists "%ProgramData%\Microsoft OneDrive"
if errorlevel 1 set "ARTIK_HATA=1"
call :KlasorSilIfExists "%SystemDrive%\OneDriveTemp"
if errorlevel 1 set "ARTIK_HATA=1"
if "%ARTIK_HATA%"=="1" (
    set "GENEL_HATA=1"
    call :Hata "Bazi OneDrive artik klasorleri tamamen temizlenemedi."
) else (
    call :Basarili "OneDrive artik klasorleri kontrol edildi ve temizlendi."
)

:: Kullanici Dosyasi Karari
if "%KORUMA%"=="0" (
    call :Bilgi "Kayitli kullanici OneDrive klasoru siliniyor: %ONEDRIVE_USER_FOLDER%"
    call :KullaniciOneDriveKlasoruSil "%ONEDRIVE_USER_FOLDER%"
    if errorlevel 3 (
        set "GENEL_HATA=1"
        call :Hata "Guvenlik kontrolu nedeniyle riskli OneDrive yolu silinmedi."
    ) else if errorlevel 2 (
        call :Atlandi "Tespit edilen OneDrive kullanici klasoru bulunamadi; silinecek yerel klasor yok."
    ) else if errorlevel 1 (
        set "GENEL_HATA=1"
        call :Hata "Kullanici OneDrive klasoru tamamen silinemedi."
    ) else (
        call :Basarili "Tespit edilen kullanici OneDrive klasoru silindi."
    )
) else (
    call :Basarili "Sahsi dosyalariniz KORUNDU."
)

:: 5. KISAYOL TEMIZLIGI
echo.
call :Bilgi "[5/8] Baslat menusu ve kisayollar temizleniyor..."
set "KISAYOL_HATA=0"
call :DosyaSilIfExists "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Microsoft OneDrive.lnk"
if errorlevel 1 set "KISAYOL_HATA=1"
call :DosyaSilIfExists "%USERPROFILE%\Links\OneDrive.lnk"
if errorlevel 1 set "KISAYOL_HATA=1"
if "%KISAYOL_HATA%"=="1" (
    set "GENEL_HATA=1"
    call :Hata "Bazi OneDrive kisayollari silinemedi."
) else (
    call :Basarili "Kisayollar kontrol edildi ve temizlendi."
)

:: 6. REGISTRY (KAYIT DEFTERI) TEMIZLIGI
echo.
call :Bilgi "[6/8] Kayit defteri ve Explorer menusu temizleniyor..."
set "REG_HATA=0"
call :RegAnahtarSilIfExists "HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
if errorlevel 1 set "REG_HATA=1"
call :RegAnahtarSilIfExists "HKCR\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
if errorlevel 1 set "REG_HATA=1"
call :RegDegerSilIfExists "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "OneDriveSetup"
if errorlevel 1 set "REG_HATA=1"
call :RegDegerSilIfExists "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "OneDrive"
if errorlevel 1 set "REG_HATA=1"
call :RegDegerSilIfExists "HKCU\Environment" "OneDrive"
if errorlevel 1 set "REG_HATA=1"
call :RegDegerSilIfExists "HKCU\Environment" "OneDriveConsumer"
if errorlevel 1 set "REG_HATA=1"
if "%REG_HATA%"=="1" (
    set "GENEL_HATA=1"
    call :Hata "Kayit defteri temizliginin bazi adimlari basarisiz oldu."
) else (
    call :Basarili "Kayit defteri kontrol edildi ve temizlendi."
)

:: 7. GRUP ILKELERI ILE ENGELLEME
echo.
call :Bilgi "[7/8] Gelecekte calismamasi icin engelleniyor..."
set "POLICY_HATA=0"
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /t REG_DWORD /v "DisableFileSyncNGSC" /d 1 /f >nul 2>&1
if errorlevel 1 set "POLICY_HATA=1"
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /t REG_DWORD /v "DisableFileSync" /d 1 /f >nul 2>&1
if errorlevel 1 set "POLICY_HATA=1"
if "%POLICY_HATA%"=="1" (
    set "GENEL_HATA=1"
    call :Hata "Engelleme ayarlarinin bazi bolumleri uygulanamadi."
) else (
    call :Basarili "Engelleme ayarlari uygulandi."
)

:: 8. ZAMANLANMIS GOREVLER - WILDCARD SCHTASKS KULLANILMAZ
echo.
call :Bilgi "[8/8] OneDrive zamanlanmis gorevleri taranip siliniyor..."
PowerShell.exe -NoProfile -NonInteractive -Command "try { $t=@(Get-ScheduledTask -ErrorAction Stop | Where-Object { $_.TaskName -like 'OneDrive*' }); if($t.Count -eq 0){exit 2}; $h=$false; foreach($x in $t){try{Unregister-ScheduledTask -TaskName $x.TaskName -TaskPath $x.TaskPath -Confirm:$false -ErrorAction Stop}catch{$h=$true}}; if($h){exit 1}else{exit 0} } catch { exit 1 }" >nul 2>&1
set "GOREV_SONUC=%ERRORLEVEL%"
if "%GOREV_SONUC%"=="2" (
    call :Atlandi "OneDrive zamanlanmis gorevi bulunamadi."
) else if "%GOREV_SONUC%"=="1" (
    set "GENEL_HATA=1"
    call :Hata "Bazi OneDrive zamanlanmis gorevleri silinemedi."
) else (
    call :Basarili "OneDrive zamanlanmis gorevleri temizlendi."
)

:: BITIS VE YENIDEN BASLATMA
echo.
call :Bilgi "Windows Gezgini (Explorer) yeniden baslatiliyor..."
start "" explorer.exe >nul 2>&1
timeout /t 2 >nul
tasklist /FI "IMAGENAME eq explorer.exe" /NH 2>nul | find /I "explorer.exe" >nul
if errorlevel 1 (
    set "GENEL_HATA=1"
    call :Hata "Explorer otomatik olarak yeniden baslatilamadi."
) else (
    call :Basarili "Explorer yeniden baslatildi."
)

echo.
if "%GENEL_HATA%"=="1" (
    call :Hata "ISLEM KISMEN TAMAMLANDI - BAZI ADIMLAR BASARISIZ OLDU."
    call :Bilgi "Yukaridaki kirmizi hata satirlarini kontrol edin."
) else (
    call :Basarili "ISLEM BASARIYLA TAMAMLANDI."
)
call :Uyari "Explorer simgesinin tamamen yenilenmesi için yeniden başlatma gerekebilir."
call :Ayirici
echo.
call :Bekle
goto Menu

:Cikis
call :EkranYenile
call :Bilgi "Ultimate OneDrive Kaldirma Araci v%VERSION% kapatiliyor..."
timeout /t 1 >nul
exit /b

:: ============================================================
:: YARDIMCI FONKSIYONLAR
:: ============================================================

:KonsolBaslangic
:: Konsol stili yalnızca bir kez hazırlanır ve yönetici yetkisi gerektirmez.
:: Önce font kalınlaştırılır, ardından bu araca özel sabit pencere boyutu tek seferde uygulanır.
:: Boyut ana menünün tamamı görünür kalacak şekilde dosya bazında tanımlanmıştır.
if defined KONSOL_BASLANGIC_HAZIR exit /b
set "KONSOL_BASLANGIC_HAZIR=1"
PowerShell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "$src='using System; using System.Runtime.InteropServices; public static class NativeConsoleFont { [StructLayout(LayoutKind.Sequential)] public struct COORD { public short X; public short Y; } [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)] public struct CONSOLE_FONT_INFOEX { public uint cbSize; public uint nFont; public COORD dwFontSize; public int FontFamily; public int FontWeight; [MarshalAs(UnmanagedType.ByValTStr, SizeConst=32)] public string FaceName; } [DllImport(\"kernel32.dll\", SetLastError=true)] public static extern IntPtr GetStdHandle(int nStdHandle); [DllImport(\"kernel32.dll\", SetLastError=true, CharSet=CharSet.Unicode)] public static extern bool GetCurrentConsoleFontEx(IntPtr hConsoleOutput, bool bMaximumWindow, ref CONSOLE_FONT_INFOEX lpConsoleCurrentFontEx); [DllImport(\"kernel32.dll\", SetLastError=true, CharSet=CharSet.Unicode)] public static extern bool SetCurrentConsoleFontEx(IntPtr hConsoleOutput, bool bMaximumWindow, ref CONSOLE_FONT_INFOEX lpConsoleCurrentFontEx); }'; try { Add-Type -TypeDefinition $src -ErrorAction Stop; $h=[NativeConsoleFont]::GetStdHandle(-11); $f=New-Object NativeConsoleFont+CONSOLE_FONT_INFOEX; $f.cbSize=[Runtime.InteropServices.Marshal]::SizeOf($f); if([NativeConsoleFont]::GetCurrentConsoleFontEx($h,$false,[ref]$f) -and $f.FontWeight -ne 700){ $f.FontWeight=700; [void][NativeConsoleFont]::SetCurrentConsoleFontEx($h,$false,[ref]$f) } } catch {}" >nul 2>&1
mode con: cols=%CONSOLE_COLS% lines=%CONSOLE_LINES% >nul 2>&1
<nul set /p "=%ESC%[0m%ESC%[1m"
exit /b

:EkranYenile
:: Ekran geçişlerinde yalnızca ANSI durumunu yeniler.
:: Pencere/font tekrar ayarlanmaz; böylece geçişlerde resize/flicker oluşmaz.
<nul set /p "=%ESC%[0m%ESC%[1m"
cls
echo.
exit /b

:ArayuzBaslik
echo %ESC%[1;96m╔══════════════════════════════════════════════════════════════╗%ESC%[0m
setlocal EnableDelayedExpansion
set "SATIR=  %~1                                                      "
set "SATIR=!SATIR:~0,54!v%VERSION%  "
echo %ESC%[1;97m║!SATIR!║%ESC%[0m
endlocal
echo %ESC%[1;90m║  okanalici                                                   ║%ESC%[0m
echo %ESC%[1;96m╚══════════════════════════════════════════════════════════════╝%ESC%[0m
echo.
exit /b

:IslemBaslik
echo %ESC%[1;96m╔══════════════════════════════════════════════════════════════╗%ESC%[0m
call :BaslikSatiri "  %~1"
echo %ESC%[1;96m╚══════════════════════════════════════════════════════════════╝%ESC%[0m
exit /b

:BaslikSatiri
setlocal EnableDelayedExpansion
set "SATIR=%~1                                                              "
set "SATIR=!SATIR:~0,62!"
echo %ESC%[1;97m║!SATIR!║%ESC%[0m
endlocal
exit /b

:KutuSatiri
setlocal EnableDelayedExpansion
set "SATIR=%~1                                                              "
set "SATIR=!SATIR:~0,62!"
echo %ESC%[1;96m║%ESC%[1;90m!SATIR!%ESC%[1;96m║%ESC%[0m
endlocal
exit /b

:BilgiKutusu
setlocal EnableDelayedExpansion
set "SATIR=╔═ AÇIKLAMA ═════════════════════════════════════════════════════════"
set "SATIR=!SATIR:~0,63!"
echo %ESC%[1;96m!SATIR!╗%ESC%[0m
endlocal
call :KutuSatiri "%~1"
echo %ESC%[1;96m╚══════════════════════════════════════════════════════════════╝%ESC%[0m
echo.
exit /b

:MenuKutusu
setlocal EnableDelayedExpansion
set "SATIR=╔═ [%~1] %~2 ════════════════════════════════════════════════════════"
set "SATIR=!SATIR:~0,63!"
echo %ESC%[1;96m!SATIR!╗%ESC%[0m
endlocal
call :KutuSatiri "%~3"
echo %ESC%[1;96m╚══════════════════════════════════════════════════════════════╝%ESC%[0m
echo.
exit /b

:Ayirici
echo %ESC%[1;90m════════════════════════════════════════════════════════════════%ESC%[0m
exit /b

:Bekle
echo %ESC%[1;90m  Devam etmek için bir tuşa basın...%ESC%[0m
pause >nul
exit /b

:Secim
<nul set /p "=%ESC%[1;93m%~2%ESC%[0m"
choice /C %~1 /N
set "SECIM_SONUC=%ERRORLEVEL%"
exit /b

:KlasorSilIfExists
if "%~1"=="" exit /b 0
setlocal EnableExtensions
set "SIL_HEDEF=%~1"
if not "%SIL_HEDEF:~1,2%"==":\" (endlocal & exit /b 3)
if "%SIL_HEDEF:~0,2%"=="\\" (endlocal & exit /b 3)
for %%I in ("%SIL_HEDEF%") do set "SIL_HEDEF=%%~fI"
if not exist "%SIL_HEDEF%" (endlocal & exit /b 0)
if /i "%SIL_HEDEF%"=="%SystemDrive%\" (endlocal & exit /b 3)
if /i "%SIL_HEDEF%"=="%SystemRoot%" (endlocal & exit /b 3)
if /i "%SIL_HEDEF%"=="%USERPROFILE%" (endlocal & exit /b 3)
if /i "%SIL_HEDEF%"=="%LOCALAPPDATA%" (endlocal & exit /b 3)
if /i "%SIL_HEDEF%"=="%PROGRAMDATA%" (endlocal & exit /b 3)
PowerShell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "$p=$env:SIL_HEDEF; try { $item=Get-Item -LiteralPath $p -Force -ErrorAction Stop; if(-not $item.PSIsContainer){exit 3}; if(($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0){exit 3}; exit 0 } catch { exit 3 }" >nul 2>&1
if errorlevel 1 (endlocal & exit /b 3)
rd /s /q "%SIL_HEDEF%" >nul 2>&1
if exist "%SIL_HEDEF%" (endlocal & exit /b 1)
endlocal
exit /b 0

:DosyaSilIfExists
if "%~1"=="" exit /b 0
if not exist "%~1" exit /b 0
del /f /q "%~1" >nul 2>&1
if exist "%~1" exit /b 1
exit /b 0

:RegAnahtarSilIfExists
reg query "%~1" >nul 2>&1
if errorlevel 1 exit /b 0
reg delete "%~1" /f >nul 2>&1
if errorlevel 1 exit /b 1
exit /b 0

:RegDegerSilIfExists
reg query "%~1" /v "%~2" >nul 2>&1
if errorlevel 1 exit /b 0
reg delete "%~1" /v "%~2" /f >nul 2>&1
if errorlevel 1 exit /b 1
exit /b 0

:KullaniciOneDriveKlasoruSil
if "%~1"=="" exit /b 2
:: OneDrive UserFolder mutlak yerel bir klasor olmali ve guvenli silme yordamindan gecmelidir.
setlocal EnableExtensions
set "SIL_HEDEF=%~1"
if not "%SIL_HEDEF:~1,2%"==":\" (endlocal & exit /b 3)
if "%SIL_HEDEF:~0,2%"=="\\" (endlocal & exit /b 3)
for %%I in ("%SIL_HEDEF%") do set "SIL_HEDEF=%%~fI"
if not exist "%SIL_HEDEF%" (endlocal & exit /b 2)
if /i "%SIL_HEDEF%"=="%SystemDrive%\" (endlocal & exit /b 3)
if /i "%SIL_HEDEF%"=="%SystemRoot%" (endlocal & exit /b 3)
if /i "%SIL_HEDEF%"=="%USERPROFILE%" (endlocal & exit /b 3)
if /i "%SIL_HEDEF%"=="%LOCALAPPDATA%" (endlocal & exit /b 3)
if /i "%SIL_HEDEF%"=="%PROGRAMDATA%" (endlocal & exit /b 3)
PowerShell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "$p=$env:SIL_HEDEF; try { if($p -match '^[A-Za-z]:\\'){ $item=Get-Item -LiteralPath $p -Force -ErrorAction Stop; if($item.PSIsContainer -and (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -eq 0)){exit 0} }; exit 3 } catch { exit 3 }" >nul 2>&1
if errorlevel 1 (endlocal & exit /b 3)
rd /s /q "%SIL_HEDEF%" >nul 2>&1
if exist "%SIL_HEDEF%" (endlocal & exit /b 1)
endlocal
exit /b 0

:YoneticiKontrol
fltmc >nul 2>&1

if errorlevel 1 (
    echo.
    call :Hata "Bu arac yonetici yetkisi olmadan calistirilamaz."
    call :Uyari "Dosyaya sağ tıklayıp 'Yönetici olarak çalıştır' seçeneğini kullanın."
    echo.
    call :Bekle
    exit /b 1
)

exit /b 0

:Basarili
echo %ESC%[1;92m  [✓] %~1%ESC%[0m
exit /b

:Hata
echo %ESC%[1;91m  [X] %~1%ESC%[0m
exit /b

:Bilgi
echo %ESC%[1;93m  [●] %~1%ESC%[0m
exit /b

:Atlandi
echo %ESC%[1;90m  [–] %~1%ESC%[0m
exit /b

:Uyari
echo %ESC%[1;93m  [!] %~1%ESC%[0m
exit /b

