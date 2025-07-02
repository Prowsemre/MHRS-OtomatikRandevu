# 📱 Telegram Bot Bildirimi Kurulum Rehberi

## 🤖 1. ADIM: Telegram Bot Oluşturma

1. **Telegram'da @BotFather'ı bulun**
   - Telegram'da `@BotFather` arayın ve mesaj atın

2. **Yeni bot oluşturun**
   ```
   /newbot
   ```
   
3. **Bot ismi verin**
   - Örnek: `MHRS Randevu Bot`
   
4. **Bot kullanıcı adı verin**
   - Örnek: `mhrs_randevu_bot` (benzersiz olmalı, `_bot` ile bitmeli)

5. **Token'ı kaydedin**
   - BotFather size bir token verecek
   - Örnek: `1234567890:ABCdefGHIjklMNOpqrsTUVwxyz`

## 💬 2. ADIM: Chat ID Alma

1. **@userinfobot'u bulun**
   - Telegram'da `@userinfobot` arayın

2. **Mesaj atın**
   - Herhangi bir mesaj atın

3. **Chat ID'nizi alın**
   - Bot size Chat ID'nizi verecek
   - Örnek: `123456789`

## ⚙️ 3. ADIM: .env Dosyasına Ekleme

```bash
# .env dosyasını düzenleyin
nano .env

# Şu satırları doldurun:
TELEGRAM_BOT_TOKEN=1234567890:ABCdefGHIjklMNOpqrsTUVwxyz
TELEGRAM_CHAT_ID=123456789
```

## 📧 4. ADIM: Email Bildirimi (Gmail Örneği)

```bash
# Gmail için .env dosyasına ekleyin:
EMAIL_SMTP_HOST=smtp.gmail.com
EMAIL_SMTP_PORT=587
EMAIL_USERNAME=sizin@gmail.com
EMAIL_PASSWORD=uygulama_sifreniz
EMAIL_TO=sizin@gmail.com
```

### Gmail Uygulama Şifresi Alma:
1. Google Hesap Ayarları → Güvenlik
2. 2FA'yı etkinleştirin
3. "Uygulama şifreleri" → "Diğer" → "MHRS Bot"
4. Oluşturulan şifreyi `EMAIL_PASSWORD`'e yazın

## 🧪 5. ADIM: Test Etme

```bash
# Botu çalıştırın
dotnet run

# Bot başladığında ilk test bildirimi gönderecek
```

## 📊 6. Bildirim Türleri

Bot şu durumlarda bildirim gönderir:

### ✅ Başarılı Durumlar:
- ✅ Randevu bulundu
- ✅ Randevu başarıyla alındı

### ❌ Hata Durumları:
- ❌ Randevu alma hatası

### 📊 Durum Raporları:
- 📊 Her 50 denemede bir durum raporu
- 🕐 Çalışma süresi
- 🔄 Toplam deneme sayısı

## 🔧 Sorun Giderme

### Telegram Bot Çalışmıyor:
1. Token'ı kontrol edin
2. Chat ID'yi kontrol edin
3. Bot'a en az bir mesaj atmış olmanız gerekir

### Email Çalışmıyor:
1. SMTP ayarlarını kontrol edin
2. Gmail için uygulama şifresi kullanın
3. 2FA etkin olmalı

### Loglar:
```bash
# Bot loglarını kontrol edin
tail -f randevu_log.txt

# Sistemd servisi kullanıyorsanız:
journalctl -fu mhrs-bot
```

## 📱 Örnek .env Dosyası

```bash
# MHRS Bot Ayarları
MHRS_TC=12345678901
MHRS_PASSWORD=SifreNiz123

# Lokasyon
MHRS_PROVINCE_ID=34
MHRS_DISTRICT_ID=449
MHRS_CLINIC_ID=165
MHRS_HOSPITAL_ID=-1
MHRS_PLACE_ID=-1
MHRS_DOCTOR_ID=-1

# Tarih
MHRS_START_DATE=2025-07-07
MHRS_END_DATE=

# Telegram (Önerilen)
TELEGRAM_BOT_TOKEN=1234567890:ABCdefGHIjklMNOpqrsTUVwxyz
TELEGRAM_CHAT_ID=123456789

# Email (Opsiyonel)
EMAIL_SMTP_HOST=smtp.gmail.com
EMAIL_SMTP_PORT=587
EMAIL_USERNAME=sizin@gmail.com
EMAIL_PASSWORD=abcd1234efgh5678
EMAIL_TO=sizin@gmail.com
```

Artık bot çalıştığında tüm önemli olayları Telegram ve/veya Email ile size bildirecek! 📱✅
