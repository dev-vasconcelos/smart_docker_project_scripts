eval arr=($(docker ps -q))

echo "Especificacoes: (para usar valor padrão apenas aperte ENTER)"

echo "Servidor origem:"
read origin_server

echo "Endereço IP do registry:"
read ipregistry

if [ -z "$ipregistry" ]; then
  ipregistry=192.168.75.141:5000  
fi
for container_id in ${arr[@]}; do 
  container_name=$(sed -e 's/^"//' -e 's/"$//' <<< $(docker inspect $container_id | jq .[0].Name | tr '[:upper:]' '[:lower:]')) 
  image_name=$(sed -e 's/^"//' -e 's/"$//' <<< $(docker inspect $container_id | jq .[0].Config.Image | tr '[:upper:]' '[:lower:]'))
  
  if [ ! -z "$origin_server" ]; then
    commit_name="$ipregistry/$origin_server$container_name/$image_name"
  else
    commit_name="$ipregistry$container_name/$image_name"
  fi

  docker commit $container_id $commit_name

done

## one line command
#for el in $(docker ps -q); do docker commit $el $ipregistry$(sed -e 's/^"//' -e
#'s/"$//' <<< $(docker inspect $el | jq .[0].Name | tr '[:upper:]'
#'[:lower:]'))/$(sed -e 's/^"//' -e 's/"$//' <<< $(docker inspect $el | jq
#.[0].Config.Image | tr '[:upper:]' '[:lower:]')); done
##
