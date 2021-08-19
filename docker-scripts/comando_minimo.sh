minimo() {
	
	
	obj=$1

	otp=$(docker inspect $obj); echo "Nome:" $(echo $otp | jq .[0].Name); echo "Envs:" $(echo $otp | jq .[0].Config.Env);echo "Entrypoint:" $(echo $otp | jq .[0].Config.Entrypoint); echo "workdir:" $(echo $otp | jq .[0].Config.WorkingDir); echo "Volumes:" $(echo $otp | jq .[0].Config.Volumes); echo "Mounts:" $(echo $otp | jq .[0].Mounts); echo "Network": $(echo $otp | jq .[0].NetworkSettings.Networks)

	update_dock_minimo
}

update_dock_minimo() {
	complete -W "$(docker inspect --format='{{.Name}}' $(docker ps -aq --no-trunc) | cut -c2-)" minimo
}

update_dock_minimo
