#! /bin/bash



RED='\033[0;31m'
BLUE='\033[0;34m'
DEFAULT='\033[0m'

Default_values() {
	CONTAINERPORT=8080
	HOSTPORT=8080
	VERSION=1.0
}

Help() {
	echo "Como rodar o projeto"
	echo
	echo "Syntax? selfrun [-n|v|p|c]"
	echo "options:"
	echo "n		Nome do Projeto, inicial maiscula, como a DLL gerada"
	echo "v		Versão do projeto com apenas 1 ponto flutuante. 1.0,1.2, etc."
	echo "p 	Porta exposta pela máquina host"
	echo "c 	Porta exposta pelo container, disponivel apenas localmente. Para acesso das demais aplicações"
	echo "w		Nome da rede do container"
	echo "i 	Ip que o container terá na rede"
	echo "l		Comando de volume para o container"
	echo "f		Pasta que o projeto está localizado"
	echo "r 	Opção de run do script, b(uildar) ou (c)ompilado"
	echo "y		Para ignorar a confirmação da execução do docker run"
	echo
	echo "exemplo: $ ./selfrun.sh -y -n NomeProjeto -f PastaProjeto -v 2.5 -p 9099 -c 5001 -w redeinteressante -i 127.17.0.5 -r b"
	echo
}

Validate_arguments() {
	ERROR=0
	if [ "$APPNAME" == "" ]; then
		echo "(n)ome do projeto necessário!"
		ERROR=1
	fi

	if ([ "$NET" != "" ] && [ "$IP" == "" ]) || ([ "$IP" != "" ] && [ "$NET" == "" ])
	then
		echo "Opções de rede incompletas [-net(w)ork OU -(i)p]"
		ERROR=1
	fi
	
	if [ "${PROJECTFOLDER}" == "" ]; then
		echo "(f)Pasta necessária!"
		ERROR=1
	fi

	if [ "${RUNOPTION}" == "" ];then
		echo "Opção (r)un necessária!"
		ERROR=1
	fi

	if [ "${RUNOPTION}" != "" ] && [ "${RUNOPTION}" != "b" ] && [ "${RUNOPTION}" != "c" ]; then
		echo "Opção (r)un precisa ser 'b' ou 'c'"
		ERROR=1
	fi

	if [ $ERROR -eq 1 ]; then
		echo
		echo -e "${RED}ERROR:${DEFAULT} exit with code 1"
		echo
		exit 1
	fi
}

Build_and_run() {
	LOWERNAME=$APPNAME
	LOWERNAME=$(echo $LOWERNAME | tr '[:upper:]' '[:lower:]')
	IMAGENAME=transpnet/$LOWERNAME:${VERSION}
	CONTAINERNAME=$LOWERNAME-container
	echo
	echo "+--------------+"
	echo "Nome da aplicação: $APPNAME"
	echo "Nome da imagem: $IMAGENAME"
	echo "Nome do container: $CONTAINERNAME"
	echo "+--------------+"
	echo
	##
	# Add backup routine option
	##

	docker rm -f $CONTAINERNAME

	chmod +x dockerfile-generator.sh

	./dockerfile-generator.sh -f $PROJECTFOLDER -n $APPNAME -$RUNOPTION
	
	docker build . -t $IMAGENAME
	
	if [ "${VOLUME}" == "" ]
	then
		echo
		echo -e "${BLUE}INFO:${DEFAULT} Nenhum volume especificado"
		echo
	else
		volume="-v $VOLUME"
	fi


	if [ "${NET}" == "" ]
	then
		echo
		echo -e "${BLUE}INFO:${DEFAULT} Nenhuma rede especificada"
		echo
	else
		network="--net $NET --ip $IP"
	fi

	echo "Comando a ser executado "
	echo "docker run -td $network $volume --name $CONTAINERNAME -p $HOSTPORT:$CONTAINERPORT --restart unless-stopped $IMAGENAME"
	
	if [ "${CONFIRMATION}" != "y" ]
	then
		echo
		read -r -p "Tem certeza que deseja rodar? [y/N] " response
		if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
		then
			docker run -td $network $volume --name $CONTAINERNAME -p $HOSTPORT:$CONTAINERPORT --restart unless-stopped $IMAGENAME
		else
			echo "O comando não foi executado"
			exit 1
		fi
	else
		docker run -td $network $volume --name $CONTAINERNAME -p $HOSTPORT:$CONTAINERPORT --restart unless-stopped $IMAGENAME
	fi

}

main() {

	Validate_arguments
	Build_and_run
}

Default_values

while getopts hyn:v:p:c:w:i:l:f:r: flags
do
	case "${flags}" in
		h) 	Help
			exit;;
		n) eval APPNAME=\"${OPTARG}\";;
		v) eval VERSION=\"${OPTARG}\";;
		p) eval HOSTPORT=\"${OPTARG}\";;
		c) eval CONTAINERPORT=\"${OPTARG}\";;
		w) eval NET=\"${OPTARG}\";;
		i) eval IP=\"${OPTARG}\";; 
		l) eval VOLUME=\"${OPTARG}\";;
		f) eval PROJECTFOLDER=\"${OPTARG}\";;
		r) eval RUNOPTION=\"${OPTARG}\";;
		y) eval CONFIRMATION=y;;

	esac
done
main
