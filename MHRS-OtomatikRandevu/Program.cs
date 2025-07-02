using MHRS_OtomatikRandevu.Models;
using MHRS_OtomatikRandevu.Models.RequestModels;
using MHRS_OtomatikRandevu.Models.ResponseModels;
using MHRS_OtomatikRandevu.Services;
using MHRS_OtomatikRandevu.Services.Abstracts;
using MHRS_OtomatikRandevu.Urls;
using MHRS_OtomatikRandevu.Utils;
using System.Net;
using System.Globalization;   // saat kontrolü için

namespace MHRS_OtomatikRandevu
{
    public class Program
    {
        static string? TC_NO;
        static string? SIFRE;

        const string TOKEN_FILE_NAME = "token.txt";
        const string LOG_FILE_NAME = "randevu_log.txt";
        static string? JWT_TOKEN;
        static DateTime TOKEN_END_DATE;

        static IClientService? _client;
        static INotificationService? _notificationService;
        static bool IsWithinAllowedWindow(DateTime t)
        {
            var h = t.Hour;  var m = t.Minute;

            bool hourly  = (m >= 57 || m <= 4);
            bool night   = (h == 0 && m >= 1 && m <= 6) ||
                           (h == 1 && m == 59) ||
                           (h == 2 && m <= 3);
            bool morning = (h == 9 && m >= 55) || (h == 10 && m <= 15);
            bool evening = (h == 19 && m >= 55) || (h == 20 && m <= 15);

            return hourly || night || morning || evening;
        }

        // Konsolda şifreyi gizli okuma fonksiyonu
        static string ReadPassword()
        {
            var pwd = string.Empty;
            ConsoleKeyInfo key;
            do
            {
                key = Console.ReadKey(true);
                if (key.Key == ConsoleKey.Enter) break;
                if (key.Key == ConsoleKey.Backspace && pwd.Length > 0)
                {
                    pwd = pwd[..^1];
                    Console.Write("\b \b");
                }
                else if (!char.IsControl(key.KeyChar))
                {
                    pwd += key.KeyChar;
                    Console.Write("*");
                }
            } while (true);
            Console.WriteLine();
            return pwd;
        }

        static void Main(string[] args)
        {
            // .env dosyasını elle yükle (DotNetEnv'e gerek kalmadan)
            if (File.Exists(".env"))
            {
                foreach (var line in File.ReadAllLines(".env"))
                {
                    var parts = line.Split('=', 2);
                    if (parts.Length == 2)
                        Environment.SetEnvironmentVariable(parts[0], parts[1]);
                }
            }

            _client = new ClientService();
            _notificationService = new NotificationService();

            // Önceki başarılı randevu kontrolü
            var successFilePath = Path.Combine(Directory.GetCurrentDirectory(), "randevu_basarili.txt");
            if (File.Exists(successFilePath))
            {
                Console.WriteLine("⚠️  UYARI: Daha önce başarılı bir randevu alınmış!");
                Console.WriteLine("📄 Detaylar:");
                Console.WriteLine(File.ReadAllText(successFilePath));
                Console.WriteLine("\n❓ Yine de devam etmek istiyor musunuz? (y/N): ");
                var answer = Console.ReadLine()?.ToLower();
                if (answer != "y" && answer != "yes")
                {
                    Console.WriteLine("Bot durduruldu.");
                    return;
                }
                Console.WriteLine("▶️  Bot devam ediyor...\n");
            }

            // ENV DEĞERLERİNİ OKU
            TC_NO = Environment.GetEnvironmentVariable("MHRS_TC") ?? string.Empty;
            SIFRE = Environment.GetEnvironmentVariable("MHRS_PASSWORD") ?? string.Empty;
            
            // Tarih ve bildirim ayarlarını oku
            ENV_START_DATE = Environment.GetEnvironmentVariable("MHRS_START_DATE") ?? "2025-07-07";
            var telegramFreq = Environment.GetEnvironmentVariable("TELEGRAM_NOTIFY_FREQUENCY");
            if (!string.IsNullOrEmpty(telegramFreq) && int.TryParse(telegramFreq, out int freq))
                TELEGRAM_NOTIFY_FREQUENCY = freq;

            // Sunucu ortamında interaktif giriş yapılmasın, eksikse hata verip çık
            if (string.IsNullOrEmpty(TC_NO) || string.IsNullOrEmpty(SIFRE))
            {
                Console.WriteLine("[ERROR] MHRS_TC veya MHRS_PASSWORD çevre değişkenleri bulunamadı. Lütfen .env dosyasını kontrol edin.");
                return;
            }
            else
            {
                Console.WriteLine($"[INFO] TC ve şifre çevre değişkenlerinden yüklendi.");
            }

            // ÖNCE LOGIN YAP VE JWT TOKEN AL
            Console.WriteLine("[INFO] MHRS sistemine giriş yapılıyor...");
            var loginResult = GetToken(_client!);
            if (loginResult == null || string.IsNullOrEmpty(loginResult.Token))
            {
                Console.WriteLine("[ERROR] MHRS sistemine giriş yapılamadı! TC kimlik ve şifrenizi kontrol edin.");
                return;
            }
            JWT_TOKEN = loginResult.Token;
            TOKEN_END_DATE = loginResult.Expiration;
            _client!.AddOrUpdateAuthorizationHeader(JWT_TOKEN);
            Console.WriteLine("[INFO] MHRS sistemine başarıyla giriş yapıldı.");

            // İl Seçim Bölümü
            var provinceIdStr = Environment.GetEnvironmentVariable("MHRS_PROVINCE_ID");
            int provinceIndex = !string.IsNullOrEmpty(provinceIdStr) ? int.Parse(provinceIdStr) : -1;
            var provinceListResponse = _client.GetSimple<List<GenericResponseModel>>(MHRSUrls.BaseUrl, MHRSUrls.GetProvinces);
            if (provinceListResponse == null || !provinceListResponse.Any())
            {
                ConsoleUtil.WriteText("Bir hata meydana geldi!", 2000);
                return;
            }
            var provinceList = provinceListResponse
                                    .DistinctBy(x => x.ValueAsInt)
                                    .OrderBy(x => x.ValueAsInt)
                                    .ToList();
            var istanbulSubLocationIds = new int[] { 341, 342 };
            while ((provinceIndex < 1 || provinceIndex > 81) && !istanbulSubLocationIds.Contains(provinceIndex))
            {
                Console.Clear();
                Console.WriteLine("-------------------------------------------");
                for (int i = 0; i < provinceList.Count; i++)
                {
                    // ID'yi de göster
                    Console.WriteLine($"{i + 1}-{provinceList[i].Text} (ID: {provinceList[i].ValueAsInt})");
                }
                Console.WriteLine("-------------------------------------------");
                Console.Write("İl Numarası (Plaka) Giriniz: ");
                provinceIndex = Convert.ToInt32(Console.ReadLine());

                if (provinceIndex == 34)
                {
                    int subLocationIndex;
                    do
                    {
                        Console.Clear();
                        Console.WriteLine("-------------------------------------------");
                        Console.WriteLine($"0-İSTANBUL\n1-İSTANBUL (AVRUPA)\n2-İSTANBUL (ANADOLU)");
                        Console.WriteLine("-------------------------------------------");

                        Console.Write(@"Alt Bölge Numarası Giriniz: ");
                        subLocationIndex = Convert.ToInt32(Console.ReadLine()); ;
                    } while (subLocationIndex < 0 && subLocationIndex > 2);

                    if (subLocationIndex != 0)
                        provinceIndex = int.Parse("34" + subLocationIndex);
                }
            }

            // İlçe Seçim Bölümü
            var districtIdStr = Environment.GetEnvironmentVariable("MHRS_DISTRICT_ID");
            int districtIndex = -2; // -2: hiç seçilmedi, -1: FARKETMEZ
            var districtList = _client.GetSimple<List<GenericResponseModel>>(MHRSUrls.BaseUrl, string.Format(MHRSUrls.GetDistricts, provinceIndex));
            if (districtList == null || !districtList.Any())
            {
                ConsoleUtil.WriteText("Bir hata meydana geldi!", 2000);
                return;
            }
            if (!string.IsNullOrEmpty(districtIdStr))
            {
                int envDistrictId = int.Parse(districtIdStr);
                if (envDistrictId == -1 || envDistrictId == 0)
                {
                    districtIndex = -1;
                }
                else
                {
                    var found = districtList.FirstOrDefault(x => x.ValueAsInt == envDistrictId);
                    if (found != null)
                        districtIndex = found.ValueAsInt;
                    else
                        districtIndex = -2; // ID bulunamazsa kullanıcıdan istenir
                }
            }
            while (districtIndex < -1)
            {
                Console.Clear();
                Console.WriteLine("-------------------------------------------");
                Console.WriteLine("0-FARKETMEZ");
                for (int i = 0; i < districtList.Count; i++)
                {
                    // ID'yi de göster
                    Console.WriteLine($"{i + 1}-{districtList[i].Text} (ID: {districtList[i].ValueAsInt})");
                }
                Console.WriteLine("-------------------------------------------");
                Console.Write("İlçe Numarası Giriniz: ");
                int input = Convert.ToInt32(Console.ReadLine());
                if (input == 0)
                    districtIndex = -1;
                else if (input > 0 && input <= districtList.Count)
                    districtIndex = districtList[input - 1].ValueAsInt;
            }

            // Klinik Seçim Bölümü
            var clinicIdStr = Environment.GetEnvironmentVariable("MHRS_CLINIC_ID");
            int clinicIndex = -1;
            var clinicListResponse = _client.Get<List<GenericResponseModel>>(MHRSUrls.BaseUrl, string.Format(MHRSUrls.GetClinics, provinceIndex, districtIndex));
            if (!clinicListResponse.Success && (clinicListResponse.Data == null || !clinicListResponse.Data.Any()))
            {
                ConsoleUtil.WriteText("Bir hata meydana geldi!", 2000);
                return;
            }
            var clinicList = clinicListResponse.Data;
            if (!string.IsNullOrEmpty(clinicIdStr))
            {
                int envClinicId = int.Parse(clinicIdStr);
                var found = clinicList.FirstOrDefault(x => x.ValueAsInt == envClinicId);
                if (found != null)
                    clinicIndex = found.ValueAsInt;
            }
            while (clinicIndex < 0)
            {
                Console.Clear();
                Console.WriteLine("-------------------------------------------");
                for (int i = 0; i < clinicList.Count; i++)
                {
                    // ID'yi de göster
                    Console.WriteLine($"{i + 1}-{clinicList[i].Text} (ID: {clinicList[i].ValueAsInt})");
                }
                Console.WriteLine("-------------------------------------------");
                Console.Write("Klinik Numarası Giriniz: ");
                int input = Convert.ToInt32(Console.ReadLine());
                if (input > 0 && input <= clinicList.Count)
                    clinicIndex = clinicList[input - 1].ValueAsInt;
            }

            // Hastane Seçim Bölümü
            var hospitalIdStr = Environment.GetEnvironmentVariable("MHRS_HOSPITAL_ID");
            int hospitalIndex = -1;
            var hospitalListResponse = _client.Get<List<GenericResponseModel>>(MHRSUrls.BaseUrl, string.Format(MHRSUrls.GetHospitals, provinceIndex, districtIndex, clinicIndex));
            if (!hospitalListResponse.Success && (hospitalListResponse.Data == null || !hospitalListResponse.Data.Any()))
            {
                ConsoleUtil.WriteText("Bir hata meydana geldi!", 2000);
                return;
            }
            var hospitalList = hospitalListResponse.Data;
            if (!string.IsNullOrEmpty(hospitalIdStr))
            {
                int envHospitalId = int.Parse(hospitalIdStr);
                var found = hospitalList.FirstOrDefault(x => x.ValueAsInt == envHospitalId);
                if (found != null)
                    hospitalIndex = found.ValueAsInt;
            }
            while (hospitalIndex < -1)
            {
                Console.Clear();
                Console.WriteLine("-------------------------------------------");
                Console.WriteLine("0-FARKETMEZ");
                for (int i = 0; i < hospitalList.Count; i++)
                {
                    Console.WriteLine($"{i + 1}-{hospitalList[i].Text} (ID: {hospitalList[i].ValueAsInt})");
                }
                Console.WriteLine("-------------------------------------------");
                Console.Write("Hastane Numarası Giriniz: ");
                int input = Convert.ToInt32(Console.ReadLine());
                if (input == 0)
                    hospitalIndex = -1;
                else if (input > 0 && input <= hospitalList.Count)
                    hospitalIndex = hospitalList[input - 1].ValueAsInt;
            }

            // Muayene Yeri Seçim Bölümü
            var placeIdStr = Environment.GetEnvironmentVariable("MHRS_PLACE_ID");
            int placeIndex = -1;
            var placeListResponse = _client.Get<List<ClinicResponseModel>>(MHRSUrls.BaseUrl, string.Format(MHRSUrls.GetPlaces, hospitalIndex, clinicIndex));
            if (!placeListResponse.Success && (placeListResponse.Data == null || !placeListResponse.Data.Any()))
            {
                ConsoleUtil.WriteText("Bir hata meydana geldi!", 2000);
                return;
            }
            var placeList = placeListResponse.Data;
            if (!string.IsNullOrEmpty(placeIdStr))
            {
                int envPlaceId = int.Parse(placeIdStr);
                var found = placeList.FirstOrDefault(x => x.ValueAsInt == envPlaceId);
                if (found != null)
                    placeIndex = found.ValueAsInt;
            }
            while (placeIndex < -1)
            {
                Console.Clear();
                Console.WriteLine("-------------------------------------------");
                Console.WriteLine("0-FARKETMEZ");
                for (int i = 0; i < placeList.Count; i++)
                {
                    Console.WriteLine($"{i + 1}-{placeList[i].Text} (ID: {placeList[i].ValueAsInt})");
                }
                Console.WriteLine("-------------------------------------------");
                Console.Write("Muayene Yeri Numarası Giriniz: ");
                int input = Convert.ToInt32(Console.ReadLine());
                if (input == 0)
                    placeIndex = -1;
                else if (input > 0 && input <= placeList.Count)
                    placeIndex = placeList[input - 1].ValueAsInt;
            }

            // Doktor Seçim Bölümü
            var doctorIdStr = Environment.GetEnvironmentVariable("MHRS_DOCTOR_ID");
            int doctorIndex = -1;
            var doctorListResponse = _client.Get<List<GenericResponseModel>>(MHRSUrls.BaseUrl, string.Format(MHRSUrls.GetDoctors, hospitalIndex, clinicIndex));
            if (!doctorListResponse.Success && (doctorListResponse.Data == null || !doctorListResponse.Data.Any()))
            {
                ConsoleUtil.WriteText("Bir hata meydana geldi!", 2000);
                return;
            }
            var doctorList = doctorListResponse.Data;
            if (!string.IsNullOrEmpty(doctorIdStr))
            {
                int envDoctorId = int.Parse(doctorIdStr);
                var found = doctorList.FirstOrDefault(x => x.ValueAsInt == envDoctorId);
                if (found != null)
                    doctorIndex = found.ValueAsInt;
            }
            while (doctorIndex < -1)
            {
                Console.Clear();
                Console.WriteLine("-------------------------------------------");
                Console.WriteLine("0-FARKETMEZ");
                for (int i = 0; i < doctorList.Count; i++)
                {
                    Console.WriteLine($"{i + 1}-{doctorList[i].Text} (ID: {doctorList[i].ValueAsInt})");
                }
                Console.WriteLine("-------------------------------------------");
                Console.Write("Doktor Numarası Giriniz: ");
                int input = Convert.ToInt32(Console.ReadLine());
                if (input == 0)
                    doctorIndex = -1;
                else if (input > 0 && input <= doctorList.Count)
                    doctorIndex = doctorList[input - 1].ValueAsInt;
            }

            // Tarih Seçim Bölümü
            string? startDate;
            string? endDate;

            // .env'den başlangıç tarihi oku, yoksa varsayılan 07-07-2025 kullan
            var envStartDate = Environment.GetEnvironmentVariable("MHRS_START_DATE");
            if (!string.IsNullOrEmpty(envStartDate))
            {
                try
                {
                    var dateArr = envStartDate.Split('-').Select(x => Convert.ToInt32(x)).ToArray();
                    var date = new DateTime(dateArr[2], dateArr[1], dateArr[0]);
                    startDate = date.ToString("yyyy-MM-dd HH:mm:ss");
                }
                catch
                {
                    // Geçersizse varsayılan 07-07-2025 kullan
                    startDate = new DateTime(2025, 7, 7).ToString("yyyy-MM-dd HH:mm:ss");
                }
            }
            else
            {
                // .env yoksa varsayılan 07-07-2025
                startDate = new DateTime(2025, 7, 7).ToString("yyyy-MM-dd HH:mm:ss");
            }

            // Bitiş tarihi otomatik olarak bugünden 12 gün sonrası
            endDate = DateTime.Now.AddDays(12).ToString("yyyy-MM-dd HH:mm:ss");

            #region Randevu Alım Bölümü
            ConsoleUtil.WriteText("Yapmış olduğunuz seçimler doğrultusunda müsait olan ilk randevu otomatik olarak alınacaktır.", 3000);
            Console.Clear();
            
            Console.WriteLine("=== MHRS Otomatik Randevu Botu ===");
            Console.WriteLine($"Başlangıç Zamanı: {DateTime.Now:yyyy-MM-dd HH:mm:ss}");
            Console.WriteLine($"Arama Kriterleri: İl({provinceIndex}) İlçe({districtIndex}) Klinik({clinicIndex})");
            Console.WriteLine($"Hastane({hospitalIndex}) Yer({placeIndex}) Doktor({doctorIndex})");
            Console.WriteLine($"Tarih Aralığı: {ENV_START_DATE} - {endDate}");
            Console.WriteLine($"Telegram Bildirimi: Her {TELEGRAM_NOTIFY_FREQUENCY} denemede bir");
            Console.WriteLine("=====================================");
            Console.WriteLine("Bot çalışıyor... (Sadece önemli olaylar gösterilecek)");
            Console.WriteLine();

            LogStatus($"Bot başlatıldı - Kriterler: İl({provinceIndex}) İlçe({districtIndex}) Klinik({clinicIndex}) Hastane({hospitalIndex}) Yer({placeIndex}) Doktor({doctorIndex})", null, true);

            bool appointmentState = false;
            int attemptCount = 0;
            bool firstTestDone = false;

            // İlk test denemesi (saat kontrolü olmadan)
            Console.WriteLine("🧪 İlk test denemesi yapılıyor... (Bot çalıştığını kontrol etmek için)");
            LogStatus("İlk test denemesi başlatıldı", null, true);

            // İlk başlatma bildirimi gönder
            if (_notificationService != null)
            {
                var startMessage = $"🤖 MHRS Bot Başlatıldı!\n\n🕐 Başlangıç: {DateTime.Now:yyyy-MM-dd HH:mm:ss}\n🎯 Hedef: İl({provinceIndex}) İlçe({districtIndex}) Klinik({clinicIndex})\n📅 Tarih: {ENV_START_DATE}\n🧪 İlk test denemesi yapılıyor...";
                _ = Task.Run(() => _notificationService.SendNotification(startMessage));
            }

            while (!appointmentState)
            {
                // İlk deneme saat kontrolü olmadan yapılır
                if (!firstTestDone)
                {
                    Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] İlk test denemesi - Saat kontrolü atlanıyor");
                    LogStatus("İlk test denemesi - Saat kontrolü atlanıyor", null, true);
                    firstTestDone = true;
                }
                else
                {
                    // İlk denemeden sonra normal saat kontrolü
                    if (!IsWithinAllowedWindow(DateTime.Now))
                    {
                        if (attemptCount % 30 == 0) // Her 30 denemede bir konsola göster
                        {
                            Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] Saat aralığı dışında, bekleniyor... (Deneme #{attemptCount})");
                        }
                        LogStatus("Saat aralığı dışında, bekleniyor");
                        Thread.Sleep(TimeSpan.FromSeconds(30));
                        continue;
                    }
                }

                if (TOKEN_END_DATE == default || TOKEN_END_DATE < DateTime.Now)
                {
                    var tkn = GetToken(_client!);
                    if (tkn == null || string.IsNullOrEmpty(tkn.Token))
                    {
                        LogStatus("Yeniden giriş hatası", null, true);
                        ConsoleUtil.WriteText("Yeniden giriş hatası!", 2000);
                        return;
                    }
                    JWT_TOKEN = tkn.Token;
                    TOKEN_END_DATE = tkn.Expiration;
                    _client!.AddOrUpdateAuthorizationHeader(JWT_TOKEN);
                    LogStatus("Token yenilendi", null, true);
                }

                attemptCount++;
                var slotRequestModel = new SlotRequestModel
                {
                    MhrsHekimId = doctorIndex,
                    MhrsIlId = provinceIndex,
                    MhrsIlceId = districtIndex,
                    MhrsKlinikId = clinicIndex,
                    MhrsKurumId = hospitalIndex,
                    MuayeneYeriId = placeIndex,
                    BaslangicZamani = startDate,
                    BitisZamani = endDate
                };

                var slot = GetSlot(_client!, slotRequestModel);
                if (slot == null || slot == default)
                {
                    // İlk test denemesi ise özel mesaj
                    if (attemptCount == 1)
                    {
                        Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] ✅ İlk test tamamlandı - Bot çalışıyor!");
                        Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] 🕐 Şimdi belirlenen saatlerde randevu arayacak...");
                        LogStatus("İlk test tamamlandı - Bot normal çalışma moduna geçti", null, true);
                        
                        // İlk test başarı bildirimi gönder
                        if (_notificationService != null)
                        {
                            var testCompleteMessage = $"✅ İlk Test Tamamlandı!\n\n🤖 Bot çalışıyor ve MHRS'ye bağlandı\n🕐 Test zamanı: {DateTime.Now:HH:mm:ss}\n❌ İlk denemede randevu bulunamadı (Normal)\n🔍 Şimdi belirlenen saatlerde randevu arayacak\n📅 Hedef tarih: {ENV_START_DATE}";
                            _ = Task.Run(() => _notificationService.SendNotification(testCompleteMessage));
                        }
                    }
                    
                    // Basit log kaydı - sadece dosyaya
                    LogStatus($"Deneme #{attemptCount} - Müsait randevu bulunamadı");
                    
                    // Her 10 denemede bir konsola minimal bilgi ver (ilk denemeden sonra)
                    if (attemptCount > 1 && attemptCount % 10 == 0)
                    {
                        Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] Deneme #{attemptCount} - Müsait randevu bulunamadı");
                    }
                    
                    // Telegram bildirim frekansına göre "randevu bulunamadı" bildirimi gönder
                    if (attemptCount > 1 && attemptCount % TELEGRAM_NOTIFY_FREQUENCY == 0 && _notificationService != null)
                    {
                        var notFoundMessage = $"🔍 Randevu Arama Raporu\n\n❌ {attemptCount} deneme yapıldı, müsait randevu bulunamadı\n⏰ Saat: {DateTime.Now:HH:mm:ss}\n🔄 Arama devam ediyor...\n📅 Hedef tarih: {ENV_START_DATE}";
                        _ = Task.Run(() => _notificationService.SendNotification(notFoundMessage));
                    }
                    
                    // Her 50 denemede bir genel durum raporu gönder
                    if (attemptCount > 1 && attemptCount % 50 == 0 && _notificationService != null)
                    {
                        var statusMessage = $"📊 MHRS Bot Durum Raporu\n\n🔄 Toplam Deneme: {attemptCount}\n⏰ Çalışma Süresi: {DateTime.Now.Subtract(DateTime.Now.Date):hh\\:mm}\n🔍 Durum: Randevu aranıyor...\n📅 Hedef Tarih: {ENV_START_DATE}";
                        _ = Task.Run(() => _notificationService.SendNotification(statusMessage));
                    }
                    
                    Thread.Sleep(TimeSpan.FromMinutes(1));
                    continue;
                }

                var appointmentRequestModel = new AppointmentRequestModel
                {
                    FkSlotId = slot.Id,
                    FkCetvelId = slot.FkCetvelId,
                    MuayeneYeriId = slot.MuayeneYeriId,
                    BaslangicZamani = slot.BaslangicZamani,
                    BitisZamani = slot.BitisZamani
                };

                LogStatus($"RANDEVU BULUNDU! - Deneme #{attemptCount}", slot.BaslangicZamani, true);
                Console.WriteLine($"\n🎉 Randevu bulundu!");
                Console.WriteLine($"📅 Tarih: {slot.BaslangicZamani}");
                Console.WriteLine("⏳ Randevu alınıyor...");
                
                // Randevu bulundu bildirimi gönder
                if (_notificationService != null)
                {
                    var foundMessage = $"🎉 RANDEVU BULUNDU!\n\n📅 Tarih: {slot.BaslangicZamani}\n🔄 Deneme: #{attemptCount}\n⏳ Randevu alınıyor...";
                    _ = Task.Run(() => _notificationService.SendNotification(foundMessage));
                }
                
                appointmentState = MakeAppointment(_client!, appointmentRequestModel, sendNotification: true);
                if (appointmentState)
                {
                    LogStatus($"BAŞARILI! Randevu alındı - Deneme #{attemptCount}", slot.BaslangicZamani, true);
                    Console.WriteLine("\n✅ BAŞARILI! Randevu alındı!");
                    Console.WriteLine($"📅 Tarih: {slot.BaslangicZamani}");
                    Console.WriteLine("🔒 Bot durduruldu.");
                    
                    // Başarı dosyası oluştur
                    var successFile = Path.Combine(Directory.GetCurrentDirectory(), "randevu_basarili.txt");
                    File.WriteAllText(successFile, $"Randevu başarıyla alındı!\nTarih: {slot.BaslangicZamani}\nAlınma Zamanı: {DateTime.Now:yyyy-MM-dd HH:mm:ss}\nToplam Deneme: {attemptCount}");
                }
                else
                {
                    LogStatus($"Randevu alma başarısız - Deneme #{attemptCount}", slot.BaslangicZamani, true);
                    Console.WriteLine("❌ Randevu alma başarısız. Arama devam ediyor...");
                }
            }
            
            LogStatus("Program sonlandı: Randevu başarıyla alındı.", null, true);
            Console.WriteLine("\nBot durdu. Herhangi bir tuşa basarak çıkabilirsiniz...");
            Console.ReadKey();
            Environment.Exit(0);   // randevu alındıysa tamamen çık
            #endregion

            Console.ReadKey();
        }

        static JwtTokenModel? GetToken(IClientService client)
        {
            // token.txt ’i, çalıştırılabilir dosyanın bir üst dizinine koy
            var exeDir  = AppContext.BaseDirectory;               //  …/publish/
            var rootDir = Directory.GetParent(exeDir)!.FullName;  //  …/linux-x64/
            rootDir     = Directory.GetParent(rootDir)!.FullName; //  …/net7.0/
            var tokenFilePath = Path.Combine(rootDir, TOKEN_FILE_NAME);

            try
            {
                var tokenData = File.ReadAllText(tokenFilePath);
                if (string.IsNullOrEmpty(tokenData) || JwtTokenUtil.GetTokenExpireTime(tokenData) < DateTime.Now)
                    throw new Exception();

                return new() { Token = tokenData, Expiration = JwtTokenUtil.GetTokenExpireTime(tokenData) };
            }
            catch (Exception)
            {
                var loginRequestModel = new LoginRequestModel
                {
                    KullaniciAdi = TC_NO,
                    Parola = SIFRE
                };

                var loginResponse = client.Post<LoginResponseModel>(MHRSUrls.BaseUrl, MHRSUrls.Login, loginRequestModel).Result;
                if (loginResponse.Data == null || string.IsNullOrEmpty(loginResponse.Data?.Jwt))
                {
                    ConsoleUtil.WriteText("Giriş yapılırken bir hata meydana geldi!", 2000);
                    return null;
                }

                if (!string.IsNullOrEmpty(tokenFilePath))
                    File.WriteAllText(tokenFilePath, loginResponse.Data!.Jwt);

                return new() { Token = loginResponse.Data!.Jwt, Expiration = JwtTokenUtil.GetTokenExpireTime(loginResponse.Data!.Jwt) };
            }
        }

        //Aynı gün içerisinde tek slot mevcut ise o slotu bulur
        //Aynı gün içerisinde birden fazla slot mevcut ise en yakın saati getirmez fakat en yakın güne ait bir slot getirir
        static SubSlot? GetSlot(IClientService client, SlotRequestModel slotRequestModel)
        {
            var slotListResponse = client.Post<List<SlotResponseModel>>(MHRSUrls.BaseUrl, MHRSUrls.GetSlots, slotRequestModel).Result;
            if (slotListResponse.Data is null)
            {
                // API'den yanıt alamadığında sadece log dosyasına yaz, konsola yazdırma
                // Bu durum normal: randevu yoksa data null dönebilir
                return null;
            }

            var saatSlotList = slotListResponse.Data.FirstOrDefault()?.HekimSlotList.FirstOrDefault()?.MuayeneYeriSlotList.FirstOrDefault()?.SaatSlotList;
            if (saatSlotList == null || !saatSlotList.Any())
                return null;

            var slot = saatSlotList.FirstOrDefault(x => x.Bos)?.SlotList.FirstOrDefault(x => x.Bos)?.SubSlot;
            if (slot == default)
                return null;

            return slot;
        }

        static bool MakeAppointment(IClientService client, AppointmentRequestModel appointmentRequestModel, bool sendNotification)
        {
            var randevuResp = client.PostSimple(MHRSUrls.BaseUrl, MHRSUrls.MakeAppointment, appointmentRequestModel);
            if (randevuResp.StatusCode != HttpStatusCode.OK)
            {
                var errorMessage = $"❌ Randevu alırken bir problem ile karşılaşıldı!\nRandevu Tarihi: {appointmentRequestModel.BaslangicZamani}";
                Console.WriteLine(errorMessage);
                
                if (sendNotification && _notificationService != null)
                {
                    _ = Task.Run(() => _notificationService.SendNotification(errorMessage));
                }
                return false;
            }

            var successMessage = $"✅ BAŞARILI! Randevu alındı!\n📅 Tarih: {appointmentRequestModel.BaslangicZamani}\n🕐 Alınma Zamanı: {DateTime.Now:yyyy-MM-dd HH:mm:ss}";
            Console.WriteLine(successMessage);

            if (sendNotification && _notificationService != null)
            {
                _ = Task.Run(() => _notificationService.SendNotification(successMessage));
            }

            return true;
        }

        static void LogStatus(string status, string? slotTime = null, bool showConsole = false)
        {
            var logPath = Path.Combine(Directory.GetCurrentDirectory(), LOG_FILE_NAME);
            var timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
            var logLine = $"[{timestamp}] {status}";
            if (!string.IsNullOrEmpty(slotTime))
                logLine += $" | Slot: {slotTime}";
            
            // Dosyaya her zaman yaz
            try
            {
                File.AppendAllText(logPath, logLine + Environment.NewLine);
            }
            catch
            {
                // Log dosyası yazılamıyorsa sessizce devam et
            }
            
            // Konsola sadece önemli mesajları yazdır
            if (showConsole)
            {
                Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] {status}");
                if (!string.IsNullOrEmpty(slotTime))
                    Console.WriteLine($"             📅 Slot: {slotTime}");
            }
        }

        static string? ENV_START_DATE;
        static int TELEGRAM_NOTIFY_FREQUENCY = 10;  // Her kaç denemede bir bildirim
    }
}