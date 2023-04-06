using Capgemini.CapabilityCatalog.Server.Services;
using Capgemini.CapabilityCatalog.Server;
using Capgemini.CapabilityCatalog.Shared.Models;
using Capgemini.Developer.Portal.Data;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Mvc.Authorization;
using Microsoft.Identity.Web;
using Microsoft.Identity.Web.UI;
using Radzen;
using Azure.Identity;
using Microsoft.FeatureManagement;

var builder = WebApplication.CreateBuilder(args);

var initialScopes = builder.Configuration["DownstreamApi:Scopes"]?.Split(' ') ?? builder.Configuration["MicrosoftGraph:Scopes"]?.Split(' ');

// Add services to the container.
builder.Services.AddAuthentication(OpenIdConnectDefaults.AuthenticationScheme)
    .AddMicrosoftIdentityWebApp(builder.Configuration.GetSection("AzureAd"))
        .EnableTokenAcquisitionToCallDownstreamApi(initialScopes)
.AddMicrosoftGraph(builder.Configuration.GetSection("MicrosoftGraph"))
            .AddInMemoryTokenCaches();
builder.Services.AddControllersWithViews()
    .AddMicrosoftIdentityUI();

builder.Services.AddAuthorization(options =>
{
    // By default, all incoming requests will be authorized according to the default policy
    options.FallbackPolicy = options.DefaultPolicy;
});

builder.Services.AddRazorPages();
builder.Services.AddServerSideBlazor()
    .AddMicrosoftIdentityConsentHandler();
builder.Services.AddSingleton<WeatherForecastService>();

builder.Services.AddScoped<DialogService>();
builder.Services.AddScoped<NotificationService>();

builder.Services.AddSingleton<IRepository<Scaffolder>>(provider =>
{
    var endpoint = builder.Configuration["CosmosAccount"];
    var key = builder.Configuration["CosmosKey"];
    return new CosmosDBRepository<Scaffolder>(endpoint, key, "Test", "PACE");
});

builder.Services.AddSingleton<IRepository<Repository>>(provider =>
{
    var endpoint = builder.Configuration["CosmosAccount"];
    var key = builder.Configuration["CosmosKey"];
    return new CosmosDBRepository<Repository>(endpoint, key, "Test", "PACE");
});

builder.Services.AddSingleton<IRepository<Library>>(provider =>
{
    var endpoint = builder.Configuration["CosmosAccount"];
    var key = builder.Configuration["CosmosKey"];
    return new CosmosDBRepository<Library>(endpoint, key, "Test", "PACE");
});

builder.Services.AddTransient<ICapabilityDataService, CapabilityDataService>();

//var appConfigurationEndpoint = builder.Configuration.GetValue<string>("AppConfigurationEndpoint");
//if (!string.IsNullOrEmpty(appConfigurationEndpoint))
//{
//    builder.Configuration.AddAzureAppConfiguration(options =>
//    {
//        var azureCredentialOptions = new DefaultAzureCredentialOptions()
//        {
//            VisualStudioTenantId = builder.Configuration.GetSection("AzureAD").GetValue<string>("TenantId")
//        };

//        var credential = new DefaultAzureCredential(azureCredentialOptions);
//        options.Connect(new Uri(appConfigurationEndpoint), credential)
//               .ConfigureKeyVault(kv => kv.SetCredential(credential))
//               .Select("*")
//               .ConfigureRefresh(config =>
//               {
//                   config.Register("*", refreshAll: true);
//               });
//    });
//}

//builder.Services.AddFeatureManagement();

builder.Configuration.AddAzureAppConfiguration(options =>
    {
         options.Connect(new Uri("https://paceappconfig.azconfig.io"), new DefaultAzureCredential())
               .Select("*")
               .ConfigureRefresh(config =>
               {
                   config.Register("*", refreshAll: true);
               });

        options.UseFeatureFlags();
    });

builder.Services.AddAzureAppConfiguration();
builder.Services.AddFeatureManagement();

//WORKS
//builder.Configuration.AddAzureAppConfiguration("Endpoint=https://paceappconfig.azconfig.io;Id=CEMt-lo-s0:PSogafo1Csz4XdIPR8ul;Se");



var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();

app.UseStaticFiles();

app.UseRouting();


app.UseAzureAppConfiguration();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapBlazorHub();
app.MapFallbackToPage("/_Host");

app.Run();
