# 🚀 MHRS Bot Sunucu Kurulum Rehberi

## 📁 Proje Yapısı

```
MHRS-OtomatikRandevu/                   # Ana dizin
├── MHRS-OtomatikRandevu/               # Kod dizini
│   ├── .env                            # ← GÜVENLİK DOSYASI (Bu dizinde)
│   ├── Program.cs                      # Ana kod
│   ├── bot-manager.sh                  # Bot yönetimi
│   ├── install.sh                      # Kurulum scripti
│   └── ...diğer dosyalar
└── README.md                           # Genel bilgiler
```

**ÖNEMLİ: .env dosyası `MHRS-OtomatikRandevu/MHRS-OtomatikRandevu/` dizininde olmalı!**

## 🔧 ADIM 1: Sunucuya Bağlanma

```bash
# SSH ile sunucuya bağlanın
ssh kullanici@sunucu-ip

# Veya PuTTY ile Windows'tan bağlanabilirsiniz
```

## 📥 ADIM 2: Projeyi İndirme

```bash
# Ana dizine gidin
cd ~

# Projeyi GitHub'dan clone edin
git clone https://github.com/TunahanDilercan/MHRS-OtomatikRandevu.git

# Proje dizinine gidin
cd MHRS-OtomatikRandevu

# Dizin yapısını kontrol edin
ls -la
# Çıktı: MHRS-OtomatikRandevu/ klasörü görülmeli
```

## ⚙️ ADIM 3: Otomatik Kurulum

```bash
# Kod dizinine gidin
cd MHRS-OtomatikRandevu

# Kurulum scriptini çalıştırın
chmod +x install.sh
./install.sh

# Script şunları yapacak:
# ✅ .NET 7.0 SDK kurulumu
# ✅ Gerekli paketleri yükleme
# ✅ Projeyi build etme
# ✅ .env dosyası oluşturma
# ✅ Dosya izinlerini ayarlama
```

## 📝 ADIM 4: .env Dosyasını Düzenleme

### Konum: `~/MHRS-OtomatikRandevu/MHRS-OtomatikRandevu/.env`

```bash
# Kod dizininde olduğunuzu doğrulayın
pwd
# Çıktı: /home/kullanici/MHRS-OtomatikRandevu/MHRS-OtomatikRandevu

# .env dosyasını nano ile açın
nano .env
```

### .env Dosyası İçeriği:

```bash
# MHRS Bot Ayarları - KENDİ BİLGİLERİNİZLE DEĞİŞTİRİN
MHRS_TC=12345678901
MHRS_PASSWORD=SifreNiz123

# Lokasyon ID'leri (Program çalıştırıldığında gösterilir)
MHRS_PROVINCE_ID=34
MHRS_DISTRICT_ID=449
MHRS_CLINIC_ID=165
MHRS_HOSPITAL_ID=-1
MHRS_PLACE_ID=-1
MHRS_DOCTOR_ID=-1

# Tarih Ayarları
MHRS_START_DATE=2025-07-07
MHRS_END_DATE=

# Telegram Bot Bildirimleri (ZORUNLU)
TELEGRAM_BOT_TOKEN=7551190144:AAGvgqB4His73C8nwHcFvh0oI-noWfNvbZw
TELEGRAM_CHAT_ID=5511899949
```

### Nano Editör Komutları:
- **Ctrl + O**: Kaydet
- **Enter**: Kaydetmeyi onayla  
- **Ctrl + X**: Çık

## 🧪 ADIM 5: İlk Test

```bash
# .env dizininde olduğunuzu doğrulayın
pwd
# Çıktı: /home/kullanici/MHRS-OtomatikRandevu/MHRS-OtomatikRandevu

# Botu test edin
dotnet run

# Beklenen çıktı:
# ✅ İlk test denemesi yapılacak
# 📱 Telegram'a "İlk Test Tamamlandı" mesajı gelecek
# 🔍 "Randevu bulunamadı (normal)" bildirimi gelecek

# Ctrl+C ile durdurun
```

## 🤖 ADIM 6: Bot Manager ile Yönetim

```bash
# Bot manager ile başlatma
./bot-manager.sh start

# Durum kontrolü
./bot-manager.sh status

# Logları takip etme
./bot-manager.sh logs

# Durdurma
./bot-manager.sh stop

# .env dosyasını düzenleme
./bot-manager.sh editenv
```

## 🔄 ADIM 7: Systemd Servis Kurulumu (Opsiyonel)

```bash
# Servis kurulumu
sudo ./ubuntu-setup.sh

# Servis başlatma
sudo systemctl start mhrs-bot

# Otomatik başlatma aktif etme
sudo systemctl enable mhrs-bot

# Servis durumu
sudo systemctl status mhrs-bot

# Servis logları
journalctl -fu mhrs-bot
```

## 📱 ADIM 8: Telegram Bot Kurulumu

1. **@BotFather** → `/newbot` → Bot oluşturun
2. **@userinfobot** → Chat ID alın
3. **.env dosyasına ekleyin:**
   ```bash
   TELEGRAM_BOT_TOKEN=sizin_bot_token
   TELEGRAM_CHAT_ID=sizin_chat_id
   ```

## 🔍 ADIM 9: Doğrulama

```bash
# .env dosyası var mı?
ls -la .env
# Çıktı: -rw------- 1 kullanici kullanici 500 Jul  3 01:30 .env

# İçeriği kontrol (şifre gizli)
cat .env | grep -v PASSWORD

# Bot çalışıyor mu?
./bot-manager.sh status

# Telegram'dan mesaj geliyor mu?
# ✅ "İlk Test Tamamlandı" mesajını bekledi
```

## 🔧 ADIM 10: Sorun Giderme

### .NET 7.0 Kurulu Değilse:
```bash
wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
chmod +x ./dotnet-install.sh
./dotnet-install.sh --version latest
export PATH="$PATH:$HOME/.dotnet"
echo 'export PATH="$PATH:$HOME/.dotnet"' >> ~/.bashrc
```

### .env Dosyası Bulunamıyorsa:
```bash
# Doğru dizinde misiniz?
pwd
cd ~/MHRS-OtomatikRandevu/MHRS-OtomatikRandevu

# Boş .env oluşturun
./make-env.sh
nano .env
```

### İzin Hatası:
```bash
chmod +x *.sh
chmod 600 .env
```

### Build Hatası:
```bash
dotnet clean
dotnet restore
dotnet build
```

## 📊 ADIM 11: İzleme ve Bakım

```bash
# Günlük log kontrolü
tail -f randevu_log.txt

# Bot çalışıyor mu?
ps aux | grep dotnet

# Sistem kaynaklarını kontrol
htop

# Disk alanı
df -h

# Haftalık güncelleme
cd ~/MHRS-OtomatikRandevu
git pull origin master
dotnet build
./bot-manager.sh restart
```

## 🎯 Başarı Kriterleri

✅ **Kurulum başarılı sayılır:**
1. `dotnet run` çalışıyor
2. Telegram'dan "İlk Test Tamamlandı" mesajı geldi
3. `.env` dosyası doğru konumda ve güvenli izinlerle
4. Bot manager komutları çalışıyor
5. Systemd servisi (opsiyonel) aktif

## 📞 Yardım

- **Telegram kurulumu**: `cat telegram-kurulum.md`
- **Ubuntu detayları**: `cat ubuntu-kurulum.md`
- **Nano kullanımı**: `cat nano-env-rehberi.md`
- **Bot komutları**: `./bot-manager.sh` (parametresiz)

---

🎉 **Kurulum tamamlandığında bot 7/24 çalışacak ve Telegram'dan tüm bilgileri alacaksınız!**
