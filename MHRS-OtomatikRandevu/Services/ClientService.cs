﻿using MHRS_OtomatikRandevu.Extensions;
using MHRS_OtomatikRandevu.Models.ResponseModels;
using MHRS_OtomatikRandevu.Services.Abstracts;
using System.Net.Http.Json;
using System.Text.Json;

namespace MHRS_OtomatikRandevu.Services
{
    public class ClientService : IClientService
    {
        private HttpClient _client;

        public ClientService()
        {
            _client = new HttpClient();
            _client.Timeout = TimeSpan.FromMinutes(5); // TIMEOUT 5 dk!
        }

        public ApiResponse<T> Get<T>(string baseUrl, string endpoint) where T : class
        {
            var response = _client.GetFromJsonAsync<ApiResponse<T>>(string.Concat(baseUrl, endpoint)).Result;
            if ((response.Warnings != null && response.Warnings.Any()) || (response.Errors != null && response.Errors.Any()))
                return new();

            return response;
        }

        public T GetSimple<T>(string baseUrl, string endpoint) where T : class
        {
            var url = string.Concat(baseUrl, endpoint);
            var httpResponse = _client.GetAsync(url).Result;
            var content = httpResponse.Content.ReadAsStringAsync().Result;
            // Console.WriteLine("[DEBUG] API Response: " + content); // debug kapatıldı
            
            if (!httpResponse.IsSuccessStatusCode)
            {
                Console.WriteLine($"[ERROR] HTTP {(int)httpResponse.StatusCode}: {httpResponse.ReasonPhrase}");
                return null;
            }
            
            try
            {
                // Önce direkt T olarak parse etmeye çalış (provinces gibi direkt list dönen API'ler için)
                var directResponse = System.Text.Json.JsonSerializer.Deserialize<T>(content);
                if (directResponse != null)
                    return directResponse;
                    
                // Direkt parse başarısızsa ApiResponse formatında parse etmeye çalış
                var apiResponse = System.Text.Json.JsonSerializer.Deserialize<ApiResponse<T>>(content);
                if (apiResponse != null)
                {
                    // Hata kontrolü yap
                    if (!apiResponse.Success || (apiResponse.Errors != null && apiResponse.Errors.Length > 0))
                    {
                        if (apiResponse.Errors != null && apiResponse.Errors.Length > 0)
                        {
                            Console.WriteLine("[ERROR] API Hatası:");
                            foreach (var error in apiResponse.Errors)
                            {
                                Console.WriteLine($"  - {error}");
                            }
                        }
                        else
                        {
                            Console.WriteLine("[ERROR] API başarısız yanıt döndü");
                        }
                        return null;
                    }
                    
                    // Başarılıysa data'yı döndür
                    if (apiResponse.Data != null)
                        return apiResponse.Data;
                }
                
                return null;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[ERROR] JSON parse hatası: {ex.Message}");
                Console.WriteLine($"[ERROR] API'dan gelen yanıt: {content}");
                return null;
            }
        }

        // --- BURASI YENİ: 3 kez deneyen POST (özellikle login için)
        public async Task<ApiResponse<T>> Post<T>(string baseUrl, string endpoint, object requestModel) where T : class
        {
            for (int attempt = 1; attempt <= 3; attempt++)
            {
                try
                {
                    var response = await _client.PostAsJsonAsync(string.Concat(baseUrl, endpoint), requestModel);
                    var data = await response.Content.ReadAsStringAsync();
                    // Console.WriteLine("[DEBUG] POST API Response: " + data); // debug kapatıldı
                    
                    if (string.IsNullOrEmpty(data))
                    {
                        if (attempt < 3)
                        {
                            Console.WriteLine($"Boş yanıt alındı, yeniden denenecek ({attempt}/3)");
                            await Task.Delay(2000); // 2 sn bekle
                            continue;
                        }
                        return new();
                    }

                    var mappedData = JsonSerializer.Deserialize<ApiResponse<T>>(data);
                    
                    // Hata kontrolü
                    if (mappedData != null && (!mappedData.Success || (mappedData.Errors != null && mappedData.Errors.Length > 0)))
                    {
                        if (mappedData.Errors != null && mappedData.Errors.Length > 0)
                        {
                            // RND4010 "randevu bulunamadı" hatası normal durum, konsola yazdırma
                            bool hasNormalError = mappedData.Errors.Any(e => e.ToString().Contains("RND4010"));
                            
                            if (!hasNormalError)
                            {
                                Console.WriteLine("[ERROR] POST API Hatası:");
                                foreach (var error in mappedData.Errors)
                                {
                                    Console.WriteLine($"  - {error}");
                                    
                                    // LGN1004 hatası için özel mesaj
                                    if (error.ToString().Contains("LGN1004"))
                                    {
                                        Console.WriteLine("[INFO] Bu hata genellikle yanlış TC/şifre veya sistem bakımından kaynaklanır.");
                                        Console.WriteLine("[INFO] Lütfen .env dosyasındaki bilgileri kontrol edin veya daha sonra tekrar deneyin.");
                                    }
                                }
                            }
                            // RND4010 hatası durumunda sadece log dosyasına yaz, konsola yazdırma
                        }
                        else
                        {
                            Console.WriteLine("[ERROR] POST API başarısız yanıt döndü");
                        }
                    }
                    
                    return mappedData!;
                }
                catch (TaskCanceledException)
                {
                    Console.WriteLine($"POST timeout, deneme {attempt}/3");
                    await Task.Delay(3000); // 3 sn bekle
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"[ERROR] POST JSON parse hatası: {ex.Message}");
                    if (attempt == 3) // son denemede hata detayını göster
                    {
                        Console.WriteLine($"[ERROR] Son deneme başarısız");
                    }
                    await Task.Delay(2000); // 2 sn bekle
                }
            }
            return new(); // 3 deneme de başarısızsa boş objeyle dön
        }

        public HttpResponseMessage PostSimple(string baseUrl, string endpoint, object requestModel)
        {
            return _client.PostAsJsonAsync(string.Concat(baseUrl, endpoint), requestModel).Result;
        }

        public void AddOrUpdateAuthorizationHeader(string jwtToken)
        {
            if (_client.DefaultRequestHeaders.Any(x => x.Key == "Authorization"))
                _client.DefaultRequestHeaders.Remove("Authorization");

            _client.DefaultRequestHeaders.AddAuthorization(jwtToken);
        }
    }
}
