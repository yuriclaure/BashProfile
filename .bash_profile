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

source ~/Codereview/main.sh
