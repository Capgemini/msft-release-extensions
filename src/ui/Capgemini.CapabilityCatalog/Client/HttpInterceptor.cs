namespace Capgemini.CapabilityCatalog.Shared.Interceptors
{
    using System.Net.Http;
    using System.Threading;
    using System.Threading.Tasks;
    using Radzen;

    public class NotificationHttpInterceptor : DelegatingHandler
    {
        private readonly NotificationService _notificationService;

        public NotificationHttpInterceptor(NotificationService notificationService)
        {
            _notificationService = notificationService;
        }

        protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
        {
            var response = await base.SendAsync(request, cancellationToken);

            if (!response.IsSuccessStatusCode)
            {
                var errorMessage = await response.Content.ReadAsStringAsync();
                _notificationService.Notify(NotificationSeverity.Error, errorMessage);
            }
            else
            {
                _notificationService.Notify(NotificationSeverity.Success, "Request completed successfully");
            }

            return response;
        }

        protected override HttpResponseMessage Send(HttpRequestMessage request, CancellationToken cancellationToken)
        {
            _notificationService.Notify(NotificationSeverity.Success, "Request completed successfully");
            return base.Send(request, cancellationToken);
        }

    }

}
