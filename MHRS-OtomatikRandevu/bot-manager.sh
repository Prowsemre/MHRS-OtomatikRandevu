#!/bin/bash

# MHRS Bot Yönetim Scripti
# Kullanım: ./bot-manager.sh [start|stop|restart|status|logs|install]

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SERVICE_NAME="mhrs-bot"

show_usage() {
    echo -e "${BLUE}MHRS Bot Yönetim Scripti${NC}"
    echo ""
    echo "Kullanım: $0 [komut]"
    echo ""
    echo "Komutlar:"
    echo "  start     - Botu başlat"
    echo "  stop      - Botu durdur"
    echo "  restart   - Botu yeniden başlat"
    echo "  status    - Bot durumunu göster"
    echo "  logs      - Gerçek zamanlı log takibi"
    echo "  botlogs   - Bot log dosyasını göster"
    echo "  install   - Botu kurulum scripti çalıştır"
    echo "  success   - Başarılı randevu dosyasını göster"
    echo "  clean     - Log dosyalarını temizle"
    echo "  env       - .env dosyasını yeniden oluştur"
    echo "  editenv   - .env dosyasını düzenle"
}

start_bot() {
    echo -e "${YELLOW}Bot başlatılıyor...${NC}"
    sudo systemctl start $SERVICE_NAME
    sleep 2
    sudo systemctl status $SERVICE_NAME --no-pager -l
}

stop_bot() {
    echo -e "${YELLOW}Bot durduruluyor...${NC}"
    sudo systemctl stop $SERVICE_NAME
    sleep 2
    echo -e "${GREEN}Bot durduruldu.${NC}"
}

restart_bot() {
    echo -e "${YELLOW}Bot yeniden başlatılıyor...${NC}"
    sudo systemctl restart $SERVICE_NAME
    sleep 2
    sudo systemctl status $SERVICE_NAME --no-pager -l
}

show_status() {
    echo -e "${BLUE}=== Bot Durumu ===${NC}"
    sudo systemctl status $SERVICE_NAME --no-pager -l
    echo ""
    echo -e "${BLUE}=== Son 10 Log Satırı ===${NC}"
    sudo journalctl -u $SERVICE_NAME -n 10 --no-pager
}

show_logs() {
    echo -e "${BLUE}=== Gerçek Zamanlı Log Takibi (Çıkmak için Ctrl+C) ===${NC}"
    echo ""
    sudo journalctl -u $SERVICE_NAME -f
}

show_bot_logs() {
    if [ -f "randevu_log.txt" ]; then
        echo -e "${BLUE}=== Bot Log Dosyası (Son 20 satır) ===${NC}"
        tail -n 20 randevu_log.txt
        echo ""
        echo -e "${YELLOW}Gerçek zamanlı takip için: tail -f randevu_log.txt${NC}"
    else
        echo -e "${RED}Bot log dosyası bulunamadı: randevu_log.txt${NC}"
    fi
}

show_success() {
    if [ -f "randevu_basarili.txt" ]; then
        echo -e "${GREEN}=== Başarılı Randevu Bilgileri ===${NC}"
        cat randevu_basarili.txt
    else
        echo -e "${YELLOW}Henüz başarılı randevu alınmamış.${NC}"
    fi
}

clean_logs() {
    echo -e "${YELLOW}Log dosyaları temizleniyor...${NC}"
    if [ -f "randevu_log.txt" ]; then
        > randevu_log.txt
        echo -e "${GREEN}randevu_log.txt temizlendi.${NC}"
    fi
    if [ -f "randevu_basarili.txt" ]; then
        rm randevu_basarili.txt
        echo -e "${GREEN}randevu_basarili.txt silindi.${NC}"
    fi
    echo -e "${GREEN}Log temizleme tamamlandı.${NC}"
}

install_bot() {
    if [ -f "ubuntu-setup.sh" ]; then
        chmod +x ubuntu-setup.sh
        ./ubuntu-setup.sh
    else
        echo -e "${RED}ubuntu-setup.sh dosyası bulunamadı!${NC}"
    fi
}

create_env() {
    if [ -f "create-env.sh" ]; then
        chmod +x create-env.sh
        ./create-env.sh
    else
        echo -e "${RED}create-env.sh dosyası bulunamadı!${NC}"
    fi
}

edit_env() {
    if [ -f ".env" ]; then
        echo -e "${YELLOW}.env dosyası düzenleniyor...${NC}"
        nano .env
        echo -e "${GREEN}.env dosyası güncellendi.${NC}"
        echo ""
        echo -e "${YELLOW}Değişikliklerin etkili olması için botu yeniden başlatın:${NC}"
        echo "./bot-manager.sh restart"
    else
        echo -e "${RED}.env dosyası bulunamadı!${NC}"
        echo -e "${YELLOW}Oluşturmak için: ./bot-manager.sh env${NC}"
    fi
}

# Ana komut işleme
case "${1:-}" in
    start)
        start_bot
        ;;
    stop)
        stop_bot
        ;;
    restart)
        restart_bot
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    botlogs)
        show_bot_logs
        ;;
    success)
        show_success
        ;;
    clean)
        clean_logs
        ;;
    env)
        create_env
        ;;
    editenv)
        edit_env
        ;;
    install)
        install_bot
        ;;
    *)
        show_usage
        exit 1
        ;;
esac
