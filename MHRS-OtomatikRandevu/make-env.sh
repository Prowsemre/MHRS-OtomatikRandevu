#!/bin/bash

# MHRS Bot .env Dosyası Oluşturucu
# Sadece boş .env dosyası oluşturur, içeriği manuel girilir

echo "=== .env Dosyası Oluşturuluyor ==="

# .env dosyası oluştur
cat > .env << 'EOF'
# MHRS Bot Ayarları
# Aşağıdaki değerleri kendi bilgilerinizle değiştirin

MHRS_TC=
MHRS_PASSWORD=

# Lokasyon ID'leri (Program çalıştırıldığında gösterilir)
MHRS_PROVINCE_ID=
MHRS_DISTRICT_ID=
MHRS_CLINIC_ID=
MHRS_HOSPITAL_ID=
MHRS_PLACE_ID=
MHRS_DOCTOR_ID=

# Tarih Ayarları
MHRS_START_DATE=
MHRS_END_DATE=

# Telegram Bot Bildirimleri (ÖNERİLEN)
# Bot Token almak için: @BotFather'a /newbot yazın
# Chat ID almak için: @userinfobot'a mesaj atın
TELEGRAM_BOT_TOKEN=
TELEGRAM_CHAT_ID=
TELEGRAM_NOTIFY_FREQUENCY=10

# Diğer bildirim türleri (opsiyonel, boş bırakılabilir)
EMAIL_SMTP_HOST=
EMAIL_USERNAME=
TWILIO_ACCOUNT_SID=
EOF

# Dosya izinlerini güvenli yap
chmod 600 .env

echo "✅ .env dosyası oluşturuldu!"
echo ""
echo "📝 Şimdi .env dosyasını düzenleyin:"
echo "nano .env"
echo ""
echo "🔒 Dosya güvenli izinlerle (600) kaydedildi."
