echo "Escreva o endereço do registry(para o padrão apenas aperte ENTER)"
read registry_addr

echo "Escreva a substring do nome para baixar(para baixar todas apenas aperte ENTER)"
read sub_string

echo "Forçar todos downloads[y/n]?(para perguntar em cada aperte ENTER)"
read force

if [ -z "$registry_addr"]; then
  registry_addr="192.168.75.141:5000"
fi

if [ ! -z "$rule" ]; then
  for i in $(curl -s $registry_addr/v2/_catalog | jq .repositories);do 
    image_addr=$(echo $i | tr -d '[=,=]\n\r' | tr -d '[="=]\n\r' | tr '[:upper:]' '[:lower:]')
    if [[ "$force" == *"y"* ]];then 
          docker pull $registry_addr/$image_addr
    else 
      echo baixar "$i"?
        read b
        if [[ "$b" == *"y"* ]];then
          docker pull $registry_addr/$image_addr
          echo "comando"
        else
          echo "-----------------"
          b="n"
        fi
    fi
  done
else
  for i in $(curl -s $registry_addr/v2/_catalog | jq .repositories); do 
    if [[ "$i" == *"$sub_string"* ]]; then 
      image_addr=$(echo $i | tr -d '[=,=]\n\r' | tr -d '[="=]\n\r' | tr '[:upper:]' '[:lower:]')
      if [[ "$force" == *"y"* ]];then
                echo $registry_addr/$image_addr
        echo $image_addr
        docker pull $registry_addr/$image_addr
      else
        echo baixar "$i"?
        read b
        if [[ "$b" == *"y"* ]];then
          docker pull $registry_addr/$image_addr 
        else
          echo "-----------------"
          b="n"
        fi
      fi
    fi 
  done
fi

