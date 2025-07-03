@echo off
echo ===================================================
echo           MHRS Otomatik Randevu Bot
echo      Sürekli Çalışma + Session Recovery Modu
echo ===================================================
echo.
echo Bot artik sürekli calisir ve session problemlerini otomatik cozer!
echo Ozellikler:
echo - Ilk 10 deneme: 3 dakikada bir (sürekli arama)
echo - Sonrasi: Belirlenen saat araliklarinda
echo - Otomatik session recovery (LGN2001 hatasi icin)
echo - Her deneme Telegram'a bildirilir
echo - Detayli debug logu
echo - Robust hata yonetimi
echo.
echo Bot baslatiliyor...
echo.

cd /d "%~dp0MHRS-OtomatikRandevu"

:restart
echo [%date% %time%] Bot baslatiliyor...

rem Eski log dosyalarini temizle (7 gunden eski)
forfiles /p . /s /m randevu_log*.txt /d -7 /c "cmd /c del @path" 2>nul

rem Botu calistir
dotnet run

rem Exit kodunu kontrol et
if %ERRORLEVEL% EQU 0 (
    echo [%date% %time%] Bot basariyla sonlandi (randevu alindi veya manuel durduruldu)
    goto end
) else (
    echo [%date% %time%] Bot hata ile sonlandi (Exit Code: %ERRORLEVEL%)
    echo.
    echo Session recovery sistemi calisiyor olabilir...
    echo 10 saniye sonra yeniden baslatiliyor...
    echo.
    timeout /t 10 /nobreak > nul
    goto restart
)

:end
echo.
echo Cikis icin herhangi bir tusa basin...
pause > nul
