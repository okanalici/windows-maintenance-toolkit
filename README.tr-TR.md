# Windows Maintenance Toolkit

Windows bakım, temizlik, tanılama, ağ onarımı, OneDrive kaldırma, WinSxS bakımı ve Windows 11 ayarları için hazırlanmış etkileşimli Batch araçları koleksiyonudur.

## Dahil edilen araçlar

| Araç | Görev | Yönetici |
|---|---|---|
| `src/clean-amd-cache.bat` | AMD/DirectX/Vulkan shader önbelleklerini temizler. | Gerekli |
| `src/clean-network-optimization.bat` | Ağ bilgileri, DNS, proxy, adaptör, TCP/IP onarım ve ayar araçları sunar. | Gerekli |
| `src/clean-onedrive.bat` | OneDrive bileşenlerini kaldırır; istenirse yerel OneDrive kullanıcı klasörünü de siler. | Gerekli |
| `src/clean-pc.bat` | Otomatik, manuel ve önizleme modlarıyla Windows temizliği yapar. | Gerekli |
| `src/clean-winsxs.bat` | DISM/SFC ile bileşen deposu analizi, onarımı ve temizliği yapar. | Gerekli |
| `src/cleanliness-scan.bat` | Dosya silmeden tarama yapar ve HTML/CSV raporları üretir. | Gerekli |
| `src/manage-right-click-menu.bat` | Windows 11 klasik/varsayılan sağ tık menüsü arasında geçiş yapar. | Gerekli değil |

## Gereksinimler

- Windows 10 veya Windows 11 (bazı özellikler yalnızca Windows 11 içindir)
- PowerShell kullanan işlemler için Windows PowerShell 5.1
- Yukarıdaki tabloda belirtilen araçlar için yönetici yetkisi
- UTF-8 ve ANSI kaçış dizilerini destekleyen Windows Komut İstemi (`cmd.exe`)

## Kullanım

1. Depoyu indirin veya klonlayın.
2. Çalıştıracağınız `src/` altındaki scriptin içeriğini inceleyin.
3. Yönetici yetkisi gereken dosyalarda `src/` altındaki ilgili `.bat` dosyasına sağ tıklayıp **Yönetici olarak çalıştır** seçeneğini kullanın.
4. Menüdeki uyarıları okuyun ve özellikle kalıcı silme işlemlerini onaylamadan önce hedefi kontrol edin.

## Önemli güvenlik notları

- `src/clean-onedrive.bat` içinde algılanan yerel OneDrive kullanıcı klasörünü kalıcı olarak silen bir seçenek bulunur.
- `src/clean-winsxs.bat` içindeki DISM `/ResetBase` işleminden sonra yüklü Windows güncellemeleri kaldırılamaz.
- `src/clean-network-optimization.bat` proxy, TCP/IP, Winsock, DNS ve ağ adaptörü ayarlarını değiştirebilir/sıfırlayabilir. Kurumsal ağ, VPN veya statik IP ayarlarının yeniden yapılandırılması gerekebilir.
- `src/clean-pc.bat` geçici dosyaları, güncelleme verilerini, bazı önbellekleri, `Windows.old` klasörünü ve Geri Dönüşüm Kutusu içeriğini silebilir. Otomatik mod bir kez onay ister; ardından temizlik adımlarını ayrı ayrı onay almadan çalıştırır.
- `src/manage-right-click-menu.bat` yalnızca geçerli kullanıcının `HKCU` ayarlarını değiştirir ve başarılı değişiklikten sonra Explorer'ı hemen yeniden başlatır. Menüdeki **2** seçeneği varsayılan Windows 11 sağ tık menüsünü geri yükler.
- `src/cleanliness-scan.bat` taranan dosyaları silmez ve sistem ayarlarını değiştirmez; ancak HTML/CSV raporları yazar ve HTML raporunu açar. Raporlar Masaüstündeki `Bilgisayar-Tarama-Raporu` klasörüne kaydedilir. Masaüstü yolu bulunamazsa çalışma dizini kullanılır; seçilen klasör kullanılamazsa sırasıyla `%LOCALAPPDATA%` ve `%TEMP%` denenir. Raporlar kişisel yolları, yüklü uygulamaları ve başlangıç girdilerini içerebilir; paylaşmadan önce hassas bilgileri kaldırın.

Önemli sistemlerde kullanmadan önce uygun bir yedek veya sistem geri yükleme noktası oluşturmanız önerilir. Scriptleri çalıştırmadan önce kaynak kodunu inceleyin.

## Sürüm

İlk genel sürüm: **1.0.0**

Her aracın sürümü `src/` altındaki kendi dosyasındaki `VERSION` değişkeninden yönetilir.

## Güvenlik

Güvenlik açığı bildirimleri için [SECURITY.md](SECURITY.md) dosyasına bakın.

## İngilizce dokümantasyon

[README.md](README.md) dosyasına bakın.

## Lisans

MIT License. Ayrıntılar için [LICENSE](LICENSE) dosyasına bakın.
