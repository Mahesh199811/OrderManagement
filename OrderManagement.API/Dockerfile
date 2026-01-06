FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app
COPY bin/Release/net9.0/publish/ .
ENTRYPOINT ["dotnet", "OrderManagement.API.dll"]
