using Microsoft.EntityFrameworkCore;
using HealthChecks.NpgSql;

var builder = WebApplication.CreateBuilder(args);

// Configure logging based on environment
builder.Logging.ClearProviders();
builder.Logging.AddConsole();
builder.Logging.AddDebug();

// Log environment information
var environment = builder.Environment.EnvironmentName;
Console.WriteLine($"=== Starting Order Management API ===");
Console.WriteLine($"Environment: {environment}");
Console.WriteLine($"Application Name: {builder.Environment.ApplicationName}");
Console.WriteLine($"Content Root: {builder.Environment.ContentRootPath}");

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

// Configure Swagger based on environment
var enableSwagger = builder.Configuration.GetValue<bool>("ApiSettings:EnableSwagger", true);
if (enableSwagger)
{
    builder.Services.AddSwaggerGen(c =>
    {
        c.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo
        {
            Title = "Order Management API",
            Version = "v1",
            Description = $"Order Management System API - {environment} Environment"
        });
    });
}

// Add CORS policy based on configuration
var allowedOrigins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>() 
    ?? new[] { "*" };

builder.Services.AddCors(options =>
{
    options.AddPolicy("DefaultCorsPolicy", policy =>
    {
        if (allowedOrigins.Contains("*"))
        {
            policy.AllowAnyOrigin()
                  .AllowAnyMethod()
                  .AllowAnyHeader();
        }
        else
        {
            policy.WithOrigins(allowedOrigins)
                  .AllowAnyMethod()
                  .AllowAnyHeader()
                  .AllowCredentials();
        }
    });
});

// Configure Database
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
Console.WriteLine($"Database Connection: {connectionString?.Replace(connectionString.Split("Password=")[1], "****")}");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(connectionString));

// Add Health Checks
builder.Services.AddHealthChecks()
    .AddNpgSql(connectionString ?? "", name: "postgres");

var app = builder.Build();

// Log application startup
app.Logger.LogInformation("Order Management API starting in {Environment} environment", environment);

// Configure the HTTP request pipeline based on environment
if (enableSwagger)
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", $"Order Management API v1 - {environment}");
        c.RoutePrefix = "swagger";
    });
    app.Logger.LogInformation("Swagger UI enabled at /swagger");
}

// Enable CORS
app.UseCors("DefaultCorsPolicy");

// Only use HTTPS redirection in production
if (app.Environment.IsProduction())
{
    app.UseHttpsRedirection();
}

// Add health check endpoint
app.MapHealthChecks("/health");

app.MapControllers();

// Log available endpoints
app.Logger.LogInformation("API is ready to accept requests");
app.Logger.LogInformation("Available endpoints:");
app.Logger.LogInformation("  - GET  /api/orders");
app.Logger.LogInformation("  - POST /api/orders");
app.Logger.LogInformation("  - GET  /api/orders/{{id}}");
app.Logger.LogInformation("  - PUT  /api/orders/{{id}}");
app.Logger.LogInformation("  - DELETE /api/orders/{{id}}");
app.Logger.LogInformation("  - GET  /health");
if (enableSwagger)
{
    app.Logger.LogInformation("  - GET  /swagger");
}

app.Run();
