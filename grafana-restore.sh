#!/bin/bash

# Cores para mensagens
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

show_splash() {
    clear
    echo -e "\e[31m"
    echo "██████╗ ███████╗███████╗████████╗ ██████╗ ██████╗ ███████╗"
    echo "██╔══██╗██╔════╝██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗██╔════╝"
    echo "██████╔╝█████╗  ███████╗   ██║   ██║   ██║██████╔╝█████╗  "
    echo "██╔══██╗██╔══╝  ╚════██║   ██║   ██║   ██║██╔══██╗██╔══╝  "
    echo "██║  ██║███████╗███████║   ██║   ╚██████╔╝██║  ██║███████╗"
    echo "╚═╝  ╚═╝╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝"
    echo -e "\e[0m"
    echo "========================================================"
    echo "               RESTAURAÇÃO GRAFANA LTS"
    echo "========================================================"
    echo ""
    sleep 2
}

show_splash

echo -e "${BLUE}========================================================${NC}"
echo -e "          ${YELLOW}🚀 Restauração Automatizada Segura${NC}"
echo -e "          ${YELLOW}📜 Injeção de Estrutura e SQLite${NC}"
echo -e "${BLUE}========================================================${NC}"

# === VERIFICAÇÃO DE ROOT ===
if [ "$(id -u)" -ne 0 ]; then
    echo -e "\n${RED}❌ ERRO: Este script deve ser executado como root.${NC}" >&2
    exit 1
fi

BASE_DIR="/backup_grafana"

# Verifica se a pasta principal de backups existe
if [ ! -d "$BASE_DIR" ]; then
    echo -e "\n${RED}❌ ERRO: O diretório base de backups ($BASE_DIR) não foi encontrado.${NC}"
    exit 1
fi

# Lê todas as pastas de backup (nível 1) e armazena em um array, ordenando das mais recentes para as mais antigas
mapfile -t BACKUP_DIRS < <(find "$BASE_DIR" -mindepth 1 -maxdepth 1 -type d | sort -r)

# Verifica se o array está vazio
if [ ${#BACKUP_DIRS[@]} -eq 0 ]; then
    echo -e "\n${RED}❌ ERRO: Nenhuma pasta de backup foi encontrada dentro de $BASE_DIR.${NC}"
    exit 1
fi

# === MENU INTERATIVO ===
echo -e "\n${YELLOW}📂 Pastas de backup disponíveis:${NC}"
i=1
for dir in "${BACKUP_DIRS[@]}"; do
    # Extrai apenas o nome final da pasta para deixar a tela limpa
    FOLDER_NAME=$(basename "$dir")
    echo -e "   [${GREEN}$i${NC}] $FOLDER_NAME"
    ((i++))
done

MAX_OPT=$((${#BACKUP_DIRS[@]}))
echo ""
read -p "Selecione o número do backup desejado (1 a $MAX_OPT): " OPTION

# Valida se a entrada do usuário é um número e se está dentro das opções válidas
if ! [[ "$OPTION" =~ ^[0-9]+$ ]] || [ "$OPTION" -lt 1 ] || [ "$OPTION" -gt "$MAX_OPT" ]; then
    echo -e "\n${RED}❌ ERRO: Opção inválida. Execução abortada.${NC}"
    exit 1
fi

# Pega o caminho completo da pasta selecionada (-1 porque o array do bash começa em 0)
SELECTED_DIR="${BACKUP_DIRS[$((OPTION-1))]}"

echo -e "\n${GREEN}🔍 Pesquisando arquivos recursivamente em: $(basename "$SELECTED_DIR")...${NC}"

# Procura os arquivos recursivamente em qualquer lugar dentro da pasta selecionada
TAR_FILE=$(find "$SELECTED_DIR" -type f -name "grafana_dirs_*.tar.gz" | head -n 1)
DB_FILE=$(find "$SELECTED_DIR" -type f -name "grafana_db_*.sqlite3.gz" | head -n 1)

if [[ -z "$TAR_FILE" || -z "$DB_FILE" ]]; then
    echo -e "${RED}❌ ERRO: Faltam arquivos estruturais (.tar.gz) ou de banco de dados (.sqlite3.gz) nesta pasta.${NC}"
    exit 1
fi

echo -e "✅ Arquivo Estrutural encontrado: $(basename "$TAR_FILE")"
echo -e "✅ Arquivo de Banco encontrado: $(basename "$DB_FILE")"

echo -e "\n${RED}⚠️  ATENÇÃO: Este processo irá SOBRESCREVER o Grafana atual.${NC}"
read -p "Deseja continuar? (s/n): " CONFIRM
if [[ "$CONFIRM" != "s" && "$CONFIRM" != "S" ]]; then
    echo -e "\nOperação cancelada pelo usuário."
    exit 0
fi

# === INÍCIO DA RESTAURAÇÃO ===
echo -e "\n${GREEN}🛑 [ETAPA 1/4] Parando serviço do Grafana...${NC}"
systemctl stop grafana-server

echo -e "\n${GREEN}📦 [ETAPA 2/4] Restaurando pastas estruturais (/etc/grafana e /var/lib/grafana)...${NC}"
tar -xzf "$TAR_FILE" -C /

echo -e "\n${GREEN}🛢️ [ETAPA 3/4] Injetando banco de dados SQLite...${NC}"
zcat "$DB_FILE" > /var/lib/grafana/grafana.db

echo -e "\n${GREEN}🔒 [ETAPA 4/4] Corrigindo permissões de usuários internos...${NC}"
chown -R grafana:grafana /etc/grafana
chown -R grafana:grafana /var/lib/grafana
chmod 640 /var/lib/grafana/grafana.db

echo -e "\n${GREEN}🚀 Religando o serviço do Grafana...${NC}"
systemctl start grafana-server

echo -e "\n${GREEN}✅ ✅ ✅ Restauração concluída com sucesso! ✅ ✅ ✅${NC}"
echo -e "Acesse o painel web para validar os seus dashboards."
echo -e "${BLUE}========================================================${NC}"