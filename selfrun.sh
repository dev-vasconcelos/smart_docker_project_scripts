#! /bin/bash



RED='\033[0;31m'
BLUE='\033[0;34m'
DEFAULT='\033[0m'

default_values() {
	CONTAINERPORT=8080
	HOSTPORT=8080
	VERSION=1.0
}

print_all_vars() {
echo $APPNAME
echo $VERSION
echo $HOSTPORT
echo $CONTAINERPORT
echo $NET
echo $IP
echo $VOLUME
echo $RUNOPTION
echo $CONFIRMATION
}

Help() {
	echo "Como rodar o projeto"
	echo
	echo "Syntax? selfrun [-n|v|p|c|w|i|l|f|r|y]"
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
	echo "Se quiser rodar por um json de configurações do projeto, apenas crie um arquivo docker.json"
	echo "e execute: $ ./selfrun.sh -f PastaProjeto -j"
	echo
	echo "exemplo: $ ./selfrun.sh -y -n NomeProjeto -f PastaProjeto -v 2.5 -p 9099 -c 5001 -w redeinteressante -i 175.21.0.5 -r b"
	echo
}

get_json_values() {
	docker_json_path=$PROJECTFOLDER/docker.json
	
	APPNAME=$(grep -Po '"appname": *\K"[^"]*"' $docker_json_path | sed -e 's/^"//' -e 's/"$//')
	VERSION=$(grep -Po '"version": *\K"[^"]*"' $docker_json_path | sed -e 's/^"//' -e 's/"$//')
	HOSTPORT=$(grep -Po '"hostport": *\K"[^"]*"' $docker_json_path | sed -e 's/^"//' -e 's/"$//')
	CONTAINERPORT=$(grep -Po '"containerport": *\K"[^"]*"' $docker_json_path | sed -e 's/^"//' -e 's/"$//')
	NET=$(grep -Po '"net": *\K"[^"]*"' $docker_json_path | sed -e 's/^"//' -e 's/"$//')
	IP=$(grep -Po '"ip": *\K"[^"]*"' $docker_json_path | sed -e 's/^"//' -e 's/"$//')
	# RUNTOPTION=$(gerp -Po '"runoption": *\K"[^"]*"' $docker_json_path | sed -e 's/^"//' -e 's/"$//')
	VOLUME=$(grep -Po '"volume": *\K"[^"]*"' $docker_json_path | sed -e 's/^"//' -e 's/"$//')
	RUNOPTION=$(grep -Po '"runoption": *\K"[^"]*"' $docker_json_path | sed -e 's/^"//' -e 's/"$//')
	CONFIRMATION=$(grep -Po '"confirmation": *\K"[^"]*"' $docker_json_path | sed -e 's/^"//' -e 's/"$//')

	print_all_vars
}



validate_arguments() {
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
		echo $RUNOPTION
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

check_network() {
	network_name=$1
	ip_container=$2
	
	IFS="." read -a sep <<< "$ip_container"

	if docker network inspect $network_name
	then
		for i in ${sep[@]}
		do
			if [ "$i" -lt "0" ] || [ "$i" -gt "255" ]
			then
				echo -e "${RED}ERROR:${DEFUALT} Ip inválido, fora do range"
				exit 1
			fi
		done	
	else
		
		for i in ${sep[@]}; do
			if [ "$i" -gt "255" ] || [ "$i" -lt  "0" ]
			then 
				echo -e "${RED}ERROR:${DEFUALT} rede inválida, verifique os ips"
				echo -e "${RED}ERROR:${DEFAULT} exit with code 1"
				exit 1
			fi
		done
			
		if [ "${sep[0]}" -gt "0" ] && [ "${sep[0]}" -le "10" ]
		then
			subnet=${sep[0]}.${sep[1]}.0.0/8
		
		elif [ "${sep[0]}" -gt "10" ] && [ "${sep[0]}" -le 172 ]
		then
			subnet=${sep[0]}.${sep[1]}.0.0/12
		
		elif [ "${sep[0]}" -gt "0" ] && [ "${sep[0]}" -le  255 ]
		then
			subnet=${sep[0]}.${sep[1]}.0.0/16
		fi
			
		if ! docker network create --subnet=$subnet $network_name
		then
			echo -e "${RED}ERRPR:${DEFAULT} comando errado: docker network create --subnet=$subnet $network_name"
			echo -e "${RED}ERROR:${DEFAULT} erro ao criar rede"
			exit 1
		fi
	fi	
	
}

build_and_run() {
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

	if ! ./dockerfile-generator.sh -f $PROJECTFOLDER -n $APPNAME -$RUNOPTION
	then
		echo
		echo -e "${RED}ERROR:${DEFAULT} Erro ao gerar dockerfile!"
		echo
		exit 1
	fi	
	
	
	if ! docker build . -t $IMAGENAME
	then
		echo
		echo -e "${RED}ERROR:${DEFAULT} Erro ao buildar dockerfile!"
		echo
		exit 1
	fi
	
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
		check_network $NET $IP 
		network="--net $NET --ip $IP"
	fi


	execcommand="docker run -td $network $volume --name $CONTAINERNAME -p $HOSTPORT:$CONTAINERPORT --restart unless-stopped $IMAGENAME"
	echo "Comando a ser executado: $execcommand"
	
	if [ "${CONFIRMATION}" != "y" ]
	then
		echo
		read -r -p "Confirmar execução [y/N] " response
		if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
		then
			if ! ${execcommand} 
			then
				echo
				echo -e "${RED}ERROR:${DEFAULT} Falha ao rodar o container"
				echo		
			fi
		else
			echo "O comando não será executado"
			exit 1
		fi
	else
		if ! ${execcommand} 
		then
			echo
			echo -e "${RED}ERROR:${DEFAULT} Falha ao rodar o container"
			echo		
		fi
	fi

}

main() {
	validate_arguments
	build_and_run
}

default_values

while getopts hjyn:v:p:c:w:i:l:f:r: flags
do
	case "${flags}" in
		h) 	Help
			exit;;
		j) 	get_json_values
			break;;

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
