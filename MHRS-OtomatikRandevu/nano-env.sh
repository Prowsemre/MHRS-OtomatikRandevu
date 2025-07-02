#!/bin/bash

# Hızlı .env düzenleme scripti
# Kullanım: ./nano-env.sh

if [ ! -f ".env" ]; then
    echo "❌ .env dosyası yok! Önce oluşturalım:"
    ./make-env.sh
fi

echo "📝 .env dosyası nano ile açılıyor..."
nano .env
echo "✅ Düzenleme tamamlandı!"
