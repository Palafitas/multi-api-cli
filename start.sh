#!/bin/bash

# Cria o diretório temporário (pode ser excluído)
mkdir tmp

# Porta dos containers para ser auto incrementada conforme lista de clientes/imagens
PORTA=9000

# Nome dos clientes, será concatenado no nome do container para diferenciá-los
CLIENTES=("pala" "fitas") 

# Strings de conexão com banco de dados, lembra de seguir a ordem conforme a variavel CLIENTES, e.g: CLIENTES("pala") <-> CONEXOES("CONEXAO_SQL_DO_PALA")
CONEXOES=("CONEXAO_SQL_PALA" "CONEXAO_SQL_FITAS")

# Pasta base de onde vão estar localizados os projetos para serem compilados
BASE='local/das/web_api/geracao/imagens'

# Nome da pasta contendo a webapi para buildar a imagem docker
IMAGENS=("NOME.Projeto.WebApi")

# Compila a webapi e cria uma dockerfile, afim de ser utilizada posteriormente para criação da imagem docker (você pode fazer esse processo manualmente e só executar a opção 2 do menu)
function gerar_base() {
dotnet restore "$BASE/$1/$1.csproj" --disable-parallel
dotnet publish "$BASE/$1/$1.csproj" -c Release -o tmp/$1 --no-restore
echo -e "FROM mcr.microsoft.com/dotnet/aspnet:8.0 \n
WORKDIR /app \n
RUN mkdir $1
COPY * $1/ \n
ENTRYPOINT [\"dotnet\", \"$1/$1.dll\"]" > tmp/$1/dockerfile
}

# Builda as imagens para utilizar no docker
function build_img() {
	docker build -q --tag $1 $2
}

function novo_container() {
	((PORTA=PORTA+1))
	docker run -q -d --name $2 --rm -p $PORTA:8080 -e ASPNETCORE_ENVIRONMENT=Production -e ConnectionStrings__DefaultConnection="$1" "$3"
}

# Inicia o nginx
function run_nginx() {
	echo '- Atualizando nginx.conf'
	cp nginx/base.conf nginx/nginx.conf
	sed -i "s|LOCATIONS|$1|g" nginx/nginx.conf

	echo "- Buildando n1_nginx"
	build_img 'n1_nginx' 'nginx'
	
	echo "- Rodando n1_nginx"
	bash -c "docker run -q -d --name 'n1_nginx' --rm -p 8080:8080 $2 'n1_nginx'"
}

function gerar_imagens() {
	for img in "${IMAGENS[@]}"
	do
		echo "- Gerando base da imagem: $img";
		gerar_base $img > /dev/null
		
		img_name="${img,,}"
		echo "- Gerando imagem docker: $img_name";
		build_img $img_name tmp/$img
	done
}

function gerar_api_clientes() {
	links_nginx=''
	locations=''
	for (( i=0; i<${#CLIENTES[@]}; i++ ));
	do 
		cliente="${CLIENTES[$i]}"
		conexao="${CONEXOES[$i]}"
	
		for (( x=0; x<${#IMAGENS[@]}; x++ ));
		do
			img="${IMAGENS[$x]}"
			img_name="${img,,}"
			container="${cliente}_${img_name}"
			rota_pos_cli="${img_name##*.}"
			echo "- Gerando container: $container"
			novo_container "$conexao" "$container" "$img_name"
			
			links_nginx="$links_nginx --link $container"
			locations="${locations}location /${cliente}/${rota_pos_cli} { proxy_pass http://${container}:8080; }\n"
		done
	done
	
	run_nginx "$locations" "$links_nginx"
}

function menu () {
	clear
	echo -e "+++ Multi API-CLI +++"
	echo " 1. Gerar imagens Docker"
	echo " 2. Gerar api para os clientes"
	read -p "Selecione uma opcao: " opcao

	case $opcao in
		1)
		gerar_imagens
		;;

		2)
		gerar_api_clientes
		;;

		*)
		echo 'KO - Opção inválida'
		;;
	esac
	
	read -p 'Pressione uma tecla para voltar ao menu...'
	menu
}

menu
