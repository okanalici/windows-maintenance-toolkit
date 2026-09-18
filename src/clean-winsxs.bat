@echo off
chcp 65001 >nul
setlocal EnableExtensions

:: ANSI Renk kodlarini kullanabilmek icin ESC karakterini tanimliyoruz
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

set "VERSION=1.0.0"
set "CONSOLE_COLS=86"
set "CONSOLE_LINES=30"
title Gelismis WinSxS Bakim ve Onarim Araci v%VERSION%
color 0F


:: Konsol görünümü yetki kontrolünden bağımsızdır.
:: Böylece araç normal veya yönetici olarak açıldığında aynı kalın/kompakt tasarımla başlar.
call :KonsolBaslangic

call :YoneticiKontrol
if errorlevel 1 exit /b

:Menu
call :EkranYenile
call :ArayuzBaslik "GELİŞMİŞ WINSXS BAKIM VE ONARIM"
call :BilgiKutusu "  Windows imajını onarır ve WinSxS deposunu temizler."
call :MenuKutusu "1" "ANALİZ" "  DISM ile WinSxS bileşen deposunu analiz eder."
call :MenuKutusu "2" "TAM BAKIM" "  DISM, SFC, bileşen temizliği ve son analiz çalıştırır."
call :MenuKutusu "3" "RESETBASE" "  Eski bileşenleri siler; güncellemeler geri alınamaz."
call :MenuKutusu "0" "ÇIKIŞ" "  Aracı işlem yapmadan kapatır."
call :Ayirici
echo.

call :Secim "1230" "Seçiminiz › "

if "%SECIM_SONUC%"=="4" goto Cikis
if "%SECIM_SONUC%"=="3" goto ResetBase
if "%SECIM_SONUC%"=="2" goto TamBakim
if "%SECIM_SONUC%"=="1" goto Analiz
goto Menu

:Analiz
call :EkranYenile
call :IslemBaslik "WINSXS ANALİZİ"
echo.
call :Bilgi "WinSxS klasoru analiz ediliyor..."
echo.

Dism.exe /Online /Cleanup-Image /AnalyzeComponentStore

if errorlevel 1 (
    echo.
    call :Hata "WinSxS analizi basarisiz oldu."
) else (
    echo.
    call :Basarili "WinSxS analizi tamamlandi."
)

echo.
call :Ayirici
call :Bekle
goto Menu

:TamBakim
call :EkranYenile
call :IslemBaslik "TAM BAKIM İŞLEMİ"
call :Uyari "İşlem 15-45 dakika sürebilir; bilgisayarı kapatmayın."
echo %ESC%[1;96m╔═ YAPILACAK İŞLEMLER ═════════════════════════════════════════╗%ESC%[0m
call :KutuSatiri "  DISM RestoreHealth + SFC + standart WinSxS temizliği"
call :KutuSatiri "  + son analiz. Bu akış ResetBase kullanmaz."
echo %ESC%[1;96m╚══════════════════════════════════════════════════════════════╝%ESC%[0m
echo.

call :Secim "EH" "Devam etmek istiyor musunuz? [E/H]: "
if "%SECIM_SONUC%"=="2" (
    call :Uyari "Tam bakım işlemi iptal edildi."
    call :Bekle
    goto Menu
)

call :EkranYenile
call :IslemBaslik "ADIM 1/4: SİSTEM SAĞLIĞI ONARIMI"
echo.
call :Bilgi "Windows imajindaki bozukluklar taraniyor ve onariliyor..."
call :Bilgi "Bu islem internet baglantisi kullanabilir."
echo.

set "DISM_HATA=0"
Dism.exe /Online /Cleanup-Image /RestoreHealth

if errorlevel 1 (
    set "DISM_HATA=1"
    call :Hata "Sistem imaji onarimi basarisiz oldu."
) else (
    call :Basarili "Sistem imaji onarimi tamamlandi."
)

if "%DISM_HATA%"=="1" (
    echo.
    call :Hata "DISM basarisiz oldu. Sonraki bakim adimlari calistirilmiyor."
    call :Bilgi "Once DISM hatasini cozin; aksi halde sistem bakimi eksik kalabilir."
    call :Bekle
    goto Menu
)

echo.
call :IslemBaslik "ADIM 2/4: SİSTEM DOSYALARINI DOĞRULAMA"
echo.
call :Bilgi "Eksik veya hatali sistem dosyalari denetleniyor..."
echo.

set "SFC_HATA=0"
sfc /scannow

if errorlevel 1 (
    set "SFC_HATA=1"
    call :Hata "SFC taramasi sorunlar tespit etti veya basarisiz oldu."
) else (
    call :Basarili "SFC taramasi tamamlandi."
)

if "%SFC_HATA%"=="1" (
    echo.
    call :Hata "SFC basarisiz oldu. WinSxS temizligi calistirilmiyor."
    call :Bilgi "Once sistem dosyasi sorunlarini giderip bakimi yeniden calistirin."
    call :Bekle
    goto Menu
)

echo.
call :IslemBaslik "ADIM 3/4: STANDART WINSXS TEMİZLİĞİ"
echo.
call :Bilgi "Artik kullanilmayan eski bilesenler guvenli sekilde temizleniyor..."
echo.

set "TEMIZLIK_HATA=0"
Dism.exe /Online /Cleanup-Image /StartComponentCleanup

if errorlevel 1 (
    set "TEMIZLIK_HATA=1"
    call :Hata "Standart WinSxS temizligi basarisiz oldu."
) else (
    call :Basarili "Standart WinSxS temizligi tamamlandi."
)

if "%TEMIZLIK_HATA%"=="1" (
    echo.
    call :Hata "Temizlik basarisiz oldu. Son analiz calistirilmiyor."
    call :Bekle
    goto Menu
)

echo.
call :IslemBaslik "ADIM 4/4: TEMİZLİK SONRASI ANALİZ"
echo.
call :Bilgi "Bilesen deposunun son durumu analiz ediliyor..."
echo.

Dism.exe /Online /Cleanup-Image /AnalyzeComponentStore

if errorlevel 1 (
    call :Hata "Son WinSxS analizi basarisiz oldu."
    call :Bekle
    goto Menu
) else (
    call :Basarili "Son WinSxS analizi tamamlandi."
)

echo.
call :Basarili "Tam bakim islemi tamamlandi."
call :Bilgi "Bilgisayari yeniden baslatmaniz tavsiye edilir."
echo.
call :Ayirici
call :Bekle
goto Menu

:ResetBase
call :EkranYenile
call :IslemBaslik "GELİŞMİŞ RESETBASE TEMİZLİĞİ"
call :Uyari "Eski bileşen sürümleri kalıcı olarak silinecektir."
call :Uyari "Mevcut Windows güncellemeleri artık geri alınamaz."
call :Uyari "Yalnızca sistem kararlıysa ve tam bakım bittiyse kullanın."
echo.

call :Secim "EH" "ResetBase çalıştırılsın mı? [E/H]: "
if "%SECIM_SONUC%"=="2" (
    call :Uyari "ResetBase işlemi iptal edildi."
    call :Bekle
    goto Menu
)

call :EkranYenile
call :IslemBaslik "RESETBASE ÇALIŞIYOR"
echo.
call :Bilgi "Eski bilesen surumleri kalici olarak temizleniyor..."
echo.

Dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase

if errorlevel 1 (
    call :Hata "ResetBase temizligi basarisiz oldu."
) else (
    call :Basarili "ResetBase temizligi tamamlandi."
    call :Bilgi "Mevcut Windows guncellemeleri artik kaldirilamaz."
)

echo.
call :Ayirici
call :Bekle
goto Menu

:Cikis
call :EkranYenile
call :Bilgi "WinSxS Araci v%VERSION% kapatiliyor..."
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

:Uyari
echo %ESC%[1;93m  [!] %~1%ESC%[0m
exit /b

