# Ubuntu Sunucuda MHRS Bot Kurulumu

## 1. .NET SDK Kurulumu
```bash
# Microsoft repository key ekle
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

# .NET SDK 7.0 kur
sudo apt-get update
sudo apt-get install -y dotnet-sdk-7.0

# Kurulum kontrolü
dotnet --version
```

## 2. Proje Dosyalarını Sunucuya İndir

### Yöntem 1: GitHub'dan Clone (Önerilen)
```bash
# Git kurulumu (yoksa)
sudo apt-get install -y git

# Proje klasörü oluştur
mkdir -p ~/mhrs-bot
cd ~/mhrs-bot

# GitHub'dan projeyi clone et
git clone https://github.com/TunahanDilercan/MHRS-OtomatikRandevu.git .

# Ana dizine git
cd MHRS-OtomatikRandevu
```

### Yöntem 2: SCP ile Kopyala
```bash
# Local bilgisayardan sunucuya kopyala
scp -r /path/to/MHRS-OtomatikRandevu user@server-ip:~/mhrs-bot/

# Sunucuda dizine git
cd ~/mhrs-bot/MHRS-OtomatikRandevu
```

### Yöntem 3: Wget ile ZIP İndir
```bash
# GitHub'dan ZIP olarak indir
wget https://github.com/TunahanDilercan/MHRS-OtomatikRandevu/archive/main.zip

# ZIP'i çıkart
unzip main.zip
mv MHRS-OtomatikRandevu-main ~/mhrs-bot/MHRS-OtomatikRandevu
cd ~/mhrs-bot/MHRS-OtomatikRandevu
```

## 3. .env Dosyasını Düzenle
```bash
cd ~/mhrs-bot/MHRS-OtomatikRandevu
nano .env
```

## 4. Projeyi Derle ve Test Et
```bash
# Proje dizinine git
cd ~/mhrs-bot/MHRS-OtomatikRandevu

# Projeyi derle
dotnet build

# Test çalıştır (kısa süre)
dotnet run
```

## 5. Systemd Servisi Oluştur (Sürekli Çalışması İçin)
```bash
# Servis dosyası oluştur
sudo nano /etc/systemd/system/mhrs-bot.service
```

Servis dosyası içeriği:
```ini
[Unit]
Description=MHRS Otomatik Randevu Botu
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/mhrs-bot/MHRS-OtomatikRandevu
ExecStart=/usr/bin/dotnet run
Restart=always
RestartSec=30
Environment=ASPNETCORE_ENVIRONMENT=Production

[Install]
WantedBy=multi-user.target
```

## 6. Servisi Etkinleştir
```bash
# Systemd servislerini yenile
sudo systemctl daemon-reload

# Servisi etkinleştir (otomatik başlama)
sudo systemctl enable mhrs-bot

# Servisi başlat
sudo systemctl start mhrs-bot

# Servis durumunu kontrol et
sudo systemctl status mhrs-bot
```

## 7. Log Takibi
```bash
# Gerçek zamanlı log takibi
sudo journalctl -u mhrs-bot -f

# Son 100 log satırı
sudo journalctl -u mhrs-bot -n 100

# Bot log dosyası
tail -f ~/mhrs-bot/MHRS-OtomatikRandevu/randevu_log.txt
```

## 8. Servis Yönetimi
```bash
# Servisi durdur
sudo systemctl stop mhrs-bot

# Servisi yeniden başlat
sudo systemctl restart mhrs-bot

# Servis durumu
sudo systemctl status mhrs-bot

# Servisi devre dışı bırak
sudo systemctl disable mhrs-bot
```

## 9. Güvenlik Önerileri
```bash
# Sadece gerekli portları aç
sudo ufw enable
sudo ufw allow 22  # SSH

# .env dosya izinlerini sınırla
chmod 600 .env

# Log dosyası boyutunu sınırla
sudo logrotate -d /etc/logrotate.conf
```

## 10. Performans İzleme
```bash
# CPU ve RAM kullanımı
htop

# Disk kullanımı
df -h

# Bot process kontrolü
ps aux | grep dotnet
```
