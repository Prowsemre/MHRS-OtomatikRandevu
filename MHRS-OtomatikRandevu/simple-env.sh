#!/bin/bash

# MHRS Bot .env Dosyası Oluşturucu
# Kullanım: ./create-env.sh

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== MHRS Bot .env Dosyası Oluşturucu ===${NC}"

# TC Kimlik
while true; do
    read -p "🆔 TC Kimlik (11 hane): " tc
    if [[ "$tc" =~ ^[0-9]{11}$ ]]; then
        break
    else
        echo -e "${RED}Hata: 11 haneli sayı girin!${NC}"
    fi
done

# Şifre
read -s -p "🔐 MHRS Şifre: " password
echo ""

# .env dosyası oluştur
cat > .env << EOF
MHRS_TC=$tc
MHRS_PASSWORD=$password
MHRS_PROVINCE_ID=70
MHRS_DISTRICT_ID=1439
MHRS_CLINIC_ID=165
MHRS_HOSPITAL_ID=-1
MHRS_PLACE_ID=-1
MHRS_DOCTOR_ID=-1
MHRS_START_DATE=2025-07-07
EOF

chmod 600 .env

echo -e "${GREEN}✅ .env dosyası oluşturuldu!${NC}"
echo ""
echo -e "${BLUE}İçerik:${NC}"
echo "TC: $tc"
echo "Şifre: ***"
echo "İl: 70, İlçe: 1439, Klinik: 165"
echo "Hastane/Yer/Doktor: -1 (Farketmez)"
