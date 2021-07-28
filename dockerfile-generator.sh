FOLDERNAME=1
PROJECTNAME=1
DOTNETVERSION=5.0


Help() {
	echo "Como rodar o projeto"
	echo
	echo "Syntax? dockerfile-generator [-n|f|b|c]"
	echo "options:"
	echo "n		Nome do projeto, tal qual a DLL gerada. DEVE ser igual ao nome .dll"
	echo "f		Nome da pasta do projeto"
	echo "b		Use para buildar e rodar o container"
	echo "c		Use para utilizar um projeto já compilado"
	echo
	echo "não utilize as opções -b e -c simultaneamente!"
}

Dockerfile-dotnet-runtime() {
	is_build=$1
	first_line="FROM mcr.microsoft.com/dotnet/aspnet:$DOTNETVERSION"
	if [ "$is_build" -eq  "1" ]	
	then
		echo $first_line >> Dockerfile
	else
		echo $first_line > Dockerfile
	fi
	
	echo "WORLDIR /app" >> Dockerfile
#	echo "COPY $PROJECTOFOLDER/DatabBase/CodeStored.db /apt/CodeStored.db" >> Dockerfile
	
	if [ "$is_build" -eq "1" ]
	then
		echo "COPY --from=build /app ./" >> Dockerfile
	else
		echo "COPY ./app ./" >> Dockerfile
	fi

	echo " " >> Dockerfile

	# add volume
	# echo "VOLUME pasta /app/Arquivos" >> Dockerfile

	echo "ENTRYPOINT [\"dotnet\",\"$PROJECTNAME.dll\"]" >> Dockerfile
}



Dockerfile-dotnet-build() {
	echo "FROM mcr.microsoft.com/dotnet/sdl:$DOTNETVERSION AS build" > Dockerfile
	echo "WORKDIR /source" >> Dockerfile

	echo " " >> Dockerfile

	echo "COPY $PROJECTFOLDER/* ./" >> Dockerfile
	echo "RUN dotnet restore" >> Dockerfile

	echo " " >> Dockerfile

	echo "RUN apt install -y tzdata" >> Dockerfile
	echo "RUN ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime" >> Dockerfile
	echo "RUN dpkg-reconfigure --frontend noninteractive tzdata" >> Dockerfile

	echo " " >> Dockerfile

	echo "COPY $PROJECTFOLDER/. ./$PROJECTFOLDER/" >> Dockerfile
	echo "wORKDIR /source/$PROJECTFOLDER" >> Dockerfile
	echo "RUN dotnet publish -c release -o /app" >> Dockerfile

	echo " " >> Dockerfile

	Dockerfile-dotnet-runtime 1
}

while getopts bchn:f: flags
do
	case "${flags}" in
		h) 	Help
			exit;;
		f) PROJECTFOLDER=${OPTARG};;
		n) PROJECTNAME=${OPTARG};;
		b) 
			Dockerfile-dotnet-build
			exit;;
		c) 
			Dockerfile-dotnet-runtime 0
			exit;;
	esac
done

echo "Acredito que você tenha esquecido de especificar se é (b)uild ou (c)ompilado"
