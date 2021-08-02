DEFAULTPROJECTFOLDER="$(echo ~)/Documents/Projects"

projeto() {(
	functions_absolute_path="$(echo ~)/phandler_function.sh"
	. $functions_absolute_path
	
	funcao=$1
	current=$(pwd)
	while getopts f:w:b:o: flags
	do
		case "${flags}" in
			f) eval funcao=\"${OPTARG}\";;
			# p) eval nome_projeto=\"${OPTARG}\";;
			w) eval workspace=\"${OPTARG}\";;
			b) eval branch=\"${OPTARG}\";;
			o) eval project_folder=\"${OPTARG}\";;
		esac
	done

	#trap "cd $current; exit 0; " INT
	shift 1
	for nome_projeto in "$@"; do
		if [ -z $nome_projeto ]; then nome_projeto=$project_folder; fi
		if [ -z "$workspace" ]; then workspace=$DEFAULTPROJECTFOLDER; fi
		if [ ! -z $project_folder ]; then path=$workspace/$project_folder/; else project_folder=$nome_projeto; path=$workspace/$nome_projeto/; fi
		
		case "${funcao}" in
			"rodar") docker_selfrun;; #$project_folder $path;;
			"deploy") git -C $path pull; docker_selfrun $project_folder $path;;
			"atualizar") git -C $path pull;;
			"status") git -C $path status;;
			"checkout") git -C $path checkout $branch;;
			"diff") git -C $path diff;;
			"up") git_up $path;;
			*) echo "Funcao não encontrada! Fechando!"; teste;break;;
		esac
	done

	unset funcao
	unset nome_projeto
	unset workspace
	unset branch
	unset project_folder

	# git_handler $funcao $nome_projeto $path $branch

	
	)}


complete -W "-f -n -w -b -o -h \
	--funcao --nome --workspace --branch --folder --help \
	rodar deploy atualizar status checkout \
        $(ls $DEFAULTPROJECTFOLDER)" projeto

