#!/bin/bash

# MHRS Bot .env Düzenleme Rehberi
# Sunucuda .env dosyasını doğru konumda düzenleme

echo "📝 .env Dosyası Düzenleme Rehberi"
echo "================================"

# Mevcut konumu kontrol et
if [ -f ".env" ]; then
    echo "✅ .env dosyası mevcut konumda bulundu"
elif [ -f "MHRS-OtomatikRandevu/.env" ]; then
    echo "✅ .env dosyası MHRS-OtomatikRandevu dizininde bulundu"
    cd MHRS-OtomatikRandevu
elif [ -f "../.env" ]; then
    echo "✅ .env dosyası üst dizinde bulundu"
    cd ..
else
    echo "❌ .env dosyası bulunamadı!"
    echo "🔧 Önce .env dosyası oluşturun:"
    echo "   ./make-env.sh"
    exit 1
fi

echo ""
echo "📂 Mevcut konum: $(pwd)"
echo "📝 .env dosyası nano ile açılıyor..."
echo ""
echo "💡 Nano Kullanım Kılavuzu:"
echo "   - Kaydetmek: Ctrl+O → Enter"
echo "   - Çıkmak: Ctrl+X"
echo "   - Arama: Ctrl+W"
echo "   - Satır numarasına git: Ctrl+G"
echo ""
echo "⏳ 3 saniye sonra nano açılacak..."
sleep 3

# Nano ile .env dosyasını aç
nano .env

echo ""
echo "✅ .env dosyası düzenleme tamamlandı!"
echo ""
echo "🔍 Mevcut .env içeriğinin özeti:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# .env içeriğini güvenli şekilde göster (şifreleri gizle)
while IFS= read -r line; do
    if [[ $line == MHRS_PASSWORD=* ]]; then
        echo "MHRS_PASSWORD=***********"
    elif [[ $line == TELEGRAM_BOT_TOKEN=* ]]; then
        echo "TELEGRAM_BOT_TOKEN=***********:***********"
    elif [[ $line == EMAIL_PASSWORD=* ]]; then
        echo "EMAIL_PASSWORD=***********"
    elif [[ $line == TWILIO_AUTH_TOKEN=* ]]; then
        echo "TWILIO_AUTH_TOKEN=***********"
    else
        echo "$line"
    fi
done < .env

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🚀 Botu başlatmak için:"
echo "   ./bot-manager.sh start"
echo ""
echo "📊 Logları takip etmek için:"
echo "   ./bot-manager.sh logs"
