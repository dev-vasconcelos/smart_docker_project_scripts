#! /bin/bash

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
	#. $DEFAULTPROJECTFOLDER/selfrun.sh -f $project_folder -j
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
	
	if [[ $(git -C $path status) == *"Your branch is up to date"* ]]
	then 
		echo "Não há nada a ser commitado"
		exit 0
       	fi

	read -r -p "Confirmar commit no brach $branch [y/N]" confirm
	
		
	echo $confirm

	if [[ "$confirm" =~ ^([yY][eE][sS]|[yY])$ ]]
	then
		git -C $path push -u origin $branch 
	else
		echo "Push cancelado"
	fi
}
