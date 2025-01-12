import os
import subprocess
import datetime
import shutil

# Configurações gerais
PG_USER = "postgres"
PG_HOST = "localhost"
PG_DATABASE = "projeto_pratico_1"
BACKUP_DIR = "/home/juancs1/Downloads/BD-UFBA/Projeto 1 v2/backupSQL"
LOGICAL_BACKUP_DIR = os.path.join(BACKUP_DIR, "logicos")
PHYSICAL_BACKUP_DIR = os.path.join(BACKUP_DIR, "fisicos")
RETENTION_DAYS = 30  # Dias para manter os backups antigos

# Função para criar backup lógico (pg_dump)
def backup_logico():
    hoje = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M")
    nome_arquivo = f"backup_logico_{hoje}.sql"
    caminho_arquivo = os.path.join(LOGICAL_BACKUP_DIR, nome_arquivo)
    try:
        os.makedirs(LOGICAL_BACKUP_DIR, exist_ok=True)
        comando = [
            "pg_dump",
            "-U", PG_USER,
            "-h", PG_HOST,
            PG_DATABASE,
            "-f", caminho_arquivo
        ]
        print(f"Criando backup lógico: {caminho_arquivo}")
        subprocess.run(comando, check=True, env={"PGPASSWORD": "edivaldo8213"})
        print("Backup lógico concluído!")
    except Exception as e:
        print(f"Erro ao criar backup lógico: {e}")

# Função para criar backup físico (pg_basebackup)
def backup_fisico():
    hoje = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M")
    caminho_backup = os.path.join(PHYSICAL_BACKUP_DIR, f"backup_fisico_{hoje}")
    try:
        os.makedirs(PHYSICAL_BACKUP_DIR, exist_ok=True)
        comando = [
            "pg_basebackup",
            "-U", PG_USER,
            "-h", PG_HOST,
            "-D", caminho_backup,
            "-F", "tar",
            "-X", "stream"
        ]
        print(f"Criando backup físico: {caminho_backup}")
        subprocess.run(comando, check=True, env={"PGPASSWORD": "edivaldo8213"})
        print("Backup físico concluído!")
    except Exception as e:
        print(f"Erro ao criar backup físico: {e}")

# Função para limpar backups antigos
def limpar_backups_antigos():
    try:
        hoje = datetime.datetime.now()
        for diretorio in [LOGICAL_BACKUP_DIR, PHYSICAL_BACKUP_DIR]:
            if not os.path.exists(diretorio):
                continue
            for arquivo in os.listdir(diretorio):
                caminho_arquivo = os.path.join(diretorio, arquivo)
                if os.path.isfile(caminho_arquivo) or caminho_arquivo.endswith(".tar"):
                    ultima_modificacao = datetime.datetime.fromtimestamp(os.path.getmtime(caminho_arquivo))
                    if (hoje - ultima_modificacao).days > RETENTION_DAYS:
                        print(f"Removendo backup antigo: {caminho_arquivo}")
                        os.remove(caminho_arquivo)
                elif os.path.isdir(caminho_arquivo):
                    ultima_modificacao = datetime.datetime.fromtimestamp(os.path.getmtime(caminho_arquivo))
                    if (hoje - ultima_modificacao).days > RETENTION_DAYS:
                        print(f"Removendo diretório de backup antigo: {caminho_arquivo}")
                        shutil.rmtree(caminho_arquivo)
        print("Limpeza de backups antigos concluída!")
    except Exception as e:
        print(f"Erro ao limpar backups antigos: {e}")

# Executa o ciclo de backup
if __name__ == "__main__":
    print("Iniciando ciclo de backup...")
    backup_logico()
    dia_da_semana = datetime.datetime.now().weekday()
    if dia_da_semana == 6:  # Backup físico aos domingos (0 = segunda-feira, 6 = domingo)
        backup_fisico()
    limpar_backups_antigos()
    print("Ciclo de backup concluído!")
