# 🚀 Grafana LTS Restore

<p align="center">

![Bash](https://img.shields.io/badge/Bash-Script-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-Compatible-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Grafana](https://img.shields.io/badge/Grafana-LTS-F46800?style=for-the-badge&logo=grafana&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)

</p>

Script desenvolvido para realizar a **restauração completa de uma instalação do Grafana LTS**, recuperando automaticamente a estrutura do ambiente e o banco de dados SQLite através de backups previamente gerados.

O processo foi pensado para ser **seguro, simples e totalmente interativo**, minimizando erros durante uma recuperação de desastre.

---

# ✨ Funcionalidades

- 📂 Lista automaticamente todos os backups disponíveis.
- 🔎 Pesquisa recursivamente os arquivos necessários.
- 📋 Menu interativo para seleção do backup.
- ✅ Validação dos arquivos antes da restauração.
- 🛑 Interrompe automaticamente o serviço do Grafana.
- 📦 Restaura:
  - `/etc/grafana`
  - `/var/lib/grafana`
- 🗄️ Restaura o banco SQLite compactado.
- 🔒 Corrige automaticamente permissões e proprietários.
- 🚀 Reinicia o serviço do Grafana ao finalizar.
- 🎨 Interface amigável utilizando cores no terminal.

---

# 📁 Estrutura esperada dos backups

O script espera encontrar os backups dentro do diretório:

```text
/backup_grafana
```

Exemplo:

```text
/backup_grafana
│
├── Backup_2026-07-30_18-00
│   ├── grafana_dirs_2026-07-30.tar.gz
│   └── grafana_db_2026-07-30.sqlite3.gz
│
├── Backup_2026-07-29_18-00
│   ├── grafana_dirs_2026-07-29.tar.gz
│   └── grafana_db_2026-07-29.sqlite3.gz
│
└── Backup_2026-07-28_18-00
    ├── grafana_dirs_2026-07-28.tar.gz
    └── grafana_db_2026-07-28.sqlite3.gz
```

A pesquisa é realizada **recursivamente**, portanto os arquivos podem estar em subdiretórios.

---

# 📦 Arquivos necessários

Cada backup deve conter obrigatoriamente:

| Arquivo | Descrição |
|----------|-----------|
| `grafana_dirs_*.tar.gz` | Backup da estrutura do Grafana |
| `grafana_db_*.sqlite3.gz` | Backup compactado do banco SQLite |

Caso algum deles esteja ausente, a restauração será interrompida.

---

# ⚙️ Como funciona

O processo de restauração executa automaticamente as seguintes etapas:

## 1️⃣ Verificação de permissões

Confirma se o script está sendo executado como **root**.

Caso contrário, a execução é interrompida.

---

## 2️⃣ Localização dos backups

O script:

- verifica a existência do diretório `/backup_grafana`;
- lista todos os backups disponíveis;
- ordena automaticamente do mais recente para o mais antigo.

---

## 3️⃣ Seleção do backup

É apresentado um menu semelhante ao abaixo:

```text
[1] Backup_2026-07-30
[2] Backup_2026-07-29
[3] Backup_2026-07-28
```

O usuário apenas informa o número correspondente.

---

## 4️⃣ Validação

Antes da restauração o script verifica se ambos os arquivos obrigatórios foram encontrados.

---

## 5️⃣ Confirmação

Antes de modificar o ambiente é exibido um aviso:

```text
⚠️ ATENÇÃO:
Este processo irá sobrescrever completamente o Grafana atual.
```

A restauração só continua após confirmação do usuário.

---

## 6️⃣ Processo automático

O script executa exatamente nesta ordem:

1. Para o serviço do Grafana
2. Extrai a estrutura do backup
3. Restaura o banco SQLite
4. Corrige permissões
5. Reinicia o serviço

---

# 🔄 Fluxo da restauração

```text
Selecionar Backup
        │
        ▼
Verificar Arquivos
        │
        ▼
Parar Grafana
        │
        ▼
Restaurar Diretórios
        │
        ▼
Restaurar Banco SQLite
        │
        ▼
Corrigir Permissões
        │
        ▼
Iniciar Grafana
        │
        ▼
Restauração Finalizada
```

---

# ▶️ Execução

Conceda permissão de execução:

```bash
chmod +x restore_grafana.sh
```

Execute como **root**:

```bash
sudo ./restore_grafana.sh
```

---

# 📋 Etapas exibidas durante a execução

Durante o processo o usuário acompanha todas as etapas:

```text
[ETAPA 1/4] Parando serviço do Grafana...

[ETAPA 2/4] Restaurando estrutura...

[ETAPA 3/4] Restaurando banco SQLite...

[ETAPA 4/4] Corrigindo permissões...

Religando serviço...

Restauração concluída!
```

---

# 🔒 Permissões aplicadas

Ao finalizar, o script garante que o ambiente permaneça consistente:

```bash
chown -R grafana:grafana /etc/grafana
chown -R grafana:grafana /var/lib/grafana
chmod 640 /var/lib/grafana/grafana.db
```

---

# 📌 Pré-requisitos

- Linux
- Bash
- Grafana instalado
- systemd
- SQLite como banco do Grafana
- Permissão de root
- Diretório `/backup_grafana`

---

# ⚠️ Importante

Este script **sobrescreve completamente**:

- configurações do Grafana;
- banco de dados SQLite;
- dashboards;
- usuários;
- organizações;
- alertas;
- datasources;
- plugins presentes no backup.

Recomenda-se executar apenas quando houver necessidade de restaurar integralmente um ambiente.

---

# ✅ Vantagens

- Interface simples
- Totalmente automatizado
- Validação de arquivos
- Evita restaurações incompletas
- Processo seguro
- Recuperação rápida de ambientes
- Ideal para Disaster Recovery
- Fácil adaptação para rotinas de administração

---

# 🛠️ Tecnologias utilizadas

- Bash
- systemctl
- tar
- gzip
- zcat
- find
- chmod
- chown

---

# 📄 Licença

Este projeto está licenciado sob a licença **MIT**.

Sinta-se à vontade para utilizar, modificar e distribuir.

---

# 👨‍💻 Autor

Desenvolvido para automatizar a recuperação de ambientes **Grafana LTS**, reduzindo o tempo de restauração e padronizando o processo de recuperação em servidores Linux.
