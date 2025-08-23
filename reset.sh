#!/bin/bash

# MHRS Bot - Tek Komut Yeniden Başlatma
# Kullanım: curl -s https://raw.githubusercontent.com/TunahanDilercan/MHRS-OtomatikRandevu/master/reset.sh | bash

echo "🔄 MHRS Bot Reset"
cd ~/MHRS-OtomatikRandevu/MHRS-OtomatikRandevu 2>/dev/null || {
    echo "❌ Bot dizini bulunamadı!"
    exit 1
}

sudo systemctl stop mhrs-bot
rm -f randevu_basarili.txt token.txt log.txt kayitliRandevular.json
sudo systemctl start mhrs-bot
echo "✅ Bot temizlendi ve yeniden başlatıldı!"
echo "📊 Log: sudo journalctl -u mhrs-bot -f"
