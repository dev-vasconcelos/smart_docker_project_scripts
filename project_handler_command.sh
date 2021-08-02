DEFAULTPROJECTFOLDER="/home/predogalahad/Documents/Projects"

projeto() {
	funcao=$1
	# nome_projeto=$2	
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

	
}

doubt() {
	echo sera que isso é elegante de fazer? uma funcao dentro de outra pra capsulas
	echo code on function inside another to encapsulate, is it elegant... or even good?
	echo when I discover, if it is will keep this way
	echo if not, then put the functions outside this file
}
	
docker_selfrun() {
	current_dir=$(pwd)
	if [ "$workspace" == "$DEFAULTPROJECTFOLDER" ]; then
	cd $DEFAULTPROJECTFOLDER && ./selfrun.sh -f $project_folder -j
	else
		cd $path && cd .. && ./selfrun.sh -f $project_folder -j
	fi
	cd $current_dir
}

git_up() {
	branch=$(git -C $path symbolic-ref --short HEAD)
	git -C $path add .
		read -r -p "Entre a mensagem de commit: " message
	git -C $path commit -m "$message"
		read -r -p "Confirmar commi no brach $branch [y/N]" confirm
	echo $confirm

	if [[ "$confirm" =~ ^([yY][eE][sS]|[yY])$ ]]
	then
		git -C $path push -u origin $branch 
	else
		echo "Push cancelado"
	fi
}

complete -W "-f -n -w -b -o -h \
	--funcao --nome --workspace --branch --folder --help \
	rodar deploy atualizar status checkout \
        $(ls $DEFAULTPROJECTFOLDER)" projeto




