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

# VEYA bot manager ile:
./bot-manager.sh editenv

# Şu satırları doldurun:
TELEGRAM_BOT_TOKEN=1234567890:ABCdefGHIjklMNOpqrsTUVwxyz
TELEGRAM_CHAT_ID=123456789
```

## 🧪 4. ADIM: Test Etme

```bash
# Botu çalıştırın
dotnet run

# VEYA bot manager ile:
./bot-manager.sh start

# Bot başladığında ilk test bildirimi gönderecek
```

## 📊 5. Bildirim Türleri

Bot şu durumlarda Telegram bildirimi gönderir:

### ✅ Başarılı Durumlar:
- 🎉 Randevu bulundu
- ✅ Randevu başarıyla alındı

### ❌ Hata Durumları:
- ❌ Randevu alma hatası

### 📊 Durum Raporları:
- 📊 Her 50 denemede bir durum raporu
- 🕐 Çalışma süresi
- 🔄 Toplam deneme sayısı

## 🔧 6. Sorun Giderme

### Telegram Bot Çalışmıyor:
1. **Token kontrolü**: BotFather'dan aldığınız token'ı doğru yazdığınızdan emin olun
2. **Chat ID kontrolü**: @userinfobot'dan aldığınız Chat ID'yi doğru yazdığınızdan emin olun
3. **İlk mesaj**: Bot'a en az bir defa mesaj atmış olmanız gerekir
4. **Bot aktif mi**: Bot'u @BotFather'da devre dışı bırakmış olabilirsiniz

### Test etmek için:
```bash
# Bot loglarını kontrol edin
tail -f randevu_log.txt

# Sistemd servisi kullanıyorsanız:
journalctl -fu mhrs-bot

# Bot manager ile durum kontrolü:
./bot-manager.sh status
```

## 📱 7. Minimal .env Dosyası Örneği

```bash
# MHRS Bot Ayarları - SADECE GEREKLİ ALANLAR
MHRS_TC=12345678901
MHRS_PASSWORD=SifreNiz123

# Lokasyon (Program çalıştırıldığında ID'ler gösterilecek)
MHRS_PROVINCE_ID=34
MHRS_DISTRICT_ID=449
MHRS_CLINIC_ID=165
MHRS_HOSPITAL_ID=-1
MHRS_PLACE_ID=-1
MHRS_DOCTOR_ID=-1

# Tarih
MHRS_START_DATE=2025-07-07
MHRS_END_DATE=

# Telegram Bot (BİLDİRİM İÇİN)
TELEGRAM_BOT_TOKEN=1234567890:ABCdefGHIjklMNOpqrsTUVwxyz
TELEGRAM_CHAT_ID=123456789

# Diğer bildirim türleri boş bırakılabilir:
EMAIL_SMTP_HOST=
EMAIL_USERNAME=
TWILIO_ACCOUNT_SID=
```

## 🚀 8. Hızlı Başlangıç

```bash
# 1. Telegram bot oluştur (@BotFather)
# 2. Chat ID al (@userinfobot)
# 3. .env dosyasını düzenle
./bot-manager.sh editenv

# 4. Botu başlat
./bot-manager.sh start

# 5. Logları takip et
./bot-manager.sh logs
```

Artık sadece Telegram ile tüm önemli bildirimleri alacaksınız! 📱✅

**İlk çalıştırıldığında bot size "İlk test denemesi" bildirimi gönderecek, böylece çalıştığını anlayacaksınız!** 🧪
