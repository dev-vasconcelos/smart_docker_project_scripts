FROM mcr.microsoft.com/dotnet/sdl:5.0 AS build
WORKDIR /source
 
COPY FolderFoda/* ./
RUN dotnet restore
 
RUN apt install -y tzdata
RUN ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata
 
COPY FolderFoda/. ./FolderFoda/
wORKDIR /source/FolderFoda
RUN dotnet publish -c release -o /app
 
FROM mcr.microsoft.com/dotnet/aspnet:5.0
WORLDIR /app
COPY --from=build /app ./
 
ENTRYPOINT ["dotnet","NomeFoda.dll"]
