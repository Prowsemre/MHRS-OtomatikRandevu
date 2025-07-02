#!/bin/bash

# MHRS Bot Hızlı Başlangıç Scripti
# Kurulum sonrası .env düzenleme ve bot başlatma

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== MHRS Bot Hızlı Başlangıç ===${NC}"

# Proje dizinine git
PROJECT_DIR="$HOME/mhrs-bot/MHRS-OtomatikRandevu"

if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}Hata: Proje dizini bulunamadı!${NC}"
    echo "Önce kurulum scriptini çalıştırın:"
    echo "curl -sSL https://raw.githubusercontent.com/TunahanDilercan/MHRS-OtomatikRandevu/main/MHRS-OtomatikRandevu/install.sh | bash"
    exit 1
fi

cd "$PROJECT_DIR"

echo -e "${YELLOW}1. .env dosyası kontrol ediliyor...${NC}"

if [ ! -f ".env" ]; then
    echo -e "${RED}Hata: .env dosyası bulunamadı!${NC}"
    exit 1
fi

# .env dosyasının içeriğini kontrol et
if grep -q "12345678901" .env; then
    echo -e "${RED}⚠️  .env dosyasında örnek veriler bulundu!${NC}"
    echo ""
    echo -e "${YELLOW}TC kimlik ve şifrenizi girmek için .env dosyasını düzenleyin:${NC}"
    echo "nano .env"
    echo ""
    echo -e "${BLUE}Mevcut .env içeriği:${NC}"
    echo "----------------------------------------"
    cat .env
    echo "----------------------------------------"
    echo ""
    read -p "Şimdi .env dosyasını düzenlemek istiyor musunuz? (y/N): " edit_env
    
    if [[ "$edit_env" =~ ^[Yy]$ ]]; then
        nano .env
        echo ""
        echo -e "${GREEN}.env dosyası düzenlendi.${NC}"
    else
        echo -e "${YELLOW}Lütfen önce .env dosyasını düzenleyin:${NC}"
        echo "nano .env"
        echo ""
        echo "Düzenledikten sonra botu başlatmak için:"
        echo "./quick-start.sh"
        exit 0
    fi
else
    echo -e "${GREEN}.env dosyası hazır görünüyor.${NC}"
fi

echo ""
echo -e "${YELLOW}2. Bot servisi kontrol ediliyor...${NC}"

# Servis durumunu kontrol et
if systemctl is-active --quiet mhrs-bot; then
    echo -e "${GREEN}Bot zaten çalışıyor!${NC}"
    echo ""
    echo -e "${BLUE}Bot Durumu:${NC}"
    sudo systemctl status mhrs-bot --no-pager -l
    echo ""
    echo -e "${YELLOW}Log takibi için: sudo journalctl -u mhrs-bot -f${NC}"
    echo -e "${YELLOW}Bot yönetimi için: ./bot-manager.sh status${NC}"
else
    echo -e "${YELLOW}Bot başlatılıyor...${NC}"
    sudo systemctl start mhrs-bot
    sleep 3
    
    if systemctl is-active --quiet mhrs-bot; then
        echo -e "${GREEN}✅ Bot başarıyla başlatıldı!${NC}"
        echo ""
        echo -e "${BLUE}Bot Durumu:${NC}"
        sudo systemctl status mhrs-bot --no-pager -l
        echo ""
        echo -e "${YELLOW}📊 Log takibi için:${NC}"
        echo "sudo journalctl -u mhrs-bot -f"
        echo ""
        echo -e "${YELLOW}🎛️ Bot yönetimi için:${NC}"
        echo "./bot-manager.sh [start|stop|status|logs|botlogs]"
        echo ""
        echo -e "${GREEN}🎯 Bot çalışıyor ve randevu arıyor!${NC}"
    else
        echo -e "${RED}❌ Bot başlatılamadı!${NC}"
        echo ""
        echo -e "${YELLOW}Hata loglarını kontrol edin:${NC}"
        sudo journalctl -u mhrs-bot -n 20 --no-pager
    fi
fi

echo ""
echo -e "${BLUE}=== Hızlı Komutlar ===${NC}"
echo "Bot durumu:     sudo systemctl status mhrs-bot"
echo "Bot durdur:     sudo systemctl stop mhrs-bot"
echo "Bot başlat:     sudo systemctl start mhrs-bot"
echo "Canlı log:      sudo journalctl -u mhrs-bot -f"
echo "Bot logları:    tail -f randevu_log.txt"
echo "Başarılı randevu: cat randevu_basarili.txt"
