@echo off
chcp 65001 >nul
setlocal EnableExtensions

:: ANSI renk kodlarini kullanabilmek icin ESC karakterini tanimliyoruz
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

set "VERSION=1.0.0"
set "CONSOLE_COLS=86"
set "CONSOLE_LINES=34"
set "POWERSHELL_EXE=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
title Bilgisayar Temizlik Taramasi v%VERSION%
color 0F

:: Konsol görünümü diğer araçlarla aynı kalın/kompakt şablonda hazırlanır.
:: Tarama salt okunur olsa da sistem genelindeki alanların eksiksiz okunabilmesi için yönetici yetkisi zorunludur.
call :KonsolBaslangic

call :YoneticiKontrol
if errorlevel 1 exit /b

:Menu
call :EkranYenile
call :ArayuzBaslik "BİLGİSAYAR TEMİZLİK TARAMASI"
call :BilgiKutusu "  Dosya silmeden temizlik ve inceleme adaylarını raporlar."
call :MenuKutusu "1" "HIZLI TARAMA" "  Temel önbellekler, Masaüstü ve İndirilenler taranır."
call :MenuKutusu "2" "STANDART TARAMA" "  Önerilen kapsam; geliştirici önbellekleri de taranır."
call :MenuKutusu "3" "DERİN TARAMA" "  Tüm kullanıcı profili ve daha fazla büyük dosya taranır."
call :MenuKutusu "4" "ÖZEL TARAMA" "  Kapsamı ve eşikleri kendiniz belirlersiniz."
call :MenuKutusu "0" "ÇIKIŞ" "  Aracı işlem yapmadan kapatır."
call :Ayirici
echo.

call :Secim "12340" "Seçiminiz › "

if "%SECIM_SONUC%"=="5" goto Cikis
if "%SECIM_SONUC%"=="4" goto OzelTarama
if "%SECIM_SONUC%"=="3" goto DerinTarama
if "%SECIM_SONUC%"=="2" goto StandartTarama
if "%SECIM_SONUC%"=="1" goto HizliTarama
goto Menu

:HizliTarama
call :TaramaBaslat "Hizli" "HIZLI TARAMA"
goto Menu

:StandartTarama
call :TaramaBaslat "Standart" "STANDART TARAMA"
goto Menu

:DerinTarama
call :TaramaBaslat "Derin" "DERİN TARAMA"
goto Menu

:OzelTarama
call :TaramaBaslat "Ozel" "ÖZEL TARAMA"
goto Menu

:TaramaBaslat
call :EkranYenile
call :IslemBaslik "%~2"
call :Bilgi "Salt okunur tarama motoru başlatılıyor..."
call :Atlandi "Bu araç hiçbir dosyayı silmez ve sistem ayarı değiştirmez."
echo.

if not exist "%POWERSHELL_EXE%" (
    call :Hata "Windows PowerShell 5.1 bulunamadı."
    call :Uyari "Beklenen konum: %POWERSHELL_EXE%"
    echo.
    call :Bekle
    exit /b 10
)

set "SELF_BAT=%~f0"
set "SCAN_MODE=%~1"

"%POWERSHELL_EXE%" -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$raw=[IO.File]::ReadAllText($env:SELF_BAT,[Text.Encoding]::UTF8); $begin='### POWERSHELL_'+'PAYLOAD_BEGIN ###'; $end='### POWERSHELL_'+'PAYLOAD_END ###'; $i=$raw.IndexOf($begin); if($i -lt 0){Write-Error 'Gomulu PowerShell baslangic isareti bulunamadi.'; exit 90}; $i=$i+$begin.Length; $j=$raw.IndexOf($end,$i); if($j -lt 0){Write-Error 'Gomulu PowerShell bitis isareti bulunamadi.'; exit 91}; $code=$raw.Substring($i,$j-$i).TrimStart([char]13,[char]10); $sb=[scriptblock]::Create($code); & $sb -TaramaModu $env:SCAN_MODE"
set "RC=%ERRORLEVEL%"

echo.
call :Ayirici
if "%RC%"=="0" (
    call :Basarili "Tarama tamamlandı. HTML ve CSV raporları oluşturuldu."
) else (
    call :Hata "Tarama hata kodu %RC% ile sonlandı."
    call :Uyari "Yukarıdaki ilk hata satırı sorunun kaynağını gösterebilir."
)
echo.
call :Bekle
exit /b %RC%

:Cikis
call :EkranYenile
call :Bilgi "Bilgisayar Temizlik Taramasi v%VERSION% kapatiliyor..."
timeout /t 1 >nul
exit /b

:: ============================================================
:: YARDIMCI FONKSIYONLAR
:: Ortak ana arayuz sablonu
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
title Bilgisayar Temizlik Taramasi v%VERSION%
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
set "FLTMC_RC=%ERRORLEVEL%"

if not "%FLTMC_RC%"=="0" (
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

goto :eof

### POWERSHELL_PAYLOAD_BEGIN ###
#requires -Version 5.1
# V3 - Windows PowerShell 5.1 uyumlu, recursive tarama hatalari bastirilmis
<#
.SYNOPSIS
    Windows bilgisayarında temizlik adaylarını salt okunur biçimde tarar.

.DESCRIPTION
    Bu betik hiçbir dosyayı veya uygulamayı silmez. Yalnızca:
    - Disk kullanımını
    - Geçici dosya ve önbellek klasörlerini
    - Büyük dosyaları
    - Eski İndirilenler dosyalarını
    - Başlangıç uygulamalarını
    - Yüklü masaüstü uygulamalarını
    tarar ve HTML/CSV raporları üretir.

    Parametre verilmezse açılışta tarama modeli seçim menüsü gösterilir.

.PARAMETER BuyukDosyaSayisi
    Rapora eklenecek en büyük dosya sayısı. Varsayılan: 30

.PARAMETER EskiDosyaGunu
    İndirilenler klasöründe kaç günden eski dosyaların işaretleneceği. Varsayılan: 90

.PARAMETER DerinTarama
    Büyük dosya aramasını yalnızca standart kullanıcı klasörleri yerine tüm kullanıcı profilinde yapar.

.PARAMETER RaporKlasoru
    Raporların kaydedileceği klasör.

.EXAMPLE
    .\Bilgisayar-Temizlik-Taramasi.ps1

.EXAMPLE
    .\Bilgisayar-Temizlik-Taramasi.ps1 -TaramaModu Derin
#>

[CmdletBinding()]
param(
    [ValidateSet("Menu", "Hizli", "Standart", "Derin", "Ozel")]
    [string]$TaramaModu = "Menu",

    [ValidateRange(5, 500)]
    [int]$BuyukDosyaSayisi = 30,

    [ValidateRange(1, 3650)]
    [int]$EskiDosyaGunu = 90,

    [switch]$DerinTarama,

    [string]$RaporKlasoru = ""
)


# Beklenmeyen hataları görünür tut. Erişim izni beklenen klasörlerde
# ilgili komutlar ayrıca -ErrorAction SilentlyContinue kullanır.
$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"
$startTime = Get-Date

# Bazı PowerShell hostlarında RawUI/WindowTitle desteklenmeyebilir.
try {
    if ($host.UI -and $host.UI.RawUI) {
        $host.UI.RawUI.WindowTitle = "Bilgisayar Temizlik Taraması"
    }
}
catch {
    # Başlık ayarlanamaması taramayı etkilemez.
}

function Read-NumberInRange {
    param(
        [Parameter(Mandatory = $true)][string]$Prompt,
        [Parameter(Mandatory = $true)][int]$Minimum,
        [Parameter(Mandatory = $true)][int]$Maximum,
        [Parameter(Mandatory = $true)][int]$Default
    )

    while ($true) {
        $raw = Read-Host ("{0} [{1}]" -f $Prompt, $Default)

        if ([string]::IsNullOrWhiteSpace($raw)) {
            return $Default
        }

        [int]$number = 0
        if ([int]::TryParse($raw, [ref]$number) -and $number -ge $Minimum -and $number -le $Maximum) {
            return $number
        }

        Write-Host ("Lütfen {0} ile {1} arasında bir sayı gir." -f $Minimum, $Maximum) -ForegroundColor Yellow
    }
}

function Read-YesNo {
    param(
        [Parameter(Mandatory = $true)][string]$Prompt,
        [bool]$Default = $true
    )

    $defaultLabel = if ($Default) { "E" } else { "H" }

    while ($true) {
        $answer = Read-Host ("{0} [E/H, varsayılan: {1}]" -f $Prompt, $defaultLabel)

        if ([string]::IsNullOrWhiteSpace($answer)) {
            return $Default
        }

        $normalized = $answer.Trim().ToLowerInvariant()
        if ($normalized -in @("e", "evet", "y", "yes")) { return $true }
        if ($normalized -in @("h", "hayır", "hayir", "n", "no")) { return $false }

        Write-Host "Lütfen E veya H gir." -ForegroundColor Yellow
    }
}

function Show-ScanMenu {
    Clear-Host
    Write-Host "============================================================" -ForegroundColor DarkCyan
    Write-Host "           BİLGİSAYAR TEMİZLİK TARAMASI" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "Bu araç hiçbir dosyayı silmez ve hiçbir ayarı değiştirmez." -ForegroundColor Green
    Write-Host "Yalnızca temizlik ve inceleme adaylarını raporlar." -ForegroundColor Green
    Write-Host ""
    Write-Host "[1] Hızlı tarama" -ForegroundColor White
    Write-Host "    Temel geçici klasörler, tarayıcı önbellekleri, Masaüstü ve İndirilenler."
    Write-Host ""
    Write-Host "[2] Standart tarama (önerilen)" -ForegroundColor White
    Write-Host "    Hızlı taramaya ek olarak geliştirici önbellekleri ve standart kullanıcı klasörleri."
    Write-Host ""
    Write-Host "[3] Derin tarama" -ForegroundColor White
    Write-Host "    Tüm kullanıcı profili, daha fazla büyük dosya ve tüm rapor bölümleri."
    Write-Host ""
    Write-Host "[4] Özel tarama" -ForegroundColor White
    Write-Host "    Kapsamı, eski dosya yaşını ve raporlanacak büyük dosya sayısını sen seçersin."
    Write-Host ""
    Write-Host "[0] Çıkış" -ForegroundColor DarkGray
    Write-Host ""
}

$HizliTarama = $false
$GelistiriciTaramasi = $true
$KuruluUygulamaTaramasi = $true
$TaramaAciklama = ""

if ($TaramaModu -eq "Menu") {
    while ($true) {
        Show-ScanMenu
        $selection = Read-Host "Tarama modelini seç"

        switch ($selection.Trim()) {
            "1" {
                $TaramaModu = "Hizli"
                break
            }
            "2" {
                $TaramaModu = "Standart"
                break
            }
            "3" {
                $TaramaModu = "Derin"
                break
            }
            "4" {
                $TaramaModu = "Ozel"
                break
            }
            "0" {
                Write-Host "İşlem iptal edildi." -ForegroundColor Yellow
                exit 0
            }
            default {
                Write-Host "Geçersiz seçim. Devam etmek için Enter tuşuna bas." -ForegroundColor Yellow
                [void](Read-Host)
            }
        }

        if ($TaramaModu -ne "Menu") { break }
    }
}

switch ($TaramaModu) {
    "Hizli" {
        $HizliTarama = $true
        $GelistiriciTaramasi = $false
        $KuruluUygulamaTaramasi = $false
        $DerinTarama = $false
        $BuyukDosyaSayisi = 15
        $EskiDosyaGunu = 180
        $TaramaAciklama = "Hızlı tarama"
    }

    "Standart" {
        $HizliTarama = $false
        $GelistiriciTaramasi = $true
        $KuruluUygulamaTaramasi = $true
        $DerinTarama = $false
        $BuyukDosyaSayisi = 30
        $EskiDosyaGunu = 90
        $TaramaAciklama = "Standart tarama"
    }

    "Derin" {
        $HizliTarama = $false
        $GelistiriciTaramasi = $true
        $KuruluUygulamaTaramasi = $true
        $DerinTarama = $true
        $BuyukDosyaSayisi = 75
        $EskiDosyaGunu = 60
        $TaramaAciklama = "Derin tarama"
    }

    "Ozel" {
        Clear-Host
        Write-Host "ÖZEL TARAMA AYARLARI" -ForegroundColor Cyan
        Write-Host ""

        $BuyukDosyaSayisi = Read-NumberInRange `
            -Prompt "Rapora kaç büyük dosya eklensin?" `
            -Minimum 5 `
            -Maximum 500 `
            -Default 40

        $EskiDosyaGunu = Read-NumberInRange `
            -Prompt "İndirilenler klasöründe kaç günden eski dosyalar işaretlensin?" `
            -Minimum 1 `
            -Maximum 3650 `
            -Default 90

        Write-Host ""
        Write-Host "[1] Standart kullanıcı klasörleri"
        Write-Host "[2] Tüm kullanıcı profili"
        $scope = Read-Host "Büyük dosya tarama kapsamını seç [1]"

        if ($scope.Trim() -eq "2") {
            $DerinTarama = $true
        }
        else {
            $DerinTarama = $false
        }

        $GelistiriciTaramasi = Read-YesNo `
            -Prompt "VS Code ve paket yöneticisi önbellekleri taransın mı?" `
            -Default $true

        $KuruluUygulamaTaramasi = Read-YesNo `
            -Prompt "Yüklü uygulamalar raporlansın mı?" `
            -Default $true

        $HizliTarama = $false
        $TaramaAciklama = "Özel tarama"
    }
}

Clear-Host
Write-Host "Seçilen model: $TaramaAciklama" -ForegroundColor Cyan
Write-Host "Büyük dosya sınırı: $BuyukDosyaSayisi" -ForegroundColor DarkCyan
Write-Host "Eski İndirilenler eşiği: $EskiDosyaGunu gün" -ForegroundColor DarkCyan
Write-Host "Geliştirici önbellekleri: $(if ($GelistiriciTaramasi) { 'Dahil' } else { 'Hariç' })" -ForegroundColor DarkCyan
Write-Host "Yüklü uygulamalar: $(if ($KuruluUygulamaTaramasi) { 'Dahil' } else { 'Hariç' })" -ForegroundColor DarkCyan
Write-Host ""


function Get-FriendlySize {
    param([AllowNull()][object]$Bytes)

    if ($null -eq $Bytes) { return "0 B" }

    [double]$value = 0
    if (-not [double]::TryParse([string]$Bytes, [ref]$value)) {
        return "0 B"
    }

    if ($value -ge 1TB) { return ("{0:N2} TB" -f ($value / 1TB)) }
    if ($value -ge 1GB) { return ("{0:N2} GB" -f ($value / 1GB)) }
    if ($value -ge 1MB) { return ("{0:N2} MB" -f ($value / 1MB)) }
    if ($value -ge 1KB) { return ("{0:N2} KB" -f ($value / 1KB)) }
    return ("{0:N0} B" -f $value)
}

function Get-SafeRecursiveFiles {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [string[]]$ExcludePaths = @()
    )

    if ([string]::IsNullOrWhiteSpace($Root)) { return }
    if (-not (Test-Path -LiteralPath $Root -PathType Container)) { return }

    $excluded = @{}
    foreach ($excludePath in $ExcludePaths) {
        if ([string]::IsNullOrWhiteSpace($excludePath)) { continue }
        try {
            $normalizedExclude = [System.IO.Path]::GetFullPath($excludePath).TrimEnd('\')
            $excluded[$normalizedExclude.ToLowerInvariant()] = $true
        }
        catch { }
    }

    $stack = New-Object 'System.Collections.Generic.Stack[string]'
    try {
        $startPath = (Get-Item -LiteralPath $Root -Force -ErrorAction Stop).FullName
        $stack.Push($startPath)
    }
    catch {
        return
    }

    while ($stack.Count -gt 0) {
        $current = $stack.Pop()

        try {
            $files = @(Get-ChildItem -LiteralPath $current -File -Force -ErrorAction Stop)
            foreach ($file in $files) {
                Write-Output $file
            }
        }
        catch {
            # Erişilemeyen veya tarama sırasında kaybolan klasörler sessizce atlanır.
        }

        try {
            $directories = @(Get-ChildItem -LiteralPath $current -Directory -Force -ErrorAction Stop)
        }
        catch {
            $directories = @()
        }

        foreach ($directory in $directories) {
            try {
                if (($directory.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
                    continue
                }

                $normalizedDirectory = [System.IO.Path]::GetFullPath($directory.FullName).TrimEnd('\').ToLowerInvariant()
                if ($excluded.ContainsKey($normalizedDirectory)) {
                    continue
                }

                $stack.Push($directory.FullName)
            }
            catch {
                # Bozuk yol/junction bilgisi taramayı durdurmasın.
            }
        }
    }
}

function Get-FolderSize {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) { return [int64]0 }

    try {
        $sum = (
            Get-SafeRecursiveFiles -Root $Path -ExcludePaths @($RaporKlasoru) |
            Measure-Object -Property Length -Sum
        ).Sum

        if ($null -eq $sum) { return [int64]0 }
        return [int64]$sum
    }
    catch {
        return [int64]0
    }
}

function Ensure-ReportFolder {
    param([string]$PreferredPath)

    $candidates = New-Object 'System.Collections.Generic.List[string]'

    if (-not [string]::IsNullOrWhiteSpace($PreferredPath)) {
        $candidates.Add($PreferredPath) | Out-Null
    }

    if (-not [string]::IsNullOrWhiteSpace($env:LOCALAPPDATA)) {
        $candidates.Add((Join-Path $env:LOCALAPPDATA 'Bilgisayar-Tarama-Raporu')) | Out-Null
    }

    if (-not [string]::IsNullOrWhiteSpace($env:TEMP)) {
        $candidates.Add((Join-Path $env:TEMP 'Bilgisayar-Tarama-Raporu')) | Out-Null
    }

    foreach ($candidate in ($candidates | Select-Object -Unique)) {
        try {
            [void][System.IO.Directory]::CreateDirectory($candidate)
            if (-not (Test-Path -LiteralPath $candidate -PathType Container)) {
                throw 'Klasör oluşturulduktan sonra bulunamadı.'
            }

            # Klasörün gerçekten yazılabilir olduğunu da doğrula.
            $probePath = Join-Path $candidate ('.rapor-yazma-testi-{0}.tmp' -f $PID)
            [System.IO.File]::WriteAllText($probePath, 'test')
            Remove-Item -LiteralPath $probePath -Force -ErrorAction SilentlyContinue

            return (Get-Item -LiteralPath $candidate -Force -ErrorAction Stop).FullName
        }
        catch {
            if ($probePath -and (Test-Path -LiteralPath $probePath)) {
                Remove-Item -LiteralPath $probePath -Force -ErrorAction SilentlyContinue
            }
            Write-Warning ('Rapor klasörü kullanılamadı: {0}' -f $candidate)
        }
    }

    throw 'Raporların yazılabileceği bir klasör oluşturulamadı.'
}

function Test-IsAdministrator {
    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($identity)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    catch {
        return $false
    }
}

function Add-Finding {
    param(
        [string]$Category,
        [string]$Item,
        [string]$Path,
        [int64]$SizeBytes,
        [string]$Risk,
        [string]$Recommendation
    )

    $findings.Add([pscustomobject]@{
        Kategori = $Category
        Oge = $Item
        Yol = $Path
        BoyutBayt = $SizeBytes
        Boyut = Get-FriendlySize $SizeBytes
        Durum = $Risk
        Oneri = $Recommendation
    }) | Out-Null
}

function Measure-And-Add {
    param(
        [string]$Category,
        [string]$Item,
        [string]$Path,
        [string]$Risk,
        [string]$Recommendation
    )

    if ([string]::IsNullOrWhiteSpace($Path)) { return }
    if (-not (Test-Path -LiteralPath $Path)) { return }

    Write-Host ("Taranıyor: {0}" -f $Item) -ForegroundColor DarkCyan
    $size = Get-FolderSize -Path $Path
    Add-Finding -Category $Category -Item $Item -Path $Path -SizeBytes $size -Risk $Risk -Recommendation $Recommendation
}

# Rapor klasörünü belirle.
if ([string]::IsNullOrWhiteSpace($RaporKlasoru)) {
    $desktop = [Environment]::GetFolderPath("Desktop")
    if ([string]::IsNullOrWhiteSpace($desktop)) {
        $desktop = (Get-Location).Path
    }
    $RaporKlasoru = Join-Path $desktop "Bilgisayar-Tarama-Raporu"
}

try {
    $RaporKlasoru = Ensure-ReportFolder -PreferredPath $RaporKlasoru
}
catch {
    Write-Error $_.Exception.Message
    exit 3
}

$findings = New-Object "System.Collections.Generic.List[object]"
$isAdmin = Test-IsAdministrator

Write-Host ""
Write-Host "Bilgisayar Temizlik Taraması" -ForegroundColor Cyan
Write-Host "Bu işlem hiçbir dosyayı silmez." -ForegroundColor Green
Write-Host ""

# Sistem bilgileri
$os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
$computer = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue
$uptime = $null
if ($os.LastBootUpTime) {
    $uptime = (Get-Date) - $os.LastBootUpTime
}

$systemInfo = @(
    [pscustomobject]@{ Bilgi = "Bilgisayar"; Deger = $env:COMPUTERNAME }
    [pscustomobject]@{ Bilgi = "Kullanıcı"; Deger = $env:USERNAME }
    [pscustomobject]@{ Bilgi = "Windows"; Deger = ("{0} — sürüm {1}, yapı {2}" -f $os.Caption, $os.Version, $os.BuildNumber) }
    [pscustomobject]@{ Bilgi = "RAM"; Deger = Get-FriendlySize ([int64]$computer.TotalPhysicalMemory) }
    [pscustomobject]@{ Bilgi = "Yönetici olarak çalışıyor"; Deger = $(if ($isAdmin) { "Evet" } else { "Hayır" }) }
    [pscustomobject]@{ Bilgi = "Çalışma süresi"; Deger = $(if ($uptime) { "{0} gün {1} saat" -f [int]$uptime.TotalDays, $uptime.Hours } else { "Bilinmiyor" }) }
    [pscustomobject]@{ Bilgi = "Tarama modu"; Deger = $TaramaAciklama }
)

# Diskler
$drives = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction SilentlyContinue |
    ForEach-Object {
        $used = [int64]($_.Size - $_.FreeSpace)
        $freePercent = if ($_.Size -gt 0) { [math]::Round(($_.FreeSpace / $_.Size) * 100, 1) } else { 0 }

        [pscustomobject]@{
            Surucu = $_.DeviceID
            Etiket = $_.VolumeName
            Toplam = Get-FriendlySize $_.Size
            Kullanilan = Get-FriendlySize $used
            Bos = Get-FriendlySize $_.FreeSpace
            BosYuzde = "$freePercent%"
        }
    }

# Geçici dosyalar ve Windows bileşenleri
$commonFolders = @(
    @{
        Category = "Geçici dosyalar"
        Item = "Kullanıcı geçici klasörü"
        Path = $env:TEMP
        Risk = "Genellikle güvenli"
        Recommendation = "Uygulamaları kapattıktan sonra Windows Depolama ayarlarıyla veya dikkatli biçimde temizlenebilir."
    },
    @{
        Category = "Geçici dosyalar"
        Item = "Yerel geçici klasör"
        Path = (Join-Path $env:LOCALAPPDATA "Temp")
        Risk = "Genellikle güvenli"
        Recommendation = "Kullanımda olan dosyalar atlanmalıdır."
    },
    @{
        Category = "Windows"
        Item = "Windows geçici klasörü"
        Path = (Join-Path $env:WINDIR "Temp")
        Risk = "Windows aracıyla temizle"
        Recommendation = "Ayarlar > Sistem > Depolama > Geçici dosyalar bölümünü kullan."
    },
    @{
        Category = "Windows"
        Item = "Windows Update indirme önbelleği"
        Path = (Join-Path $env:WINDIR "SoftwareDistribution\Download")
        Risk = "Elle silme"
        Recommendation = "Windows Depolama veya Disk Temizleme aracını kullan; klasörü doğrudan silme."
    },
    @{
        Category = "Windows"
        Item = "Teslim İyileştirme önbelleği"
        Path = (Join-Path $env:ProgramData "Microsoft\Windows\DeliveryOptimization\Cache")
        Risk = "Windows aracıyla temizle"
        Recommendation = "Windows Depolama ayarlarından temizle."
    },
    @{
        Category = "Hata raporları"
        Item = "Uygulama çökme dökümleri"
        Path = (Join-Path $env:LOCALAPPDATA "CrashDumps")
        Risk = "İncele"
        Recommendation = "Hata ayıklama yapmıyorsan eski dökümler temizlenebilir."
    },
    @{
        Category = "Hata raporları"
        Item = "Windows hata raporu arşivi"
        Path = (Join-Path $env:ProgramData "Microsoft\Windows\WER\ReportArchive")
        Risk = "Windows aracıyla temizle"
        Recommendation = "Disk Temizleme veya Depolama ayarlarını kullan."
    },
    @{
        Category = "Windows"
        Item = "Küçük resim ve simge önbelleği"
        Path = (Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Explorer")
        Risk = "İncele"
        Recommendation = "Depolama ayarlarında Küçük Resimler seçeneğiyle temizlenebilir."
    }
)

foreach ($folder in $commonFolders) {
    Measure-And-Add -Category $folder.Category -Item $folder.Item -Path $folder.Path -Risk $folder.Risk -Recommendation $folder.Recommendation
}

# Geri Dönüşüm Kutusu
$recyclePath = Join-Path $env:SystemDrive '$Recycle.Bin'
Measure-And-Add `
    -Category "Kullanıcı dosyaları" `
    -Item "Geri Dönüşüm Kutusu" `
    -Path $recyclePath `
    -Risk "İncele" `
    -Recommendation "İçeriğini kontrol ettikten sonra Geri Dönüşüm Kutusu üzerinden boşalt."

# Tarayıcı önbellekleri
$browserFolders = @(
    @{
        Item = "Google Chrome önbelleği"
        Path = (Join-Path $env:LOCALAPPDATA "Google\Chrome\User Data\Default\Cache")
    },
    @{
        Item = "Google Chrome kod önbelleği"
        Path = (Join-Path $env:LOCALAPPDATA "Google\Chrome\User Data\Default\Code Cache")
    },
    @{
        Item = "Microsoft Edge önbelleği"
        Path = (Join-Path $env:LOCALAPPDATA "Microsoft\Edge\User Data\Default\Cache")
    },
    @{
        Item = "Microsoft Edge kod önbelleği"
        Path = (Join-Path $env:LOCALAPPDATA "Microsoft\Edge\User Data\Default\Code Cache")
    }
)

foreach ($folder in $browserFolders) {
    Measure-And-Add `
        -Category "Tarayıcı önbelleği" `
        -Item $folder.Item `
        -Path $folder.Path `
        -Risk "Genellikle güvenli" `
        -Recommendation "Tarayıcı kapalıyken tarayıcının kendi ayarlarından temizlemek tercih edilir."
}

$firefoxProfiles = Join-Path $env:APPDATA "Mozilla\Firefox\Profiles"
if (Test-Path -LiteralPath $firefoxProfiles) {
    Get-ChildItem -LiteralPath $firefoxProfiles -Directory -Force |
        ForEach-Object {
            $cachePath = Join-Path $_.FullName "cache2"
            Measure-And-Add `
                -Category "Tarayıcı önbelleği" `
                -Item ("Firefox önbelleği — " + $_.Name) `
                -Path $cachePath `
                -Risk "Genellikle güvenli" `
                -Recommendation "Firefox kapalıyken tarayıcı ayarlarından temizlemek tercih edilir."
        }
}

# VS Code ve geliştirici önbellekleri
$developerFolders = @(
    @{
        Item = "VS Code Cache"
        Path = (Join-Path $env:APPDATA "Code\Cache")
        Risk = "Genellikle güvenli"
        Recommendation = "VS Code kapalıyken temizlenebilir; ilk açılış biraz yavaşlayabilir."
    },
    @{
        Item = "VS Code CachedData"
        Path = (Join-Path $env:APPDATA "Code\CachedData")
        Risk = "Genellikle güvenli"
        Recommendation = "VS Code kapalıyken temizlenebilir."
    },
    @{
        Item = "VS Code Code Cache"
        Path = (Join-Path $env:APPDATA "Code\Code Cache")
        Risk = "Genellikle güvenli"
        Recommendation = "VS Code kapalıyken temizlenebilir."
    },
    @{
        Item = "npm önbelleği"
        Path = (Join-Path $env:LOCALAPPDATA "npm-cache")
        Risk = "Paket yöneticisiyle temizle"
        Recommendation = "npm cache verify veya gerekirse npm cache clean --force kullan."
    },
    @{
        Item = "pnpm deposu"
        Path = (Join-Path $env:LOCALAPPDATA "pnpm\store")
        Risk = "Paket yöneticisiyle temizle"
        Recommendation = "pnpm store prune kullan."
    },
    @{
        Item = "Yarn önbelleği"
        Path = (Join-Path $env:LOCALAPPDATA "Yarn\Cache")
        Risk = "Paket yöneticisiyle temizle"
        Recommendation = "yarn cache clean kullan."
    },
    @{
        Item = "pip önbelleği"
        Path = (Join-Path $env:LOCALAPPDATA "pip\Cache")
        Risk = "Paket yöneticisiyle temizle"
        Recommendation = "py -m pip cache purge kullan."
    },
    @{
        Item = "NuGet paket önbelleği"
        Path = (Join-Path $env:USERPROFILE ".nuget\packages")
        Risk = "İncele"
        Recommendation = "Paketler gerektiğinde yeniden indirilir; dotnet nuget locals all --clear tercih edilir."
    },
    @{
        Item = "Gradle önbelleği"
        Path = (Join-Path $env:USERPROFILE ".gradle\caches")
        Risk = "İncele"
        Recommendation = "Aktif Java/Android projelerin yoksa veya yeniden indirmeyi kabul ediyorsan temizlenebilir."
    },
    @{
        Item = "Maven yerel deposu"
        Path = (Join-Path $env:USERPROFILE ".m2\repository")
        Risk = "İncele"
        Recommendation = "Bağımlılıklar yeniden indirilir; aktif projeleri göz önünde bulundur."
    },
    @{
        Item = "Cargo kayıt önbelleği"
        Path = (Join-Path $env:USERPROFILE ".cargo\registry")
        Risk = "İncele"
        Recommendation = "Rust bağımlılıkları yeniden indirilebilir; doğrudan silmeden önce projelerini kontrol et."
    },
    @{
        Item = "VS Code eklentileri"
        Path = (Join-Path $env:USERPROFILE ".vscode\extensions")
        Risk = "Elle silme"
        Recommendation = "Bu klasörü doğrudan silme; kullanmadığın eklentileri VS Code içinden kaldır."
    }
)

if ($GelistiriciTaramasi) {
    foreach ($folder in $developerFolders) {
        Measure-And-Add `
            -Category "Geliştirici araçları" `
            -Item $folder.Item `
            -Path $folder.Path `
            -Risk $folder.Risk `
            -Recommendation $folder.Recommendation
    }
}
else {
    Write-Host "Geliştirici önbellekleri bu tarama modelinde atlandı." -ForegroundColor DarkGray
}

# Docker ve WSL sanal diskleri — yalnızca dosya boyutu raporlanır.
$specialFiles = @(
    @{
        Category = "Docker/WSL"
        Item = "Docker Desktop sanal diski"
        Path = (Join-Path $env:LOCALAPPDATA "Docker\wsl\data\ext4.vhdx")
        Risk = "Kesinlikle elle silme"
        Recommendation = "Docker Desktop içindeki temizleme seçeneklerini veya docker system df/prune komutlarını kontrollü kullan."
    },
    @{
        Category = "Bellek dökümleri"
        Item = "Windows bellek dökümü"
        Path = (Join-Path $env:WINDIR "MEMORY.DMP")
        Risk = "İncele"
        Recommendation = "Hata ayıklama gerekmiyorsa Windows Depolama veya Disk Temizleme ile kaldırılabilir."
    },
    @{
        Category = "Uyku dosyası"
        Item = "Hazırda bekletme dosyası"
        Path = (Join-Path $env:SystemDrive "hiberfil.sys")
        Risk = "Elle silme"
        Recommendation = "Hazırda bekletmeyi kullanmıyorsan yönetici terminalinde powercfg /hibernate off komutuyla kaldırılabilir."
    }
)

foreach ($file in $specialFiles) {
    if (Test-Path -LiteralPath $file.Path) {
        $item = Get-Item -LiteralPath $file.Path -Force
        Add-Finding `
            -Category $file.Category `
            -Item $file.Item `
            -Path $file.Path `
            -SizeBytes ([int64]$item.Length) `
            -Risk $file.Risk `
            -Recommendation $file.Recommendation
    }
}

# Büyük dosyalar
Write-Host ""
Write-Host "Büyük dosyalar aranıyor..." -ForegroundColor Cyan

$knownFolders = @(
    [Environment]::GetFolderPath("Desktop"),
    [Environment]::GetFolderPath("MyDocuments"),
    [Environment]::GetFolderPath("MyPictures"),
    [Environment]::GetFolderPath("MyVideos"),
    [Environment]::GetFolderPath("MyMusic"),
    (Join-Path $env:USERPROFILE "Downloads")
) |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and (Test-Path -LiteralPath $_) } |
    Select-Object -Unique

if ($DerinTarama) {
    $largeFileRoots = @($env:USERPROFILE)
}
elseif ($HizliTarama) {
    $largeFileRoots = @(
        [Environment]::GetFolderPath("Desktop"),
        (Join-Path $env:USERPROFILE "Downloads")
    ) |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and (Test-Path -LiteralPath $_) } |
        Select-Object -Unique
}
else {
    $largeFileRoots = @($knownFolders)
}

$allCandidateFiles = foreach ($root in $largeFileRoots) {
    Get-SafeRecursiveFiles -Root $root -ExcludePaths @($RaporKlasoru)
}

$largeFiles = $allCandidateFiles |
    Sort-Object -Property Length -Descending |
    Select-Object -First $BuyukDosyaSayisi |
    ForEach-Object {
        [pscustomobject]@{
            Dosya = $_.Name
            Yol = $_.FullName
            Boyut = Get-FriendlySize $_.Length
            BoyutBayt = [int64]$_.Length
            SonDegisiklik = $_.LastWriteTime
        }
    }

# Eski İndirilenler dosyaları
$downloadsPath = Join-Path $env:USERPROFILE "Downloads"
$oldDownloads = @()
if (Test-Path -LiteralPath $downloadsPath) {
    $cutoff = (Get-Date).AddDays(-$EskiDosyaGunu)

    $oldDownloads = Get-SafeRecursiveFiles -Root $downloadsPath -ExcludePaths @($RaporKlasoru) |
        Where-Object { $_.LastWriteTime -lt $cutoff } |
        Sort-Object -Property Length -Descending |
        ForEach-Object {
            [pscustomobject]@{
                Dosya = $_.Name
                Yol = $_.FullName
                Boyut = Get-FriendlySize $_.Length
                BoyutBayt = [int64]$_.Length
                SonDegisiklik = $_.LastWriteTime
            }
        }

    $oldDownloadBytes = ($oldDownloads | Measure-Object -Property BoyutBayt -Sum).Sum
    if ($null -eq $oldDownloadBytes) { $oldDownloadBytes = 0 }

    Add-Finding `
        -Category "Kullanıcı dosyaları" `
        -Item ("İndirilenler klasöründe {0} günden eski dosyalar ({1} adet)" -f $EskiDosyaGunu, @($oldDownloads).Count) `
        -Path $downloadsPath `
        -SizeBytes ([int64]$oldDownloadBytes) `
        -Risk "İncele" `
        -Recommendation "Silmeden önce listedeki dosyaları tek tek kontrol et."
}

# Başlangıç uygulamaları
$startupItems = New-Object "System.Collections.Generic.List[object]"
$runKeys = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"
)

foreach ($key in $runKeys) {
    if (Test-Path $key) {
        $properties = Get-ItemProperty -Path $key -ErrorAction SilentlyContinue
        foreach ($property in $properties.PSObject.Properties) {
            if ($property.Name -notmatch "^PS(Path|ParentPath|ChildName|Drive|Provider)$") {
                $startupItems.Add([pscustomobject]@{
                    Kaynak = $key
                    Ad = $property.Name
                    Komut = [string]$property.Value
                }) | Out-Null
            }
        }
    }
}

$startupFolders = @(
    [Environment]::GetFolderPath("Startup"),
    [Environment]::GetFolderPath("CommonStartup")
) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and (Test-Path -LiteralPath $_) }

foreach ($folder in $startupFolders) {
    Get-ChildItem -LiteralPath $folder -Force |
        ForEach-Object {
            $startupItems.Add([pscustomobject]@{
                Kaynak = $folder
                Ad = $_.Name
                Komut = $_.FullName
            }) | Out-Null
        }
}

# Yüklü uygulamalar
$installedApps = @()

if ($KuruluUygulamaTaramasi) {
    Write-Host "Yüklü uygulamalar listeleniyor..." -ForegroundColor Cyan

    $uninstallKeys = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    $installedApps = foreach ($key in $uninstallKeys) {
        Get-ItemProperty -Path $key -ErrorAction SilentlyContinue |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_.DisplayName) } |
            ForEach-Object {
                $estimatedBytes = if ($_.EstimatedSize) { [int64]$_.EstimatedSize * 1KB } else { [int64]0 }

                [pscustomobject]@{
                    Uygulama = $_.DisplayName
                    Surum = $_.DisplayVersion
                    Yayinci = $_.Publisher
                    TahminiBoyut = Get-FriendlySize $estimatedBytes
                    TahminiBoyutBayt = $estimatedBytes
                    KurulumTarihi = $_.InstallDate
                    KaldirmaKomutu = $_.UninstallString
                }
            }
    }

    $installedApps = $installedApps |
        Sort-Object -Property Uygulama, Surum -Unique
}
else {
    Write-Host "Yüklü uygulamalar bu tarama modelinde atlandı." -ForegroundColor DarkGray
}

# CSV çıktıları
# Uzun taramalarda masaüstü senkronizasyonu veya başka bir süreç klasörü
# kaldırmış olabilir. Çıktı yazmadan hemen önce tekrar doğrula/oluştur.
try {
    $RaporKlasoru = Ensure-ReportFolder -PreferredPath $RaporKlasoru
}
catch {
    Write-Error $_.Exception.Message
    exit 3
}
$findings |
    Sort-Object -Property BoyutBayt -Descending |
    Export-Csv -Path (Join-Path $RaporKlasoru "Temizlik-Adaylari.csv") -NoTypeInformation -Encoding UTF8

$largeFiles |
    Export-Csv -Path (Join-Path $RaporKlasoru "Buyuk-Dosyalar.csv") -NoTypeInformation -Encoding UTF8

$oldDownloads |
    Export-Csv -Path (Join-Path $RaporKlasoru "Eski-Indirilenler.csv") -NoTypeInformation -Encoding UTF8

$startupItems |
    Export-Csv -Path (Join-Path $RaporKlasoru "Baslangic-Uygulamalari.csv") -NoTypeInformation -Encoding UTF8

$installedApps |
    Sort-Object -Property TahminiBoyutBayt -Descending |
    Export-Csv -Path (Join-Path $RaporKlasoru "Yuklu-Uygulamalar.csv") -NoTypeInformation -Encoding UTF8

# HTML raporu
$elapsed = (Get-Date) - $startTime
$totalCandidateBytes = ($findings | Measure-Object -Property BoyutBayt -Sum).Sum
if ($null -eq $totalCandidateBytes) { $totalCandidateBytes = 0 }

$topFindings = $findings |
    Sort-Object -Property BoyutBayt -Descending |
    Select-Object -First 50 Kategori, Oge, Yol, Boyut, Durum, Oneri

$largeFileView = $largeFiles |
    Select-Object Dosya, Yol, Boyut, SonDegisiklik

$oldDownloadsView = $oldDownloads |
    Select-Object -First 100 Dosya, Yol, Boyut, SonDegisiklik

$appsView = $installedApps |
    Sort-Object -Property TahminiBoyutBayt -Descending |
    Select-Object -First 100 Uygulama, Surum, Yayinci, TahminiBoyut, KurulumTarihi

$style = @"
<meta charset="utf-8">
<style>
body {
    font-family: "Segoe UI", Arial, sans-serif;
    margin: 32px;
    background: #f5f7fa;
    color: #1f2937;
}
h1, h2 { color: #111827; }
.card {
    background: white;
    border: 1px solid #dbe2ea;
    border-radius: 10px;
    padding: 18px;
    margin: 16px 0;
    box-shadow: 0 2px 8px rgba(0,0,0,.04);
}
.notice {
    background: #ecfdf5;
    border-left: 5px solid #10b981;
    padding: 14px;
    border-radius: 6px;
}
.warning {
    background: #fff7ed;
    border-left: 5px solid #f97316;
    padding: 14px;
    border-radius: 6px;
}
table {
    border-collapse: collapse;
    width: 100%;
    background: white;
    font-size: 13px;
}
th, td {
    border: 1px solid #dbe2ea;
    padding: 8px;
    text-align: left;
    vertical-align: top;
}
th {
    background: #eaf0f7;
    position: sticky;
    top: 0;
}
tr:nth-child(even) { background: #f9fafb; }
.small { color: #6b7280; font-size: 12px; }
</style>
"@

$systemHtml = $systemInfo | ConvertTo-Html -Fragment
$drivesHtml = $drives | ConvertTo-Html -Fragment
$findingsHtml = $topFindings | ConvertTo-Html -Fragment
$largeFilesHtml = $largeFileView | ConvertTo-Html -Fragment
$oldDownloadsHtml = if (@($oldDownloadsView).Count -gt 0) {
    $oldDownloadsView | ConvertTo-Html -Fragment
} else {
    "<p>Belirlenen yaştan eski dosya bulunamadı.</p>"
}
$startupHtml = if ($startupItems.Count -gt 0) {
    $startupItems | ConvertTo-Html -Fragment
} else {
    "<p>Başlangıç girdisi bulunamadı.</p>"
}
$appsHtml = if (@($appsView).Count -gt 0) {
    $appsView | ConvertTo-Html -Fragment
}
else {
    "<p>Yüklü uygulamalar bu tarama modelinde taranmadı veya uygulama bulunamadı.</p>"
}

$htmlBody = @"
<h1>Bilgisayar Temizlik Taraması</h1>

<div class="notice">
<strong>Salt okunur tarama:</strong> Bu betik hiçbir dosyayı silmedi ve hiçbir sistem ayarını değiştirmedi.
</div>

<div class="card">
<h2>Özet</h2>
<p><strong>Raporlanan toplam alan:</strong> $(Get-FriendlySize $totalCandidateBytes)</p>
<p><strong>Tarama süresi:</strong> $([math]::Round($elapsed.TotalMinutes, 1)) dakika</p>
<p><strong>Tarama tarihi:</strong> $(Get-Date -Format "dd.MM.yyyy HH:mm:ss")</p>
<p class="small">Bu toplamın tamamı silinebilir alan değildir. Bazı öğeler yalnızca inceleme amacıyla raporlanmıştır.</p>
</div>

<div class="card">
<h2>Sistem bilgileri</h2>
$systemHtml
</div>

<div class="card">
<h2>Diskler</h2>
$drivesHtml
</div>

<div class="warning">
<strong>Önemli:</strong> “Elle silme” veya “Kesinlikle elle silme” olarak işaretlenen öğeleri doğrudan kaldırma.
İlgili Windows, Docker veya paket yöneticisi aracını kullan.
</div>

<div class="card">
<h2>Temizlik ve inceleme adayları</h2>
$findingsHtml
</div>

<div class="card">
<h2>En büyük dosyalar</h2>
$largeFilesHtml
</div>

<div class="card">
<h2>İndirilenler klasöründeki eski dosyalar</h2>
$oldDownloadsHtml
</div>

<div class="card">
<h2>Başlangıç uygulamaları</h2>
$startupHtml
</div>

<div class="card">
<h2>Boyuta göre yüklü uygulamalar</h2>
$appsHtml
<p class="small">Bazı uygulamalar boyut bilgisini Windows kayıt defterine yazmadığı için 0 B görünebilir.</p>
</div>
"@

try {
    $RaporKlasoru = Ensure-ReportFolder -PreferredPath $RaporKlasoru
}
catch {
    Write-Error $_.Exception.Message
    exit 3
}

$reportPath = Join-Path $RaporKlasoru "Bilgisayar-Temizlik-Raporu.html"
ConvertTo-Html -Title "Bilgisayar Temizlik Taraması" -Head $style -Body $htmlBody |
    Out-File -FilePath $reportPath -Encoding UTF8

Write-Host ""
Write-Host "Tarama tamamlandı." -ForegroundColor Green
Write-Host ("Rapor: {0}" -f $reportPath) -ForegroundColor Yellow
Write-Host ("Toplam raporlanan alan: {0}" -f (Get-FriendlySize $totalCandidateBytes)) -ForegroundColor Yellow
Write-Host ""
Write-Host "En büyük 5 inceleme adayı:" -ForegroundColor Cyan

$findings |
    Sort-Object -Property BoyutBayt -Descending |
    Select-Object -First 5 |
    ForEach-Object {
        Write-Host ("- {0}: {1} [{2}]" -f $_.Oge, $_.Boyut, $_.Durum)
    }

Write-Host ""
Write-Host "HTML raporu açılıyor..." -ForegroundColor DarkCyan
try {
    Start-Process -FilePath $reportPath -ErrorAction Stop
}
catch {
    Write-Warning "HTML raporu otomatik açılamadı. Aşağıdaki dosyayı elle açabilirsin:"
    Write-Host $reportPath -ForegroundColor Yellow
}

exit 0

### POWERSHELL_PAYLOAD_END ###
