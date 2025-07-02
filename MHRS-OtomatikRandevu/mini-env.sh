#!/bin/bash
read -p "TC: " tc && read -s -p "Şifre: " pass && echo "" && echo "MHRS_TC=$tc
MHRS_PASSWORD=$pass
MHRS_PROVINCE_ID=70
MHRS_DISTRICT_ID=1439
MHRS_CLINIC_ID=165
MHRS_HOSPITAL_ID=-1
MHRS_PLACE_ID=-1
MHRS_DOCTOR_ID=-1
MHRS_START_DATE=2025-07-07" > .env && chmod 600 .env && echo "✅ .env oluşturuldu!"
