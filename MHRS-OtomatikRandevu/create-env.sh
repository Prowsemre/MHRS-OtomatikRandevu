#!/bin/bash

# MHRS Bot .env Dosyası Oluşturucu
# Kullanım: ./create-env.sh

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== MHRS Bot .env Dosyası Oluşturucu ===${NC}"
echo ""

# Mevcut .env dosyası kontrolü
if [ -f ".env" ]; then
    echo -e "${YELLOW}⚠️  .env dosyası zaten mevcut!${NC}"
    echo ""
    echo -e "${BLUE}Mevcut içerik:${NC}"
    echo "----------------------------------------"
    cat .env | sed 's/MHRS_PASSWORD=.*/MHRS_PASSWORD=***GIZLI***/'
    echo "----------------------------------------"
    echo ""
    
    read -p "🔄 Yeniden oluşturmak istiyor musunuz? (y/N): " recreate
    
    if [[ ! "$recreate" =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}İşlem iptal edildi.${NC}"
        exit 0
    fi
    
    # Backup oluştur
    cp .env .env.backup
    echo -e "${GREEN}✅ Mevcut .env dosyası .env.backup olarak yedeklendi.${NC}"
    echo ""
fi

echo -e "${YELLOW}📝 MHRS Giriş Bilgilerinizi Girin:${NC}"
echo ""

# TC Kimlik Numarası
while true; do
    read -p "🆔 TC Kimlik Numaranız (11 hane): " tc_number
    
    if [[ "$tc_number" =~ ^[0-9]{11}$ ]]; then
        break
    else
        echo -e "${RED}❌ Hata: TC kimlik numarası 11 haneli olmalı!${NC}"
        echo ""
    fi
done

# MHRS Şifresi
while true; do
    read -s -p "🔐 MHRS Şifreniz: " password
    echo ""
    
    if [ -n "$password" ]; then
        read -s -p "🔐 Şifreyi tekrar girin: " password_confirm
        echo ""
        
        if [ "$password" = "$password_confirm" ]; then
            break
        else
            echo -e "${RED}❌ Şifreler eşleşmiyor! Tekrar deneyin.${NC}"
            echo ""
        fi
    else
        echo -e "${RED}❌ Şifre boş olamaz!${NC}"
        echo ""
    fi
done

echo ""
echo -e "${YELLOW}🏥 Lokasyon Ayarları:${NC}"
echo ""

# İl ID
echo -e "${BLUE}İl seçimi (varsayılan: 70 - Karaman):${NC}"
read -p "🌍 İl ID (Enter = varsayılan): " province_id
province_id=${province_id:-70}

# İlçe ID
echo -e "${BLUE}İlçe seçimi (varsayılan: 1439, -1 = Farketmez):${NC}"
read -p "🏘️ İlçe ID (Enter = varsayılan): " district_id
district_id=${district_id:-1439}

# Klinik ID
echo -e "${BLUE}Klinik seçimi (varsayılan: 165):${NC}"
read -p "🏥 Klinik ID (Enter = varsayılan): " clinic_id
clinic_id=${clinic_id:-165}

# Hastane ID
echo -e "${BLUE}Hastane seçimi (varsayılan: -1 = Farketmez):${NC}"
read -p "🏨 Hastane ID (Enter = farketmez): " hospital_id
hospital_id=${hospital_id:--1}

# Muayene Yeri ID
echo -e "${BLUE}Muayene yeri seçimi (varsayılan: -1 = Farketmez):${NC}"
read -p "📍 Muayene Yeri ID (Enter = farketmez): " place_id
place_id=${place_id:--1}

# Doktor ID
echo -e "${BLUE}Doktor seçimi (varsayılan: -1 = Farketmez):${NC}"
read -p "👨‍⚕️ Doktor ID (Enter = farketmez): " doctor_id
doctor_id=${doctor_id:--1}

echo ""
echo -e "${YELLOW}📅 Tarih Ayarları:${NC}"
echo ""

# Başlangıç tarihi
echo -e "${BLUE}Randevu arama başlangıç tarihi (varsayılan: 2025-07-07):${NC}"
read -p "📅 Başlangıç tarihi (GG-AA-YYYY): " start_date
start_date=${start_date:-07-07-2025}

echo ""
echo -e "${YELLOW}📝 .env dosyası oluşturuluyor...${NC}"

# .env dosyası oluştur
cat > .env << EOF
# MHRS Bot Ayarları - $(date)
# Bu dosyayı kimseyle paylaşmayın!

# MHRS Giriş Bilgileri
MHRS_TC=$tc_number
MHRS_PASSWORD=$password

# Lokasyon ID'leri
# -1 = Farketmez, diğer değerler program içinde gösterilir
MHRS_PROVINCE_ID=$province_id
MHRS_DISTRICT_ID=$district_id
MHRS_CLINIC_ID=$clinic_id
MHRS_HOSPITAL_ID=$hospital_id
MHRS_PLACE_ID=$place_id
MHRS_DOCTOR_ID=$doctor_id

# Tarih Ayarları
MHRS_START_DATE=$start_date
MHRS_END_DATE=

# NOT: Bitiş tarihi otomatik olarak bugünden 12 gün sonrası alınır
EOF

# Dosya izinlerini güvenli yap
chmod 600 .env

echo -e "${GREEN}✅ .env dosyası başarıyla oluşturuldu!${NC}"
echo ""

echo -e "${BLUE}📄 Oluşturulan ayarlar:${NC}"
echo "----------------------------------------"
echo "TC Kimlik: $tc_number"
echo "Şifre: ***GIZLI***"
echo "İl ID: $province_id"
echo "İlçe ID: $district_id"
echo "Klinik ID: $clinic_id"
echo "Hastane ID: $hospital_id"
echo "Muayene Yeri ID: $place_id"
echo "Doktor ID: $doctor_id"
echo "Başlangıç Tarihi: $start_date"
echo "----------------------------------------"
echo ""

echo -e "${GREEN}🔒 Dosya güvenli izinlerle (600) kaydedildi.${NC}"
echo ""

echo -e "${YELLOW}🚀 Sonraki adımlar:${NC}"
echo "1. Botu başlatın: sudo systemctl start mhrs-bot"
echo "2. Durumu kontrol edin: sudo systemctl status mhrs-bot"
echo "3. Log takibi: sudo journalctl -u mhrs-bot -f"
echo ""

# .env dosyasını düzenlemek isterse
read -p "📝 .env dosyasını manuel olarak düzenlemek istiyor musunuz? (y/N): " edit_manual

if [[ "$edit_manual" =~ ^[Yy]$ ]]; then
    nano .env
    echo -e "${GREEN}✅ .env dosyası düzenlendi.${NC}"
fi

echo ""
echo -e "${BLUE}💡 İpucu: .env dosyasını daha sonra düzenlemek için:${NC}"
echo "nano .env"
