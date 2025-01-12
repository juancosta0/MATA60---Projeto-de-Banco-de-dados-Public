BEGIN;

-- Índices para TAB_USUARIO
CREATE INDEX idx_usuario_cpf ON TAB_USUARIO(cpf);
-- Justificativa: Índice criado para acelerar consultas que busquem usuários pelo CPF, dado que é um campo único e frequentemente utilizado como identificador.

CREATE INDEX idx_usuario_email ON TAB_USUARIO(email);
-- Justificativa: Este índice otimiza consultas que busquem usuários pelo email, um campo com alta probabilidade de uso em autenticações ou buscas de dados.

-- Índices para TAB_LOCAL
CREATE INDEX idx_local_endereco ON TAB_LOCAL(endereco);
-- Justificativa: Este índice facilita buscas por endereços específicos ou para operações que envolvam locais por endereço.

-- Índices para TAB_EVENTO
CREATE INDEX idx_evento_data_inicio ON TAB_EVENTO(data_inicio);
-- Justificativa: Índice criado para otimizar consultas por eventos em períodos específicos, especialmente quando ordenados pela data de início.

CREATE INDEX idx_evento_status ON TAB_EVENTO(status);
-- Justificativa: Otimiza buscas baseadas no status do evento, uma característica relevante para filtrar eventos ativos, cancelados, etc.

-- Índices para TAB_ATIVIDADE
CREATE INDEX idx_atividade_tipo ON TAB_ATIVIDADE(tipo);
-- Justificativa: Facilita a segmentação de atividades por tipo, útil em relatórios ou buscas categorizadas.

CREATE INDEX idx_atividade_data_inicio ON TAB_ATIVIDADE(data_inicio);
-- Justificativa: Otimiza a busca por atividades que começam em períodos específicos.

-- Índices para TAB_PAGAMENTO
CREATE INDEX idx_pagamento_id_usuario ON TAB_PAGAMENTO(id_usuario);
-- Justificativa: Acelera consultas relacionadas a pagamentos realizados por um usuário específico.

CREATE INDEX idx_pagamento_id_atividade ON TAB_PAGAMENTO(id_atividade);
-- Justificativa: Acelera a busca por pagamentos relacionados a uma atividade específica.

CREATE INDEX idx_pagamento_status_pagamento ON TAB_PAGAMENTO(status_pagamento);
-- Justificativa: Otimiza buscas e relatórios baseados no status do pagamento.

-- Índices para TAB_CONTRATADO
CREATE INDEX idx_contratado_cpf ON TAB_CONTRATADO(cpf);
-- Justificativa: Facilita a busca de contratados por CPF, um identificador único.

-- Índices para TAB_RESPONSAVEL
CREATE INDEX idx_responsavel_cpf ON TAB_RESPONSAVEL(cpf);
-- Justificativa: Acelera buscas de responsáveis pelo CPF, que é único e relevante para autenticação ou identificação.

-- Índices para tabelas de relacionamento
CREATE INDEX idx_evento_local_id_evento ON TAB_EVENTO_LOCAL(id_evento);
-- Justificativa: Otimiza junções e buscas envolvendo eventos associados a locais.

CREATE INDEX idx_evento_local_id_local ON TAB_EVENTO_LOCAL(id_local);
-- Justificativa: Acelera consultas relacionadas a locais associados a eventos.

CREATE INDEX idx_atividade_contratado_funcao_id_atividade ON TAB_ATIVIDADE_CONTRATADO_FUNCAO(id_atividade);
-- Justificativa: Otimiza buscas por contratados ou funções relacionadas a uma atividade específica.

CREATE INDEX idx_evento_responsavel_id_evento ON TAB_EVENTO_RESPONSAVEL(id_evento);
-- Justificativa: Facilita a busca por responsáveis associados a eventos específicos.

CREATE INDEX idx_evento_responsavel_id_responsavel ON TAB_EVENTO_RESPONSAVEL(id_responsavel);
-- Justificativa: Acelera consultas relacionadas a eventos de um responsável específico.

COMMIT;
