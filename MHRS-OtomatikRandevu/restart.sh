#!/bin/bash

# MHRS Bot - Hızlı Yeniden Başlatma
# Tek komutla bot durdur, temizle, başlat

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔄 MHRS Bot Hızlı Restart${NC}"
echo "========================"

# 1. Stop & Clean
echo -e "${YELLOW}1. Bot durduruluyor ve temizleniyor...${NC}"
sudo systemctl stop mhrs-bot 2>/dev/null
rm -f randevu_basarili.txt token.txt log.txt kayitliRandevular.json randevu_log*.txt 2>/dev/null

# 2. Start
echo -e "${YELLOW}2. Bot başlatılıyor...${NC}"
sudo systemctl start mhrs-bot

# 3. Status
sleep 2
if systemctl is-active mhrs-bot >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Bot başarıyla başlatıldı!${NC}"
else
    echo -e "${RED}❌ Bot başlatma hatası!${NC}"
    echo -e "${YELLOW}Durum kontrolü:${NC}"
    sudo systemctl status mhrs-bot --no-pager
    exit 1
fi

echo ""
echo -e "${BLUE}📊 İzleme komutları:${NC}"
echo -e "${GREEN}Canlı log:${NC}    sudo journalctl -u mhrs-bot -f"
echo -e "${GREEN}Bot durumu:${NC}   sudo systemctl status mhrs-bot"
echo -e "${GREEN}Son loglar:${NC}   sudo journalctl -u mhrs-bot -n 20"
