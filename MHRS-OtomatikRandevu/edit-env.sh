#!/bin/bash

# MHRS Bot .env Dosyası Düzenleyici
# .env dosyasını güvenli şekilde nano ile açar

echo "=== .env Dosyası Düzenleyici ==="

# .env dosyası var mı kontrol et
if [ ! -f ".env" ]; then
    echo "❌ .env dosyası bulunamadı!"
    echo ""
    echo "🔧 Önce .env dosyası oluşturalım:"
    echo "   ./make-env.sh"
    echo "   veya"
    echo "   ./create-env.sh"
    echo ""
    exit 1
fi

echo "📝 .env dosyası nano ile açılıyor..."
echo "💡 Düzenleme tamamlandıktan sonra:"
echo "   - Kaydetmek için: Ctrl+O, Enter"
echo "   - Çıkmak için: Ctrl+X"
echo ""
echo "⏳ 3 saniye sonra nano açılacak..."
sleep 3

# Nano ile .env dosyasını aç
nano .env

echo ""
echo "✅ .env dosyası düzenleme tamamlandı!"
echo ""
echo "🔍 Mevcut .env içeriği:"
echo "----------------------------------------"
# Şifreleri gizleyerek göster
while IFS= read -r line; do
    if [[ $line == MHRS_PASSWORD=* ]]; then
        echo "MHRS_PASSWORD=***********"
    else
        echo "$line"
    fi
done < .env
echo "----------------------------------------"
echo ""
echo "✅ .env dosyası hazır! Şimdi botu çalıştırabilirsiniz:"
echo "   dotnet run"
echo "   veya"
echo "   ./bot-manager.sh start"
