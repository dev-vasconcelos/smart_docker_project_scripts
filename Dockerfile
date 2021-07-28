FROM mcr.microsoft.com/dotnet/aspnet:5.0
WORLDIR /app
COPY ./app ./
 
ENTRYPOINT ["dotnet","A.dll"]
