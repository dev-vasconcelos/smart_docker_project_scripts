
## rodar container postgres
docker run --name $db_container -e POSTGRES_PASSWORD=$db_pass -e POSTGRES_USER=$db_user -e POSTGRES_DB=$db_name -p $hostport:5432 -d postgres
#docker run --name postgresGenerico -e POSTGRES_PASSWORD=passwd -e POSTGRES_USER=user -e POSTGRES_DB=dbroot -p 5432:5432 -d postgres

## exportar todos os DB's de um banco
docker exec -t $db_container pg_dumpall -c -U user > dump_$db_name_`date +%d-%m-%Y"_"%H_%M_%S`.sql
#docker exec -t postgresGenerico pg_dumpall -c -U user > dump_generico_`date +%d-%m-%Y"_"%H_%M_%S`.sql

## Exportar Database
docker exec -t $db_container pg_dump -C -U $db_user $db_name > dump_$db_name_`date +%d-%m-%Y"_"%H_%M_%S`.sql
#docker exec -t postgresGenerico pg_dump -C -U user dbgenerico > dump_armazem_`date +%d-%m-%Y"_"%H_%M_%S`.sql

## Importar Database
cat $dump_file | docker exec -i $db_container psql -U $db_user -d $db_name
#cat dump_armazem_02-08-2021_17_39_15.sql | docker exec -i postgresGenerico psql -U user -d dbarmazem

## Mostrar tabelas // para verificação do import
docker exec -t $db_container psql -U $db_user -d $dbname -c '\dt'
#docker exec -t postgresGenerico psql -U user -d dbgenerico -c '\dt'

## Entrar no psql do container
docker exec -ti $db_container -sql -U $db_user -d $db_name
#docker exec -ti postgresGenerico psql -U user -d dbarmazem
