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




--Atualizar o status de um pagamento:
CREATE OR REPLACE PROCEDURE atualiza_status_pagamento(
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
CREATE OR REPLACE PROCEDURE usuario_com_mais_pagamento(
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


--registrar Usuário com Pagamento e Atividade
CREATE OR REPLACE PROCEDURE registra_usuario_pagamento_atividade(
    p_cpf VARCHAR(11),
    p_senha VARCHAR(255),
    p_dica_senha VARCHAR(255),
    p_nome_sobrenome VARCHAR(50),
    p_ultimo_nome VARCHAR(50),
    p_instituicao VARCHAR(50),
    p_escolaridade VARCHAR(100),
    p_telefone VARCHAR(15),
    p_email VARCHAR(255),
    p_sexo CHAR(1),
    p_valor NUMERIC(15,2),
    p_forma_pagamento VARCHAR(100),
    p_status_pagamento VARCHAR(100),
    p_id_atividade INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    _id_usuario INTEGER;
BEGIN
    -- Inserir o novo usuário
    INSERT INTO TAB_USUARIO (
        cpf, senha, dica_senha, nome_sobrenome, ultimo_nome, instituicao, escolaridade, telefone, email, sexo
    ) VALUES (
        p_cpf, p_senha, p_dica_senha, p_nome_sobrenome, p_ultimo_nome, p_instituicao, p_escolaridade, p_telefone, p_email, p_sexo
    )
    RETURNING id_usuario INTO _id_usuario;

    -- Inserir o pagamento relacionado ao usuário e atividade
    INSERT INTO TAB_PAGAMENTO (
        valor, forma_pagamento, status_pagamento, id_usuario, id_atividade
    ) VALUES (
        p_valor, p_forma_pagamento, p_status_pagamento, _id_usuario, p_id_atividade
    );

    -- Mensagem de sucesso
    RAISE NOTICE 'Usuário e pagamento registrados com sucesso. ID do usuário: %', _id_usuario;
END;
$$;
