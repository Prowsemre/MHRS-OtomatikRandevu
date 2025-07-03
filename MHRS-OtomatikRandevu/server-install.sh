#!/bin/bash

# MHRS Bot Sunucu Kurulum Scripti
# Tek komutla tüm kurulumu yapar

echo "🖥️  MHRS Bot Sunucu Kurulumu Başlıyor..."
echo "========================================"

# Sistemi güncelle
echo "📦 Sistem güncelleniyor..."
sudo apt update && sudo apt upgrade -y

# Gerekli paketleri yükle
echo "🛠️  Gerekli paketler yükleniyor..."
sudo apt install git nano curl wget -y

# .NET 7.0 SDK yükle
echo "⚙️  .NET 7.0 SDK yükleniyor..."
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update
sudo apt install -y dotnet-sdk-7.0

# .NET sürümünü kontrol et
echo "✅ .NET SDK sürümü:"
dotnet --version

echo ""
echo "🎯 Kurulum tamamlandı!"
echo "📋 Şimdi şu komutları çalıştırın:"
echo ""
echo "1. Projeyi indirin:"
echo "   git clone https://github.com/KULLANICI_ADINIZ/MHRS-OtomatikRandevu.git"
echo ""
echo "2. Dizine gidin:"
echo "   cd MHRS-OtomatikRandevu"
echo ""
echo "3. Kurulum yapın:"
echo "   ./MHRS-OtomatikRandevu/install.sh"
echo ""
echo "4. .env dosyasını düzenleyin:"
echo "   ./MHRS-OtomatikRandevu/bot-manager.sh editenv"
echo ""
echo "5. Botu başlatın:"
echo "   ./MHRS-OtomatikRandevu/bot-manager.sh start"
