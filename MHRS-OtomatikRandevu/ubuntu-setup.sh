#!/bin/bash

# MHRS Bot Ubuntu Kurulum Scripti
# Kullanım: chmod +x ubuntu-setup.sh && ./ubuntu-setup.sh

echo "=== MHRS Bot Ubuntu Kurulum Başlıyor ==="

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Hata kontrolü
set -e

echo -e "${YELLOW}1. Sistem güncelleniyor...${NC}"
sudo apt-get update

echo -e "${YELLOW}2. .NET SDK 7.0 kuruluyor...${NC}"
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

echo -e "${YELLOW}3. Proje dizini hazırlanıyor...${NC}"
# Mevcut dizinde çalış
PROJECT_DIR=$(pwd)
echo "Proje dizini: $PROJECT_DIR"

echo -e "${YELLOW}4. Proje derleniyor...${NC}"
dotnet build

echo -e "${YELLOW}5. .env dosyası kontrol ediliyor...${NC}"
if [ ! -f ".env" ]; then
    echo -e "${RED}HATA: .env dosyası bulunamadı!${NC}"
    echo "Lütfen .env dosyasını oluşturun:"
    echo "MHRS_TC=your_tc"
    echo "MHRS_PASSWORD=your_password"
    echo "MHRS_PROVINCE_ID=70"
    echo "MHRS_DISTRICT_ID=1439"
    echo "MHRS_CLINIC_ID=165"
    echo "MHRS_HOSPITAL_ID=-1"
    echo "MHRS_PLACE_ID=-1"
    echo "MHRS_DOCTOR_ID=-1"
    echo "MHRS_START_DATE=2025-07-07"
    exit 1
fi

echo -e "${YELLOW}6. Systemd servisi oluşturuluyor...${NC}"
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

echo -e "${YELLOW}7. Servis etkinleştiriliyor...${NC}"
sudo systemctl daemon-reload
sudo systemctl enable mhrs-bot

echo -e "${GREEN}=== Kurulum Tamamlandı! ===${NC}"
echo ""
echo "Bot yönetimi için komutlar:"
echo "  Başlat:    sudo systemctl start mhrs-bot"
echo "  Durdur:    sudo systemctl stop mhrs-bot"
echo "  Durumu:    sudo systemctl status mhrs-bot"
echo "  Log:       sudo journalctl -u mhrs-bot -f"
echo "  Bot Log:   tail -f randevu_log.txt"
echo ""
echo -e "${YELLOW}Botu başlatmak için: sudo systemctl start mhrs-bot${NC}"
echo -e "${YELLOW}Log takibi için:     sudo journalctl -u mhrs-bot -f${NC}"
