ARG NET_IMAGE=8.0-bookworm-slim
FROM mcr.microsoft.com/dotnet/aspnet:${NET_IMAGE} AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:${NET_IMAGE} AS build
WORKDIR /src/frontend
COPY . .
RUN dotnet restore "Frontend.csproj"


FROM build AS publish
RUN dotnet publish --no-restore "Frontend.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish/ .
ENTRYPOINT ["dotnet", "Frontend.dll"]