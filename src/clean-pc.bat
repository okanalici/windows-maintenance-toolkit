@echo off
chcp 65001 >nul
setlocal EnableExtensions

:: ANSI Renk kodlarini kullanabilmek icin ESC karakterini tanimliyoruz
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

set "VERSION=1.0.0"
set "CONSOLE_COLS=86"
set "CONSOLE_LINES=30"
title Gelismis Sistem Bakim ve Temizlik Araci v%VERSION%
color 0F

:: Sistem klasorleri, servisler ve Geri Donusum Kutusu icin yonetici yetkisi zorunludur
:: Konsol görünümü yetki kontrolünden bağımsızdır.
:: Böylece araç normal veya yönetici olarak açıldığında aynı kalın/kompakt tasarımla başlar.
call :KonsolBaslangic

call :YoneticiKontrol
if errorlevel 1 exit /b

:Menu
call :EkranYenile
call :ArayuzBaslik "GELİŞMİŞ SİSTEM BAKIM VE TEMİZLİK"
call :BilgiKutusu "  Windows geçici dosyalarını ve bakım kalıntılarını temizler."
call :MenuKutusu "1" "OTOMATİK SİLME" "  On temizlik adımını onay sormadan çalıştırır."
call :MenuKutusu "2" "MANUEL SİLME" "  Her temizlik adımından önce onay ister."
call :MenuKutusu "3" "ÖNİZLEME" "  Silinebilir alanları değişiklik yapmadan tarar."
call :MenuKutusu "0" "ÇIKIŞ" "  Aracı işlem yapmadan kapatır."
call :Ayirici
echo.

call :Secim "1230" "Seçiminiz › "

if "%SECIM_SONUC%"=="4" goto Cikis
if "%SECIM_SONUC%"=="3" goto OnizlemeMod
if "%SECIM_SONUC%"=="2" goto ManuelMod
if "%SECIM_SONUC%"=="1" goto OtoMod
goto Menu

:OtoMod
call :EkranYenile
call :IslemBaslik "OTOMATİK SİLME MODU"
call :Uyari "On temizlik adımı sırayla ve otomatik çalıştırılacaktır."
echo %ESC%[1;96m╔═ YAPILACAK İŞLEMLER ═════════════════════════════════════════╗%ESC%[0m
call :KutuSatiri "  Update + Temp + MSOCache + SquirrelTemp + Windows.old"
call :KutuSatiri "  + Prefetch + WER + DNS + Geri Dönüşüm Kutusu"
echo %ESC%[1;96m╚══════════════════════════════════════════════════════════════╝%ESC%[0m
echo.

call :Secim "EH" "Devam etmek istiyor musunuz? [E/H]: "
if "%SECIM_SONUC%"=="2" (
    call :Uyari "Otomatik silme iptal edildi."
    call :Bekle
    goto Menu
)

call :EkranYenile
call :IslemBaslik "OTOMATİK SİLME BAŞLADI"
echo.

set "OTO_HATA=0"
call :ISLEM_UPDATE
if errorlevel 1 set "OTO_HATA=1"
call :ISLEM_WINTEMP
if errorlevel 1 set "OTO_HATA=1"
call :ISLEM_USERTEMP
if errorlevel 1 set "OTO_HATA=1"
call :ISLEM_MSOCACHE
if errorlevel 1 set "OTO_HATA=1"
call :ISLEM_SQUIRREL
if errorlevel 1 set "OTO_HATA=1"
call :ISLEM_WINOLD
if errorlevel 1 set "OTO_HATA=1"
call :ISLEM_PREFETCH
if errorlevel 1 set "OTO_HATA=1"
call :ISLEM_WER
if errorlevel 1 set "OTO_HATA=1"
call :ISLEM_DNS
if errorlevel 1 set "OTO_HATA=1"
call :ISLEM_RECYCLE
if errorlevel 1 set "OTO_HATA=1"

echo.
if "%OTO_HATA%"=="1" (
    call :Hata "Otomatik silme tamamlandi ancak bazi adimlar kismen basarisiz oldu."
    call :Bilgi "Yukaridaki kirmizi hata satirlarini kontrol edin."
) else (
    call :Basarili "Otomatik silme islemleri basariyla tamamlandi."
)
echo.
call :Ayirici
call :Bekle
goto Menu

:ManuelMod
call :EkranYenile
call :IslemBaslik "MANUEL SİLME MODU"
echo.
call :Bilgi "Her islem icin onay sorulacaktir."
echo.
set "MANUEL_HATA=0"

call :Bilgi "[1/10] Windows Update Download icerigi temizlensin mi?"
call :Secim "EH" "  Seçiminiz [E/H]: "
if "%SECIM_SONUC%"=="1" (
    call :ISLEM_UPDATE
    if errorlevel 1 set "MANUEL_HATA=1"
)

call :Bilgi "[2/10] Windows Temp icerigi temizlensin mi?"
call :Secim "EH" "  Seçiminiz [E/H]: "
if "%SECIM_SONUC%"=="1" (
    call :ISLEM_WINTEMP
    if errorlevel 1 set "MANUEL_HATA=1"
)

call :Bilgi "[3/10] Kullanici Temp icerigi temizlensin mi?"
call :Secim "EH" "  Seçiminiz [E/H]: "
if "%SECIM_SONUC%"=="1" (
    call :ISLEM_USERTEMP
    if errorlevel 1 set "MANUEL_HATA=1"
)

call :Bilgi "[4/10] Office MSOCache temizlensin mi?"
call :Secim "EH" "  Seçiminiz [E/H]: "
if "%SECIM_SONUC%"=="1" (
    call :ISLEM_MSOCACHE
    if errorlevel 1 set "MANUEL_HATA=1"
)

call :Bilgi "[5/10] SquirrelTemp temizlensin mi?"
call :Secim "EH" "  Seçiminiz [E/H]: "
if "%SECIM_SONUC%"=="1" (
    call :ISLEM_SQUIRREL
    if errorlevel 1 set "MANUEL_HATA=1"
)

call :Bilgi "[6/10] Windows.old silinsin mi?"
call :Secim "EH" "  Seçiminiz [E/H]: "
if "%SECIM_SONUC%"=="1" (
    call :ISLEM_WINOLD
    if errorlevel 1 set "MANUEL_HATA=1"
)

call :Bilgi "[7/10] Prefetch temizlensin mi?"
call :Secim "EH" "  Seçiminiz [E/H]: "
if "%SECIM_SONUC%"=="1" (
    call :ISLEM_PREFETCH
    if errorlevel 1 set "MANUEL_HATA=1"
)

call :Bilgi "[8/10] Hata Raporlari WER temizlensin mi?"
call :Secim "EH" "  Seçiminiz [E/H]: "
if "%SECIM_SONUC%"=="1" (
    call :ISLEM_WER
    if errorlevel 1 set "MANUEL_HATA=1"
)

call :Bilgi "[9/10] DNS Onbellegi sifirlansin mi?"
call :Secim "EH" "  Seçiminiz [E/H]: "
if "%SECIM_SONUC%"=="1" (
    call :ISLEM_DNS
    if errorlevel 1 set "MANUEL_HATA=1"
)

call :Bilgi "[10/10] Geri Donusum Kutusu bosaltilsin mi?"
call :Secim "EH" "  Seçiminiz [E/H]: "
if "%SECIM_SONUC%"=="1" (
    call :ISLEM_RECYCLE
    if errorlevel 1 set "MANUEL_HATA=1"
)

echo.
if "%MANUEL_HATA%"=="1" (
    call :Hata "Manuel silme tamamlandi ancak secilen bazi adimlar kismen basarisiz oldu."
) else (
    call :Basarili "Manuel silme islemleri tamamlandi."
)
echo.
call :Ayirici
call :Bekle
goto Menu

:OnizlemeMod
call :EkranYenile
call :IslemBaslik "ÖNİZLEME MODU"
echo.
echo %ESC%[1;90m  Bu mod hicbir dosya silmez.%ESC%[0m
echo %ESC%[1;90m  Sadece temizlenecek alanlarin bulunup bulunmadigini kontrol eder.%ESC%[0m
echo.

call :ONIZLE_UPDATE
call :ONIZLE_WINTEMP
call :ONIZLE_USERTEMP
call :ONIZLE_MSOCACHE
call :ONIZLE_SQUIRREL
call :ONIZLE_WINOLD
call :ONIZLE_PREFETCH
call :ONIZLE_WER
call :ONIZLE_DNS
call :ONIZLE_RECYCLE

echo.
call :Basarili "Onizleme tamamlandi. Hicbir dosya silinmedi."
echo.
call :Ayirici
call :Bekle
goto Menu

:: ----------------------------------------------------------
:: ISLEM FONKSIYONLARI
:: ----------------------------------------------------------

:ISLEM_UPDATE
call :Bilgi "Windows Update Download icerigi temizleniyor..."
set "UPDATE_HATA=0"
set "WU_ORIG=Unknown"
set "BITS_ORIG=Unknown"

for /f "delims=" %%S in ('PowerShell.exe -NoProfile -NonInteractive -Command "try { (Get-Service -Name wuauserv -ErrorAction Stop).Status.ToString() } catch { Write-Output Unknown }"') do set "WU_ORIG=%%S"
for /f "delims=" %%S in ('PowerShell.exe -NoProfile -NonInteractive -Command "try { (Get-Service -Name bits -ErrorAction Stop).Status.ToString() } catch { Write-Output Unknown }"') do set "BITS_ORIG=%%S"

if /i "%WU_ORIG%"=="Unknown" (
    set "UPDATE_HATA=1"
    call :Uyari "Windows Update servisinin ilk durumu okunamadi; servis durumu degistirilmeyecek."
) else if /i "%WU_ORIG%"=="Running" (
    net stop wuauserv >nul 2>&1
    if errorlevel 1 (
        set "UPDATE_HATA=1"
        call :Hata "Windows Update servisi durdurulamadi."
    )
)

if /i "%BITS_ORIG%"=="Unknown" (
    set "UPDATE_HATA=1"
    call :Uyari "BITS servisinin ilk durumu okunamadi; servis durumu degistirilmeyecek."
) else if /i "%BITS_ORIG%"=="Running" (
    net stop bits >nul 2>&1
    if errorlevel 1 (
        set "UPDATE_HATA=1"
        call :Hata "BITS servisi durdurulamadi."
    )
)

if not exist "%SystemRoot%\SoftwareDistribution\Download" (
    mkdir "%SystemRoot%\SoftwareDistribution\Download" >nul 2>&1
    if errorlevel 1 set "UPDATE_HATA=1"
)

if exist "%SystemRoot%\SoftwareDistribution\Download" (
    del /f /s /q "%SystemRoot%\SoftwareDistribution\Download\*.*" >nul 2>&1
    for /d %%D in ("%SystemRoot%\SoftwareDistribution\Download\*") do rd /s /q "%%D" >nul 2>&1
    call :KlasorBosMu "%SystemRoot%\SoftwareDistribution\Download"
    if errorlevel 1 (
        set "UPDATE_HATA=1"
        call :Hata "Windows Update Download klasorunde silinemeyen icerik kaldi."
    )
) else (
    set "UPDATE_HATA=1"
    call :Hata "Windows Update Download klasoru olusturulamadi."
)

:: Yalnizca arac baslamadan once calisan servisler yeniden calisir durumda tutulur.
:: Durdurma basarisiz olduysa ve servis zaten calisiyorsa gereksiz net start uygulanmaz.
if /i "%BITS_ORIG%"=="Running" (
    call :ServisCalisiyorMu "bits"
    if errorlevel 1 (
        net start bits >nul 2>&1
        if errorlevel 1 (
            set "UPDATE_HATA=1"
            call :Hata "BITS servisi onceki calisir durumuna getirilemedi."
        )
    )
)
if /i "%WU_ORIG%"=="Running" (
    call :ServisCalisiyorMu "wuauserv"
    if errorlevel 1 (
        net start wuauserv >nul 2>&1
        if errorlevel 1 (
            set "UPDATE_HATA=1"
            call :Hata "Windows Update servisi onceki calisir durumuna getirilemedi."
        )
    )
)

if "%UPDATE_HATA%"=="1" (
    call :Hata "Windows Update Download temizligi kismen tamamlandi."
    echo.
    exit /b 1
)
call :Basarili "Windows Update Download icerigi temizlendi; servis durumlari korundu."
echo.
exit /b 0

:ISLEM_WINTEMP
call :Bilgi "Windows Temp icerigi temizleniyor..."
if exist "%SystemRoot%\Temp" (
    del /f /s /q "%SystemRoot%\Temp\*.*" >nul 2>&1
    for /d %%D in ("%SystemRoot%\Temp\*") do rd /s /q "%%D" >nul 2>&1
    call :KlasorBosMu "%SystemRoot%\Temp"
    if errorlevel 1 (
        call :Hata "Windows Temp kismen temizlendi; kullanimdaki bazi ogeler kaldi."
        echo.
        exit /b 1
    )
    call :Basarili "Windows Temp icerigi tamamen temizlendi."
) else (
    mkdir "%SystemRoot%\Temp" >nul 2>&1
    if errorlevel 1 (
        call :Hata "Windows Temp klasoru olusturulamadi."
        echo.
        exit /b 1
    )
    call :Basarili "Windows Temp klasoru yoktu; bos olarak yeniden olusturuldu."
)
echo.
exit /b 0

:ISLEM_USERTEMP
call :Bilgi "Kullanici Temp icerigi temizleniyor..."
if exist "%TEMP%" (
    del /f /s /q "%TEMP%\*.*" >nul 2>&1
    for /d %%D in ("%TEMP%\*") do rd /s /q "%%D" >nul 2>&1
    call :KlasorBosMu "%TEMP%"
    if errorlevel 1 (
        call :Hata "Kullanici Temp kismen temizlendi; kullanimdaki bazi ogeler kaldi."
        echo.
        exit /b 1
    )
    call :Basarili "Kullanici Temp icerigi tamamen temizlendi."
) else (
    mkdir "%TEMP%" >nul 2>&1
    if errorlevel 1 (
        call :Hata "Kullanici Temp klasoru olusturulamadi."
        echo.
        exit /b 1
    )
    call :Basarili "Kullanici Temp klasoru yoktu; bos olarak yeniden olusturuldu."
)
echo.
exit /b 0

:ISLEM_MSOCACHE
call :Bilgi "MSOCache temizleniyor..."
if exist "%SYSTEMDRIVE%\MSOCache\All Users" (
    del /f /s /q "%SYSTEMDRIVE%\MSOCache\All Users\*.*" >nul 2>&1
    for /d %%D in ("%SYSTEMDRIVE%\MSOCache\All Users\*") do rd /s /q "%%D" >nul 2>&1
    rd /s /q "%SYSTEMDRIVE%\MSOCache\All Users" >nul 2>&1
    if exist "%SYSTEMDRIVE%\MSOCache\All Users" (
        call :Hata "MSOCache tamamen silinemedi; kullanimdaki ogeler kalmis olabilir."
        echo.
        exit /b 1
    )
    call :Basarili "MSOCache temizlendi."
) else (
    call :Atlandi "MSOCache bulunamadı, geçiliyor."
)
echo.
exit /b 0

:ISLEM_SQUIRREL
call :Bilgi "SquirrelTemp temizleniyor..."
if exist "%LOCALAPPDATA%\SquirrelTemp" (
    del /f /s /q "%LOCALAPPDATA%\SquirrelTemp\*.*" >nul 2>&1
    for /d %%D in ("%LOCALAPPDATA%\SquirrelTemp\*") do rd /s /q "%%D" >nul 2>&1
    rd /s /q "%LOCALAPPDATA%\SquirrelTemp" >nul 2>&1
    if exist "%LOCALAPPDATA%\SquirrelTemp" (
        call :Hata "SquirrelTemp tamamen silinemedi; kullanimdaki ogeler kalmis olabilir."
        echo.
        exit /b 1
    )
    call :Basarili "SquirrelTemp temizlendi."
) else (
    call :Atlandi "SquirrelTemp bulunamadı, geçiliyor."
)
echo.
exit /b 0

:ISLEM_WINOLD
call :Bilgi "Windows.old kontrol ediliyor..."
if exist "%SYSTEMDRIVE%\Windows.old" (
    takeown /F "%SYSTEMDRIVE%\Windows.old" /A /R /D Y >nul 2>&1
    icacls "%SYSTEMDRIVE%\Windows.old" /grant *S-1-5-32-544:F /T /C /Q >nul 2>&1
    rd /s /q "%SYSTEMDRIVE%\Windows.old" >nul 2>&1
    if exist "%SYSTEMDRIVE%\Windows.old" (
        call :Hata "Windows.old tamamen silinemedi. Bazi dosyalar kilitli olabilir."
        echo.
        exit /b 1
    )
    call :Basarili "Windows.old silindi."
) else (
    call :Atlandi "Windows.old bulunamadı, geçiliyor."
)
echo.
exit /b 0

:ISLEM_PREFETCH
call :Bilgi "Prefetch temizleniyor..."
if exist "%SystemRoot%\Prefetch" (
    del /f /s /q "%SystemRoot%\Prefetch\*.*" >nul 2>&1
    for /d %%D in ("%SystemRoot%\Prefetch\*") do rd /s /q "%%D" >nul 2>&1
    call :KlasorBosMu "%SystemRoot%\Prefetch"
    if errorlevel 1 (
        call :Hata "Prefetch kismen temizlendi; kullanimdaki bazi ogeler kaldi."
        echo.
        exit /b 1
    )
    call :Basarili "Prefetch icerigi tamamen temizlendi."
) else (
    call :Atlandi "Prefetch klasörü bulunamadı, geçiliyor."
)
echo.
exit /b 0

:ISLEM_WER
call :Bilgi "Hata raporlari WER temizleniyor..."
set "WER_BULUNDU=0"
set "WER_HATA=0"
if exist "%LOCALAPPDATA%\Microsoft\Windows\WER" (
    set "WER_BULUNDU=1"
    del /f /s /q "%LOCALAPPDATA%\Microsoft\Windows\WER\*.*" >nul 2>&1
    for /d %%D in ("%LOCALAPPDATA%\Microsoft\Windows\WER\*") do rd /s /q "%%D" >nul 2>&1
    call :KlasorBosMu "%LOCALAPPDATA%\Microsoft\Windows\WER"
    if errorlevel 1 set "WER_HATA=1"
)
if exist "%ProgramData%\Microsoft\Windows\WER" (
    set "WER_BULUNDU=1"
    del /f /s /q "%ProgramData%\Microsoft\Windows\WER\*.*" >nul 2>&1
    for /d %%D in ("%ProgramData%\Microsoft\Windows\WER\*") do rd /s /q "%%D" >nul 2>&1
    call :KlasorBosMu "%ProgramData%\Microsoft\Windows\WER"
    if errorlevel 1 set "WER_HATA=1"
)
if "%WER_BULUNDU%"=="0" (
    call :Atlandi "WER hata raporu klasorleri bulunamadi, geçiliyor."
    echo.
    exit /b 0
)
if "%WER_HATA%"=="1" (
    call :Hata "WER kismen temizlendi; kullanimdaki bazi raporlar kaldi."
    echo.
    exit /b 1
)
call :Basarili "Kullanici ve ProgramData WER hata raporlari tamamen temizlendi."
echo.
exit /b 0

:ISLEM_DNS
call :Bilgi "DNS onbellegi temizleniyor..."
ipconfig /flushdns >nul 2>&1
if errorlevel 1 (
    call :Hata "DNS onbellegi temizlenemedi."
    echo.
    exit /b 1
)
call :Basarili "DNS onbellegi temizlendi."
echo.
exit /b 0

:ISLEM_RECYCLE
call :Bilgi "Geri Donusum Kutusu bosaltiliyor..."
:: Guvenlik: Clear-RecycleBin basarisiz olursa tum suruculerdeki $Recycle.Bin agaclari silinmez.
:: Boylece fallback islemi cmdlet'in kullanici kapsamini genisletmez.
PowerShell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "try { Clear-RecycleBin -Force -ErrorAction Stop; exit 0 } catch { exit 1 }" >nul 2>&1
if errorlevel 1 (
    call :Hata "Geri Donusum Kutusu bosaltilamadi; guvensiz klasor fallback'i calistirilmadi."
    echo.
    exit /b 1
)
call :Basarili "Geri Donusum Kutusu bosaltildi."
echo.
exit /b 0

:: ----------------------------------------------------------
:: ONIZLEME FONKSIYONLARI
:: ----------------------------------------------------------

:ONIZLE_UPDATE
if exist "%SystemRoot%\SoftwareDistribution\Download" (
    call :Var "Windows Update Download klasoru bulundu. Icerik temizlenebilir."
) else (
    call :Yok "Windows Update Download klasoru bulunamadi."
)
exit /b

:ONIZLE_WINTEMP
if exist "%SystemRoot%\Temp" (
    call :Var "Windows Temp klasoru bulundu. Sadece icerik temizlenir."
) else (
    call :Yok "Windows Temp klasoru bulunamadi."
)
exit /b

:ONIZLE_USERTEMP
if exist "%TEMP%" (
    call :Var "Kullanici Temp klasoru bulundu. Sadece icerik temizlenir."
) else (
    call :Yok "Kullanici Temp klasoru bulunamadi."
)
exit /b

:ONIZLE_MSOCACHE
if exist "%SYSTEMDRIVE%\MSOCache\All Users" (
    call :Var "MSOCache bulundu. Office artiklari temizlenebilir."
) else (
    call :Yok "MSOCache bulunamadi."
)
exit /b

:ONIZLE_SQUIRREL
if exist "%LOCALAPPDATA%\SquirrelTemp" (
    call :Var "SquirrelTemp bulundu. Discord/Teams artiklari temizlenebilir."
) else (
    call :Yok "SquirrelTemp bulunamadi."
)
exit /b

:ONIZLE_WINOLD
if exist "%SYSTEMDRIVE%\Windows.old" (
    call :Var "Windows.old bulundu. Otomatik veya manuel modda silinebilir."
) else (
    call :Yok "Windows.old bulunamadi."
)
exit /b

:ONIZLE_PREFETCH
if exist "%SystemRoot%\Prefetch" (
    call :Var "Prefetch klasoru bulundu. Icerik temizlenebilir."
) else (
    call :Yok "Prefetch klasoru bulunamadi."
)
exit /b

:ONIZLE_WER
set "WER_FOUND=0"
if exist "%LOCALAPPDATA%\Microsoft\Windows\WER" set "WER_FOUND=1"
if exist "%ProgramData%\Microsoft\Windows\WER" set "WER_FOUND=1"
if "%WER_FOUND%"=="1" (
    call :Var "WER hata raporu klasorleri bulundu. Kullanici ve ProgramData kontrol edilir."
) else (
    call :Yok "WER hata raporu klasoru bulunamadi."
)
exit /b

:ONIZLE_DNS
call :Var "DNS onbellegi sifirlanabilir. Bu islem dosya silmez."
exit /b

:ONIZLE_RECYCLE
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "try { $items = (New-Object -ComObject Shell.Application).NameSpace(0xA).Items().Count; if ($items -gt 0) { exit 0 } else { exit 2 } } catch { exit 1 }" >nul 2>&1
if errorlevel 2 (
    call :Yok "Geri Donusum Kutusu bos gorunuyor."
) else if errorlevel 1 (
    call :Bilgi "Geri Donusum Kutusu durumu okunamadi fakat temizleme denenebilir."
) else (
    call :Var "Geri Donusum Kutusu icinde dosya var. Bosaltilabilir."
)
exit /b

:Cikis
call :EkranYenile
call :Bilgi "Gelismis Sistem Bakim ve Temizlik Araci v%VERSION% kapatiliyor..."
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

:ServisCalisiyorMu
PowerShell.exe -NoProfile -NonInteractive -Command "try { if((Get-Service -Name '%~1' -ErrorAction Stop).Status -eq [System.ServiceProcess.ServiceControllerStatus]::Running){exit 0}else{exit 1} } catch { exit 1 }" >nul 2>&1
exit /b %ERRORLEVEL%

:KlasorBosMu
:: Donus 0: klasor yok veya bos. Donus 1: en az bir oge kaldi.
for /f "delims=" %%A in ('dir /a /b "%~1" 2^>nul') do exit /b 1
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

:: Renkli Mesaj Fonksiyonlari
:Basarili
echo %ESC%[1;92m  [✓] %~1%ESC%[0m
exit /b

:Hata
echo %ESC%[1;91m  [X] %~1%ESC%[0m
exit /b

:Bilgi
echo %ESC%[1;93m  [●] %~1%ESC%[0m
exit /b

:Var
echo %ESC%[1;92m  [✓] %~1%ESC%[0m
exit /b

:Yok
echo %ESC%[1;90m  [–] %~1%ESC%[0m
exit /b

:Atlandi
echo %ESC%[1;90m  [–] %~1%ESC%[0m
exit /b

:Uyari
echo %ESC%[1;93m  [!] %~1%ESC%[0m
exit /b
