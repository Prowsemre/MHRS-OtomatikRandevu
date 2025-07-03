#!/bin/bash

# 🚀 MHRS Otomatik Randevu Bot - Hızlı Sunucu Kurulum
# Ubuntu/Debian için tek komut kurulum scripti

set -e

echo "🚀 MHRS Otomatik Randevu Bot - Sunucu Kurulumu Başlatılıyor..."
echo "=================================================="

# Renkli çıktı için
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 1. Sistem Güncellemesi
print_status "Sistem paketleri güncelleniyor..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y wget curl git nano unzip

print_success "Sistem güncellemesi tamamlandı!"

# 2. .NET 7.0 Runtime Kurulumu
print_status ".NET 7.0 Runtime kuruluyor..."

# Microsoft paket deposunu ekle
if ! dpkg -l | grep -q packages-microsoft-prod; then
    wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb
fi

sudo apt update
sudo apt install -y aspnetcore-runtime-7.0

# .NET kurulumunu doğrula
if command -v dotnet &> /dev/null; then
    DOTNET_VERSION=$(dotnet --version)
    print_success ".NET $DOTNET_VERSION başarıyla kuruldu!"
else
    print_error ".NET kurulumu başarısız!"
    exit 1
fi

# 3. Repository Klonlama
print_status "MHRS Bot repository'si indiriliyor..."

cd ~
if [ -d "MHRS-OtomatikRandevu" ]; then
    print_warning "MHRS-OtomatikRandevu dizini zaten mevcut. Güncelleniyor..."
    cd MHRS-OtomatikRandevu
    git pull
else
    git clone https://github.com/your-username/MHRS-OtomatikRandevu.git
    cd MHRS-OtomatikRandevu
fi

cd MHRS-OtomatikRandevu

# İzinleri ayarla
chmod +x *.sh 2>/dev/null || true

print_success "Repository başarıyla indirildi!"

# 4. .env Dosyası Kontrolü
print_status ".env dosyası kontrol ediliyor..."

if [ ! -f .env ]; then
    print_warning ".env dosyası bulunamadı. Oluşturuluyor..."
    
    echo "🔧 .env dosyası oluşturuluyor..."
    echo "Lütfen MHRS bilgilerinizi girin:"
    
    if [ -f make-env.sh ]; then
        ./make-env.sh
    else
        # Basit .env oluştur
        cat > .env << 'EOF'
# MHRS Giriş Bilgileri (ZORUNLU)
MHRS_TC=12345678901
MHRS_PASSWORD=şifreniz

# Hedef Kriterler (ZORUNLU - ID değerleri)
MHRS_PROVINCE_ID=34
MHRS_DISTRICT_ID=449
MHRS_CLINIC_ID=1500
MHRS_HOSPITAL_ID=1234
MHRS_PLACE_ID=5678
MHRS_DOCTOR_ID=9012

# Tarih Bilgileri
MHRS_START_DATE=07-07-2025

# Telegram Bildirimleri (İsteğe Bağlı)
TELEGRAM_BOT_TOKEN=
TELEGRAM_CHAT_ID=

# SMS Bildirimleri (İsteğe Bağlı)
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_PHONE_NUMBER=
SMS_TO_NUMBER=
EOF
        print_warning ".env dosyası oluşturuldu. Lütfen bilgilerinizi girin:"
        print_status "nano .env komutu ile düzenleyebilirsiniz."
    fi
else
    print_success ".env dosyası mevcut!"
fi

# 5. Bot Derleme
print_status "Bot derleniyor..."

if dotnet build --configuration Release; then
    print_success "Bot başarıyla derlendi!"
else
    print_error "Bot derleme hatası!"
    exit 1
fi

# 6. Test Çalıştırması
print_status "Bot test ediliyor..."

print_warning "30 saniye test çalıştırması yapılıyor..."
timeout 30s dotnet run --configuration Release || true

print_success "Test tamamlandı!"

# 7. Systemd Servis Kurulumu
print_status "Systemd servisi kuruluyor..."

BOT_DIR=$(pwd)
USER_NAME=$(whoami)

sudo tee /etc/systemd/system/mhrs-bot.service > /dev/null << EOF
[Unit]
Description=MHRS Otomatik Randevu Bot
After=network.target

[Service]
Type=simple
User=$USER_NAME
WorkingDirectory=$BOT_DIR
ExecStart=/usr/bin/dotnet run --configuration Release
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable mhrs-bot.service

print_success "Systemd servisi kuruldu!"

# 8. Kurulum Özeti
echo ""
echo "🎉 KURULUM TAMAMLANDI!"
echo "=================================="
print_success "MHRS Otomatik Randevu Bot başarıyla kuruldu!"
echo ""
echo "📁 Bot Dizini: $BOT_DIR"
echo "📝 Konfigürasyon: $BOT_DIR/.env"
echo "📊 Log Dosyası: $BOT_DIR/randevu_log.txt"
echo ""
echo "🔧 YAPILINACAKLAR:"
echo "1. .env dosyasını düzenleyin:"
echo "   nano .env"
echo ""
echo "2. Bot'u başlatın:"
echo "   ./bot-manager.sh start"
echo ""
echo "3. Logları takip edin:"
echo "   ./bot-manager.sh logs"
echo ""
echo "4. Servis olarak başlatmak için:"
echo "   sudo systemctl start mhrs-bot.service"
echo "   sudo systemctl status mhrs-bot.service"
echo ""
echo "📞 Bot Yönetim Komutları:"
echo "   ./bot-manager.sh start    # Bot'u başlat"
echo "   ./bot-manager.sh stop     # Bot'u durdur"
echo "   ./bot-manager.sh status   # Durum kontrol"
echo "   ./bot-manager.sh logs     # Log takibi"
echo "   ./bot-manager.sh editenv  # .env düzenle"
echo ""
print_warning "ÖNEMLİ: .env dosyasındaki bilgileri düzenlemeyi unutmayın!"
echo ""
