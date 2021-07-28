FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /source
 
COPY PastaProjeto/* ./
RUN dotnet restore
 
RUN apt install -y tzdata
RUN ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata
 
COPY PastaProjeto/. ./PastaProjeto/
WORKDIR /source/PastaProjeto
RUN dotnet publish -c release -o /app
 
FROM mcr.microsoft.com/dotnet/aspnet:5.0
WORKDIR /app
COPY --from=build /app ./
 
ENTRYPOINT ["dotnet","NomeProjeto.dll"]
