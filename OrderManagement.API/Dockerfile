FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app
COPY bin/Release/net9.0/publish/ .
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "OrderManagement.API.dll"]
