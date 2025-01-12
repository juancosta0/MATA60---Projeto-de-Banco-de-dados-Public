--Criando a tabela usuario 
CREATE TABLE TAB_USUARIO (
	id_usuario SERIAL,
	cpf VARCHAR(11) NOT NULL UNIQUE,
	senha VARCHAR(255) NOT NULL, --implementar um hash no Back para não armazenar a senha direta do usuario
	dica_senha VARCHAR(255) DEFAULT NULL, 
	nome_sobrenome VARCHAR(50) NOT NULL,
	ultimo_nome VARCHAR(50) NOT NULL,
	instituicao VARCHAR(50) DEFAULT NULL, 
	escolaridade VARCHAR(100) NOT NULL,
	telefone VARCHAR(15) NOT NULL, 
	email VARCHAR(255) NOT NULL,
	sexo CHAR(1) NOT NULL
);
ALTER TABLE TAB_USUARIO
ADD CONSTRAINT PK_PESSOA PRIMARY KEY (id_usuario);

--Criando a tabela local
CREATE TABLE TAB_LOCAL(
	id_local SERIAL,
	endereco VARCHAR(255) NOT NULL,
	capacidade INTEGER NOT NULL,
	tipo_local VARCHAR(50)
);
ALTER TABLE TAB_LOCAL
ADD CONSTRAINT PK_LOCAL PRIMARY KEY (id_local);

--Criando a tabela evento
CREATE TABLE TAB_EVENTO (
    id_evento SERIAL,
    nome_evento VARCHAR(255) NOT NULL,
    data_inicio DATE NOT NULL,
    data_termino DATE NOT NULL,
    tipo VARCHAR(255) NOT NULL,
    status VARCHAR(100) NOT NULL,
	gratuidade VARCHAR(3) NOT NULL
);

ALTER TABLE TAB_EVENTO
ADD CONSTRAINT PK_EVENTO PRIMARY KEY (id_evento);

--Criando a tabela função
CREATE TABLE TAB_FUNCAO(
	id_funcao SERIAL,
	nome_funcao VARCHAR(100) NOT NULL
);
ALTER TABLE TAB_FUNCAO
ADD CONSTRAINT PK_FUNCAO PRIMARY KEY(id_funcao);

--Criando a tabela atividade
CREATE TABLE TAB_ATIVIDADE(
    id_atividade SERIAL,
    nome_atividade VARCHAR(255) NOT NULL,
    tipo VARCHAR(100) NOT NULL,
    area VARCHAR(255) NOT NULL,
    resumo VARCHAR(255) NOT NULL,
	data_inicio DATE NOT NULL,
	data_termino DATE NOT NULL
    -- Falta chaves estrangeiras
);
ALTER TABLE TAB_ATIVIDADE
ADD CONSTRAINT PK_ATIVIDADE PRIMARY KEY(id_atividade);




--Criando a tabela pagamento
CREATE TABLE TAB_PAGAMENTO(
	id_pagamento SERIAL,
	valor NUMERIC(15,2) NOT NULL,
	forma_pagamento VARCHAR(100) NOT NULL,
	status_pagamento VARCHAR(100) NOT NULL
    -- Falta chaves estrangeiras
);

ALTER TABLE TAB_PAGAMENTO
ADD CONSTRAINT PK_PAGAMENTO PRIMARY KEY(id_pagamento);

--Criando a tabela contratado
CREATE TABLE TAB_contratado (
    id_contratado SERIAL,
    nome_completo VARCHAR(50) NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL
);
ALTER TABLE TAB_CONTRATADO
ADD CONSTRAINT PK_CONSTRATADO PRIMARY KEY(id_contratado);

--Criando a tabela responsavel
CREATE TABLE tab_responsavel (
    id_responsavel SERIAL,
    nome_completo VARCHAR(50),
    cpf VARCHAR(11),
    senha VARCHAR(255),
    UNIQUE (cpf)
);

ALTER TABLE tab_responsavel
ADD CONSTRAINT PK_RESPONSAVEL PRIMARY KEY(id_responsavel);

--Criando a tabela de relacionamento evento local
CREATE TABLE TAB_EVENTO_LOCAL (
    id_evento INTEGER NOT NULL,
    id_local INTEGER NOT NULL,
    FOREIGN KEY (id_evento) REFERENCES TAB_EVENTO(id_evento),
    FOREIGN KEY (id_local) REFERENCES TAB_LOCAL(id_local)
);

--Criando a tabela de relacionamento atividade contratado funcao
CREATE TABLE TAB_ATIVIDADE_CONTRATADO_FUNCAO (
    id_atividade INTEGER NOT NULL,
    id_contratado INTEGER NOT NULL,
	id_funcao INTEGER NOT NULL,
    FOREIGN KEY (id_atividade) REFERENCES TAB_ATIVIDADE(id_atividade),
    FOREIGN KEY (id_contratado) REFERENCES TAB_CONTRATADO(id_contratado),
	FOREIGN KEY (id_funcao) REFERENCES TAB_FUNCAO(id_funcao)
);
ALTER TABLE TAB_ATIVIDADE_CONTRATADO_FUNCAO
ADD CONSTRAINT UC_atividade_contratado_funcao UNIQUE (id_atividade, id_contratado, id_funcao);

--Criando a tabela de relacionamento evento responsavel
CREATE TABLE TAB_EVENTO_RESPONSAVEL (
    id_evento INTEGER NOT NULL,
    id_responsavel INTEGER NOT NULL,
    FOREIGN KEY (id_evento) REFERENCES TAB_EVENTO(id_evento),
    FOREIGN KEY (id_responsavel) REFERENCES TAB_RESPONSAVEL(id_responsavel)
);




--DEFININDO CONSTRAINTS

BEGIN;

ALTER TABLE TAB_PAGAMENTO
ADD COLUMN id_usuario INTEGER NOT NULL; 

ALTER TABLE TAB_PAGAMENTO
ADD CONSTRAINT FK_ID_USUARIO
FOREIGN KEY (id_usuario)
REFERENCES TAB_USUARIO(id_usuario)
ON DELETE CASCADE;

ALTER TABLE TAB_PAGAMENTO
ADD COLUMN id_atividade INTEGER NOT NULL; 

ALTER TABLE TAB_PAGAMENTO
ADD CONSTRAINT FK_ID_ATIVIDADE
FOREIGN KEY (id_atividade)
REFERENCES TAB_ATIVIDADE(id_atividade)
ON DELETE CASCADE;

ALTER TABLE TAB_PAGAMENTO
ADD CONSTRAINT UC_USUARIO_ATIVIDADE UNIQUE (id_usuario, id_atividade);

commit;

BEGIN;

ALTER TABLE TAB_ATIVIDADE
ADD COLUMN id_evento INTEGER NOT NULL; 

ALTER TABLE TAB_ATIVIDADE
ADD CONSTRAINT FK_ID_EVENTO
FOREIGN KEY (id_evento)
REFERENCES TAB_EVENTO(id_evento)
ON DELETE CASCADE;


commit;



