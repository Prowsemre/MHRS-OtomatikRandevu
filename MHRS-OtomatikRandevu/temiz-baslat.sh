#!/bin/bash

# MHRS Bot - Başarı Durumunu Temizle ve Yeniden Başlat
# Bu script randevu başarı durumunu siler ve botu temiz başlatır

echo "🧹 MHRS Bot Temizlik ve Yeniden Başlatma"
echo "========================================"

# Bot servisini durdur
echo "1. Bot servisi durduruluyor..."
sudo systemctl stop mhrs-bot

# Başarı dosyalarını temizle
echo "2. Başarı durumu dosyaları temizleniyor..."
rm -f randevu_basarili.txt
rm -f token.txt
rm -f log.txt
rm -f kayitliRandevular.json
rm -f randevu_log*.txt

echo "✅ Temizlik tamamlandı!"
echo ""

# Bot servisini başlat
echo "3. Bot yeniden başlatılıyor..."
sudo systemctl start mhrs-bot

# Durum kontrol
echo "4. Bot durumu:"
sudo systemctl status mhrs-bot --no-pager -l

echo ""
echo "📊 Logları takip etmek için:"
echo "sudo journalctl -u mhrs-bot -f"
