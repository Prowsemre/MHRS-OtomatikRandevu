# PowerShell Background Job ile Sürekli Çalıştırma

## Tek Komutla Başlatma

```powershell
# PowerShell'i Admin olarak aç ve şu komutu çalıştır:
Start-Job -Name "MHRSBot" -ScriptBlock {
    Set-Location "D:\FilesHan\mhrskod\MHRS-OtomatikRandevu"
    while ($true) {
        try {
            Write-Host "[$(Get-Date)] MHRS Bot başlatılıyor..."
            & ".\start_bot_with_recovery.bat"
        }
        catch {
            Write-Host "[$(Get-Date)] Hata: $($_.Exception.Message)"
            Start-Sleep -Seconds 30
        }
    }
}
```

## Job Kontrolü

```powershell
# Job durumunu kontrol et
Get-Job -Name "MHRSBot"

# Job çıktısını gör
Receive-Job -Name "MHRSBot" -Keep

# Job'u durdur
Stop-Job -Name "MHRSBot"
Remove-Job -Name "MHRSBot"
```

## Persistent PowerShell Script

```powershell
# Bu scripti kaydet: run_mhrs_forever.ps1
param(
    [string]$LogPath = ".\mhrs_powershell.log"
)

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    Write-Host $logMessage
    Add-Content -Path $LogPath -Value $logMessage
}

Set-Location "D:\FilesHan\mhrskod\MHRS-OtomatikRandevu"

while ($true) {
    try {
        Write-Log "MHRS Bot başlatılıyor..."
        
        # Bot'u çalıştır
        $process = Start-Process -FilePath ".\start_bot_with_recovery.bat" -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Log "Bot başarıyla sonlandı (randevu alındı)"
            break
        } else {
            Write-Log "Bot hata ile sonlandı (Exit Code: $($process.ExitCode))"
            Write-Log "30 saniye bekleyip yeniden başlatılıyor..."
            Start-Sleep -Seconds 30
        }
    }
    catch {
        Write-Log "Kritik hata: $($_.Exception.Message)"
        Write-Log "60 saniye bekleyip yeniden başlatılıyor..."
        Start-Sleep -Seconds 60
    }
}
```

## Çalıştırma
```powershell
# Script'i çalıştır
.\run_mhrs_forever.ps1
```
