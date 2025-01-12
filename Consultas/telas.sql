--   PARTICIPANTE SE INSCREVENTO NO SISTEMA 
--Faça aqui o registro no sistema
--Seu CPF('12345678925')
--Senha('AmorDaMinhaVida')
--Dica de senha('Juan')
--Nome e sobre nome('Laila Gabriel')
--Ultimo nome('Silva')
--Instituição('UFBA')
--Escolaridade('Ensino Medio')
--Telefone('77987559953')
--Email('aplicativoslaila@gmail.com')
--Sexo('F')
INSERT INTO TAB_USUARIO (
    cpf,
    senha,
    dica_senha,
    nome_sobrenome,
    ultimo_nome,
    instituicao,
    escolaridade,
    telefone,
    email,
    sexo
) VALUES (
    '12345678925',
    'AmorDaMinhaVida', 
    'Juan',
    'Laila Gabriel',
    'Silva',
    'UFBA',
    'Ensino Medio',
    '77987559953',
    'aplicativoslaila@gmail.com',
    'F'
);
--(SIMPLES)ESCOLHENDO O EVENTO E A ATIVIDADE
--Selecione o evento e a atividade em que deseja se inscrever 
(SELECT E.nome_evento, A.nome_atividade, E.id_evento, A.id_atividade, E.gratuidade
FROM TAB_ATIVIDADE A
LEFT JOIN TAB_EVENTO E ON E.id_evento = A.id_evento;)

--Evento desejado('A simplicidade de inovar com força total') --dados ocultos (id_evento_ 166)
--Atividade desejada('Introdutório em Inteligência Artificial') --dados ocultos(id_atividade = 2085)
--Evento Gratis
INSERT INTO TAB_PAGAMENTO(valor,forma_pagamento,status_pagamento,id_usuario,id_atividade) VALUES(
	0.00,
	'cortesia',
	'pago',
	1851,
	2085
)


--   PARTICIPANTE SE INSCREVENDO NO SISTEMA
--Faça aqui o registro no sistema
--Seu CPF('98765432110')
--Senha('MelhorAmigo123')
--Dica de senha('Cachorro')
--Nome e sobrenome('João Pedro')
--Ultimo nome('Almeida')
--Instituição('USP')
--Escolaridade('Graduação')
--Telefone('11987654321')
--Email('joaopedro.almeida@usp.br')
--Sexo('M')
INSERT INTO TAB_USUARIO (
    cpf,
    senha,
    dica_senha,
    nome_sobrenome,
    ultimo_nome,
    instituicao,
    escolaridade,
    telefone,
    email,
    sexo
) VALUES (
    '98765432110',
    'MelhorAmigo123', 
    'Cachorro',
    'João Pedro',
    'Almeida',
    'USP',
    'Graduação',
    '11987654321',
    'joaopedro.almeida@usp.br',
    'M'
);


--   PARTICIPANTE SE INSCREVENDO NO SISTEMA
--Faça aqui o registro no sistema
--Seu CPF('32145698722')
--Senha('Vida1234!')
--Dica de senha('Minha vida')
--Nome e sobrenome('Ana Clara')
--Ultimo nome('Souza')
--Instituição('UNB')
--Escolaridade('Mestrado')
--Telefone('61998765432')
--Email('ana.clara@unb.br')
--Sexo('F')
INSERT INTO TAB_USUARIO (
    cpf,
    senha,
    dica_senha,
    nome_sobrenome,
    ultimo_nome,
    instituicao,
    escolaridade,
    telefone,
    email,
    sexo
) VALUES (
    '32145698722',
    'Vida1234!', 
    'Minha vida',
    'Ana Clara',
    'Souza',
    'UNB',
    'Mestrado',
    '61998765432',
    'ana.clara@unb.br',
    'F'
);


--   PARTICIPANTE SE INSCREVENDO NO SISTEMA
--Faça aqui o registro no sistema
--Seu CPF('65498712333')
--Senha('Segredo@2025')
--Dica de senha('Segredo')
--Nome e sobrenome('Carlos Eduardo')
--Ultimo nome('Pereira')
--Instituição('UFSC')
--Escolaridade('Doutorado')
--Telefone('48996543210')
--Email('carlos.pereira@ufsc.br')
--Sexo('M')
INSERT INTO TAB_USUARIO (
    cpf,
    senha,
    dica_senha,
    nome_sobrenome,
    ultimo_nome,
    instituicao,
    escolaridade,
    telefone,
    email,
    sexo
) VALUES (
    '65498712333',
    'Segredo@2025', 
    'Segredo',
    'Carlos Eduardo',
    'Pereira',
    'UFSC',
    'Doutorado',
    '48996543210',
    'carlos.pereira@ufsc.br',
    'M'
);

--   PARTICIPANTE SE INSCREVENDO NO SISTEMA
--Faça aqui o registro no sistema
--Seu CPF('98712365444')
--Senha('Natureza*123')
--Dica de senha('Natureza')
--Nome e sobrenome('Beatriz Helena')
--Ultimo nome('Lima')
--Instituição('UNESP')
--Escolaridade('Graduação')
--Telefone('11987541236')
--Email('beatriz.lima@unesp.br')
--Sexo('F')
INSERT INTO TAB_USUARIO (
    cpf,
    senha,
    dica_senha,
    nome_sobrenome,
    ultimo_nome,
    instituicao,
    escolaridade,
    telefone,
    email,
    sexo
) VALUES (
    '98712365444',
    'Natureza*123', 
    'Natureza',
    'Beatriz Helena',
    'Lima',
    'UNESP',
    'Graduação',
    '11987541236',
    'beatriz.lima@unesp.br',
    'F'
);

--   PARTICIPANTE SE INSCREVENDO NO SISTEMA
--Faça aqui o registro no sistema
--Seu CPF('32178965455')
--Senha('Trabalho2025')
--Dica de senha('Futuro')
--Nome e sobrenome('Lucas Vinícius')
--Ultimo nome('Oliveira')
--Instituição('UFRJ')
--Escolaridade('Pós-graduação')
--Telefone('21965478910')
--Email('lucas.oliveira@ufrj.br')
--Sexo('M')
INSERT INTO TAB_USUARIO (
    cpf,
    senha,
    dica_senha,
    nome_sobrenome,
    ultimo_nome,
    instituicao,
    escolaridade,
    telefone,
    email,
    sexo
) VALUES (
    '32178965455',
    'Trabalho2025', 
    'Futuro',
    'Lucas Vinícius',
    'Oliveira',
    'UFRJ',
    'Pós-graduação',
    '21965478910',
    'lucas.oliveira@ufrj.br',
    'M'
);

--   PARTICIPANTE SE INSCREVENDO NO SISTEMA
--Faça aqui o registro no sistema
--Seu CPF('45612378966')
--Senha('Familia1234')
--Dica de senha('Família')
--Nome e sobrenome('Maria Luiza')
--Ultimo nome('Castro')
--Instituição('UFPR')
--Escolaridade('Ensino Médio')
--Telefone('41996547852')
--Email('maria.castro@ufpr.br')
--Sexo('F')
INSERT INTO TAB_USUARIO (
    cpf,
    senha,
    dica_senha,
    nome_sobrenome,
    ultimo_nome,
    instituicao,
    escolaridade,
    telefone,
    email,
    sexo
) VALUES (
    '45612378966',
    'Familia1234', 
    'Família',
    'Maria Luiza',
    'Castro',
    'UFPR',
    'Ensino Médio',
    '41996547852',
    'maria.castro@ufpr.br',
    'F'
);
--   PARTICIPANTE SE INSCREVENDO NO SISTEMA
--Faça aqui o registro no sistema
--Seu CPF('74185296377')
--Senha('Amigos@2025')
--Dica de senha('Amigos')
--Nome e sobrenome('Felipe Augusto')
--Ultimo nome('Martins')
--Instituição('UFC')
--Escolaridade('Graduação')
--Telefone('85987451236')
--Email('felipe.martins@ufc.br')
--Sexo('M')
INSERT INTO TAB_USUARIO (
    cpf,
    senha,
    dica_senha,
    nome_sobrenome,
    ultimo_nome,
    instituicao,
    escolaridade,
    telefone,
    email,
    sexo
) VALUES (
    '74185296377',
    'Amigos@2025', 
    'Amigos',
    'Felipe Augusto',
    'Martins',
    'UFC',
    'Graduação',
    '85987451236',
    'felipe.martins@ufc.br',
    'M'
);

--   PARTICIPANTE SE INSCREVENDO NO SISTEMA
--Faça aqui o registro no sistema
--Seu CPF('85274196388')
--Senha('Felicidade@123')
--Dica de senha('Felicidade')
--Nome e sobrenome('Gabriela Vitória')
--Ultimo nome('Carvalho')
--Instituição('UNIFESP')
--Escolaridade('Mestrado')
--Telefone('11963258741')
--Email('gabriela.carvalho@unifesp.br')
--Sexo('F')
INSERT INTO TAB_USUARIO (
    cpf,
    senha,
    dica_senha,
    nome_sobrenome,
    ultimo_nome,
    instituicao,
    escolaridade,
    telefone,
    email,
    sexo
) VALUES (
    '85274196388',
    'Felicidade@123', 
    'Felicidade',
    'Gabriela Vitória',
    'Carvalho',
    'UNIFESP',
    'Mestrado',
    '11963258741',
    'gabriela.carvalho@unifesp.br',
    'F'
);

INSERT INTO TAB_USUARIO (
    cpf,
    senha,
    dica_senha,
    nome_sobrenome,
    ultimo_nome,
    instituicao,
    escolaridade,
    telefone,
    email,
    sexo
) VALUES (
    '85274196388',
    'Felicidade@123', 
    'Felicidade',
    'Gabriela Vitória',
    'Carvalho',
    'UNIFESP',
    'Mestrado',
    '11963258741',
    'gabriela.carvalho@unifesp.br',
    'F'
);

--(AVANÇADA)Consulta de Eventos com Informações dos Responsáveis e Locais
--Esta consulta retorna uma lista de eventos, incluindo o nome do evento,
--os responsáveis associados (com nome completo), e os locais onde o evento ocorre.
(SELECT 
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
)

--(INTERMEDIARIA)Participantes que Pagaram por Atividades e Detalhes do Pagamento
--Esta consulta retorna uma lista de usuários que realizaram pagamentos, 
--incluindo o nome do usuário, a atividade pela qual pagaram, o valor do pagamento e a forma de pagamento.
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

--(INTERMEDIARIA)Número de Contratados por Função em Atividades
--ta consulta retorna a contagem de contratados por função, agrupados por nome da função e tipo de atividade.
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

--(AVANÇADA)Detalhes de Atividades, Contratados e suas Funções no Evento
--Esta consulta lista as atividades realizadas em eventos, os contratados responsáveis, 
--suas funções e o local onde o evento ocorre.
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

-- (AVANÇADA) Participantes Pagantes e Detalhes de Eventos e Locais
--Esta consulta retorna uma lista de participantes que realizaram pagamentos, 
--os eventos correspondentes, os locais onde os eventos ocorrem e o valor pago.

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

--(INTERMEDIARIA)Locais com Capacidade Média para Eventos
--Esta consulta calcula a capacidade média dos locais utilizados para eventos, agrupando por tipo de evento.
SELECT 
    e.tipo AS tipo_evento,
    AVG(l.capacidade) AS capacidade_media
FROM 
    TAB_EVENTO e
JOIN TAB_EVENTO_LOCAL el ON e.id_evento = el.id_evento
JOIN TAB_LOCAL l ON el.id_local = l.id_local
GROUP BY e.tipo
ORDER BY e.tipo;

--(SIMPLES)Visualiza todo os usuarios
SELECT * FROM TAB_USUARIO;

--(SIMPLES)VISUALIZA todos os eventos
SELECT * FROM TAB_EVENTO

--(SIMPLES)Visualiza todo os pagamentos
SELECT * FROM TAB_PAGAMENTO;

--(SIMPLES)VISUALIZA todos as atividades
SELECT * FROM TAB_ATIVIDADE;
