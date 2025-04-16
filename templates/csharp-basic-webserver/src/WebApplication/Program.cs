/*
filename: templates/csharp-basic-webserver/src/WebApplication/Program.cs
This is a basic web server using ASP.NET Core and C#
It serves a simple "Hello world" message on the root URL
Demonstrates how to:
- Set up a minimal ASP.NET Core web application
- Configure port binding
- Implement automatic reload during development
- Format datetime output
*/

using System;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.Hosting;

var builder = WebApplication.CreateBuilder(args);

// Configure server port (matches Python template's 3000)
// Environment variable ASPNETCORE_URLS can override this
var port = Environment.GetEnvironmentVariable("ASPNETCORE_URLS")?.Split(':').Last() ?? "3000";
builder.WebHost.UseUrls($"http://0.0.0.0:{port}");

var app = builder.Build();

// Root endpoint handler - equivalent to Flask's @app.route('/')
app.MapGet("/", () => 
{
    // Format current time to "HH:mm:ss" and date to "dd/MM/yyyy"
    var currentTime = DateTime.Now.ToString("HH:mm:ss");
    var currentDate = DateTime.Now.ToString("dd/MM/yyyy");
    
    // Return message with template name and formatted datetime
    return $"Hello world! Template: csharp-basic-webserver. Time: {currentTime} Date: {currentDate}";
});

// Start the web server with Kestrel (ASP.NET Core's web server)
app.Run();

