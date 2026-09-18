@echo off
chcp 65001 >nul
setlocal EnableExtensions

:: ANSI Renk kodlarini kullanabilmek icin ESC karakterini tanimliyoruz
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

set "VERSION=1.0.0"
set "CONSOLE_COLS=86"
set "CONSOLE_LINES=31"
title AMD Shader Cache Temizleyici v%VERSION%
color 0F

:: Sistem cache klasorlerine erisim icin yonetici yetkisi zorunludur
:: Konsol görünümü yetki kontrolünden bağımsızdır.
:: Böylece araç normal veya yönetici olarak açıldığında aynı kalın/kompakt tasarımla başlar.
call :KonsolBaslangic

call :YoneticiKontrol
if errorlevel 1 exit /b

:Menu
call :EkranYenile
call :ArayuzBaslik "AMD SHADER CACHE TEMİZLEYİCİ"

echo %ESC%[1;96m╔═ AÇIKLAMA ═══════════════════════════════════════════════════╗%ESC%[0m
call :KutuSatiri "  AMD, DirectX ve Vulkan shader önbelleklerini temizler."
call :KutuSatiri "  Oyunları ve kişisel dosyaları silmez."
echo %ESC%[1;96m╚══════════════════════════════════════════════════════════════╝%ESC%[0m
echo.

echo %ESC%[1;96m╔═ [1] TÜM CACHE ══════════════════════════════════════════════╗%ESC%[0m
call :KutuSatiri "  Kullanıcı, Packages ve sistem shader cache'ini siler."
echo %ESC%[1;96m╚══════════════════════════════════════════════════════════════╝%ESC%[0m
echo.

echo %ESC%[1;96m╔═ [2] KULLANICI CACHE ════════════════════════════════════════╗%ESC%[0m
call :KutuSatiri "  AppData ve Windows Packages shader cache'ini siler."
echo %ESC%[1;96m╚══════════════════════════════════════════════════════════════╝%ESC%[0m
echo.

echo %ESC%[1;96m╔═ [3] SİSTEM CACHE ═══════════════════════════════════════════╗%ESC%[0m
call :KutuSatiri "  Sistem profillerindeki AMD shader cache'ini siler."
echo %ESC%[1;96m╚══════════════════════════════════════════════════════════════╝%ESC%[0m
echo.

echo %ESC%[1;96m╔═ [0] ÇIKIŞ ══════════════════════════════════════════════════╗%ESC%[0m
call :KutuSatiri "  Aracı işlem yapmadan kapatır."
echo %ESC%[1;96m╚══════════════════════════════════════════════════════════════╝%ESC%[0m
echo.
echo %ESC%[1;90m════════════════════════════════════════════════════════════════%ESC%[0m
echo.

<nul set /p "=%ESC%[1;93mSeçiminiz › %ESC%[0m"
choice /C 1230 /N
set "MENU_SECIM=%ERRORLEVEL%"

if "%MENU_SECIM%"=="4" goto Cikis
if "%MENU_SECIM%"=="3" goto SistemCache
if "%MENU_SECIM%"=="2" goto KullaniciCache
if "%MENU_SECIM%"=="1" goto TumCache
goto Menu

:TumCache
call :EkranYenile
call :IslemBaslik "TÜM CACHE TEMİZLİĞİ"
call :Uyari "Açık oyunları ve GPU kullanan programları kapatın."
echo %ESC%[1;96m╔═ YAPILACAK İŞLEMLER ═════════════════════════════════════════╗%ESC%[0m
call :KutuSatiri "  Kullanıcı AppData klasörlerindeki shader cache silinir."
call :KutuSatiri "  Windows Packages altındaki cache silinir."
call :KutuSatiri "  Sistem klasörlerindeki cache silinir."
echo %ESC%[1;96m╚══════════════════════════════════════════════════════════════╝%ESC%[0m
echo.

<nul set /p "=%ESC%[1;93mDevam etmek istiyor musunuz? [E/H]: %ESC%[0m"
choice /C EH /N
set "ONAY_SECIM=%ERRORLEVEL%"
if "%ONAY_SECIM%"=="2" (
    call :Uyari "Temizlik işlemi iptal edildi."
    call :Bekle
    goto Menu
)

call :EkranYenile
call :IslemBaslik "TÜM CACHE TEMİZLİĞİ BAŞLADI"
echo.
set "TUM_HATA=0"
call :KullaniciCacheIslem
if errorlevel 1 set "TUM_HATA=1"
call :PaketCacheIslem
if errorlevel 1 set "TUM_HATA=1"
call :SistemCacheIslem
if errorlevel 1 set "TUM_HATA=1"

echo.
if "%TUM_HATA%"=="1" (
    call :Hata "Tum cache temizligi kismen tamamlandi. Silinemeyen ogeler yukarida bildirildi."
) else (
    call :Basarili "Tum cache temizligi basariyla tamamlandi."
)
call :Ayirici
call :Bekle
echo.
goto Menu

:KullaniciCache
call :EkranYenile
call :IslemBaslik "KULLANICI CACHE TEMİZLİĞİ"
echo.
set "KULLANICI_TOPLAM_HATA=0"
call :KullaniciCacheIslem
if errorlevel 1 set "KULLANICI_TOPLAM_HATA=1"
call :PaketCacheIslem
if errorlevel 1 set "KULLANICI_TOPLAM_HATA=1"

echo.
if "%KULLANICI_TOPLAM_HATA%"=="1" (
    call :Hata "Kullanici cache temizligi kismen tamamlandi."
) else (
    call :Basarili "Kullanici cache temizligi basariyla tamamlandi."
)
call :Ayirici
call :Bekle
echo.
goto Menu

:SistemCache
call :EkranYenile
call :IslemBaslik "SİSTEM CACHE TEMİZLİĞİ"
echo.
call :SistemCacheIslem
set "SISTEM_TOPLAM_SONUC=%ERRORLEVEL%"

echo.
if "%SISTEM_TOPLAM_SONUC%"=="0" (
    call :Basarili "Sistem cache temizligi basariyla tamamlandi."
) else (
    call :Hata "Sistem cache temizligi kismen tamamlandi."
)
call :Ayirici
call :Bekle
echo.
goto Menu

:: ----------------------------------------------------------
:: ISLEM FONKSIYONLARI
:: ----------------------------------------------------------

:KullaniciCacheIslem
call :Bilgi "Kullanici AppData klasorleri temizleniyor..."

set "HATA_VAR=0"

if exist "%LOCALAPPDATA%\AMD\DxCache" (
    rmdir /s /q "%LOCALAPPDATA%\AMD\DxCache" 2>nul
    if exist "%LOCALAPPDATA%\AMD\DxCache" (set "HATA_VAR=1") else (call :Basarili "DxCache temizlendi.")
) else (
    call :Atlandi "DxCache bulunamadı, geçiliyor."
)

if exist "%LOCALAPPDATA%\AMD\DxcCache" (
    rmdir /s /q "%LOCALAPPDATA%\AMD\DxcCache" 2>nul
    if exist "%LOCALAPPDATA%\AMD\DxcCache" (set "HATA_VAR=1") else (call :Basarili "DxcCache temizlendi.")
) else (
    call :Atlandi "DxcCache bulunamadı, geçiliyor."
)

if exist "%LOCALAPPDATA%\AMD\DX9Cache" (
    rmdir /s /q "%LOCALAPPDATA%\AMD\DX9Cache" 2>nul
    if exist "%LOCALAPPDATA%\AMD\DX9Cache" (set "HATA_VAR=1") else (call :Basarili "DX9Cache temizlendi.")
) else (
    call :Atlandi "DX9Cache bulunamadı, geçiliyor."
)

if exist "%LOCALAPPDATA%\AMD\VkCache" (
    rmdir /s /q "%LOCALAPPDATA%\AMD\VkCache" 2>nul
    if exist "%LOCALAPPDATA%\AMD\VkCache" (set "HATA_VAR=1") else (call :Basarili "VkCache temizlendi.")
) else (
    call :Atlandi "VkCache bulunamadı, geçiliyor."
)

if exist "%LOCALAPPDATA%\AMD\OglCache" (
    rmdir /s /q "%LOCALAPPDATA%\AMD\OglCache" 2>nul
    if exist "%LOCALAPPDATA%\AMD\OglCache" (set "HATA_VAR=1") else (call :Basarili "OglCache temizlendi.")
) else (
    call :Atlandi "OglCache bulunamadı, geçiliyor."
)

if exist "%USERPROFILE%\AppData\LocalLow\AMD\DxCache" (
    rmdir /s /q "%USERPROFILE%\AppData\LocalLow\AMD\DxCache" 2>nul
    if exist "%USERPROFILE%\AppData\LocalLow\AMD\DxCache" (set "HATA_VAR=1") else (call :Basarili "LocalLow DxCache temizlendi.")
) else (
    call :Atlandi "LocalLow DxCache bulunamadı, geçiliyor."
)

if "%HATA_VAR%"=="1" (
    call :Hata "Bazi kullanici cache dosyalari temizlenemedi (kullanimda olabilir)."
) else (
    call :Basarili "Kullanici cache klasorleri kontrol edildi ve temizlendi."
)
echo.
if "%HATA_VAR%"=="1" exit /b 1
exit /b 0

:PaketCacheIslem
call :Bilgi "Windows Uygulamalari (Packages) onbellekleri temizleniyor..."
set "PAKET_BULUNDU=0"
set "PAKET_HATA=0"

if not exist "%LOCALAPPDATA%\Packages" (
    call :Atlandi "Windows Packages klasörü bulunamadı, geçiliyor."
    echo.
    exit /b 0
)

for /d /r "%LOCALAPPDATA%\Packages" %%d in (DxCache) do @if exist "%%d" (
    set "PAKET_BULUNDU=1"
    rmdir /s /q "%%d" 2>nul
    if exist "%%d" set "PAKET_HATA=1"
)

for /d /r "%LOCALAPPDATA%\Packages" %%d in (DxcCache) do @if exist "%%d" (
    set "PAKET_BULUNDU=1"
    rmdir /s /q "%%d" 2>nul
    if exist "%%d" set "PAKET_HATA=1"
)

if "%PAKET_BULUNDU%"=="0" (
    call :Atlandi "Packages altında temizlenecek cache bulunamadı."
) else if "%PAKET_HATA%"=="1" (
    call :Hata "Bazi Packages cache klasorleri temizlenemedi."
) else (
    call :Basarili "Paket cache klasorleri dogrulandi ve temizlendi."
)
echo.
if "%PAKET_HATA%"=="1" exit /b 1
exit /b 0

:SistemCacheIslem
call :Bilgi "Sistem klasorleri temizleniyor..."

set "SIS_HATA=0"

if exist "%SystemRoot%\ServiceProfiles\LocalService\AppData\Local\AMD\DxCache" (
    rmdir /s /q "%SystemRoot%\ServiceProfiles\LocalService\AppData\Local\AMD\DxCache" 2>nul
    if exist "%SystemRoot%\ServiceProfiles\LocalService\AppData\Local\AMD\DxCache" (set "SIS_HATA=1") else (call :Basarili "ServiceProfiles DxCache temizlendi.")
) else (
    call :Atlandi "ServiceProfiles DxCache bulunamadı, geçiliyor."
)

if exist "%SystemRoot%\System32\config\systemprofile\AppData\Local\AMD\DxCache" (
    rmdir /s /q "%SystemRoot%\System32\config\systemprofile\AppData\Local\AMD\DxCache" 2>nul
    if exist "%SystemRoot%\System32\config\systemprofile\AppData\Local\AMD\DxCache" (set "SIS_HATA=1") else (call :Basarili "SystemProfile DxCache temizlendi.")
) else (
    call :Atlandi "SystemProfile DxCache bulunamadı, geçiliyor."
)

if exist "%SystemRoot%\System32\config\systemprofile\AppData\Local\AMD\DxcCache" (
    rmdir /s /q "%SystemRoot%\System32\config\systemprofile\AppData\Local\AMD\DxcCache" 2>nul
    if exist "%SystemRoot%\System32\config\systemprofile\AppData\Local\AMD\DxcCache" (set "SIS_HATA=1") else (call :Basarili "SystemProfile DxcCache temizlendi.")
) else (
    call :Atlandi "SystemProfile DxcCache bulunamadı, geçiliyor."
)

if "%SIS_HATA%"=="1" (
    call :Hata "Bazi sistem cache dosyalari temizlenemedi."
) else (
    call :Basarili "Sistem cache klasorleri kontrol edildi ve temizlendi."
)

call :Uyari "Not: Windows tarafından anlık kullanılan bazı dosyalar atlanmış olabilir; bu normaldir."
echo.
if "%SIS_HATA%"=="1" exit /b 1
exit /b 0

:Cikis
call :EkranYenile
call :Bilgi "AMD Shader Cache Temizleyici v%VERSION% kapatiliyor..."
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
echo.
exit /b

:BaslikSatiri
setlocal EnableExtensions EnableDelayedExpansion
set "SATIR=%~1"
set "BOSLUK=                                                              "
set "SATIR=!SATIR!!BOSLUK!"
set "SATIR=!SATIR:~0,62!"
echo %ESC%[1;97m║!SATIR!║%ESC%[0m
endlocal
exit /b

:KutuSatiri
setlocal EnableExtensions EnableDelayedExpansion
set "SATIR=%~1"
set "BOSLUK=                                                              "
set "SATIR=!SATIR!!BOSLUK!"
set "SATIR=!SATIR:~0,62!"
echo %ESC%[1;96m║%ESC%[1;90m!SATIR!%ESC%[1;96m║%ESC%[0m
endlocal
exit /b

:Ayirici
echo %ESC%[1;90m════════════════════════════════════════════════════════════════%ESC%[0m
exit /b

:Bekle
echo %ESC%[1;90m  Devam etmek için bir tuşa basın...%ESC%[0m
pause >nul
exit /b

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

