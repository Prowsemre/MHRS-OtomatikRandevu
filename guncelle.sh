#!/bin/bash

# MHRS Bot Güncelleme Komutları
# Bu komutları sunucunuzda çalıştırın

echo "=== MHRS Bot Güncelleme ==="
echo "Mevcut bot durduruluyor..."

# 1. Bot servisini durdur
sudo systemctl stop mhrs-bot
sudo systemctl disable mhrs-bot

# 2. Eski dosyaları temizle (opsiyonel - yedek almak istiyorsanız atlayın)
# cd ~
# rm -rf MHRS-OtomatikRandevu_OLD
# mv MHRS-OtomatikRandevu MHRS-OtomatikRandevu_OLD

# 3. Yeni versiyonu çek
cd ~/MHRS-OtomatikRandevu
git pull origin master

# VEYA tamamen yeni indirmek isterseniz:
# cd ~
# git clone https://github.com/TunahanDilercan/MHRS-OtomatikRandevu.git
# cd MHRS-OtomatikRandevu/MHRS-OtomatikRandevu

# 4. .env dosyanızı kontrol edin
echo ""
echo "📝 .env dosyanızı kontrol edin:"
echo "nano ~/MHRS-OtomatikRandevu/MHRS-OtomatikRandevu/.env"

# 5. Servisi yeniden başlat
sudo systemctl enable mhrs-bot
sudo systemctl start mhrs-bot

# 6. Durumu kontrol et
sudo systemctl status mhrs-bot
echo ""
echo "📊 Log takibi için:"
echo "sudo journalctl -u mhrs-bot -f"
