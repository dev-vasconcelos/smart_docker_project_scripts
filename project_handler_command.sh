DEFAULTPROJECTFOLDER="/home/predogalahad/Documents/Projects"

projeto() {
	funcao=$1
	nome_projeto=$2	
	while getopts f:w:p:o: flags
	do
		case "${flags}" in
			f) eval funcao=\"${OPTARG}\";;
			n) eval nome_projeto=\"${OPTARG}\";;
			w) eval workspace=\"${OPTARG}\";;
			b) eval branch=\"${OPTARG}\";;
			o) eval project_folder=\"${OPTARG}\";;
		esac
	done

	if [ -z $nome_projeto ]; then nome_projeto=$project_folder; fi

	if [ -z "$workspace" ]; then workspace=$DEFAULTPROJECTFOLDER; fi
	
	if [ ! -z $project_folder ]; then path=$workspace/$project_folder/; else project_folder=$nome_projeto; path=$workspace/$nome_projeto/; fi
	
	case "${funcao}" in
		"rodar") docker_selfrun $project_folder $path;;
		"deploy") git -C $path pull; docker_selfrun $project_folder $path;;
		"atualizar") git -C $path pull;;
		"status") git -C $path status;;
		"checkout") git -C $path checkout $branch
	esac

	unset funcao
	unset nome_projeto
	unset workspace
	unset branch
	unset project_folder

	# git_handler $funcao $nome_projeto $path $branch
}

docker_selfrun() {
	project_folder=$1
	path=$2
	echo $project_folder
	echo $path
	if [ "$workspace" == "$DEFAULTPROJECTFOLDER" ]; then
		cd $DEFAULTPROJECTFOLDER && ./selfrun.sh -f $project_folder -j
	else
		current_dir=$(pwd)
		cd $path && cd .. && ./selfrun.sh -f $project_folder -j && cd current_dir
		# cd current_dir
	fi
	sleep 2
}

git_handler() {
	funcao=$1
	nome_projeto=$2
	path=$3
	branch=$4
	if [ "${funcao}" == "atualizar" ]; then
		git -C $path pull
	elif [ "${funcao}" == "status" ]; then
		git -C $path status
	elif [ "${funcao}" == "checkout" ]; then	
		git -C $path checkout $branch
	else
		echo "tu é burro nao passou; projeto FUNCAO NOME_PROJETO PATH"
	fi
}
