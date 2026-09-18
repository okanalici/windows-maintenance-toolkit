@echo off
chcp 65001 >nul
setlocal EnableExtensions

:: ANSI Renk kodlarini kullanabilmek icin ESC karakterini tanimliyoruz
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

set "VERSION=1.0.0"
set "CONSOLE_COLS=86"
set "CONSOLE_LINES=50"
title Genel Ag Onarim ve Optimizasyon Araci v%VERSION%
color 0F

:: Proxy yedegi repo klasoruna degil, kullanicinin gecici klasorune yazilir.
set "PROXY_BACKUP=%TEMP%\windows_maintenance_proxy_backup.reg"

:: Yonetici yetkisi kontrolu
:: Konsol görünümü yetki kontrolünden bağımsızdır.
:: Böylece araç normal veya yönetici olarak açıldığında aynı kalın/kompakt tasarımla başlar.
call :KonsolBaslangic

call :YoneticiKontrol
if errorlevel 1 exit /b

:Menu
call :EkranYenile
call :ArayuzBaslik "GENEL AĞ ONARIM VE OPTİMİZASYON"
call :BilgiKutusu "  DNS, proxy, adaptör ve TCP/IP sorunlarını onarır."
call :MenuKutusu "1" "AĞ BİLGİLERİ" "  IP, DNS, ağ geçidi ve MAC bilgilerini gösterir."
call :MenuKutusu "2" "BAĞLANTI TESTİ" "  8.8.8.8 adresine dört ping gönderir."
call :MenuKutusu "3" "DNS ÖNBELLEĞİ" "  Windows DNS çözümleme önbelleğini temizler."
call :MenuKutusu "4" "HIZLI DNS" "  Cloudflare, Google veya DHCP DNS uygular."
call :MenuKutusu "5" "PROXY SIFIRLAMA" "  WinHTTP ve kullanıcı proxy ayarlarını temizler."
call :MenuKutusu "6" "TCP/IP OPTİMİZASYONU" "  Auto-Tuning, ECN, Heuristics ve RSS ayarlarını düzenler."
call :MenuKutusu "7" "ADAPTÖR SIFIRLAMA" "  Aktif fiziksel adaptörleri kapatıp yeniden açar."
call :MenuKutusu "8" "TAM AĞ ONARIMI" "  IP, DNS, proxy, ARP, Winsock ve TCP/IP'yi sıfırlar."
call :MenuKutusu "0" "ÇIKIŞ" "  Aracı işlem yapmadan kapatır."
call :Ayirici
echo.

call :Secim "123456780" "Seçiminiz › "

if "%SECIM_SONUC%"=="9" goto Cikis
if "%SECIM_SONUC%"=="8" goto TamAgOnarimi
if "%SECIM_SONUC%"=="7" goto AdaptorSifirla
if "%SECIM_SONUC%"=="6" goto TcpIpOptimizasyonu
if "%SECIM_SONUC%"=="5" goto ProxySifirla
if "%SECIM_SONUC%"=="4" goto DnsDegistirici
if "%SECIM_SONUC%"=="3" goto DnsTemizle
if "%SECIM_SONUC%"=="2" goto BaglantiTesti
if "%SECIM_SONUC%"=="1" goto AgBilgileri
goto Menu

:BaglantiTesti
call :EkranYenile
call :IslemBaslik "BAĞLANTI TESTİ"
echo.
call :Bilgi "Google DNS adresine baglanti testi yapiliyor: 8.8.8.8"
echo.

ping 8.8.8.8 -n 4

if errorlevel 1 (
    call :Hata "Baglanti testi basarisiz oldu."
) else (
    call :Basarili "Baglanti testi basarili."
)

echo.
call :Ayirici
call :Bekle
goto Menu

:AgBilgileri
call :EkranYenile
call :IslemBaslik "IP VE MAC BİLGİLERİ"
echo.
call :Bilgi "Ag bilgileri listeleniyor..."
echo.

ipconfig /all

echo.
call :Basarili "Ag bilgileri listelendi."
echo.
call :Ayirici
call :Bekle
goto Menu

:ProxySifirla
call :EkranYenile
call :IslemBaslik "PROXY AYARLARINI SIFIRLA"
echo.
set "PROXY_HATA=0"
call :Bilgi "Proxy ayarlari yedekleniyor..."
reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" "%PROXY_BACKUP%" /y >nul 2>&1
if errorlevel 1 (
    set "PROXY_HATA=1"
    call :Hata "Proxy ayarlari yedeklenemedi. Kullanici proxy ayarlari degistirilmeyecek."
) else (
    call :Basarili "Proxy ayarlari yedeklendi."

    call :Bilgi "Kullanici proxy ayari kapatiliyor..."
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f >nul 2>&1
    if errorlevel 1 (
        set "PROXY_HATA=1"
        call :Hata "Kullanici proxy ayari kapatilamadi."
    ) else (
        call :Basarili "Kullanici proxy ayari kapatildi."
    )

    call :RegDegerSilIfExists "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" "ProxyServer"
    if errorlevel 1 set "PROXY_HATA=1"
    call :RegDegerSilIfExists "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" "ProxyOverride"
    if errorlevel 1 set "PROXY_HATA=1"
    call :RegDegerSilIfExists "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" "AutoConfigURL"
    if errorlevel 1 set "PROXY_HATA=1"
)

call :Bilgi "WinHTTP proxy sifirlaniyor..."
netsh winhttp reset proxy >nul 2>&1
if errorlevel 1 (
    set "PROXY_HATA=1"
    call :Hata "WinHTTP proxy sifirlama basarisiz oldu."
) else (
    call :Basarili "WinHTTP proxy sifirlandi."
)

echo.
if "%PROXY_HATA%"=="1" (
    call :Hata "Proxy sifirlama kismen tamamlandi. Yukaridaki hata adimlarini kontrol edin."
) else (
    call :Basarili "Proxy sifirlama islemi basariyla tamamlandi."
)
echo.
call :Ayirici
call :Bekle
goto Menu

:DnsTemizle
call :EkranYenile
call :IslemBaslik "DNS ÖNBELLEĞİNİ TEMİZLE"
echo.
call :Bilgi "DNS onbellegi temizleniyor..."
ipconfig /flushdns >nul 2>&1

if errorlevel 1 (
    call :Hata "DNS onbellegi temizlenemedi."
) else (
    call :Basarili "DNS onbellegi temizlendi."
)

echo.
call :Ayirici
call :Bekle
goto Menu

:TamAgOnarimi
call :EkranYenile
call :IslemBaslik "TAM AĞ ONARIMI"
call :Uyari "İnternet bağlantısı geçici olarak kesilebilir."
call :Uyari "Statik IP, kurumsal proxy ve özel VPN ayarları etkilenebilir."
echo %ESC%[1;96m╔═ YAPILACAK İŞLEMLER ═════════════════════════════════════════╗%ESC%[0m
call :KutuSatiri "  IP, DNS, proxy, ARP, Winsock ve TCP/IP sıfırlanır."
echo %ESC%[1;96m╚══════════════════════════════════════════════════════════════╝%ESC%[0m
echo.

call :Secim "EH" "Devam etmek istiyor musunuz? [E/H]: "
if "%SECIM_SONUC%"=="2" (
    call :Uyari "Tam ağ onarımı iptal edildi."
    call :Bekle
    goto Menu
)

call :EkranYenile
call :IslemBaslik "TAM AĞ ONARIMI BAŞLADI"
echo.
set "AG_HATA=0"

call :Bilgi "IP adresi serbest birakiliyor..."
ipconfig /release >nul 2>&1
if errorlevel 1 (
    set "AG_HATA=1"
    call :Hata "IP adresi serbest birakilamadi."
) else (
    call :Basarili "IP adresi serbest birakildi."
)

call :Bilgi "DNS onbellegi temizleniyor..."
ipconfig /flushdns >nul 2>&1
if errorlevel 1 (
    set "AG_HATA=1"
    call :Hata "DNS onbellegi temizlenemedi."
) else (
    call :Basarili "DNS onbellegi temizlendi."
)

call :Bilgi "WinHTTP proxy ayarlari sifirlaniyor..."
netsh winhttp reset proxy >nul 2>&1
if errorlevel 1 (
    set "AG_HATA=1"
    call :Hata "WinHTTP proxy sifirlanamadi."
) else (
    call :Basarili "WinHTTP proxy sifirlandi."
)

call :Bilgi "Kullanici proxy ayarlari yedeklenip sifirlaniyor..."
reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" "%PROXY_BACKUP%" /y >nul 2>&1
if errorlevel 1 (
    set "AG_HATA=1"
    call :Hata "Kullanici proxy ayarlari yedeklenemedi; guvenlik icin HKCU proxy ayarlari degistirilmedi."
) else (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f >nul 2>&1
    if errorlevel 1 (
        set "AG_HATA=1"
        call :Hata "Kullanici proxy ayari kapatilamadi."
    ) else (
        call :Basarili "Kullanici proxy ayari kapatildi."
    )
    call :RegDegerSilIfExists "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" "ProxyServer"
    if errorlevel 1 (
        set "AG_HATA=1"
        call :Hata "ProxyServer degeri silinemedi."
    )
    call :RegDegerSilIfExists "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" "ProxyOverride"
    if errorlevel 1 (
        set "AG_HATA=1"
        call :Hata "ProxyOverride degeri silinemedi."
    )
    call :RegDegerSilIfExists "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" "AutoConfigURL"
    if errorlevel 1 (
        set "AG_HATA=1"
        call :Hata "AutoConfigURL degeri silinemedi."
    )
)

call :Bilgi "ARP onbellegi temizleniyor..."
arp -d * >nul 2>&1
if errorlevel 1 (
    set "AG_HATA=1"
    call :Hata "ARP onbellegi temizlenemedi."
) else (
    call :Basarili "ARP onbellegi temizlendi."
)

call :Bilgi "Winsock yapisi sifirlaniyor..."
netsh winsock reset >nul 2>&1
if errorlevel 1 (
    set "AG_HATA=1"
    call :Hata "Winsock yapisi sifirlanamadi."
) else (
    call :Basarili "Winsock yapisi sifirlandi."
)

call :Bilgi "TCP/IP yapisi sifirlaniyor..."
netsh int ip reset >nul 2>&1
if errorlevel 1 (
    set "AG_HATA=1"
    call :Hata "TCP/IP yapisi sifirlanamadi."
) else (
    call :Basarili "TCP/IP yapisi sifirlandi."
)

call :Bilgi "Yeni IP adresi aliniyor..."
ipconfig /renew >nul 2>&1
if errorlevel 1 (
    set "AG_HATA=1"
    call :Hata "Yeni IP adresi alinamadi."
) else (
    call :Basarili "Yeni IP adresi alindi."
)

echo.
if "%AG_HATA%"=="1" (
    call :Hata "Tam ag onarimi kismen tamamlandi. Bir veya daha fazla adim basarisiz oldu."
    call :Bilgi "Yukaridaki kirmizi hata satirlarini kontrol edin."
) else (
    call :Basarili "Tam ag onarimi basariyla tamamlandi."
)
call :Bilgi "Degisikliklerin tam uygulanmasi icin bilgisayari yeniden baslatmaniz onerilir."
echo.
call :Ayirici
call :Bekle
goto Menu

:TcpIpOptimizasyonu
call :EkranYenile
call :IslemBaslik "TCP/IP AĞ OPTİMİZASYONU"
echo.
call :Bilgi "TCP/IP performans ayarlari uygulaniyor..."
echo %ESC%[1;90m  Bu islem ozellikle oyunlarda paket kaybini azaltmak%ESC%[0m
echo %ESC%[1;90m  ve anlik ping sicramalarini onlemek icin yapilandirilir.%ESC%[0m
echo.

set "OPT_HATA=0"

call :Bilgi "Auto-Tuning seviyesi ayarlaniyor (normal)..."
netsh int tcp set global autotuninglevel=normal >nul 2>&1
if errorlevel 1 (
    call :Hata "Auto-Tuning ayarlanamadi."
    set "OPT_HATA=1"
) else (
    call :Basarili "Auto-Tuning: normal olarak ayarlandi."
)

call :Bilgi "ECN (Explicit Congestion Notification) kapatiliyor..."
netsh int tcp set global ecncapability=disabled >nul 2>&1
if errorlevel 1 (
    call :Hata "ECN kapatilamadi."
    set "OPT_HATA=1"
) else (
    call :Basarili "ECN kapatildi."
)

call :Bilgi "TCP Heuristics kapatiliyor..."
netsh int tcp set heuristics disabled >nul 2>&1
if errorlevel 1 (
    call :Hata "TCP Heuristics kapatilamadi."
    set "OPT_HATA=1"
) else (
    call :Basarili "TCP Heuristics kapatildi."
)

call :Bilgi "RSS (Receive Side Scaling) aktif ediliyor..."
netsh int tcp set global rss=enabled >nul 2>&1
if errorlevel 1 (
    call :Hata "RSS aktif edilemedi."
    set "OPT_HATA=1"
) else (
    call :Basarili "RSS aktif edildi."
)

echo.
if "%OPT_HATA%"=="1" (
    call :Hata "Bazi optimizasyon ayarlari uygulanamadi. Ekrandaki hata adimlarini kontrol edin."
) else (
    call :Basarili "Tum optimizasyon ayarlari basariyla uygulandi."
)

echo.
call :Ayirici
call :Bekle
goto Menu

:DnsDegistirici
call :EkranYenile
call :IslemBaslik "HIZLI DNS DEĞİŞTİRİCİ"
call :MenuKutusu "1" "CLOUDFLARE DNS" "  Düşük gecikme: 1.1.1.1 / 1.0.0.1"
call :MenuKutusu "2" "GOOGLE DNS" "  Genel kararlılık: 8.8.8.8 / 8.8.4.4"
call :MenuKutusu "3" "OTOMATİK DNS" "  DHCP tarafından sağlanan DNS ayarlarına döner."
call :MenuKutusu "0" "ANA MENÜ" "  Değişiklik yapmadan ana menüye döner."
call :Ayirici
echo.

call :Secim "1230" "Seçiminiz › "

if "%SECIM_SONUC%"=="4" goto Menu
if "%SECIM_SONUC%"=="3" goto DnsOtomatik
if "%SECIM_SONUC%"=="2" goto DnsGoogle
if "%SECIM_SONUC%"=="1" goto DnsCloudflare
goto DnsDegistirici

:DnsCloudflare
call :Bilgi "Cloudflare DNS aktif fiziksel adaptorlere ayarlaniyor..."
powershell -NoProfile -Command "$a=@(Get-NetAdapter -Physical | Where-Object {$_.Status -eq 'Up'}); if($a.Count -eq 0){exit 2}; $h=$false; foreach($i in $a){try{Set-DnsClientServerAddress -InterfaceIndex $i.ifIndex -ServerAddresses '1.1.1.1','1.0.0.1','2606:4700:4700::1111','2606:4700:4700::1001' -ErrorAction Stop}catch{$h=$true}}; if($h){exit 1}else{exit 0}" >nul 2>&1
set "DNS_SONUC=%ERRORLEVEL%"
goto DnsSonuc

:DnsGoogle
call :Bilgi "Google DNS aktif fiziksel adaptorlere ayarlaniyor..."
powershell -NoProfile -Command "$a=@(Get-NetAdapter -Physical | Where-Object {$_.Status -eq 'Up'}); if($a.Count -eq 0){exit 2}; $h=$false; foreach($i in $a){try{Set-DnsClientServerAddress -InterfaceIndex $i.ifIndex -ServerAddresses '8.8.8.8','8.8.4.4','2001:4860:4860::8888','2001:4860:4860::4444' -ErrorAction Stop}catch{$h=$true}}; if($h){exit 1}else{exit 0}" >nul 2>&1
set "DNS_SONUC=%ERRORLEVEL%"
goto DnsSonuc

:DnsOtomatik
call :Bilgi "Aktif fiziksel adaptorlerin DNS ayarlari otomatige donduruluyor..."
powershell -NoProfile -Command "$a=@(Get-NetAdapter -Physical | Where-Object {$_.Status -eq 'Up'}); if($a.Count -eq 0){exit 2}; $h=$false; foreach($i in $a){try{Set-DnsClientServerAddress -InterfaceIndex $i.ifIndex -ResetServerAddresses -ErrorAction Stop}catch{$h=$true}}; if($h){exit 1}else{exit 0}" >nul 2>&1
set "DNS_SONUC=%ERRORLEVEL%"
goto DnsSonuc

:DnsSonuc
if "%DNS_SONUC%"=="2" (
    call :Hata "Aktif fiziksel ag adaptoru bulunamadi. VPN ve sanal adaptorler degistirilmedi."
) else if not "%DNS_SONUC%"=="0" (
    call :Hata "DNS ayarlari degistirilemedi."
) else (
    call :Basarili "DNS ayarlari basariyla degistirildi."
    call :Bilgi "Yeni ayarlarin devreye girmesi icin onbellek temizleniyor..."
    ipconfig /flushdns >nul 2>&1
)
echo.
call :Ayirici
call :Bekle
goto Menu

:AdaptorSifirla
call :EkranYenile
call :IslemBaslik "AĞ ADAPTÖRÜ SIFIRLAMA"
call :Uyari "Aktif fiziksel adaptörler kapatılıp yeniden açılacaktır."
call :Uyari "VPN ve sanal adaptörler işleme dahil edilmez."
call :Uyari "İnternet bağlantınız kısa süreliğine kesilecektir."
echo.

call :Secim "EH" "Devam etmek istiyor musunuz? [E/H]: "
if "%SECIM_SONUC%"=="2" (
    call :Uyari "Adaptör sıfırlama iptal edildi."
    call :Bekle
    goto Menu
)

call :EkranYenile
call :IslemBaslik "AĞ ADAPTÖRÜ SIFIRLAMA BAŞLADI"
echo.

set "AKTIF_ADAPTOR_LIST=%TEMP%\windows_maintenance_active_adapters_%RANDOM%.txt"
call :Bilgi "Yalnizca aktif fiziksel ag adaptorleri tespit ediliyor..."
powershell -NoProfile -Command "$a=@(Get-NetAdapter -Physical | Where-Object {$_.Status -eq 'Up'}); if($a.Count -eq 0){exit 2}; try{$a.Name | Set-Content -LiteralPath '%AKTIF_ADAPTOR_LIST%' -Encoding UTF8 -ErrorAction Stop; exit 0}catch{exit 1}" >nul 2>&1
set "ADAPTOR_LIST_SONUC=%ERRORLEVEL%"

if "%ADAPTOR_LIST_SONUC%"=="2" (
    call :Hata "Aktif fiziksel ag adaptoru bulunamadi. VPN ve sanal adaptorler isleme alinmadi."
    del /f /q "%AKTIF_ADAPTOR_LIST%" >nul 2>&1
    call :Bekle
    goto Menu
)

if not "%ADAPTOR_LIST_SONUC%"=="0" (
    call :Hata "Aktif fiziksel adaptor listesi olusturulamadi. Islem durduruldu."
    del /f /q "%AKTIF_ADAPTOR_LIST%" >nul 2>&1
    call :Bekle
    goto Menu
)

set "ADAPTOR_HATA=0"

call :Bilgi "Tespit edilen aktif fiziksel adaptorler devre disi birakiliyor..."
powershell -NoProfile -Command "$h=$false; Get-Content -LiteralPath '%AKTIF_ADAPTOR_LIST%' | Where-Object {$_.Trim()} | ForEach-Object {try{Disable-NetAdapter -Name $_ -Confirm:$false -ErrorAction Stop}catch{$h=$true}}; if($h){exit 1}else{exit 0}" >nul 2>&1
if errorlevel 1 (
    set "ADAPTOR_HATA=1"
    call :Hata "Ag adaptorleri devre disi birakilamadi."
) else (
    call :Basarili "Ag adaptorleri devre disi birakildi."
)

call :Bilgi "3 saniye bekleniyor..."
timeout /t 3 >nul

call :Bilgi "Islem oncesinde aktif olan adaptorler tekrar aktif ediliyor..."
powershell -NoProfile -Command "$h=$false; Get-Content -LiteralPath '%AKTIF_ADAPTOR_LIST%' | Where-Object {$_.Trim()} | ForEach-Object {try{Enable-NetAdapter -Name $_ -Confirm:$false -ErrorAction Stop}catch{$h=$true}}; if($h){exit 1}else{exit 0}" >nul 2>&1
set "ADAPTOR_ACMA_SONUC=%ERRORLEVEL%"
del /f /q "%AKTIF_ADAPTOR_LIST%" >nul 2>&1
if not "%ADAPTOR_ACMA_SONUC%"=="0" (
    set "ADAPTOR_HATA=1"
    call :Hata "Ag adaptorleri aktif edilemedi."
) else (
    call :Basarili "Ag adaptorleri aktif edildi."
)

call :Bilgi "Baglanti stabilize ediliyor (5 saniye)..."
timeout /t 5 >nul

echo.
if "%ADAPTOR_HATA%"=="1" (
    call :Hata "Ag adaptoru sifirlama islemi kismen tamamlandi."
) else (
    call :Basarili "Ag adaptoru sifirlama tamamlandi."
)
echo.
call :Ayirici
call :Bekle
goto Menu

:Cikis
call :EkranYenile
call :Bilgi "Genel Ag Onarim ve Optimizasyon Araci v%VERSION% kapatiliyor..."
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

:RegDegerSilIfExists
reg query "%~1" /v "%~2" >nul 2>&1
if errorlevel 1 exit /b 0
reg delete "%~1" /v "%~2" /f >nul 2>&1
if errorlevel 1 exit /b 1
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

:Uyari
echo %ESC%[1;93m  [!] %~1%ESC%[0m
exit /b

