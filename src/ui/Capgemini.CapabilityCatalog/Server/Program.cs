using Capgemini.CapabilityCatalog.Shared.Models;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Identity.Web;
using Capgemini.CapabilityCatalog.Server;
using Capgemini.CapabilityCatalog.Server.Services;


namespace Capgemini.CapabilityCatalog
{
    public class Program
    {
      
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Add services to the container.
            builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
                .AddMicrosoftIdentityWebApi(builder.Configuration.GetSection("AzureAd"));

            builder.Services.AddControllersWithViews();
            builder.Services.AddRazorPages();

        //    builder.Services.AddTransient<CapabilityDataService>();
             

            builder.Services.AddSingleton<IRepository<Scaffolder>>(provider =>
            {
                var endpoint = builder.Configuration["CosmosAccount"];
                var key = builder.Configuration["CosmosKey"];
                return new CosmosDBRepository<Scaffolder>(endpoint, key, "Test", "PACE");
            });

            builder.Services.AddTransient<ICapabilityDataService, CapabilityDataService>();

            var app = builder.Build();

            // Configure the HTTP request pipeline.
            if (app.Environment.IsDevelopment())
            {
                app.UseWebAssemblyDebugging();
            }
            else
            {
                app.UseExceptionHandler("/Error");
                // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
                app.UseHsts();
            }


            app.UseHttpsRedirection();

            app.UseBlazorFrameworkFiles();
            app.UseStaticFiles();

            app.UseRouting();

            app.UseAuthentication();
            app.UseAuthorization();


            app.MapRazorPages();
            app.MapControllers();
            app.MapFallbackToFile("index.html");

            app.Run();
        }
    }
}