Restauração Automatizada do Grafana (LTS)
Este repositório/diretório contém o script oficial de restauração automatizada para o Grafana. Ele foi projetado para atuar em conjunto com o nosso script de backup diário, garantindo uma recuperação de desastres (Disaster Recovery) rápida, interativa e à prova de falhas de permissão.

Visão Geral
O script restore_grafana.sh automatiza a injeção de configurações, plugins e do banco de dados SQLite do Grafana. Ele possui um menu interativo que lista os backups disponíveis e aplica correções automáticas de permissões (chown) para evitar atritos com o sistema operacional após a restauração.

Funcionalidades
Menu Interativo: Lista automaticamente todas as subpastas de backup encontradas em /backup_grafana, ordenadas da mais recente para a mais antiga.

Busca Recursiva (Smart Find): Não exige que os arquivos de backup tenham nomes estáticos fixos. O script varre a pasta selecionada e localiza as extensões .tar.gz (estrutura) e .sqlite3.gz (banco de dados) automaticamente.

Proteção de Integridade: Desliga temporariamente o serviço do Grafana (grafana-server) durante a injeção de dados para evitar corrupção do banco SQLite em uso.

Auto-Correção de Permissões (UID Fix): Mapeia e corrige a propriedade das pastas /etc/grafana e /var/lib/grafana para o usuário de sistema grafana local, prevenindo erros de tela cinza ou Permission Denied.

Pré-requisitos
Antes de executar este script, garanta que o seu ambiente atenda aos seguintes requisitos:

Sistema Operacional: Ubuntu ou Debian.

Privilégios: Acesso completo de root ou permissões via sudo.

Grafana Instalado: O servidor de destino já deve ter os binários do Grafana instalados. Este script restaura os dados, não instala o software do zero.

Estrutura de Diretórios: Os arquivos de backup devem estar localizados no diretório base padrão da automação:

Plaintext
/backup_grafana/
├── bkp_2026-07-30/
│   ├── grafana_db_20260730.sqlite3.gz
│   └── grafana_dirs_2026-07-30.tar.gz
└── bkp_2026-07-31/
    ├── grafana_db_20260731.sqlite3.gz
    └── grafana_dirs_2026-07-31.tar.gz
    
Como Usar
1. Dê permissão de execução ao script:
O arquivo precisa ser executável para rodar no terminal.

Bash
chmod +x restore_grafana.sh
2. Execute o script como administrador:

Bash
sudo ./restore_grafana.sh
3. Siga o fluxo na tela:

O script apresentará um menu numerado com as datas de backup disponíveis.

Digite o número correspondente à data desejada e pressione ENTER.

Confirme a operação digitando s quando o sistema alertar sobre a sobrescrita dos dados atuais.

Aguarde a finalização (geralmente leva menos de 10 segundos).

Aviso Importante: Após a restauração em um servidor recém-instalado, se as versões do Grafana (antiga vs. nova) forem muito discrepantes, pode ser necessário atualizar os plugins manualmente executando grafana cli plugins update-all e reiniciando o serviço.
