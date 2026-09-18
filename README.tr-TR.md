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
| `src/cleanliness-scan.bat` | Dosya silmeden tarama yapar ve HTML/CSV raporları üretir. | Tam kapsam için gerekli |
| `src/manage-right-click-menu.bat` | Windows 11 klasik/varsayılan sağ tık menüsü arasında geçiş yapar. | Gerekli değil |

## Gereksinimler

- Windows 10 veya Windows 11 (bazı özellikler yalnızca Windows 11 içindir)
- PowerShell kullanan işlemler için Windows PowerShell 5.1
- Yukarıdaki tabloda belirtilen araçlar için yönetici yetkisi
- UTF-8 destekleyen Windows konsolu

## Kullanım

1. Depoyu indirin veya klonlayın.
2. Çalıştıracağınız `src/` altındaki scriptin içeriğini inceleyin.
3. Yönetici yetkisi gereken dosyalarda `src/` altındaki ilgili `.bat` dosyasına sağ tıklayıp **Yönetici olarak çalıştır** seçeneğini kullanın.
4. Menüdeki uyarıları okuyun ve özellikle kalıcı silme işlemlerini onaylamadan önce hedefi kontrol edin.

## Önemli güvenlik notları

- `src/clean-onedrive.bat` içinde algılanan yerel OneDrive kullanıcı klasörünü kalıcı olarak silen bir seçenek bulunur.
- `src/clean-winsxs.bat` içindeki DISM `/ResetBase` işleminden sonra yüklü Windows güncellemeleri kaldırılamaz.
- `src/clean-network-optimization.bat` proxy, TCP/IP, Winsock, DNS ve ağ adaptörü ayarlarını değiştirebilir/sıfırlayabilir. Kurumsal ağ, VPN veya statik IP ayarlarının yeniden yapılandırılması gerekebilir.
- `src/clean-pc.bat` geçici dosyaları, bazı önbellekleri ve Geri Dönüşüm Kutusu içeriğini silebilir.

Önemli sistemlerde kullanmadan önce uygun bir yedek veya sistem geri yükleme noktası oluşturmanız önerilir. Scriptleri çalıştırmadan önce kaynak kodunu inceleyin.

## Sürüm

İlk genel sürüm: **1.0.0**

Her aracın sürümü `src/` altındaki kendi dosyasındaki `VERSION` değişkeninden yönetilir.

## Lisans

MIT License. Ayrıntılar için [LICENSE](LICENSE) dosyasına bakın.
