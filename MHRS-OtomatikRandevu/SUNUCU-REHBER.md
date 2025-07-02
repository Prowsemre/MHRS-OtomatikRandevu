# MHRS Bot Sunucu Hızlı Komutlar Rehberi

## 🚀 TEK SATIR KURULUM (Ubuntu)
```bash
curl -sSL https://raw.githubusercontent.com/KULLANICI_ADINIZ/MHRS-OtomatikRandevu/master/MHRS-OtomatikRandevu/server-install.sh | bash
```

## 📦 MANUEL KURULUM ADIMLARI

### 1. Projeyi İndirme
```bash
git clone https://github.com/KULLANICI_ADINIZ/MHRS-OtomatikRandevu.git
cd MHRS-OtomatikRandevu
```

### 2. Kurulum
```bash
chmod +x MHRS-OtomatikRandevu/install.sh
./MHRS-OtomatikRandevu/install.sh
```

### 3. .env Dosyası Düzenleme
```bash
# Seçenek 1: Bot manager ile
./MHRS-OtomatikRandevu/bot-manager.sh editenv

# Seçenek 2: Nano rehberi ile
./MHRS-OtomatikRandevu/edit-env-guide.sh

# Seçenek 3: Doğrudan nano
cd MHRS-OtomatikRandevu
nano .env
```

### 4. Bot Başlatma
```bash
# Manuel çalıştırma
cd MHRS-OtomatikRandevu
dotnet run

# Servis olarak çalıştırma
./bot-manager.sh start
```

## 🔧 BOT YÖNETİM KOMUTLARI

```bash
# Bot durumu
./bot-manager.sh status

# Logları takip et
./bot-manager.sh logs

# Bot'u durdur
./bot-manager.sh stop

# Bot'u başlat
./bot-manager.sh start

# Bot'u yeniden başlat
./bot-manager.sh restart

# .env dosyasını düzenle
./bot-manager.sh editenv

# Başarılı randevu dosyasını göster
./bot-manager.sh success
```

## 📝 .env DOSYASI ÖRNEĞİ

```bash
# MHRS Bilgileri (ZORUNLU)
MHRS_TC=12345678901
MHRS_PASSWORD=SifreNiz123
MHRS_PROVINCE_ID=34
MHRS_DISTRICT_ID=449
MHRS_CLINIC_ID=165
MHRS_HOSPITAL_ID=-1
MHRS_PLACE_ID=-1
MHRS_DOCTOR_ID=-1
MHRS_START_DATE=2025-07-07
MHRS_END_DATE=

# Telegram Bot (ZORUNLU)
TELEGRAM_BOT_TOKEN=1234567890:ABCdefGHIjklMNOpqrsTUVwxyz
TELEGRAM_CHAT_ID=123456789
TELEGRAM_NOTIFY_FREQUENCY=10

# Email (İsteğe bağlı)
EMAIL_SMTP_HOST=smtp.gmail.com
EMAIL_SMTP_PORT=587
EMAIL_USERNAME=sizin@gmail.com
EMAIL_PASSWORD=uygulama_sifreniz
EMAIL_TO=sizin@gmail.com
```

## 🔍 SORUN GİDERME

### Bot çalışmıyor:
```bash
# Logları kontrol et
./bot-manager.sh logs

# Servis durumunu kontrol et
sudo systemctl status mhrs-bot

# Manuel çalıştırıp hata mesajını gör
cd MHRS-OtomatikRandevu
dotnet run
```

### .env dosyası bulunamıyor:
```bash
# Mevcut konumu kontrol et
pwd
ls -la .env

# Doğru dizine git
cd MHRS-OtomatikRandevu
ls -la .env
```

### Telegram bildirimi gelmiyor:
```bash
# .env dosyasını kontrol et
./bot-manager.sh editenv

# Bot token ve chat ID'yi doğrula
# Test için manuel çalıştır
dotnet run
```

## 📱 TELEGRAM BOT KURULUMU

1. **@BotFather** → `/newbot` → Bot oluştur
2. **@userinfobot** → Chat ID al
3. **.env dosyasına ekle**:
   ```
   TELEGRAM_BOT_TOKEN=token_buraya
   TELEGRAM_CHAT_ID=chat_id_buraya
   ```
