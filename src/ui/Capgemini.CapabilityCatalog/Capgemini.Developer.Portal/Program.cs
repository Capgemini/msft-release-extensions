using Capgemini.CapabilityCatalog.Server.Services;
using Capgemini.CapabilityCatalog.Server;
using Capgemini.CapabilityCatalog.Shared.Models;
using Capgemini.Developer.Portal.Data;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
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
    options.FallbackPolicy = options.DefaultPolicy;
});

builder.Services.AddRazorPages();
builder.Services.AddServerSideBlazor()
    .AddMicrosoftIdentityConsentHandler();
builder.Services.AddSingleton<WeatherForecastService>();

builder.Services.AddScoped<DialogService>();
builder.Services.AddScoped<NotificationService>();

var endpoint = builder.Configuration["CosmosAccount"];
var key = builder.Configuration["CosmosKey"];
var databaseName = "PACE";
var containerName = "PACE";

builder.Services.AddSingleton<IRepository<Scaffolder>>(provider =>
{  
    return new CosmosDBRepository<Scaffolder>(endpoint,key, databaseName, containerName);
});

builder.Services.AddSingleton<IRepository<Repository>>(provider =>
{  
    return new CosmosDBRepository<Repository>(endpoint,key, databaseName, containerName);
});

builder.Services.AddSingleton<IRepository<Library>>(provider =>
{
    return new CosmosDBRepository<Library>(endpoint,key, databaseName, containerName);
});

builder.Services.AddTransient<ICapabilityDataService, CapabilityDataService>();


builder.Configuration.AddAzureAppConfiguration(options =>
    {
         options.Connect(new Uri(builder.Configuration["AppConfigurationEndpoint"]), new DefaultAzureCredential())
               .Select("*")
               .ConfigureRefresh(config =>
               {
                   config.Register("*", refreshAll: true);
               });

        options.UseFeatureFlags();
    });

builder.Services.AddAzureAppConfiguration();
builder.Services.AddFeatureManagement();


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