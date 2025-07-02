#!/bin/bash

# MHRS Bot GitHub'dan Kurulum Scripti
# Kullanım: curl -sSL https://raw.githubusercontent.com/TunahanDilercan/MHRS-OtomatikRandevu/main/MHRS-OtomatikRandevu/install.sh | bash

echo "=== MHRS Bot GitHub'dan Kurulum ==="

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# GitHub repository bilgileri
GITHUB_USER="TunahanDilercan"
GITHUB_REPO="MHRS-OtomatikRandevu"
GITHUB_BRANCH="main"

# Hata kontrolü
set -e

echo -e "${YELLOW}1. Sistem güncelleniyor...${NC}"
sudo apt-get update

echo -e "${YELLOW}2. Gerekli paketler kuruluyor...${NC}"
sudo apt-get install -y git curl wget unzip

echo -e "${YELLOW}3. .NET SDK 7.0 kuruluyor...${NC}"
# Microsoft repository key ekle
if [ ! -f /etc/apt/sources.list.d/microsoft-prod.list ]; then
    wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb
    sudo apt-get update
fi

# .NET SDK kur
sudo apt-get install -y dotnet-sdk-7.0

echo -e "${GREEN}.NET SDK kuruldu: $(dotnet --version)${NC}"

echo -e "${YELLOW}4. Proje GitHub'dan indiriliyor...${NC}"
PROJECT_DIR="$HOME/mhrs-bot"

# Eğer dizin varsa temizle
if [ -d "$PROJECT_DIR" ]; then
    echo -e "${YELLOW}Mevcut kurulum temizleniyor...${NC}"
    rm -rf "$PROJECT_DIR"
fi

# Projeyi clone et
git clone "https://github.com/$GITHUB_USER/$GITHUB_REPO.git" "$PROJECT_DIR"
cd "$PROJECT_DIR/MHRS-OtomatikRandevu"

echo -e "${YELLOW}5. Proje derleniyor...${NC}"
dotnet restore
dotnet build --configuration Release

echo -e "${YELLOW}6. .env dosyası hazırlanıyor...${NC}"
if [ ! -f .env ]; then
    cat > .env << 'EOF'
# MHRS Bot Ayarları
MHRS_TC=
MHRS_PASSWORD=

# Lokasyon ID'leri
MHRS_PROVINCE_ID=
MHRS_DISTRICT_ID=
MHRS_CLINIC_ID=
MHRS_HOSPITAL_ID=-1
MHRS_PLACE_ID=-1
MHRS_DOCTOR_ID=-1

# Tarih Ayarları
MHRS_START_DATE=2025-07-07
MHRS_END_DATE=

# Telegram Bot Bildirimleri
TELEGRAM_BOT_TOKEN=
TELEGRAM_CHAT_ID=
TELEGRAM_NOTIFY_FREQUENCY=10

# E-posta Bildirimleri (opsiyonel)
EMAIL_SMTP_HOST=
EMAIL_USERNAME=
EMAIL_PASSWORD=
EMAIL_TO=

# SMS Bildirimleri (opsiyonel)
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_FROM_PHONE=
TWILIO_TO_PHONE=
EOF
    chmod 600 .env
    echo -e "${GREEN}.env dosyası oluşturuldu${NC}"
else
    echo -e "${YELLOW}.env dosyası zaten mevcut${NC}"
fi

echo -e "${YELLOW}7. Systemd servis dosyası oluşturuluyor...${NC}"
sudo tee /etc/systemd/system/mhrs-bot.service > /dev/null << EOF
[Unit]
Description=MHRS Otomatik Randevu Botu
After=network.target

[Service]
Type=notify
User=$USER
WorkingDirectory=$PROJECT_DIR/MHRS-OtomatikRandevu
ExecStart=/usr/bin/dotnet run --project $PROJECT_DIR/MHRS-OtomatikRandevu
Restart=always
RestartSec=5
Environment=DOTNET_CLI_HOME=/tmp

[Install]
WantedBy=multi-user.target
EOF

echo -e "${YELLOW}8. Dosya izinleri ayarlanıyor...${NC}"
chmod +x *.sh 2>/dev/null || true
chmod 600 .env

echo -e "${YELLOW}9. Systemd servisi aktifleştiriliyor...${NC}"
sudo systemctl daemon-reload
sudo systemctl enable mhrs-bot

echo -e "${GREEN}=== KURULUM TAMAMLANDI! ===${NC}"
echo ""
echo -e "${BLUE}📁 Proje konumu: ${PROJECT_DIR}/MHRS-OtomatikRandevu${NC}"
echo -e "${BLUE}📝 .env dosyasını düzenleyin: ${NC}"
echo -e "   ${YELLOW}nano $PROJECT_DIR/MHRS-OtomatikRandevu/.env${NC}"
echo ""
echo -e "${BLUE}🚀 Bot yönetim komutları:${NC}"
echo -e "   ${GREEN}cd $PROJECT_DIR/MHRS-OtomatikRandevu${NC}"
echo -e "   ${GREEN}./bot-manager.sh start${NC}     # Botu başlat"
echo -e "   ${GREEN}./bot-manager.sh status${NC}    # Durum kontrol"
echo -e "   ${GREEN}./bot-manager.sh logs${NC}      # Log takibi"
echo -e "   ${GREEN}./bot-manager.sh stop${NC}      # Botu durdur"
echo ""
echo -e "${YELLOW}⚠️  .env dosyasını düzenledikten sonra botu başlatın!${NC}"
echo ""

# Eski klasörü sil
if [ -d "$PROJECT_DIR" ]; then
    echo -e "${YELLOW}Eski kurulum bulundu, siliniyor...${NC}"
    rm -rf "$PROJECT_DIR"
fi

# Proje klasörü oluştur
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# GitHub'dan clone et
echo -e "${BLUE}GitHub Repository: https://github.com/$GITHUB_USER/$GITHUB_REPO${NC}"
git clone "https://github.com/$GITHUB_USER/$GITHUB_REPO.git" .

# Ana dizine git
cd "MHRS-OtomatikRandevu"
PROJECT_DIR="$PROJECT_DIR/MHRS-OtomatikRandevu"

echo -e "${YELLOW}5. Proje derleniyor...${NC}"
dotnet build

echo -e "${YELLOW}6. .env dosyası kontrol ediliyor...${NC}"
if [ ! -f ".env" ]; then
    echo -e "${RED}UYARI: .env dosyası bulunamadı!${NC}"
    echo -e "${YELLOW}.env dosyası örneği oluşturuluyor...${NC}"
    
    cat > .env << 'EOF'
# MHRS Bot Ayarları
MHRS_TC=12345678901
MHRS_PASSWORD=your_password

# Lokasyon ID'leri
MHRS_PROVINCE_ID=70
MHRS_DISTRICT_ID=1439
MHRS_CLINIC_ID=165
MHRS_HOSPITAL_ID=-1
MHRS_PLACE_ID=-1
MHRS_DOCTOR_ID=-1

# Tarih ayarları
MHRS_START_DATE=2025-07-07
MHRS_END_DATE=
EOF
    
    echo -e "${GREEN}.env dosyası oluşturuldu.${NC}"
    echo ""
    echo -e "${BLUE}=== .env Dosyasını Düzenleyin ===${NC}"
    
    # Interaktif olarak bilgileri al
    read -p "🆔 TC Kimlik Numaranızı girin: " tc_input
    read -s -p "🔐 MHRS Şifrenizi girin: " password_input
    echo ""
    
    # TC kimlik kontrolü
    if [[ ! "$tc_input" =~ ^[0-9]{11}$ ]]; then
        echo -e "${RED}Hata: TC kimlik 11 haneli olmalı!${NC}"
        tc_input="12345678901"
    fi
    
    # .env dosyasını güncelle
    sed -i "s/MHRS_TC=12345678901/MHRS_TC=$tc_input/" .env
    sed -i "s/MHRS_PASSWORD=your_password/MHRS_PASSWORD=$password_input/" .env
    
    echo -e "${GREEN}✅ TC kimlik ve şifre .env dosyasına kaydedildi.${NC}"
    echo ""
    
    # Opsiyonel: Diğer ayarları sormak ister misiniz?
    read -p "🏥 Lokasyon ayarlarını değiştirmek istiyor musunuz? (y/N): " change_location
    
    if [[ "$change_location" =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${BLUE}Lokasyon ID'leri (-1 = Farketmez):${NC}"
        
        read -p "🌍 İl ID (varsayılan 70): " province_id
        province_id=${province_id:-70}
        sed -i "s/MHRS_PROVINCE_ID=70/MHRS_PROVINCE_ID=$province_id/" .env
        
        read -p "🏘️ İlçe ID (varsayılan 1439, -1=farketmez): " district_id
        district_id=${district_id:-1439}
        sed -i "s/MHRS_DISTRICT_ID=1439/MHRS_DISTRICT_ID=$district_id/" .env
        
        read -p "🏥 Klinik ID (varsayılan 165): " clinic_id
        clinic_id=${clinic_id:-165}
        sed -i "s/MHRS_CLINIC_ID=165/MHRS_CLINIC_ID=$clinic_id/" .env
        
        echo -e "${GREEN}✅ Lokasyon ayarları güncellendi.${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}📄 Oluşturulan .env dosyası:${NC}"
    echo "----------------------------------------"
    cat .env | sed 's/MHRS_PASSWORD=.*/MHRS_PASSWORD=***GIZLI***/'
    echo "----------------------------------------"
    echo ""
    
elif grep -q "12345678901" .env; then
    echo -e "${YELLOW}.env dosyası mevcut ama örnek veriler var.${NC}"
    echo ""
    read -p "🔄 .env dosyasını yeniden düzenlemek istiyor musunuz? (y/N): " redo_env
    
    if [[ "$redo_env" =~ ^[Yy]$ ]]; then
        echo ""
        read -p "🆔 TC Kimlik Numaranızı girin: " tc_input
        read -s -p "🔐 MHRS Şifrenizi girin: " password_input
        echo ""
        
        # TC kimlik kontrolü
        if [[ ! "$tc_input" =~ ^[0-9]{11}$ ]]; then
            echo -e "${RED}Hata: TC kimlik 11 haneli olmalı!${NC}"
        else
            sed -i "s/MHRS_TC=.*/MHRS_TC=$tc_input/" .env
            sed -i "s/MHRS_PASSWORD=.*/MHRS_PASSWORD=$password_input/" .env
            echo -e "${GREEN}✅ .env dosyası güncellendi.${NC}"
        fi
    fi
else
    echo -e "${GREEN}.env dosyası zaten hazır.${NC}"
fi

echo -e "${YELLOW}7. Systemd servisi oluşturuluyor...${NC}"
sudo tee /etc/systemd/system/mhrs-bot.service > /dev/null <<EOF
[Unit]
Description=MHRS Otomatik Randevu Botu
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$PROJECT_DIR
ExecStart=/usr/bin/dotnet run
Restart=always
RestartSec=30
Environment=ASPNETCORE_ENVIRONMENT=Production
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

echo -e "${YELLOW}8. Servis etkinleştiriliyor...${NC}"
sudo systemctl daemon-reload
sudo systemctl enable mhrs-bot

echo -e "${YELLOW}9. Dosya izinleri ayarlanıyor...${NC}"
chmod +x ubuntu-setup.sh 2>/dev/null || true
chmod +x bot-manager.sh 2>/dev/null || true
chmod +x quick-start.sh 2>/dev/null || true
chmod 600 .env

echo -e "${GREEN}=== Kurulum Tamamlandı! ===${NC}"
echo ""
echo -e "${BLUE}Proje Dizini:${NC} $PROJECT_DIR"
echo -e "${BLUE}GitHub Repo:${NC}  https://github.com/$GITHUB_USER/$GITHUB_REPO"
echo ""
echo -e "${YELLOW}ÖNEMLİ: .env dosyasını düzenlemeniz gerekiyor!${NC}"
echo -e "${RED}TC kimlik ve şifrenizi girdikten sonra botu başlatabilirsiniz.${NC}"
echo ""
echo -e "${YELLOW}Sonraki Adımlar:${NC}"
echo "1. .env dosyasını düzenleyin:"
echo "   nano .env"
echo ""
echo "2. TC kimlik ve şifrenizi girin"
echo ""
echo "3. Botu başlatın:"
echo "   sudo systemctl start mhrs-bot"
echo ""
echo "4. Durumu kontrol edin:"
echo "   sudo systemctl status mhrs-bot"
echo ""
echo "5. Log takibi:"
echo "   sudo journalctl -u mhrs-bot -f"
echo ""
echo -e "${GREEN}Bot yönetimi için: ./bot-manager.sh [start|stop|status|logs]${NC}"
echo -e "${BLUE}Hızlı başlangıç için: ./quick-start.sh${NC}"

# .env dosyasını kontrol et ve uyarı ver
if grep -q "12345678901" .env 2>/dev/null; then
    echo ""
    echo -e "${RED}⚠️  DİKKAT: .env dosyasında örnek veriler var!${NC}"
    echo -e "${RED}   Lütfen gerçek TC kimlik ve şifrenizi girin!${NC}"
    echo -e "${YELLOW}   Düzenlemek için: nano .env${NC}"
    echo ""
    echo -e "${BLUE}📋 .env dosyası örneği:${NC}"
    echo "MHRS_TC=your_actual_tc_number"
    echo "MHRS_PASSWORD=your_actual_password"
    echo "MHRS_PROVINCE_ID=70"
    echo "MHRS_DISTRICT_ID=1439"
    echo "MHRS_CLINIC_ID=165"
    echo "# ..."
fi
