FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY SecurityRadar.Web/SecurityRadar.Web.csproj SecurityRadar.Web/
RUN dotnet restore SecurityRadar.Web/SecurityRadar.Web.csproj
COPY SecurityRadar.Web/ SecurityRadar.Web/
RUN dotnet publish SecurityRadar.Web/SecurityRadar.Web.csproj -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
RUN useradd --create-home --uid 10001 appuser
USER 10001
COPY --from=build /app/publish .
EXPOSE 8080
ENTRYPOINT ["dotnet","SecurityRadar.Web.dll"]
