#!/bin/bash

# MHRS Bot - Sadece Temizlik
# Bot'u başlatmaz, sadece başarı durumu ve cache dosyalarını temizler

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧹 MHRS Bot Temizlik Aracı${NC}"
echo "=============================="

# Bot durumunu kontrol et
if systemctl is-active mhrs-bot >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Bot şu anda çalışıyor!${NC}"
    echo -e "${YELLOW}   Temizlik için önce durdurun: sudo systemctl stop mhrs-bot${NC}"
    echo ""
    read -p "Bot'u otomatik durdurup temizlik yapmak istiyor musunuz? (y/N): " stop_bot
    
    if [[ "$stop_bot" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Bot durduruluyor...${NC}"
        sudo systemctl stop mhrs-bot
        echo -e "${GREEN}✅ Bot durduruldu${NC}"
    else
        echo -e "${RED}❌ Temizlik iptal edildi. Önce bot'u durdurun.${NC}"
        exit 1
    fi
fi

echo ""
echo -e "${YELLOW}🗑️  Başarı durumu ve cache dosyaları temizleniyor...${NC}"

# Temizlenecek dosyalar listesi
files_to_clean=(
    "randevu_basarili.txt"
    "token.txt"
    "log.txt"
    "kayitliRandevular.json"
    "randevu_log*.txt"
)

cleaned_count=0

for file in "${files_to_clean[@]}"; do
    if ls $file 1> /dev/null 2>&1; then
        rm -f $file
        echo -e "${GREEN}   ✅ $file silindi${NC}"
        ((cleaned_count++))
    fi
done

echo ""
if [ $cleaned_count -eq 0 ]; then
    echo -e "${GREEN}✨ Zaten temiz! Silinecek dosya bulunamadı.${NC}"
else
    echo -e "${GREEN}✅ Temizlik tamamlandı! $cleaned_count dosya silindi.${NC}"
fi

echo ""
echo -e "${BLUE}📋 Bot'u manuel başlatmak için:${NC}"
echo -e "${GREEN}   sudo systemctl start mhrs-bot${NC}"
echo ""
echo -e "${BLUE}📊 Log takibi için:${NC}"
echo -e "${GREEN}   sudo journalctl -u mhrs-bot -f${NC}"
