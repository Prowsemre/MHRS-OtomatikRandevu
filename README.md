![Banner](https://i.hizliresim.com/jv6ah3o.jpg)
# MHRS Otomatik Randevu Botu

MHRS kullanıcı bilgileriniz ile giriş yaptıktan sonra İl-İlçe-Klinik-Doktor gibi filtrelemeler yaparak aradığınız randevunun müsaitlik durumunu anlık olarak takip edebilir ve randevuyu otomatik olarak alabilirsiniz.

## 🚀 Özellikler

- ✅ **Tam Otomatik**: Randevu bulana kadar çalışır, başarılı olunca durur
- ✅ **Platform Bağımsız**: Windows ve Linux'ta çalışır
- ✅ **Güvenli**: .env dosyası ile güvenli parametre yönetimi
- ✅ **Telegram Bildirimleri**: Randevu durumu anlık bildirim
- ✅ **Loglama**: Tüm işlemleri detaylı loglama
- ✅ **Saat Kontrolü**: MHRS'in aktif olduğu saatlerde çalışır
- ✅ **Systemd Desteği**: Ubuntu'da servis olarak çalışır
- ✅ **GitHub Entegrasyonu**: Kolay kurulum ve güncelleme

## 📋 Gereksinimler

- .NET 7.0 SDK
- MHRS hesabı (TC kimlik + şifre)

## 🔧 Kurulum

### Windows'ta Hızlı Çalıştır
1. [.NET 7.0](https://dotnet.microsoft.com/en-us/download/dotnet/7.0) indirip kurun
2. `HizliCalistir` klasöründeki `MHRS-OtomatikRandevu.exe` dosyasını çalıştırın
3. Adımları takip edin

### Ubuntu Server'da Kurulum

#### Tek Komutla Kurulum (Önerilen)
```bash
curl -sSL https://raw.githubusercontent.com/TunahanDilercan/MHRS-OtomatikRandevu/main/install.sh | bash
```

#### Manuel Kurulum
```bash
# 1. Projeyi clone edin
git clone https://github.com/TunahanDilercan/MHRS-OtomatikRandevu.git
cd MHRS-OtomatikRandevu/MHRS-OtomatikRandevu

# 2. Kurulum scriptini çalıştırın
chmod +x ubuntu-setup.sh
./ubuntu-setup.sh

# 3. .env dosyasını düzenleyin
nano .env

# 4. Botu başlatın
sudo systemctl start mhrs-bot
```

## ⚙️ Konfigürasyon

`.env` dosyasını oluşturun ve ayarlarınızı girin:

```env
# MHRS Giriş Bilgileri
MHRS_TC=12345678901
MHRS_PASSWORD=your_password

# Lokasyon ID'leri (Programda görüntülenir)
MHRS_PROVINCE_ID=70         # İl ID
MHRS_DISTRICT_ID=1439       # İlçe ID (-1: Farketmez)
MHRS_CLINIC_ID=165          # Klinik ID
MHRS_HOSPITAL_ID=-1         # Hastane ID (-1: Farketmez)
MHRS_PLACE_ID=-1            # Muayene Yeri ID (-1: Farketmez)
MHRS_DOCTOR_ID=-1           # Doktor ID (-1: Farketmez)

# Tarih Ayarları
MHRS_START_DATE=2025-07-07  # Başlangıç tarihi (GG-AA-YYYY)

# Telegram Bildirimleri (Önerilen)
TELEGRAM_BOT_TOKEN=your_bot_token      # @BotFather'dan alın
TELEGRAM_CHAT_ID=your_chat_id          # @userinfobot'dan alın
TELEGRAM_NOTIFY_FREQUENCY=10           # Her kaç denemede bildirim (varsayılan: 10)
```

## 🎯 Kullanım

### Ubuntu'da Bot Yönetimi
```bash
# Bot durumunu kontrol et
./bot-manager.sh status

# Botu başlat
./bot-manager.sh start

# Botu durdur
./bot-manager.sh stop

# Canlı log takibi
./bot-manager.sh logs

# Bot log dosyasını göster
./bot-manager.sh botlogs

# Başarılı randevu bilgisini göster
./bot-manager.sh success
```

### Çalışma Saatleri
Bot aşağıdaki saatlerde aktif olarak randevu arar:
- **Saatlik**: Her saatin 57. dakikasından 4. dakikasına kadar
- **Gece**: 00:01-00:06, 01:59-02:03
- **Sabah**: 09:55-10:15
- **Akşam**: 19:55-20:15

## 📊 Log Takibi

### Sistem Logları
```bash
# Canlı log takibi
sudo journalctl -u mhrs-bot -f

# Son 100 log satırı
sudo journalctl -u mhrs-bot -n 100
```

### Bot Logları
```bash
# Bot log dosyası
tail -f randevu_log.txt

# Başarılı randevu bilgisi
cat randevu_basarili.txt
```

## 🔄 Otomatik Güncelleme

GitHub Actions ile otomatik deployment:
1. Kodu GitHub'a push edin
2. Actions otomatik olarak sunucuya deploy eder
3. Bot yeniden başlatılır

## 💡 İpuçları

- Bot randevu bulana kadar çalışır, başarılı olunca durur
- Tekrar başlatmak için önceki başarıyı onaylamanız gerekir
- Log dosyalarında tüm denemeler kaydedilir
- Sistem yeniden başladığında bot otomatik başlar

## 🔒 Güvenlik

- `.env` dosyası gizli bilgileri içerir, paylaşmayın
- Sunucuda dosya izinlerini `chmod 600 .env` ile sınırlayın
- Sadece gerekli portları açık tutun

## 📈 Performans

Bot minimum kaynak kullanır:
- RAM: ~50-100MB
- CPU: Minimal (çoğunlukla beklemede)
- Network: Sadece MHRS API çağrıları

## ❓ Sorun Giderme

### Bot çalışmıyor
```bash
# Servis durumunu kontrol et
sudo systemctl status mhrs-bot

# Hata loglarını incele
sudo journalctl -u mhrs-bot -n 50
```

### Login hatası
- TC kimlik ve şifrenizi kontrol edin
- MHRS hesabınızın aktif olduğundan emin olun

### Randevu bulunamıyor
- Arama kriterlerinizi genişletin
- Log dosyasından deneme sayısını kontrol edin

## 📞 Destek

Sorunlarınız için GitHub Issues kullanın veya pull request gönderin.

## 📄 Lisans

Bu proje açık kaynak kodludur ve eğitim amaçlıdır.
