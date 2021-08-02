# Dotnet e Docker
## _Tudo que pode ser automatizado, deve ser_

Conjunto de scripts para se trabalhar com dotnet, postgres e docker de maneira fácil
- Comando linux para se trabalhar em qualquer projeto de qualquer lugar
- Scripts de referência para criar mais scripts ou comandos
- ✨Automação✨

## Features

- Realizar ações de git de qualquer lugar(push, pull, status e checkout)
- Realizar ações de containerização de qualquer lugar(*backup da imagem do projeto*, *gerar imagem do projeto*, *backup do volume do projeto*, *importação de volume para o projeto*, deploy da aplicação em container, atualização do projeto e auto deploy da aplicação em container)
- Realizar ações de banco de dados containerizado relacionado a um projeto(*entrar no CLI do banco*, *exportação e importação de DB*, *iniciar container de banco*)
- Realizar ações de volume do docker(*backup de volume*, *importar volume*, *navegar por arquivos do volume* )

## Preparação
> Atualize as variáveis de phandler_command.sh para o seu ambiente
Rode setup.sh para adicionar o comando ao seu bashrc.
 
## Comando phandler
O comando phandler aceita uma função para múltiplos projetos.
```sh
$ phandler [funcão] [..]
```

Para atualizar vários projetos por exemplo:
```sh
$ phandler atualizar $projeto0 $projeto1 $projeto2
```

### Container
| Função | Descrição |
| ------ | ------ |
| `entrar` | Entra na CLI do container |
| rodar | Builda e realiza o deploy do projeto |
| deploy | atualiza o código, builda e faz o deploy do projeto |
| `build_image` | Builda e realiza backup da imagem docker do projeto|
| `imagem` | Realiza o backup da imagem docker do projeto|
| `import_volume` | Importa um volume .tar.gz para o projeto |
| `export_volume` | Exporta um volume em .tar.gz para o projeto |
| `volume` | Navegar no volume (REQUER SUDO) |

### Git

| Função | Descrição |
| ------ | ------ |
| atualizar | Realiza o git pull do projeto |
| up | Realiza o git add, commit e push no projeto |
| diff | Realiza o git diff no projeto |
| status | Realiza o git status no projeto |
| checkout | Realiza o git checkout no projeto |

### Banco de Dados
| Função | Descrição |
| ------ | ------ |
| `sql` | Entra no postgres do container |
| `dump` | Realiza a exportação do banco |
| `import` | Realiza a importação de um bd |

### Parâmetros
Você também pode utilizar os paramêtros caso queria especificar mais

| Parâmetro | Descrição |
| ------ | ------ |
| -f | Função |
| -w | Caminho da workspace |
| -o | Pasta do projeto |
| -b | Branch do projeto |



