#!/bin/bash

# MHRS Bot Ubuntu Deployment Script
# Bu script bot'u Ubuntu sunucusuna deploy etmek için kullanılır

set -e  # Hata durumunda dur

echo "🐧 MHRS Bot Ubuntu Deployment Script"
echo "====================================="

# Değişkenler (bunları kendi sunucunuza göre değiştirin)
UBUNTU_USER="ubuntu"
UBUNTU_HOST="your-server-ip"
REMOTE_PATH="/home/$UBUNTU_USER/MHRS-OtomatikRandevu"
LOCAL_PATH="."

# Fonksiyonlar
print_step() {
    echo ""
    echo "📋 $1"
    echo "----------------------------------------"
}

print_error() {
    echo "❌ HATA: $1"
    exit 1
}

print_success() {
    echo "✅ $1"
}

# SSH bağlantı testi
test_ssh_connection() {
    print_step "SSH bağlantısı test ediliyor..."
    if ssh -o ConnectTimeout=10 -o BatchMode=yes $UBUNTU_USER@$UBUNTU_HOST exit 2>/dev/null; then
        print_success "SSH bağlantısı başarılı"
    else
        print_error "SSH bağlantısı başarısız. SSH key'lerinizi kontrol edin."
    fi
}

# Dosyaları transfer et
transfer_files() {
    print_step "Dosyalar Ubuntu sunucusuna transfer ediliyor..."
    
    # Eski dosyaları yedekle
    ssh $UBUNTU_USER@$UBUNTU_HOST "if [ -d '$REMOTE_PATH' ]; then mv '$REMOTE_PATH' '${REMOTE_PATH}_backup_$(date +%Y%m%d_%H%M%S)'; fi"
    
    # Yeni dosyaları kopyala
    scp -r $LOCAL_PATH $UBUNTU_USER@$UBUNTU_HOST:$REMOTE_PATH
    
    print_success "Dosya transferi tamamlandı"
}

# Ubuntu'da .NET kurulumunu kontrol et
check_dotnet() {
    print_step ".NET runtime kontrol ediliyor..."
    
    if ssh $UBUNTU_USER@$UBUNTU_HOST "command -v dotnet &> /dev/null"; then
        DOTNET_VERSION=$(ssh $UBUNTU_USER@$UBUNTU_HOST "dotnet --version")
        print_success ".NET runtime bulundu: $DOTNET_VERSION"
    else
        print_step ".NET runtime kuruluyor..."
        ssh $UBUNTU_USER@$UBUNTU_HOST "
            wget https://packages.microsoft.com/config/ubuntu/\$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
            sudo dpkg -i packages-microsoft-prod.deb
            rm packages-microsoft-prod.deb
            sudo apt update
            sudo apt install -y dotnet-runtime-8.0
        "
        print_success ".NET runtime kuruldu"
    fi
}

# İzinleri ayarla
set_permissions() {
    print_step "Dosya izinleri ayarlanıyor..."
    
    ssh $UBUNTU_USER@$UBUNTU_HOST "
        cd $REMOTE_PATH
        chmod +x start_bot_with_recovery.sh
        chmod 644 MHRS-OtomatikRandevu/.env
        find . -type f -name '*.cs' -exec chmod 644 {} \;
        find . -type f -name '*.csproj' -exec chmod 644 {} \;
    "
    
    print_success "İzinler ayarlandı"
}

# Projeyi build et
build_project() {
    print_step "Proje build ediliyor..."
    
    ssh $UBUNTU_USER@$UBUNTU_HOST "
        cd $REMOTE_PATH/MHRS-OtomatikRandevu
        dotnet restore
        dotnet build --configuration Release
    "
    
    print_success "Proje build edildi"
}

# Systemd service oluştur
create_service() {
    print_step "Systemd service oluşturuluyor..."
    
    ssh $UBUNTU_USER@$UBUNTU_HOST "
        sudo tee /etc/systemd/system/mhrs-bot.service > /dev/null <<EOF
[Unit]
Description=MHRS Otomatik Randevu Bot
After=network.target

[Service]
Type=simple
User=$UBUNTU_USER
WorkingDirectory=$REMOTE_PATH
ExecStart=$REMOTE_PATH/start_bot_with_recovery.sh
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
    "
    
    ssh $UBUNTU_USER@$UBUNTU_HOST "
        sudo systemctl daemon-reload
        sudo systemctl enable mhrs-bot
    "
    
    print_success "Systemd service oluşturuldu"
}

# Test çalıştırması
test_bot() {
    print_step "Bot test ediliyor..."
    
    ssh $UBUNTU_USER@$UBUNTU_HOST "
        cd $REMOTE_PATH
        timeout 30s ./start_bot_with_recovery.sh || true
    "
    
    print_success "Test tamamlandı"
}

# Service'i başlat
start_service() {
    print_step "Bot service'i başlatılıyor..."
    
    ssh $UBUNTU_USER@$UBUNTU_HOST "
        sudo systemctl start mhrs-bot
        sudo systemctl status mhrs-bot --no-pager
    "
    
    print_success "Bot service'i başlatıldı"
}

# Main deployment flow
main() {
    echo "🚀 Deployment başlıyor..."
    echo ""
    
    # Kullanıcıdan onay al
    read -p "Ubuntu sunucusuna deploy etmek istediğinizden emin misiniz? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Deployment iptal edildi."
        exit 1
    fi
    
    # Deployment adımları
    test_ssh_connection
    transfer_files
    check_dotnet
    set_permissions
    build_project
    create_service
    test_bot
    start_service
    
    echo ""
    echo "🎉 Deployment tamamlandı!"
    echo ""
    echo "📋 Kullanışlı komutlar:"
    echo "   Status:    ssh $UBUNTU_USER@$UBUNTU_HOST 'sudo systemctl status mhrs-bot'"
    echo "   Logs:      ssh $UBUNTU_USER@$UBUNTU_HOST 'sudo journalctl -u mhrs-bot -f'"
    echo "   Stop:      ssh $UBUNTU_USER@$UBUNTU_HOST 'sudo systemctl stop mhrs-bot'"
    echo "   Start:     ssh $UBUNTU_USER@$UBUNTU_HOST 'sudo systemctl start mhrs-bot'"
    echo "   Restart:   ssh $UBUNTU_USER@$UBUNTU_HOST 'sudo systemctl restart mhrs-bot'"
    echo ""
    echo "🔍 Log takibi için:"
    echo "   ssh $UBUNTU_USER@$UBUNTU_HOST 'tail -f $REMOTE_PATH/MHRS-OtomatikRandevu/randevu_log.txt'"
}

# Script'i çalıştır
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
