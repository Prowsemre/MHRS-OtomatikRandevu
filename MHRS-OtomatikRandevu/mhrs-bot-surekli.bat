@echo off
title MHRS Bot - Otomatik Yeniden Baslat
echo =====================================
echo MHRS Otomatik Randevu Botu
echo Otomatik Yeniden Baslatma Modu
echo =====================================
echo.

:start
echo [%time%] Bot baslatiliyor...
cd /d "D:\FilesHan\mhrskod\MHRS-OtomatikRandevu\MHRS-OtomatikRandevu"
dotnet run

echo.
echo [%time%] Bot durdu. 30 saniye bekleyip yeniden baslatiliyor...
echo =====================================
timeout /t 30
goto start
