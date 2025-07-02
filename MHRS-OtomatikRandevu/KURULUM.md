# 🚀 MHRS Bot - Ubuntu Tek Komut Kurulum

GitHub repository'niz hazır! Artık kullanıcılar tek komutla kurulum yapabilir:

## ⚡ Tek Komutla Kurulum

```bash
curl -sSL https://raw.githubusercontent.com/TunahanDilercan/MHRS-OtomatikRandevu/main/MHRS-OtomatikRandevu/install.sh | bash
```

## 📋 Kurulum Sonrası Adımlar

1. **📝 .env dosyasını düzenle:**
```bash
cd ~/mhrs-bot/MHRS-OtomatikRandevu
nano .env
```

2. **🎯 TC kimlik ve şifrenizi girin:**
```env
MHRS_TC=12345678901          # Gerçek TC kimlik numaranız
MHRS_PASSWORD=your_password  # MHRS şifreniz
```

3. **🚀 Botu başlatın:**
```bash
sudo systemctl start mhrs-bot
```

4. **📊 Durumu kontrol edin:**
```bash
sudo systemctl status mhrs-bot
```

5. **📈 Log takibi:**
```bash
sudo journalctl -u mhrs-bot -f
```

## 🎛️ Bot Yönetimi

```bash
# Bot yönetim scriptini kullan
cd ~/mhrs-bot/MHRS-OtomatikRandevu

./bot-manager.sh start     # Başlat
./bot-manager.sh stop      # Durdur
./bot-manager.sh status    # Durum
./bot-manager.sh logs      # Canlı log
./bot-manager.sh botlogs   # Bot logları
./bot-manager.sh success   # Başarılı randevu
```

## 🔄 Güncelleme

Bot otomatik olarak GitHub'dan güncellemeleri alır. Manuel güncelleme için:

```bash
cd ~/mhrs-bot/MHRS-OtomatikRandevu
git pull origin main
sudo systemctl restart mhrs-bot
```

## 🎯 GitHub Repository

**Repository:** https://github.com/TunahanDilercan/MHRS-OtomatikRandevu

Kurulum tamamlandıktan sonra bot:
- ✅ Sürekli çalışacak
- ✅ Sistem açılışında otomatik başlayacak
- ✅ Randevu bulana kadar arayacak
- ✅ Başarılı olunca duracak
- ✅ Tüm işlemleri loglayacak
