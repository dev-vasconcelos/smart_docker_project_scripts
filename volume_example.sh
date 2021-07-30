volume_name=volumescript
container_name=containerscript1
path_to_tolder=/app
path_to_volume_folder=/app
new_container=containerscript2
image=ubuntu


docker volume create $volume_name
# docker volume create volumeinteressante

# docker volume create --name my_test_volume --opt type=none --opt device=/home/jinna/Jinna_Balu/Test_volume --opt o=bind

docker volume ls

docker volume inspect $volume_name
# docker volume inspect volumeinteressante

## docker volume rm $volume_name
# docker volume rm volumeinteressante

docker run -td --name $container_name -v ${volume_name}:$path_to_folder $image
# docker run -td --name container1 -v volumescript:/app ubuntu

## backup ##
docker run --rm --volumes-from $container_name -v $(pwd):/backup ubuntu tar cvf /backup/backup.tar /$path_to_volume_folder

# docker run --rm --volumes-from container1 -v $(pwd):/backup ubuntu tar cvf /backup/backup.tar /app

#pegar do backup
# docker run -v volumeinteressante:/app --name container2 ubuntu /bin/bash
docker run -v $volume_name:$path_to_folder  --name $new_container $image

# docker run --rm --volumes-from container2 -v $(pwd):/backup ubuntu bash -c "cd /app && tar xvf /backup/backup.tar --strip 1"
docker run --rm --volumes-from $new_container -v $(pwd):/backup ubuntu bash -c "cd /$path_to_volume_folder && tar xvf /backup/backup.tar --strip 1"



