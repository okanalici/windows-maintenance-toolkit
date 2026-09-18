@echo off
chcp 65001 >nul
setlocal EnableExtensions

:: ANSI Renk kodlarini kullanabilmek icin ESC karakterini tanimliyoruz
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

set "VERSION=1.0.0"
set "CONSOLE_COLS=86"
set "CONSOLE_LINES=26"
title Windows 11 Sag Tik Menu Ayari v%VERSION%
color 0F

:: Bu araç yalnızca geçerli kullanıcının (HKCU) sağ tık menüsü ayarını değiştirir.
:: Yönetici yetkisi gerekmez; normal kullanıcı olarak çalıştırılması önerilir.
call :KonsolBaslangic

:Menu
call :EkranYenile
call :ArayuzBaslik "WINDOWS 11 SAĞ TIK MENÜ AYARLARI"
call :BilgiKutusu "  Windows 11 sağ tık menüsünün görünümünü değiştirir."
call :MenuKutusu "1" "KLASİK MENÜ" "  Klasik tam sağ tık menüsünü etkinleştirir."
call :MenuKutusu "2" "WINDOWS 11 MENÜSÜ" "  Varsayılan Windows 11 menüsünü geri yükler."
call :MenuKutusu "0" "ÇIKIŞ" "  Aracı işlem yapmadan kapatır."
call :Ayirici
echo.

call :Secim "120" "Seçiminiz › "

if "%SECIM_SONUC%"=="3" goto Cikis
if "%SECIM_SONUC%"=="2" goto YeniMenu
if "%SECIM_SONUC%"=="1" goto KlasikMenu
goto Menu

:KlasikMenu
call :EkranYenile
call :IslemBaslik "KLASİK SAĞ TIK MENÜSÜ"
echo.
call :Bilgi "Klasik sag-tik menusu ayarlaniyor..."

reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve >nul 2>&1

if errorlevel 1 (
    call :Hata "Klasik sag-tik menusu ayarlanamadi."
) else (
    call :ExplorerYenidenBaslat
    call :Basarili "Klasik sag-tik menusu AKTIF edildi."
)

echo.
call :Ayirici
call :Bekle
goto Menu

:YeniMenu
call :EkranYenile
call :IslemBaslik "WINDOWS 11 MENÜSÜ"
echo.
call :Bilgi "Yeni Windows 11 menusu geri yukleniyor..."

reg delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f >nul 2>&1

if errorlevel 1 (
    call :Hata "Yeni menu ayarlanamadi (Zaten aktif olabilir)."
) else (
    call :ExplorerYenidenBaslat
    call :Basarili "Yeni sag-tik menusu (Varsayilan) AKTIF edildi."
)

echo.
call :Ayirici
call :Bekle
goto Menu

:ExplorerYenidenBaslat
call :Bilgi "Explorer yeniden baslatiliyor..."
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 1 >nul
start explorer.exe
call :Basarili "Explorer yeniden baslatildi."
exit /b

:Cikis
call :EkranYenile
call :Bilgi "Sag Tik Menu Araci v%VERSION% kapatiliyor..."
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


:Basarili
echo %ESC%[1;92m  [✓] %~1%ESC%[0m
exit /b

:Hata
echo %ESC%[1;91m  [X] %~1%ESC%[0m
exit /b

:Bilgi
echo %ESC%[1;93m  [●] %~1%ESC%[0m
exit /b

:Uyari
echo %ESC%[1;93m  [!] %~1%ESC%[0m
exit /b

