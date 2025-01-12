--Eventos com maior número de responsaveis
CREATE MATERIALIZED VIEW eventos_populares AS
SELECT e.id_evento, e.nome_evento, COUNT(ep.id_evento) as num_participantes
FROM TAB_EVENTO e
JOIN TAB_EVENTO_RESPONSAVEL ep ON e.id_evento = ep.id_evento
GROUP BY e.id_evento
ORDER BY num_participantes DESC;

--Atividades mais populares por tipo:
CREATE MATERIALIZED VIEW atividades_populares AS
SELECT a.tipo, COUNT(ac.id_atividade) as num_atividades
FROM TAB_ATIVIDADE a
JOIN TAB_ATIVIDADE_CONTRATADO_FUNCAO ac ON a.id_atividade = ac.id_atividade
GROUP BY a.tipo
ORDER BY num_atividades DESC;

--Gastos totais por evento:
CREATE MATERIALIZED VIEW gastos_por_evento AS
SELECT e.id_evento, e.nome_evento, SUM(p.valor) as total_gasto
FROM TAB_EVENTO e
JOIN TAB_ATIVIDADE a ON e.id_evento = a.id_evento
JOIN TAB_PAGAMENTO p ON a.id_atividade = p.id_atividade
GROUP BY e.id_evento;

--Calcular o número total de participantes em um evento:
CREATE OR REPLACE PROCEDURE atualizar_status_pagamento(
    IN p_id_pagamento INTEGER,
    IN p_novo_status VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE TAB_PAGAMENTO
    SET status_pagamento = p_novo_status
    WHERE id_pagamento = p_id_pagamento;
END;
$$;


--Atualizar o status de um pagamento:
CREATE OR REPLACE PROCEDURE atualizar_status_pagamento(
    IN p_id_pagamento INTEGER,
    IN p_novo_status VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE TAB_PAGAMENTO
    SET status_pagamento = p_novo_status
    WHERE id_pagamento = p_id_pagamento;
END;
$$;


--Retorna o usuario que fez mais pagamentos
CREATE OR REPLACE PROCEDURE usuario_com_mais_pagamentos(
    OUT p_id_usuario INTEGER,
    OUT p_nome_sobrenome VARCHAR,
    OUT p_total_pagamentos INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT
        u.id_usuario,
        u.nome_sobrenome,
        COUNT(*) AS total_pagamentos
    INTO
        p_id_usuario, p_nome_sobrenome, p_total_pagamentos
    FROM
        TAB_PAGAMENTO p
    JOIN TAB_ATIVIDADE a ON p.id_atividade = a.id_atividade
    JOIN TAB_USUARIO u ON a.id_usuario = u.id_usuario
    GROUP BY u.id_usuario, u.nome_sobrenome
    ORDER BY total_pagamentos DESC
    LIMIT 1;
END;
$$;
