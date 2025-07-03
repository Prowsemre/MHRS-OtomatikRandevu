# Windows Task Scheduler ile Sürekli Çalıştırma

## Görev Oluşturma

### 1. Task Scheduler Aç
- Windows + R → `taskschd.msc`
- Veya "Task Scheduler" ara

### 2. Yeni Görev Oluştur
- Sağ tıkla → "Create Basic Task"
- İsim: "MHRS Bot"
- Açıklama: "MHRS Otomatik Randevu Bot"

### 3. Trigger (Tetikleyici)
- **When to start**: "When the computer starts"
- Veya "Daily" seçip her 5 dakikada bir kontrol

### 4. Action (Eylem)
- **Action**: "Start a program"
- **Program/script**: `D:\FilesHan\mhrskod\MHRS-OtomatikRandevu\start_bot_with_recovery.bat`
- **Start in**: `D:\FilesHan\mhrskod\MHRS-OtomatikRandevu`

### 5. Conditions (Koşullar)
- ✅ "Start only if the computer is on AC power" - KALDIR
- ✅ "Wake the computer to run this task" - EKLE
- ✅ "Start only if the network connection is available" - EKLE

### 6. Settings (Ayarlar)
- ✅ "Allow task to be run on demand"
- ✅ "Run task as soon as possible after a scheduled start is missed"
- ✅ "If the running task does not end when requested, force it to stop"
- **Stop task if it runs longer than**: 3 days (randevu bulana kadar)
- ✅ "If the task is already running, then the following rule applies": "Do not start a new instance"

### 7. İleri Ayarlar
- **Security options**: "Run only when user is logged on"
- **Run with highest privileges**: ✅ İşaretle

## Manuel Test
```cmd
schtasks /run /tn "MHRS Bot"
```

## Görevi Devre Dışı Bırakma
```cmd
schtasks /change /tn "MHRS Bot" /disable
```

## Görevi Silme
```cmd
schtasks /delete /tn "MHRS Bot"
```
