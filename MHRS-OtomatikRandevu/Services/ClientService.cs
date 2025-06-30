using MHRS_OtomatikRandevu.Extensions;
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
            var response = _client.GetFromJsonAsync<T>(string.Concat(baseUrl, endpoint)).Result;
            return response;
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
                    if (string.IsNullOrEmpty(data))
                        return new();

                    var mappedData = JsonSerializer.Deserialize<ApiResponse<T>>(data);
                    return mappedData!;
                }
                catch (TaskCanceledException)
                {
                    Console.WriteLine($"POST timeout, deneme {attempt}/3");
                    await Task.Delay(3000); // 3 sn bekle
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
