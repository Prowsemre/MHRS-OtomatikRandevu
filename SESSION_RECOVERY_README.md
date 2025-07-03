# MHRS Otomatik Randevu Bot - Session Recovery Update

## 🔄 Session Recovery (Oturum Kurtarma) Sistemi

Bu güncelleme ile bot artık **MHRS session expiration (LGN2001) hatalarını otomatik olarak çözebilir**!

### ✅ Çözülen Problemler

- **LGN2001 Hatası**: "Başka yerden giriş yaptığınızdan oturum sonlanmıştır" hatası artık bot'u durdurmaz
- **Manuel Müdahale**: Artık session dolduğunda manuel restart gerekmiyor
- **Sürekli Çalışma**: Bot 7/24 kesintisiz çalışabilir

### 🆕 Yeni Özellikler

#### 1. Otomatik Session Recovery
- Session dolduğunda otomatik olarak fresh login yapar
- Eski token'ları temizler ve yeni token alır
- Başarısız request'leri otomatik olarak tekrar dener

#### 2. Comprehensive Error Handling
- Session expiration tüm API çağrılarında yakalanır:
  - Province/District listesi alma
  - Slot arama
  - Randevu alma
- Her aşamada session recovery desteği

#### 3. Detaylı Logging ve Bildirimler
- Session recovery durumları log dosyasına kaydedilir
- Telegram ile recovery durumu bildirimleri gönderilir
- Debug modunda tüm HTTP request/response detayları görünür

#### 4. Robust Token Management
- Token cache'i otomatik temizlenir
- Authorization header'lar düzgün yönetilir
- Fresh login için proper header temizliği

### 📋 Kullanım

#### Hızlı Başlatma (Önerilen)
```bash
# Windows için
start_bot_with_recovery.bat

# Linux/Ubuntu için
./start_bot_with_recovery.sh
```

#### Manuel Başlatma
```bash
cd MHRS-OtomatikRandevu
dotnet run
```

### 🔧 Session Recovery Nasıl Çalışır?

1. **Detection**: Bot HTTP 401 + LGN2001 hatası yakaladığında
2. **Clear State**: Eski token file'ı ve header'ları temizler
3. **Fresh Login**: Temiz bir login request gönderir
4. **Update Token**: Yeni token'ı günceller ve header'lara ekler
5. **Retry**: Başarısız olan request'i yeni token ile tekrar dener
6. **Notification**: Telegram ile recovery durumu bildirir

### 📊 Recovery İstatistikleri

Recovery işlemleri şu bilgilerle log edilir:
- Recovery başlama zamanı
- Recovery başarı/başarısızlık durumu
- Hangi API endpoint'inde sorun yaşandığı
- Retry durumları

### ⚙️ Konfigürasyon

Session recovery otomatik çalışır, ek konfigürasyon gerekmez. Mevcut `.env` dosyanız aynen kullanılabilir.

### 🔍 Troubleshooting

#### Session Recovery Başarısız Olursa
1. **TC/Şifre Kontrol**: `.env` dosyasındaki bilgileri kontrol edin
2. **Çoklu Giriş**: Başka yerden giriş yapmadığınızdan emin olun
3. **MHRS Bakım**: MHRS sistemi bakımda olabilir, daha sonra deneyin

#### Debug Modunu Açma
Bot otomatik olarak detaylı debug log'ları tutar. Log dosyası: `randevu_log.txt`

### 📈 Performance

- **Overhead**: Session recovery minimal performance etkisi yapar
- **Memory**: Token management optimize edildi
- **Network**: Sadece gerektiğinde fresh login yapılır

### 🛡️ Güvenlik

- Token'lar güvenli şekilde saklanır
- Eski token'lar otomatik temizlenir
- Login credentials '.env' dosyasında korunur

### 🐛 Bilinen Sınırlamalar

1. Eğer TC/şifre yanlışsa session recovery çalışmaz
2. MHRS sistemi tamamen down ise recovery de başarısız olur
3. Çok sık recovery gerekirse (>5 dakikada bir) manuel kontrol önerilir

### 📝 Değişiklik Log'u

#### v2.1 - Session Recovery Update
- ✅ SessionExpiredException sınıfı eklendi
- ✅ ClientService'e session detection eklendi
- ✅ Program.cs'e recovery logic eklendi
- ✅ Telegram bildirim entegrasyonu
- ✅ Comprehensive error handling
- ✅ Improved logging
- ✅ Auto-restart batch script

### 💡 İpuçları

1. **Sürekli Çalışma**: `start_bot_with_recovery.bat` kullanın
2. **Telegram Kurulumu**: Bildirimleri kaçırmamak için Telegram bot'unu kurun
3. **Log Takibi**: `randevu_log.txt` dosyasını periyodik kontrol edin
4. **Çoklu Instance**: Aynı anda sadece bir bot instance'ı çalıştırın

### 🆘 Destek

Session recovery ile ilgili sorunlarda:
1. `randevu_log.txt` dosyasını kontrol edin
2. Debug çıktılarını inceleyin
3. Telegram bildirimlerini takip edin

---

**Not**: Bu güncelleme bot'un daha stabil ve güvenilir çalışmasını sağlar. Artık MHRS session problemleri bot'u durdurmayacak!
