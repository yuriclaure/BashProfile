PROJECTS_ROOT_FOLDER='/c/Users/yuriclaure/Projetos'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

abrirPastaDoProjeto() {
    cd $PROJECTS_ROOT_FOLDER/$1
}
autocompleteAbrirPastaDoProjeto() {
    local token=${COMP_WORDS[COMP_CWORD]}
    
    local words=""
    for folder in $(ls $PROJECTS_ROOT_FOLDER); do 
    	words="$words$folder ";
    done;
    local wordsLower=$( printf %s "$words" | tr [:upper:] [:lower:] )
    local tokenLower=$( printf %s "$token" | tr [:upper:] [:lower:] )
    
    COMPREPLY=( $(compgen -W "$wordsLower" -- $tokenLower) )
}

updateAllProjects() {
	local currentFolder=${pwd}
	for project in $(ls $PROJECTS_ROOT_FOLDER); do
		printf "${RED}Atualizando projeto ${GREEN}"$project"${NC}\n"
		ir $project;
		atualizar;
	done
	cd $currentFolder

}

openVisualStudio() {
	printf "${RED}Abrindo projeto no Visual Studio.${NC}\n";
	start */*.sln
}

compilarProjeto() {
	printf "${RED}Compilando projeto.${NC}\n";
	MSBuild.exe -verbosity:quiet src/*.sln;
}

tratarMigracao() {
	if ! [ -z "$1" ] && [ $1 = "rollback" ]
	then
		printf "${RED}Realizando rollback da última migração.${NC}\n";
		MSBuild.exe -verbosity:quiet src/builds/migrations.proj /target:Rollback;
	else
		printf "${RED}Realizando migrações do projeto.${NC}\n";
		MSBuild.exe -verbosity:quiet src/builds/migrations.proj /target:Migrate;
	fi
}

restaurarTudo() {
	currentFolder=$(pwd)

	printf "${RED}Restaurando DB do ${GREEN}Alternativo${NC}.\n";
	restaurar_domus;
	ir domus-alternativo;
	migrar;

	printf "${RED}Restaurando DB do ${GREEN}Administração${NC}.\n";
	restaurar_adm;
	ir domus-administracao;
	migrar;
	
	cd $currentFolder;
}

# __codereview_finish() {
# 	current_git_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p');

# 	if [ $current_git_branch = "master" ];
# 		then
# 		printf "${RED}Você não pode finalizar code reviews na master.${NC}";
# 		return;
# 	fi

# 	printf "Finalizar essa code review ira deletar essa branch e irá descartar as mudanças que nao foram merged na master.\n";
# 	read -p "Você tem certeza que quer fazer isso [Y/N]? " -n 1 -r;
# 	if [[ ! $REPLY =~ ^[Yy]$ ]];
# 	then
# 	    return;
# 	fi

# 	git checkout . &> /dev/null
# 	git checkout master &> /dev/null
# 	git pull &> /dev/null
# 	git branch -d $current_git_branch &> /dev/null

# 	printf "\n${GREEN}Code review de ${current_git_branch} finalizada.";
# }

# __codereview_help() {
# 	printf "codereview <branch_name> [--push]\n"
# 	printf "\tCria (ou altera) uma branch com o nome <branch_name> para criar um pull request."
# 	printf "\tSe a master tiver commits, eles são movidos para essa nova branch."
# 	printf "\tSe voce adicionar --push ele já envia para o servidor as alterações.\n"
# 	printf "codereview --push"
# 	printf "\tEnvia os commits na branch atual para o servidor e cria um pull request (ou atualiza um existente).\n"
# 	printf "codereview --finish"
# 	printf "\tFinaliza o code review deletando a branch atual e voltando para a master."
# 	return;
# }


# __codereview_create_pull_request() {
# 	declare -A repositories_id=( 
# 		["http://tfs01:8080/tfs/DigithoBrasil/Solu%C3%A7%C3%B5es%20em%20Software/_git/Domus-Contemplados"]="e5d33934-6334-4845-ade3-37b255d93dfe" 
# 		["http://tfs01:8080/tfs/DigithoBrasil/Solu%C3%A7%C3%B5es%20em%20Software/_git/Domus-Inscricao"]="1a92b651-ba36-46e8-8a82-0ba44e953488"
# 		["http://tfs01:8080/tfs/DigithoBrasil/Solu%C3%A7%C3%B5es%20em%20Software/_git/Domus-Seguranca"]="28dbdb07-0288-4b3b-b3c8-7033335e3634"
# 		["http://tfs01:8080/tfs/DigithoBrasil/Solu%C3%A7%C3%B5es%20em%20Software/_git/Domus-Selecao"]="7fae0e9d-1c05-4afb-8bf5-789160da6ad7"
# 		["http://tfs01:8080/tfs/DigithoBrasil/Solu%C3%A7%C3%B5es%20em%20Software/_git/Domus-Alternativo"]="e9e8f20f-8c4a-456d-a704-7fb790bb57ab"
# 		["http://tfs01:8080/tfs/DigithoBrasil/Solu%C3%A7%C3%B5es%20em%20Software/_git/Domus-Administracao"]="53aac979-9e6c-4365-8139-d304d0d7570d"
# 		["http://tfs01:8080/tfs/DigithoBrasil/Solu%C3%A7%C3%B5es%20em%20Software/_git/Domus-Tramitacao"]="ae71aaba-a768-48a9-b68a-ed4a7bf4b4d6"
# 		["http://tfs01:8080/tfs/DigithoBrasil/Solu%C3%A7%C3%B5es%20em%20Software/_git/Enderecos"]="c7eb0744-0bd6-455c-bbaa-f426cd8f2801"
# 	)

# 	current_git_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p');
# 	current_repo=$(git config remote.origin.url 2>&1)
# 	current_repo_id=${repositories_id["${current_repo}"]}

# 	list_of_pull_requests=$(curl --ntlm -u : http://tfs01:8080/tfs/DigithoBrasil/_apis/git/repositories/${current_repo_id}/pullrequests?api-version=2.0 2> /dev/null)

# 	# if there is already an active pull request for the same branch
# 	printf "$list_of_pull_requests" | grep -q "\"sourceRefName\":\"refs/heads/$current_git_branch\",\"targetRefName\":\"refs/heads/master\""
# 	if [ $? = 0 ]; 
# 		then
# 			printf "${GREEN}Pull request atualizada com sucesso.${NC}"
# 	else
# 		printf "${GREEN}Criando pull request${NC}\n";

# 		read -p "Título da pull request: " -r;
# 		title=$REPLY
# 		read -p "Descrição da pull request: " -r;
# 		description=$REPLY

# 		curl --ntlm -u : -X POST -i -H "Content-type: application/json" -X POST http://tfs01:8080/tfs/DigithoBrasil/_apis/git/repositories/${current_repo_id}/pullrequests?api-version=2.0 -d "
#     {
#         \"sourceRefName\":\"refs/heads/${current_git_branch}\",
#         \"targetRefName\":\"refs/heads/master\",
#         \"title\":\"${title}\",
#         \"description\":\"${description}\"
#     }" &> /dev/null

# 		printf "${GREEN}Pull request criada com sucesso.${NC}"
# 	fi
# }

# __codereview_push_and_create() {
# 	current_git_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p');

# 	if [ $current_git_branch = "master" ];
# 		then
# 		printf "${RED}Impossível criar code review na master. Veja --help para ajuda.${NC}\n";
# 		return;
# 	fi

# 	git_push_output=$(git push --set-upstream origin ${current_git_branch} 2>&1);
# 	if ! [ $? = 0 ];
# 		then
# 		printf "${RED}Você tem mudanças não comittadas no branch atual.${NC}\n";
# 		printf "$git_push_output";
# 		return;
# 	fi

# 	__codereview_create_pull_request;

# }

# __codereview_check_options() {
# 	option=$1

# 	if [ $option = "--push" ];
# 		then
# 		__codereview_push_and_create;
# 	elif [ $option = "--finish" ]; 
# 		then
# 		__codereview_finish;
# 	elif [ $option = "--help" ];
# 		then
# 		__codereview_help;
# 	else
# 		printf "${RED}Parametro $option não reconhecido. Veja --help para ajuda.${NC}\n";
# 		return;
# 	fi
# }

# __codereview() {

# 	if [ -z "$1" ];
# 		then
# 		echo "Você precisa informar o nome da branch para onde a code review será instanciada. Exemplo:";
# 		printf "\n\tcodereview novo_botao\n";
# 		printf "Veja --help para mais ajuda.";
# 		return;
# 	fi

# 	if [[ "$1" ==  "--"* ]];
# 		then
# 			if [ $# = 1 ];
# 				then
# 				__codereview_check_options $1;
# 			else
# 				printf "${RED}Número de parametros incompatível. Veja --help para ajuda.${NC}\n";
# 			fi
# 		return;
# 	fi

# 	local should_it_push=false;

# 	if [ $# -gt 2 ];
# 		then
# 		printf "${RED}Número de parametros incompatível. Veja --help para ajuda.${NC}\n";
# 		return;
# 	elif [ $# = 2 ];
# 		then
# 		if [ $2 = "--push" ];
# 			then
# 			should_it_push=true;
# 		else
# 			printf "${RED}Parametro $2 não reconhecido. Veja --help para ajuda.${NC}\n";
# 			return;
# 		fi
# 	fi

# 	name_of_work=$1;
# 	current_git_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p');

# 	# switching to master before creating new branch
# 	if ! [ $current_git_branch = "master" ];
# 		then
# 		changing_to_master_output=$(git checkout master 2>&1);
# 		if ! [ $? = 0 ];
# 			then
# 			printf "${RED}Você tem mudanças não comittadas no branch atual.${NC}\n";
# 			printf "$changing_to_master_output";
# 			return;
# 		fi
# 	fi

# 	# if branch already exists
# 	git show-branch $name_of_work &> /dev/null;
# 	if [ $? = 0 ];
# 		then
# 		printf "${RED}Uma branch com o nome de $name_of_work já existe!${NC}\n${NC}";
# 		read -p "Você deseja realizar um merge da master nessa branch [Y/N]? " -n 1 -r;
# 		echo ""
# 		if [[ ! $REPLY =~ ^[Yy]$ ]];
# 		then
# 		    return;
# 		fi

# 		changing_to_work_branch_output=$(git checkout $name_of_work 2>&1);
# 		if ! [ $? = 0 ];
# 			then
# 			printf "${RED}Você tem mudanças não comittadas no branch atual.${NC}\n";
# 			printf "$changing_to_work_branch_output";
# 			return;
# 		fi
# 		git merge master
# 		if [ $? = 0 ];
# 			then
# 			git checkout master &> /dev/null
# 			git fetch origin &> /dev/null
# 			git reset --hard origin/master &> /dev/null
# 			git checkout $name_of_work &> /dev/null
# 			return;
# 		fi
# 	else
# 		git branch $name_of_work &> /dev/null;
# 		git checkout $name_of_work &> /dev/null;
# 		git checkout master &> /dev/null;
# 		git fetch origin &> /dev/null
# 		git reset --hard origin/master &> /dev/null
# 		git checkout $name_of_work &> /dev/null;
# 	fi




# 	if [ should_it_push = true ];
# 		then
# 		__codereview_push_and_create;
# 	else
# 		printf "${GREEN}Branch criada e pronta para ser usada para a code review. \nExecute ${RED}codereview --push${GREEN} quando estiver pronto.${NC}";
# 	fi
# }

complete -F autocompleteAbrirPastaDoProjeto ir

alias ir=abrirPastaDoProjeto
alias recarregar='source ~/.bash_profile'
alias bp='vim ~/.bash_profile'
alias vs=openVisualStudio
alias compilar=compilarProjeto
alias migrar=tratarMigracao
alias atualizar='git pull;compilar;migrar'
alias ver='explorer .'
alias limpar='MSBuild.exe -verbosity:quiet -target:clean src/*.sln'
alias testar='compilar;nunit-console.exe -noresult -config=Debug src/*Dominio.Testes*/*.csproj'
alias atualizar_todos=updateAllProjects
alias restaurar_tudo=restaurarTudo
alias restaurar_adm='sqlcmd -Q "use master; ALTER DATABASE AGEHAB_ADMINISTRACAO SET SINGLE_USER WITH ROLLBACK IMMEDIATE RESTORE DATABASE AGEHAB_ADMINISTRACAO FROM DISK = '"'"'B:\bancos\AGEHAB_ADMINISTRACAO_20160815_Full.bak'"'"' WITH REPLACE"'
alias restaurar_domus='sqlcmd -Q "use master; ALTER DATABASE AGEHAB_domus SET SINGLE_USER WITH ROLLBACK IMMEDIATE RESTORE DATABASE AGEHAB_domus FROM DISK = '"'"'B:\bancos\AGEHAB_domus_20160815_Full.bak'"'"' WITH REPLACE"'
alias restaurar_seguranca='sqlcmd -Q "use master; ALTER DATABASE AGEHAB_domus_seguranca SET SINGLE_USER WITH ROLLBACK IMMEDIATE RESTORE DATABASE AGEHAB_domus_seguranca FROM DISK = '"'"'B:\bancos\AGEHAB_domus_seguranca_S902_13102014_1440.bak'"'"' WITH REPLACE"'
alias restaurar_selecao='sqlcmd -Q "use master; ALTER DATABASE AGEHAB_selecao SET SINGLE_USER WITH ROLLBACK IMMEDIATE RESTORE DATABASE AGEHAB_selecao FROM DISK = '"'"'B:\bancos\AGEHAB_selecao_20160615_Full.bak'"'"' WITH REPLACE"'
alias restaurar_inscricao='sqlcmd -Q "use master; ALTER DATABASE AGEHAB_inscricao_web SET SINGLE_USER WITH ROLLBACK IMMEDIATE RESTORE DATABASE AGEHAB_inscricao_web FROM DISK = '"'"'B:\bancos\AGEHAB_inscricao_web_S904_26102015_1547.bak'"'"' WITH REPLACE"'
alias restaurar_contemplados='sqlcmd -Q "use master; ALTER DATABASE AGEHAB_contemplados SET SINGLE_USER WITH ROLLBACK IMMEDIATE RESTORE DATABASE AGEHAB_contemplados FROM DISK = '"'"'B:\bancos\AGEHAB_contemplados_S902_13102014_1437.bak'"'"' WITH REPLACE"'
# alias codereview=__codereview

source ~/Codereview/main.sh
