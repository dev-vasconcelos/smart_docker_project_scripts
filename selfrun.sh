#! /bin/bash

#Init global
# APPNAME="CACETA"

Default_values() {
	CONTAINERPORT=8080
	HOSTPORT=8080
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
	echo
	echo "exemplo: $ ./selfrun.sh -n ProjetoInteressante  -p 9099 -c 5001 -v 1.0"
}

Get_arguments() {
	while getopts hn:v:p:c: flags
	do
		case "${flags}" in
			h) 	Help
				exit;;
			n) APPNAME=${OPTARG};;
			v) ${VERSION}=${OPTARG};;
			p) ${HOSTPORT}=${OPTARG};;
			c) ${CONTAINERPORT}=${OPTARG};;
			w) ${NET}=${OPTARG};;
			i) ${IP}=${OPTARG};; 
			l) ${VOLUME}=${OPTGARG};;
			f) ${PROJECTFOLDE}=${OPTARG};;

		esac
	done
}

Validate_arguments() {
	if [ "${APPNAME}" == "" ]; then
		echo "Project -(n)ame required!"
		ERROR=1
	fi

	if [ "${NET}" != "" ] && [ "${IP}" == "" ] | [ "${IP}" != ""] && [ "${NET}" == "" ]
	then
		echo "missing full network options [-net(w)ork name OR -(i)p]"
		ERROR=1
	fi
	
	if [ "${PROJECTFOLDER}" == "" ]; then
		echo "Project -(f)older required!"
		ERROR=1
	fi

	if [ $ERROR -gt 0 ]; then
		echo "ERROR: exit with code 1"
		exit 1
	fi
}

Build_and_run() {
	LOWERNAME=${APPNAME}
	LOWERNAME=$(echo $LOWERNAME | tr '[:upper:]' '[:lower:]')
	IMAGENAME=transpnet/$LOWERNAME:$VERSION
	CONTAINERNAME=$LOWERNAME-container
	echo $APPNAME
	echo $LOWERNAME
	echo $IMAGENAME
	echo $CONTAINERNAME
	##
	# Add backup routine option
	##

	# docker rm -f $CONTAINERNAME

	# chmod +x dockerfile-generator.sh

	# ./dockerfile-generator.sh - options

	if [ "$VOLUME" == "" ]
	then
		echo "é padrão"
	fi
	if [ "$NET" == "" ]
	then
		echo "net padrao"
	fi

	# docker run -td --net nomedanet --ip 127.21.0.69 -v $(pwd)/Volume:/app/Arquivos --name $CONTAINERNAME -p $PORTHOST:$PORTCONTAINER --restart unless-stopped $IMAGENAME

	# docker build -t #IMAGENAME

}
main() {
	APPNAME="AAAAAAAA"
	Default_values
	Get_arguments
	#Validate_arguments
	Build_and_run
}

main
