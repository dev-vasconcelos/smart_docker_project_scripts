#! /bin/bash

#Init global
# APPNAME="CACETA"

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
	echo
	echo "exemplo: $ ./selfrun.sh -n ProjetoInteressante  -p 9099 -c 5001 -v 1.0"
}

Validate_arguments() {
	ERROR=0
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

	if [ "${RUNOPTION}" == "" ];then
		echo "(r)un option required!"	
	fi

	if [ "${RUNOPTION}" != "" ] && [ "${RUNOPTION}" != "b" ] && [ "${RUNOPTION}" != "c" ]; then
		echo "(r)un option precisa ser 'b' ou 'c'"
		ERROR=1
	fi

	if [ $ERROR -eq 1 ]; then
		echo "ERROR: exit with code 1"
		exit 1
	fi


}

Build_and_run() {
	LOWERNAME=${APPNAME}
	LOWERNAME=$(echo $LOWERNAME | tr '[:upper:]' '[:lower:]')
	IMAGENAME=transpnet/$LOWERNAME:$VERSION
	CONTAINERNAME=$LOWERNAME-container
	echo "+--------------+"
	echo "Nome da aplicação: $APPNAME"
	echo "Nome da imagem: $IMAGENAME"
	echo "Nome do container: $CONTAINERNAME"
	echo "+--------------+"
	##
	# Add backup routine option
	##

	# docker rm -f $CONTAINERNAME

	chmod +x dockerfile-generator.sh

	./dockerfile-generator.sh -f $PROJECTFOLDER -n $APPNAME -$RUNOPTION

	if [ "$VOLUME" == "" ]
	then
		echo "INFO: Nenhum volume especificado"
	fi
	if [ "$NET" == "" ]
	then
		echo "INFO: Nenhuma rede especificada"
	fi

	# docker run -td --net nomedanet --ip 127.21.0.69 -v $(pwd)/Volume:/app/Arquivos --name $CONTAINERNAME -p $PORTHOST:$PORTCONTAINER --restart unless-stopped $IMAGENAME

	# docker build -t #IMAGENAME

}

main() {
	Default_values
	Validate_arguments
	Build_and_run
}

while getopts hn:v:p:c:w:i:l:f:r: flags
do
	case "${flags}" in
		h) 	Help
			exit;;
		n) eval APPNAME=\"${OPTARG}\";;
		v) VERSION=${OPTARG};;
		p) HOSTPORT=${OPTARG};;
		c) CONTAINERPORT=${OPTARG};;
		w) NET=${OPTARG};;
		i) IP=${OPTARG};; 
		l) VOLUME=${OPTGARG};;
		f) PROJECTFOLDER=${OPTARG};;
		r) RUNOPTION=${OPTARG};;

	esac
done
main
