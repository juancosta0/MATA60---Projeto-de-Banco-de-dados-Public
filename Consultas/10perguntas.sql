--Qual o total arrecadado em cada evento?
CREATE OR REPLACE VIEW VW_ARRECADACAO_EVENTOS AS
SELECT 
    E.id_evento,
    E.nome_evento,
    SUM(P.valor) AS total_arrecadado
FROM 
    TAB_EVENTO E
INNER JOIN 
    TAB_ATIVIDADE A ON E.id_evento = A.id_evento
INNER JOIN 
    TAB_PAGAMENTO P ON A.id_atividade = P.id_atividade
GROUP BY 
    E.id_evento, E.nome_evento;

--Eventos com Informações dos Responsáveis e Locais
CREATE OR REPLACE VIEW VW_EVENTOS_RESPONSAVEIS_LOCAIS AS
SELECT 
    e.nome_evento AS evento,
    STRING_AGG(DISTINCT r.nome_completo, ', ') AS responsaveis,
    STRING_AGG(DISTINCT l.endereco, ', ') AS locais
FROM 
    TAB_EVENTO e
JOIN TAB_EVENTO_RESPONSAVEL er ON e.id_evento = er.id_evento
JOIN TAB_RESPONSAVEL r ON er.id_responsavel = r.id_responsavel
JOIN TAB_EVENTO_LOCAL el ON e.id_evento = el.id_evento
JOIN TAB_LOCAL l ON el.id_local = l.id_local
GROUP BY e.id_evento, e.nome_evento
ORDER BY e.nome_evento;

--Participantes que Pagaram por Atividades e Detalhes do Pagamento
CREATE OR REPLACE VIEW VW_PARTICIPANTES_PAGAMENTOS AS
SELECT 
    u.nome_sobrenome AS participante,
    a.nome_atividade AS atividade,
    p.valor AS valor_pago,
    p.forma_pagamento AS forma_pagamento
FROM 
    TAB_PAGAMENTO p
JOIN TAB_USUARIO u ON p.id_usuario = u.id_usuario
JOIN TAB_ATIVIDADE a ON p.id_atividade = a.id_atividade
ORDER BY u.nome_sobrenome, a.nome_atividade;

--Número de Contratados por Função em Atividades
CREATE OR REPLACE VIEW VW_CONTRATADOS_FUNCAO_ATIVIDADE AS
SELECT 
    f.nome_funcao AS funcao,
    a.tipo AS tipo_atividade,
    COUNT(DISTINCT cf.id_contratado) AS total_contratados
FROM 
    TAB_ATIVIDADE_CONTRATADO_FUNCAO cf
JOIN TAB_FUNCAO f ON cf.id_funcao = f.id_funcao
JOIN TAB_ATIVIDADE a ON cf.id_atividade = a.id_atividade
GROUP BY f.nome_funcao, a.tipo
ORDER BY f.nome_funcao, a.tipo;

--Detalhes de Atividades, Contratados e Suas Funções no Evento
CREATE OR REPLACE VIEW VW_ATIVIDADES_CONTRATADOS_FUNCAO_EVENTO AS
SELECT 
    e.nome_evento AS evento,
    a.nome_atividade AS atividade,
    c.nome_completo AS contratado,
    f.nome_funcao AS funcao,
    l.endereco AS local
FROM 
    TAB_ATIVIDADE a
JOIN TAB_EVENTO e ON a.id_evento = e.id_evento
JOIN TAB_ATIVIDADE_CONTRATADO_FUNCAO acf ON a.id_atividade = acf.id_atividade
JOIN TAB_CONTRATADO c ON acf.id_contratado = c.id_contratado
JOIN TAB_FUNCAO f ON acf.id_funcao = f.id_funcao
JOIN TAB_EVENTO_LOCAL el ON e.id_evento = el.id_evento
JOIN TAB_LOCAL l ON el.id_local = l.id_local
ORDER BY e.nome_evento, a.nome_atividade, c.nome_completo;

--Participantes Pagantes e Detalhes de Eventos e Locais
CREATE OR REPLACE VIEW VW_PARTICIPANTES_EVENTOS_LOCAIS AS
SELECT 
    u.nome_sobrenome AS participante,
    e.nome_evento AS evento,
    l.endereco AS local,
    p.valor AS valor_pago
FROM 
    TAB_PAGAMENTO p
JOIN TAB_USUARIO u ON p.id_usuario = u.id_usuario
JOIN TAB_ATIVIDADE a ON p.id_atividade = a.id_atividade
JOIN TAB_EVENTO e ON a.id_evento = e.id_evento
JOIN TAB_EVENTO_LOCAL el ON e.id_evento = el.id_evento
JOIN TAB_LOCAL l ON el.id_local = l.id_local
ORDER BY u.nome_sobrenome, e.nome_evento, l.endereco;

--Locais com Capacidade Média para Eventos
CREATE OR REPLACE VIEW VW_CAPACIDADE_MEDIA_LOCAIS AS
SELECT 
    e.tipo AS tipo_evento,
    AVG(l.capacidade) AS capacidade_media
FROM 
    TAB_EVENTO e
JOIN TAB_EVENTO_LOCAL el ON e.id_evento = el.id_evento
JOIN TAB_LOCAL l ON el.id_local = l.id_local
GROUP BY e.tipo
ORDER BY e.tipo;

--Eventos com Maior Duração
CREATE OR REPLACE VIEW VW_EVENTOS_DURACAO AS
SELECT 
    id_evento,
    nome_evento,
    data_inicio,
    data_termino,
    (data_termino - data_inicio) AS duracao_dias
FROM 
    TAB_EVENTO
ORDER BY duracao_dias DESC;

--Contratados Alocados em Múltiplas Atividades
CREATE OR REPLACE VIEW VW_CONTRATADOS_MULTIPLAS_ATIVIDADES AS
SELECT 
    c.id_contratado,
    c.nome_completo,
    COUNT(DISTINCT cf.id_atividade) AS total_atividades
FROM 
    TAB_ATIVIDADE_CONTRATADO_FUNCAO cf
JOIN TAB_CONTRATADO c ON cf.id_contratado = c.id_contratado
GROUP BY c.id_contratado, c.nome_completo
HAVING COUNT(DISTINCT cf.id_atividade) > 1
ORDER BY total_atividades DESC;

--Usuários com Mais Participações em Atividades
CREATE OR REPLACE VIEW VW_USUARIOS_MAIS_ATIVIDADES AS
SELECT 
    u.id_usuario,
    u.nome_sobrenome,
    COUNT(DISTINCT p.id_atividade) AS total_atividades
FROM 
    TAB_PAGAMENTO p
JOIN TAB_USUARIO u ON p.id_usuario = u.id_usuario
GROUP BY u.id_usuario, u.nome_sobrenome
ORDER BY total_atividades DESC;

