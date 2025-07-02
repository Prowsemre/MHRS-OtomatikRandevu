#!/usr/bin/env bash
set -euo pipefail

cd /root/MHRS-OtomatikRandevu

# flock kilidi: eş zamanlı iki örnek çalışmasın
flock -n /tmp/mhrs-bot.lock \
      ./bin/Release/net7.0/linux-x64/publish/MHRS-OtomatikRandevu
