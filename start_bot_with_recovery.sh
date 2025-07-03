#!/bin/bash

echo "==================================================="
echo "          MHRS Otomatik Randevu Bot"
echo "       Session Recovery Enabled Version"
echo "         Ubuntu/Linux Compatible"
echo "==================================================="
echo ""
echo "Bot artık session dolma problemlerini otomatik çözebilir!"
echo "Özellikler:"
echo "- Otomatik session recovery (LGN2001 hatası için)"
echo "- Telegram bildirimleri ile session recovery raporları"
echo "- Detaylı debug logu"
echo "- Robust hata yönetimi"
echo "- İlk çalıştığında anında randevu kontrolü"
echo ""
echo "Bot başlatılıyor..."
echo ""

# Script'in bulunduğu dizine git
cd "$(dirname "$0")/MHRS-OtomatikRandevu"

restart_bot() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Bot başlatılıyor..."
    
    # Eski log dosyalarını temizle (7 günden eski)
    find . -name "randevu_log*.txt" -type f -mtime +7 -delete 2>/dev/null || true
    
    # .NET runtime kontrolü
    if ! command -v dotnet &> /dev/null; then
        echo "HATA: .NET runtime bulunamadı!"
        echo "Kurulum için: https://docs.microsoft.com/en-us/dotnet/core/install/linux"
        exit 1
    fi
    
    # Proje dosyası kontrolü
    if [ ! -f "MHRS-OtomatikRandevu.csproj" ]; then
        echo "HATA: Proje dosyası bulunamadı!"
        echo "Doğru dizinde olduğunuzdan emin olun."
        exit 1
    fi
    
    # .env dosyası kontrolü
    if [ ! -f ".env" ]; then
        echo "UYARI: .env dosyası bulunamadı!"
        echo "MHRS_TC ve MHRS_PASSWORD environment variables'larını kontrol edin."
    fi
    
    # Botu çalıştır
    dotnet run
    
    # Exit kodunu kontrol et
    exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Bot başarıyla sonlandı (randevu alındı veya manuel durduruldu)"
        exit 0
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Bot hata ile sonlandı (Exit Code: $exit_code)"
        echo ""
        echo "Session recovery sistemi çalışıyor olabilir..."
        echo "10 saniye sonra yeniden başlatılıyor..."
        echo ""
        sleep 10
        restart_bot
    fi
}

# Ctrl+C yakalamak için trap
trap 'echo -e "\n[$(date '+%Y-%m-%d %H:%M:%S')] Bot durduruldu."; exit 0' INT

restart_bot
