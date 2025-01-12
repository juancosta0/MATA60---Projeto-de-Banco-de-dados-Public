--
-- PostgreSQL database dump
--

-- Dumped from database version 16.6 (Ubuntu 16.6-1.pgdg24.04+1)
-- Dumped by pg_dump version 17.2 (Ubuntu 17.2-1.pgdg24.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: btree_gin; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gin WITH SCHEMA public;


--
-- Name: EXTENSION btree_gin; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION btree_gin IS 'support for indexing common datatypes in GIN';


--
-- Name: adicionarfuncao(character varying, integer, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.adicionarfuncao(IN p_nome_funcao character varying, IN p_horas integer, IN p_area character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO TAB_FUNCAO (nome_funcao, horas, area)
    VALUES (p_nome_funcao, p_horas, p_area);
END;
$$;


ALTER PROCEDURE public.adicionarfuncao(IN p_nome_funcao character varying, IN p_horas integer, IN p_area character varying) OWNER TO postgres;

--
-- Name: adicionarpessoa(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.adicionarpessoa(IN p_cpf character varying, IN p_senha character varying, IN p_dica_senha character varying, IN p_nome_sobrenome character varying, IN p_ultimo_nome character varying, IN p_escolaridade character varying, IN p_telefone character varying, IN p_email character varying, IN p_sexo character)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO TAB_PESSOA (
        cpf, senha, dica_senha, nome_sobrenome, ultimo_nome,
        escolaridade, telefone, email, sexo
    ) VALUES (
        p_cpf, p_senha, p_dica_senha, p_nome_sobrenome, p_ultimo_nome,
        p_escolaridade, p_telefone, p_email, p_sexo
    );
END;
$$;


ALTER PROCEDURE public.adicionarpessoa(IN p_cpf character varying, IN p_senha character varying, IN p_dica_senha character varying, IN p_nome_sobrenome character varying, IN p_ultimo_nome character varying, IN p_escolaridade character varying, IN p_telefone character varying, IN p_email character varying, IN p_sexo character) OWNER TO postgres;

--
-- Name: log_sensitive_access(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.log_sensitive_access() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    RAISE NOTICE 'Tentativa de acesso sensível na tabela tab_pessoa por %', current_user;
    RETURN NEW; -- Para UPDATE
    -- RETURN OLD; -- Para DELETE
END;
$$;


ALTER FUNCTION public.log_sensitive_access() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: tab_evento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tab_evento (
    id_evento integer NOT NULL,
    nome_evento character varying(255) NOT NULL,
    data_inicio date NOT NULL,
    data_termino date NOT NULL,
    tipo character varying(255) NOT NULL,
    status character varying(100) NOT NULL,
    id_local integer NOT NULL,
    pagamento boolean DEFAULT false NOT NULL
);


ALTER TABLE public.tab_evento OWNER TO postgres;

--
-- Name: tab_evento_funcao_pessoa; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tab_evento_funcao_pessoa (
    id_pessoa integer NOT NULL,
    id_evento integer NOT NULL,
    id_funcao integer NOT NULL
);


ALTER TABLE public.tab_evento_funcao_pessoa OWNER TO postgres;

--
-- Name: tab_funcao; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tab_funcao (
    id_funcao integer NOT NULL,
    nome_funcao character varying(100) NOT NULL,
    horas integer NOT NULL,
    area character varying(100) NOT NULL
);


ALTER TABLE public.tab_funcao OWNER TO postgres;

--
-- Name: tab_pessoa; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tab_pessoa (
    id_pessoa integer NOT NULL,
    cpf character varying(11) NOT NULL,
    senha character varying(255) NOT NULL,
    dica_senha character varying(255) DEFAULT NULL::character varying,
    nome_sobrenome character varying(50) NOT NULL,
    ultimo_nome character varying(50) NOT NULL,
    escolaridade character varying(100) NOT NULL,
    telefone character varying(15) NOT NULL,
    email character varying(255) NOT NULL,
    sexo character(1) NOT NULL
);


ALTER TABLE public.tab_pessoa OWNER TO postgres;

--
-- Name: evento_pessoa_funcao; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.evento_pessoa_funcao AS
 SELECT e.nome_evento,
    p.cpf,
    p.nome_sobrenome,
    f.nome_funcao
   FROM (((public.tab_evento e
     JOIN public.tab_evento_funcao_pessoa efp ON ((efp.id_evento = e.id_evento)))
     JOIN public.tab_funcao f ON ((f.id_funcao = efp.id_funcao)))
     JOIN public.tab_pessoa p ON ((p.id_pessoa = efp.id_pessoa)))
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.evento_pessoa_funcao OWNER TO postgres;

--
-- Name: tab_inscrito; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tab_inscrito (
    id_inscrito integer NOT NULL,
    data_inscricao date NOT NULL,
    nome_cracha character varying(50) NOT NULL,
    status character varying(50) NOT NULL,
    id_evento integer NOT NULL,
    id_tipo integer NOT NULL,
    id_pessoa integer NOT NULL
);


ALTER TABLE public.tab_inscrito OWNER TO postgres;

--
-- Name: tab_pagamento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tab_pagamento (
    id_pagamento integer NOT NULL,
    valor numeric(15,2) NOT NULL,
    forma_pagamento character varying(100) NOT NULL,
    status_pagamento character varying(100) NOT NULL,
    id_inscrito integer NOT NULL
);


ALTER TABLE public.tab_pagamento OWNER TO postgres;

--
-- Name: nome_cpf_valor_evento; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.nome_cpf_valor_evento AS
 SELECT pe.nome_sobrenome,
    pe.cpf,
    pa.valor,
    e.nome_evento
   FROM (((public.tab_inscrito i
     JOIN public.tab_pessoa pe ON ((pe.id_pessoa = i.id_pessoa)))
     JOIN public.tab_pagamento pa ON ((i.id_inscrito = pa.id_inscrito)))
     JOIN public.tab_evento e ON ((e.id_evento = i.id_evento)))
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.nome_cpf_valor_evento OWNER TO postgres;

--
-- Name: tab_atividade; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tab_atividade (
    id_atividade integer NOT NULL,
    nome_atividade character varying(255) NOT NULL,
    tipo character varying(100) NOT NULL,
    status_atividade character varying(100) NOT NULL,
    area character varying(255) NOT NULL,
    resumo character varying(255) NOT NULL,
    id_evento integer NOT NULL,
    id_inscrito integer NOT NULL
);


ALTER TABLE public.tab_atividade OWNER TO postgres;

--
-- Name: tab_atividade_autor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tab_atividade_autor (
    id_autor integer NOT NULL,
    id_atividade integer NOT NULL
);


ALTER TABLE public.tab_atividade_autor OWNER TO postgres;

--
-- Name: tab_atividade_funcao_pessoa; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tab_atividade_funcao_pessoa (
    id_funcao integer NOT NULL,
    id_pessoa integer NOT NULL,
    id_atividade integer NOT NULL
);


ALTER TABLE public.tab_atividade_funcao_pessoa OWNER TO postgres;

--
-- Name: tab_atividade_id_atividade_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tab_atividade_id_atividade_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tab_atividade_id_atividade_seq OWNER TO postgres;

--
-- Name: tab_atividade_id_atividade_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tab_atividade_id_atividade_seq OWNED BY public.tab_atividade.id_atividade;


--
-- Name: tab_autores; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tab_autores (
    id_autor integer NOT NULL,
    id_pessoa integer NOT NULL
);


ALTER TABLE public.tab_autores OWNER TO postgres;

--
-- Name: tab_autores_id_autor_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tab_autores_id_autor_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tab_autores_id_autor_seq OWNER TO postgres;

--
-- Name: tab_autores_id_autor_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tab_autores_id_autor_seq OWNED BY public.tab_autores.id_autor;


--
-- Name: tab_certificado; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tab_certificado (
    id_certificado integer NOT NULL,
    tipo_certificado character varying(255) NOT NULL,
    horas integer NOT NULL,
    status_certificado character varying(255) NOT NULL,
    data_emissao date,
    id_evento integer NOT NULL,
    id_atividade integer,
    id_inscrito integer
);


ALTER TABLE public.tab_certificado OWNER TO postgres;

--
-- Name: tab_certificado_id_certificado_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tab_certificado_id_certificado_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tab_certificado_id_certificado_seq OWNER TO postgres;

--
-- Name: tab_certificado_id_certificado_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tab_certificado_id_certificado_seq OWNED BY public.tab_certificado.id_certificado;


--
-- Name: tab_evento_id_evento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tab_evento_id_evento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tab_evento_id_evento_seq OWNER TO postgres;

--
-- Name: tab_evento_id_evento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tab_evento_id_evento_seq OWNED BY public.tab_evento.id_evento;


--
-- Name: tab_funcao_id_funcao_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tab_funcao_id_funcao_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tab_funcao_id_funcao_seq OWNER TO postgres;

--
-- Name: tab_funcao_id_funcao_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tab_funcao_id_funcao_seq OWNED BY public.tab_funcao.id_funcao;


--
-- Name: tab_inscrito_id_inscrito_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tab_inscrito_id_inscrito_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tab_inscrito_id_inscrito_seq OWNER TO postgres;

--
-- Name: tab_inscrito_id_inscrito_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tab_inscrito_id_inscrito_seq OWNED BY public.tab_inscrito.id_inscrito;


--
-- Name: tab_local; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tab_local (
    id_local integer NOT NULL,
    endereco character varying(255) NOT NULL,
    capacidade integer NOT NULL,
    duracao integer NOT NULL,
    tipo_local character varying(50)
);


ALTER TABLE public.tab_local OWNER TO postgres;

--
-- Name: tab_local_id_local_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tab_local_id_local_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tab_local_id_local_seq OWNER TO postgres;

--
-- Name: tab_local_id_local_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tab_local_id_local_seq OWNED BY public.tab_local.id_local;


--
-- Name: tab_pagamento_id_pagamento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tab_pagamento_id_pagamento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tab_pagamento_id_pagamento_seq OWNER TO postgres;

--
-- Name: tab_pagamento_id_pagamento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tab_pagamento_id_pagamento_seq OWNED BY public.tab_pagamento.id_pagamento;


--
-- Name: tab_pessoa_id_pessoa_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tab_pessoa_id_pessoa_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tab_pessoa_id_pessoa_seq OWNER TO postgres;

--
-- Name: tab_pessoa_id_pessoa_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tab_pessoa_id_pessoa_seq OWNED BY public.tab_pessoa.id_pessoa;


--
-- Name: tab_pessoa_masked; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.tab_pessoa_masked AS
 SELECT id_pessoa,
    nome_sobrenome,
    ultimo_nome,
    sexo,
        CASE
            WHEN (CURRENT_USER = ANY (ARRAY['auditor_user'::name, 'inscrito_user'::name])) THEN '***.***.***-**'::character varying
            ELSE cpf
        END AS cpf,
        CASE
            WHEN (CURRENT_USER = 'inscrito_user'::name) THEN NULL::character varying
            ELSE email
        END AS email,
        CASE
            WHEN (CURRENT_USER = 'inscrito_user'::name) THEN NULL::character varying
            ELSE telefone
        END AS telefone
   FROM public.tab_pessoa
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.tab_pessoa_masked OWNER TO postgres;

--
-- Name: tab_tipo_inscrito; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tab_tipo_inscrito (
    id_tipo integer NOT NULL,
    nome_tipo character varying(100) NOT NULL,
    permissao_submissao boolean NOT NULL,
    limite_vaga integer NOT NULL
);


ALTER TABLE public.tab_tipo_inscrito OWNER TO postgres;

--
-- Name: tab_tipo_pessoa_id_tipo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tab_tipo_pessoa_id_tipo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tab_tipo_pessoa_id_tipo_seq OWNER TO postgres;

--
-- Name: tab_tipo_pessoa_id_tipo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tab_tipo_pessoa_id_tipo_seq OWNED BY public.tab_tipo_inscrito.id_tipo;


--
-- Name: vw_eventos_por_tipo_e_trimestre; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_eventos_por_tipo_e_trimestre AS
 SELECT tipo,
    to_char((data_inicio)::timestamp with time zone, 'YYYY-Q'::text) AS trimestre,
    count(*) AS quantidade_eventos
   FROM public.tab_evento
  GROUP BY tipo, (to_char((data_inicio)::timestamp with time zone, 'YYYY-Q'::text));


ALTER VIEW public.vw_eventos_por_tipo_e_trimestre OWNER TO postgres;

--
-- Name: vw_locais_mais_utilizados; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_locais_mais_utilizados AS
 SELECT l.endereco,
    count(*) AS total_eventos
   FROM (public.tab_evento e
     JOIN public.tab_local l ON ((e.id_local = l.id_local)))
  GROUP BY l.endereco
  ORDER BY (count(*)) DESC;


ALTER VIEW public.vw_locais_mais_utilizados OWNER TO postgres;

--
-- Name: vw_media_participantes_por_tipo; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_media_participantes_por_tipo AS
 SELECT e.tipo,
    count(i.id_inscrito) AS total_inscritos,
    round(avg(count(i.id_inscrito)) OVER (PARTITION BY e.tipo)) AS media_participantes
   FROM (public.tab_evento e
     JOIN public.tab_inscrito i ON ((e.id_evento = i.id_evento)))
  WHERE ((i.status)::text = 'Confirmada'::text)
  GROUP BY e.tipo;


ALTER VIEW public.vw_media_participantes_por_tipo OWNER TO postgres;

--
-- Name: vw_participante_mais_submete; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_participante_mais_submete AS
 SELECT pe.nome_sobrenome,
    count(*) AS total_trabalhos
   FROM ((public.tab_atividade t
     JOIN public.tab_inscrito p ON ((t.id_inscrito = p.id_inscrito)))
     JOIN public.tab_pessoa pe ON ((pe.id_pessoa = p.id_pessoa)))
  GROUP BY pe.id_pessoa, pe.nome_sobrenome
  ORDER BY (count(*)) DESC;


ALTER VIEW public.vw_participante_mais_submete OWNER TO postgres;

--
-- Name: vw_perfil_inscrito_evento; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_perfil_inscrito_evento AS
 SELECT p.escolaridade,
    p.sexo
   FROM ((public.tab_inscrito i
     JOIN public.tab_evento e ON ((e.id_evento = i.id_evento)))
     JOIN public.tab_pessoa p ON ((i.id_pessoa = p.id_pessoa)))
  WHERE (i.id_evento = ANY (ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]));


ALTER VIEW public.vw_perfil_inscrito_evento OWNER TO postgres;

--
-- Name: vw_receita_total_gerada_por_cada_evento; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_receita_total_gerada_por_cada_evento AS
 SELECT e.nome_evento,
    sum(p.valor) AS receita_total
   FROM ((public.tab_evento e
     JOIN public.tab_inscrito i ON ((e.id_evento = i.id_evento)))
     JOIN public.tab_pagamento p ON ((i.id_inscrito = p.id_inscrito)))
  GROUP BY e.nome_evento;


ALTER VIEW public.vw_receita_total_gerada_por_cada_evento OWNER TO postgres;

--
-- Name: vw_retorno_inscrito_evento; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_retorno_inscrito_evento AS
 WITH participantesretornantes AS (
         SELECT i.id_pessoa,
            count(*) AS total_eventos
           FROM public.tab_inscrito i
          GROUP BY i.id_pessoa
         HAVING (count(*) > 1)
        )
 SELECT count(*) AS count,
    round((((count(*))::numeric * 100.0) / (( SELECT count(DISTINCT tab_inscrito.id_pessoa) AS count
           FROM public.tab_inscrito))::numeric)) AS porcentagem_retorno
   FROM participantesretornantes;


ALTER VIEW public.vw_retorno_inscrito_evento OWNER TO postgres;

--
-- Name: vw_taxa_emissão_certificado; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."vw_taxa_emissão_certificado" AS
 SELECT e.nome_evento,
    round((((count(
        CASE
            WHEN ((c.status_certificado)::text = 'Liberado'::text) THEN 1
            ELSE NULL::integer
        END))::numeric * 100.0) / (count(i.id_inscrito))::numeric), 2) AS percentual_certificados_emitidos
   FROM ((public.tab_evento e
     JOIN public.tab_inscrito i ON ((e.id_evento = i.id_evento)))
     LEFT JOIN public.tab_certificado c ON ((i.id_inscrito = c.id_inscrito)))
  GROUP BY e.nome_evento;


ALTER VIEW public."vw_taxa_emissão_certificado" OWNER TO postgres;

--
-- Name: vw_tempo_medio_inscricao_evento; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_tempo_medio_inscricao_evento AS
 SELECT e.tipo,
    round(avg((e.data_inicio - i.data_inscricao))) AS media_dias_antecedencia
   FROM (public.tab_inscrito i
     JOIN public.tab_evento e ON ((i.id_evento = e.id_evento)))
  WHERE ((i.status)::text = 'Confirmada'::text)
  GROUP BY e.tipo;


ALTER VIEW public.vw_tempo_medio_inscricao_evento OWNER TO postgres;

--
-- Name: tab_atividade id_atividade; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_atividade ALTER COLUMN id_atividade SET DEFAULT nextval('public.tab_atividade_id_atividade_seq'::regclass);


--
-- Name: tab_autores id_autor; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_autores ALTER COLUMN id_autor SET DEFAULT nextval('public.tab_autores_id_autor_seq'::regclass);


--
-- Name: tab_certificado id_certificado; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_certificado ALTER COLUMN id_certificado SET DEFAULT nextval('public.tab_certificado_id_certificado_seq'::regclass);


--
-- Name: tab_evento id_evento; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_evento ALTER COLUMN id_evento SET DEFAULT nextval('public.tab_evento_id_evento_seq'::regclass);


--
-- Name: tab_funcao id_funcao; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_funcao ALTER COLUMN id_funcao SET DEFAULT nextval('public.tab_funcao_id_funcao_seq'::regclass);


--
-- Name: tab_inscrito id_inscrito; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_inscrito ALTER COLUMN id_inscrito SET DEFAULT nextval('public.tab_inscrito_id_inscrito_seq'::regclass);


--
-- Name: tab_local id_local; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_local ALTER COLUMN id_local SET DEFAULT nextval('public.tab_local_id_local_seq'::regclass);


--
-- Name: tab_pagamento id_pagamento; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_pagamento ALTER COLUMN id_pagamento SET DEFAULT nextval('public.tab_pagamento_id_pagamento_seq'::regclass);


--
-- Name: tab_pessoa id_pessoa; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_pessoa ALTER COLUMN id_pessoa SET DEFAULT nextval('public.tab_pessoa_id_pessoa_seq'::regclass);


--
-- Name: tab_tipo_inscrito id_tipo; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_tipo_inscrito ALTER COLUMN id_tipo SET DEFAULT nextval('public.tab_tipo_pessoa_id_tipo_seq'::regclass);


--
-- Data for Name: tab_atividade; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tab_atividade (id_atividade, nome_atividade, tipo, status_atividade, area, resumo, id_evento, id_inscrito) FROM stdin;
26701	Atividade 1	Mesa	Em andamento	Tecnologia	Resumo da atividade 1	1	1895
26702	Atividade 2	Roda de Conversa	Em andamento	Tecnologia	Resumo da atividade 2	9	1898
26703	Atividade 3	Artigo	Em andamento	Tecnologia	Resumo da atividade 3	2	1901
26704	Atividade 4	Artigo	Concluída	Tecnologia	Resumo da atividade 4	1	1903
26705	Atividade 5	Mesa	Em andamento	Tecnologia	Resumo da atividade 5	4	1904
26706	Atividade 6	Mesa	Concluída	Tecnologia	Resumo da atividade 6	1	1906
26707	Atividade 7	Mesa	Concluída	Tecnologia	Resumo da atividade 7	3	1909
26708	Atividade 8	Artigo	Concluída	Tecnologia	Resumo da atividade 8	9	1916
26709	Atividade 9	Mesa	Em andamento	Tecnologia	Resumo da atividade 9	4	1918
26710	Atividade 10	Artigo	Concluída	Tecnologia	Resumo da atividade 10	8	1920
26711	Atividade 11	Palestra	Concluída	Tecnologia	Resumo da atividade 11	2	1921
26712	Atividade 12	Roda de Conversa	Concluída	Tecnologia	Resumo da atividade 12	6	1922
26713	Atividade 13	Mesa	Em andamento	Tecnologia	Resumo da atividade 13	1	1924
26714	Atividade 14	Mesa	Em andamento	Tecnologia	Resumo da atividade 14	1	1925
26715	Atividade 15	Roda de Conversa	Concluída	Tecnologia	Resumo da atividade 15	3	1927
26716	Atividade 16	Palestra	Concluída	Tecnologia	Resumo da atividade 16	4	1929
26717	Atividade 17	Palestra	Concluída	Tecnologia	Resumo da atividade 17	4	1937
26718	Atividade 18	Palestra	Em andamento	Tecnologia	Resumo da atividade 18	8	1938
26719	Atividade 19	Mesa	Concluída	Tecnologia	Resumo da atividade 19	4	1939
26720	Atividade 20	Artigo	Em andamento	Tecnologia	Resumo da atividade 20	1	1940
26721	Atividade 21	Artigo	Em andamento	Tecnologia	Resumo da atividade 21	4	1942
26722	Atividade 22	Mesa	Concluída	Tecnologia	Resumo da atividade 22	8	1944
26723	Atividade 23	Artigo	Concluída	Tecnologia	Resumo da atividade 23	10	1945
26724	Atividade 24	Mesa	Concluída	Tecnologia	Resumo da atividade 24	8	1946
26725	Atividade 25	Roda de Conversa	Em andamento	Tecnologia	Resumo da atividade 25	5	1947
26726	Atividade 26	Mesa	Em andamento	Tecnologia	Resumo da atividade 26	10	1949
26727	Atividade 27	Palestra	Em andamento	Tecnologia	Resumo da atividade 27	1	1950
26728	Atividade 28	Mesa	Concluída	Tecnologia	Resumo da atividade 28	8	1952
26729	Atividade 29	Artigo	Em andamento	Tecnologia	Resumo da atividade 29	7	1955
26730	Atividade 30	Palestra	Em andamento	Tecnologia	Resumo da atividade 30	3	1956
26731	Atividade 31	Mesa	Concluída	Tecnologia	Resumo da atividade 31	7	1959
26732	Atividade 32	Mesa	Concluída	Tecnologia	Resumo da atividade 32	4	1962
26733	Atividade 33	Mesa	Concluída	Tecnologia	Resumo da atividade 33	1	1963
26734	Atividade 34	Palestra	Em andamento	Tecnologia	Resumo da atividade 34	6	1966
26735	Atividade 35	Mesa	Concluída	Tecnologia	Resumo da atividade 35	4	1968
26736	Atividade 36	Palestra	Em andamento	Tecnologia	Resumo da atividade 36	6	1972
26737	Atividade 37	Palestra	Em andamento	Tecnologia	Resumo da atividade 37	9	1973
26738	Atividade 38	Artigo	Concluída	Tecnologia	Resumo da atividade 38	9	1974
26739	Atividade 39	Palestra	Em andamento	Tecnologia	Resumo da atividade 39	3	1975
26740	Atividade 40	Artigo	Concluída	Tecnologia	Resumo da atividade 40	5	1977
26741	Atividade 41	Roda de Conversa	Concluída	Tecnologia	Resumo da atividade 41	1	1980
26742	Atividade 42	Roda de Conversa	Em andamento	Tecnologia	Resumo da atividade 42	10	1982
26743	Atividade 43	Mesa	Em andamento	Tecnologia	Resumo da atividade 43	2	1983
26744	Atividade 44	Artigo	Concluída	Tecnologia	Resumo da atividade 44	4	1984
26745	Atividade 45	Roda de Conversa	Em andamento	Tecnologia	Resumo da atividade 45	7	1985
26746	Atividade 46	Palestra	Em andamento	Tecnologia	Resumo da atividade 46	5	1986
26747	Atividade 47	Artigo	Concluída	Tecnologia	Resumo da atividade 47	9	1989
26748	Atividade 48	Mesa	Em andamento	Tecnologia	Resumo da atividade 48	6	1990
26749	Atividade 49	Palestra	Concluída	Tecnologia	Resumo da atividade 49	9	1991
26750	Atividade 50	Mesa	Concluída	Tecnologia	Resumo da atividade 50	1	1992
26751	Atividade 51	Roda de Conversa	Concluída	Tecnologia	Resumo da atividade 51	3	1993
26752	Atividade 52	Artigo	Em andamento	Tecnologia	Resumo da atividade 52	6	1997
26753	Atividade 53	Palestra	Em andamento	Tecnologia	Resumo da atividade 53	5	2000
26754	Atividade 54	Artigo	Em andamento	Tecnologia	Resumo da atividade 54	3	2002
26755	Atividade 55	Roda de Conversa	Em andamento	Tecnologia	Resumo da atividade 55	10	2003
26756	Atividade 56	Mesa	Concluída	Tecnologia	Resumo da atividade 56	6	2007
26757	Atividade 57	Artigo	Concluída	Tecnologia	Resumo da atividade 57	3	2010
26758	Atividade 58	Artigo	Em andamento	Tecnologia	Resumo da atividade 58	10	2012
26759	Atividade 59	Mesa	Em andamento	Tecnologia	Resumo da atividade 59	10	2013
26760	Atividade 60	Palestra	Concluída	Tecnologia	Resumo da atividade 60	1	2015
26761	Atividade 61	Roda de Conversa	Concluída	Tecnologia	Resumo da atividade 61	8	2017
26762	Atividade 62	Artigo	Concluída	Tecnologia	Resumo da atividade 62	9	2019
26763	Atividade 63	Palestra	Em andamento	Tecnologia	Resumo da atividade 63	1	2022
26764	Atividade 64	Artigo	Concluída	Tecnologia	Resumo da atividade 64	4	2023
26765	Atividade 65	Palestra	Em andamento	Tecnologia	Resumo da atividade 65	2	2025
26766	Atividade 66	Artigo	Concluída	Tecnologia	Resumo da atividade 66	2	2028
26767	Atividade 67	Roda de Conversa	Em andamento	Tecnologia	Resumo da atividade 67	9	2029
26768	Atividade 68	Artigo	Concluída	Tecnologia	Resumo da atividade 68	1	2032
26769	Atividade 69	Palestra	Concluída	Tecnologia	Resumo da atividade 69	7	2039
26770	Atividade 70	Palestra	Concluída	Tecnologia	Resumo da atividade 70	3	2040
26771	Atividade 71	Artigo	Concluída	Tecnologia	Resumo da atividade 71	8	2047
26772	Atividade 72	Palestra	Em andamento	Tecnologia	Resumo da atividade 72	5	2048
26773	Atividade 73	Mesa	Em andamento	Tecnologia	Resumo da atividade 73	10	2051
26774	Atividade 74	Artigo	Em andamento	Tecnologia	Resumo da atividade 74	8	2053
26775	Atividade 75	Roda de Conversa	Em andamento	Tecnologia	Resumo da atividade 75	4	2057
26776	Atividade 76	Mesa	Concluída	Tecnologia	Resumo da atividade 76	1	2059
26777	Atividade 77	Roda de Conversa	Em andamento	Tecnologia	Resumo da atividade 77	6	2064
26778	Atividade 78	Artigo	Em andamento	Tecnologia	Resumo da atividade 78	10	2065
26779	Atividade 79	Mesa	Em andamento	Tecnologia	Resumo da atividade 79	2	2066
26780	Atividade 80	Artigo	Em andamento	Tecnologia	Resumo da atividade 80	10	2069
26781	Atividade 81	Mesa	Em andamento	Tecnologia	Resumo da atividade 81	6	2071
26782	Atividade 82	Roda de Conversa	Concluída	Tecnologia	Resumo da atividade 82	7	2072
26783	Atividade 83	Artigo	Em andamento	Tecnologia	Resumo da atividade 83	5	2074
26784	Atividade 84	Mesa	Em andamento	Tecnologia	Resumo da atividade 84	9	2081
26785	Atividade 85	Mesa	Concluída	Tecnologia	Resumo da atividade 85	3	2082
26786	Atividade 86	Mesa	Em andamento	Tecnologia	Resumo da atividade 86	6	2085
26787	Atividade 87	Mesa	Concluída	Tecnologia	Resumo da atividade 87	8	2086
26788	Atividade 88	Palestra	Concluída	Tecnologia	Resumo da atividade 88	8	2092
26789	Atividade 89	Artigo	Em andamento	Tecnologia	Resumo da atividade 89	8	2093
26790	Atividade 90	Artigo	Concluída	Tecnologia	Resumo da atividade 90	7	2094
26791	Atividade 91	Artigo	Em andamento	Tecnologia	Resumo da atividade 91	3	2096
26792	Atividade 92	Palestra	Em andamento	Tecnologia	Resumo da atividade 92	1	2097
26793	Atividade 93	Palestra	Concluída	Tecnologia	Resumo da atividade 93	10	2099
26794	Atividade 94	Mesa	Concluída	Tecnologia	Resumo da atividade 94	8	2100
26795	Atividade 95	Palestra	Em andamento	Tecnologia	Resumo da atividade 95	10	2101
26796	Atividade 96	Mesa	Em andamento	Tecnologia	Resumo da atividade 96	9	2103
26797	Atividade 97	Palestra	Em andamento	Tecnologia	Resumo da atividade 97	1	2104
26798	Atividade 98	Artigo	Concluída	Tecnologia	Resumo da atividade 98	1	2105
26799	Atividade 99	Mesa	Concluída	Tecnologia	Resumo da atividade 99	9	2108
26800	Atividade 100	Palestra	Em andamento	Tecnologia	Resumo da atividade 100	7	2109
26801	Atividade 101	Intervenção Artística	Concluída	Tecnologia	Resumo da atividade 101	8	2116
26802	Atividade 102	Mesa	Concluída	Tecnologia	Resumo da atividade 102	9	2118
26803	Atividade 103	Roda de Conversa	Em andamento	Tecnologia	Resumo da atividade 103	8	2121
26804	Atividade 104	Palestra	Em andamento	Tecnologia	Resumo da atividade 104	7	2123
26805	Atividade 105	Artigo	Concluída	Tecnologia	Resumo da atividade 105	3	2127
26806	Atividade 106	Roda de Conversa	Em andamento	Tecnologia	Resumo da atividade 106	9	2128
26807	Atividade 107	Artigo	Concluída	Tecnologia	Resumo da atividade 107	6	2129
26808	Atividade 108	Mesa	Concluída	Tecnologia	Resumo da atividade 108	9	2130
26809	Atividade 109	Artigo	Concluída	Tecnologia	Resumo da atividade 109	2	2132
26810	Atividade 110	Mesa	Em andamento	Tecnologia	Resumo da atividade 110	3	2135
26811	Atividade 111	Mesa	Concluída	Tecnologia	Resumo da atividade 111	8	2136
26812	Atividade 112	Artigo	Concluída	Tecnologia	Resumo da atividade 112	6	2137
26813	Atividade 113	Artigo	Em andamento	Tecnologia	Resumo da atividade 113	5	2138
26814	Atividade 114	Mesa	Concluída	Tecnologia	Resumo da atividade 114	3	2143
26815	Atividade 115	Palestra	Concluída	Tecnologia	Resumo da atividade 115	2	2146
26816	Atividade 116	Mesa	Em andamento	Tecnologia	Resumo da atividade 116	3	2148
26817	Atividade 117	Mesa	Concluída	Tecnologia	Resumo da atividade 117	7	2150
26818	Atividade 118	Artigo	Concluída	Tecnologia	Resumo da atividade 118	9	2151
26819	Atividade 119	Artigo	Em andamento	Tecnologia	Resumo da atividade 119	3	2153
26820	Atividade 120	Mesa	Concluída	Tecnologia	Resumo da atividade 120	8	2154
26821	Atividade 121	Roda de Conversa	Concluída	Tecnologia	Resumo da atividade 121	3	2155
26822	Atividade 122	Roda de Conversa	Em andamento	Tecnologia	Resumo da atividade 122	6	2160
26823	Atividade 123	Roda de Conversa	Concluída	Tecnologia	Resumo da atividade 123	7	2163
26824	Atividade 124	Palestra	Em andamento	Tecnologia	Resumo da atividade 124	9	2165
26825	Atividade 125	Roda de Conversa	Em andamento	Tecnologia	Resumo da atividade 125	4	2166
26826	Atividade 126	Artigo	Em andamento	Tecnologia	Resumo da atividade 126	3	2168
26827	Atividade 127	Palestra	Em andamento	Tecnologia	Resumo da atividade 127	10	2169
26828	Atividade 128	Palestra	Concluída	Tecnologia	Resumo da atividade 128	4	2173
26829	Atividade 129	Roda de Conversa	Em andamento	Tecnologia	Resumo da atividade 129	6	2175
26830	Atividade 130	Artigo	Concluída	Tecnologia	Resumo da atividade 130	8	2176
26831	Atividade 131	Roda de Conversa	Concluída	Tecnologia	Resumo da atividade 131	2	2177
26832	Atividade 132	Roda de Conversa	Concluída	Tecnologia	Resumo da atividade 132	2	2180
26833	Atividade 133	Artigo	Concluída	Tecnologia	Resumo da atividade 133	5	2181
26834	Atividade 134	Palestra	Em andamento	Tecnologia	Resumo da atividade 134	8	2185
26835	Atividade 135	Mesa	Em andamento	Tecnologia	Resumo da atividade 135	9	2186
26836	Atividade 136	Mesa	Concluída	Tecnologia	Resumo da atividade 136	5	2189
26837	Atividade 137	Artigo	Concluída	Tecnologia	Resumo da atividade 137	7	2190
26838	Atividade 138	Palestra	Em andamento	Tecnologia	Resumo da atividade 138	5	2195
26839	Atividade 139	Roda de Conversa	Em andamento	Tecnologia	Resumo da atividade 139	10	2196
26840	Atividade 140	Palestra	Concluída	Tecnologia	Resumo da atividade 140	4	2199
26841	Atividade 141	Mesa	Concluída	Tecnologia	Resumo da atividade 141	9	2200
26842	Atividade 142	Artigo	Em andamento	Tecnologia	Resumo da atividade 142	2	2202
26843	Atividade 143	Intervenção Artística	Em andamento	Tecnologia	Resumo da atividade 143	5	2204
26844	Atividade 144	Artigo	Concluída	Tecnologia	Resumo da atividade 144	5	2207
26845	Atividade 145	Artigo	Em andamento	Tecnologia	Resumo da atividade 145	3	2209
26846	Atividade 146	Palestra	Concluída	Tecnologia	Resumo da atividade 146	5	2211
26847	Atividade 147	Artigo	Concluída	Tecnologia	Resumo da atividade 147	4	2212
26848	Atividade 148	Mesa	Em andamento	Tecnologia	Resumo da atividade 148	1	2214
26849	Atividade 149	Mesa	Concluída	Tecnologia	Resumo da atividade 149	10	2217
26850	Atividade 150	Artigo	Em andamento	Tecnologia	Resumo da atividade 150	7	2224
26851	Atividade 151	Palestra	Em andamento	Tecnologia	Resumo da atividade 151	7	2228
26852	Atividade 152	Mesa	Em andamento	Tecnologia	Resumo da atividade 152	7	2231
26853	Atividade 153	Intervenção Artística	Em andamento	Tecnologia	Resumo da atividade 153	7	2232
26854	Atividade 154	Roda de Conversa	Concluída	Tecnologia	Resumo da atividade 154	8	2236
26855	Atividade 155	Roda de Conversa	Concluída	Tecnologia	Resumo da atividade 155	3	2240
26856	Atividade 156	Artigo	Concluída	Tecnologia	Resumo da atividade 156	7	2241
26857	Atividade 157	Palestra	Em andamento	Tecnologia	Resumo da atividade 157	5	2242
26858	Atividade 158	Mesa	Concluída	Tecnologia	Resumo da atividade 158	2	2245
26859	Atividade 159	Artigo	Em andamento	Tecnologia	Resumo da atividade 159	4	2247
26860	Atividade 160	Palestra	Em andamento	Tecnologia	Resumo da atividade 160	4	2248
26861	Atividade 161	Roda de Conversa	Em andamento	Tecnologia	Resumo da atividade 161	8	2250
26862	Atividade 162	Mesa	Concluída	Tecnologia	Resumo da atividade 162	7	2251
26863	Atividade 163	Palestra	Concluída	Tecnologia	Resumo da atividade 163	5	2258
26864	Atividade 164	Palestra	Concluída	Tecnologia	Resumo da atividade 164	7	2266
26865	Atividade 165	Roda de Conversa	Em andamento	Tecnologia	Resumo da atividade 165	7	2267
26866	Atividade 166	Palestra	Em andamento	Tecnologia	Resumo da atividade 166	2	2270
26867	Atividade 167	Mesa	Concluída	Tecnologia	Resumo da atividade 167	6	2271
26868	Atividade 168	Artigo	Em andamento	Tecnologia	Resumo da atividade 168	9	2278
26869	Atividade 169	Artigo	Em andamento	Tecnologia	Resumo da atividade 169	6	2287
26870	Atividade 170	Artigo	Concluída	Tecnologia	Resumo da atividade 170	4	2288
26871	Atividade 171	Mesa	Concluída	Tecnologia	Resumo da atividade 171	4	2295
26872	Atividade 172	Intervenção Artística	Em andamento	Tecnologia	Resumo da atividade 172	1	2297
26873	Atividade 173	Artigo	Concluída	Tecnologia	Resumo da atividade 173	2	2298
26874	Atividade 174	Artigo	Em andamento	Tecnologia	Resumo da atividade 174	10	2299
26875	Atividade 175	Roda de Conversa	Em andamento	Tecnologia	Resumo da atividade 175	2	2300
26876	Atividade 176	Roda de Conversa	Concluída	Tecnologia	Resumo da atividade 176	8	2302
26877	Atividade 177	Mesa	Concluída	Tecnologia	Resumo da atividade 177	5	2303
26878	Atividade 178	Artigo	Em andamento	Tecnologia	Resumo da atividade 178	3	2304
26879	Atividade 179	Intervenção Artística	Concluída	Tecnologia	Resumo da atividade 179	10	2306
26880	Atividade 180	Artigo	Concluída	Tecnologia	Resumo da atividade 180	9	2307
26881	Atividade 181	Artigo	Concluída	Tecnologia	Resumo da atividade 181	4	2308
26882	Atividade 182	Roda de Conversa	Concluída	Tecnologia	Resumo da atividade 182	10	2311
26883	Atividade 183	Mesa	Concluída	Tecnologia	Resumo da atividade 183	6	2315
26884	Atividade 184	Artigo	Concluída	Tecnologia	Resumo da atividade 184	4	2317
26885	Atividade 185	Mesa	Concluída	Tecnologia	Resumo da atividade 185	4	2321
26886	Atividade 186	Artigo	Concluída	Tecnologia	Resumo da atividade 186	5	2323
26887	Atividade 187	Palestra	Concluída	Tecnologia	Resumo da atividade 187	1	2324
26888	Atividade 188	Palestra	Concluída	Tecnologia	Resumo da atividade 188	8	2325
26889	Atividade 189	Mesa	Concluída	Tecnologia	Resumo da atividade 189	1	2328
26890	Atividade 190	Mesa	Concluída	Tecnologia	Resumo da atividade 190	3	2330
26891	Atividade 191	Mesa	Concluída	Tecnologia	Resumo da atividade 191	2	2331
26892	Atividade 192	Palestra	Em andamento	Tecnologia	Resumo da atividade 192	4	2334
26893	Atividade 193	Artigo	Em andamento	Tecnologia	Resumo da atividade 193	10	2335
26894	Atividade 194	Roda de Conversa	Em andamento	Tecnologia	Resumo da atividade 194	10	2338
26895	Atividade 195	Artigo	Concluída	Tecnologia	Resumo da atividade 195	7	2339
26896	Atividade 196	Artigo	Em andamento	Tecnologia	Resumo da atividade 196	4	2341
26897	Atividade 197	Artigo	Concluída	Tecnologia	Resumo da atividade 197	10	2343
26898	Atividade 198	Roda de Conversa	Concluída	Tecnologia	Resumo da atividade 198	2	2345
26899	Atividade 199	Mesa	Concluída	Tecnologia	Resumo da atividade 199	5	2349
26900	Atividade 200	Artigo	Concluída	Tecnologia	Resumo da atividade 200	8	2350
\.


--
-- Data for Name: tab_atividade_autor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tab_atividade_autor (id_autor, id_atividade) FROM stdin;
\.


--
-- Data for Name: tab_atividade_funcao_pessoa; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tab_atividade_funcao_pessoa (id_funcao, id_pessoa, id_atividade) FROM stdin;
\.


--
-- Data for Name: tab_autores; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tab_autores (id_autor, id_pessoa) FROM stdin;
1	268
2	286
3	211
4	250
5	226
6	298
7	260
8	253
9	290
10	202
11	220
12	230
13	266
14	257
15	272
16	221
17	241
18	200
19	273
20	243
21	231
22	259
23	274
24	275
25	279
26	218
27	219
28	297
29	248
30	267
31	262
32	210
33	276
34	291
35	222
36	245
37	217
38	215
39	255
40	265
41	246
42	239
43	280
44	281
45	227
46	201
47	295
48	208
49	261
50	282
51	225
52	285
53	209
54	205
55	223
56	240
57	252
58	269
59	288
60	242
61	258
62	214
63	207
64	292
65	249
66	236
67	256
68	206
69	204
70	203
71	263
72	232
73	235
74	234
75	213
76	238
77	224
78	293
79	277
80	289
81	296
82	233
83	216
84	271
85	251
86	237
87	254
88	284
89	283
90	228
91	270
92	264
93	278
94	294
95	212
96	287
97	247
98	229
99	244
\.


--
-- Data for Name: tab_certificado; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tab_certificado (id_certificado, tipo_certificado, horas, status_certificado, data_emissao, id_evento, id_atividade, id_inscrito) FROM stdin;
2495	Ouvinte	15	Bloqueado	\N	10	\N	1894
2496	Ouvinte	15	Liberado	2024-12-06	1	\N	1895
2497	Ouvinte	11	Bloqueado	\N	3	\N	1896
2498	Ouvinte	11	Bloqueado	\N	9	\N	1897
2499	Ouvinte	12	Bloqueado	\N	9	\N	1898
2500	Ouvinte	13	Bloqueado	\N	4	\N	1899
2501	Ouvinte	13	Bloqueado	\N	1	\N	1900
2502	Ouvinte	10	Liberado	2024-12-07	2	\N	1901
2503	Ouvinte	11	Bloqueado	\N	8	\N	1902
2504	Ouvinte	14	Liberado	2024-12-16	1	\N	1903
2505	Ouvinte	13	Bloqueado	\N	4	\N	1904
2506	Ouvinte	11	Bloqueado	\N	8	\N	1905
2507	Ouvinte	14	Bloqueado	\N	1	\N	1906
2508	Ouvinte	14	Bloqueado	\N	6	\N	1907
2509	Ouvinte	15	Liberado	2024-12-09	6	\N	1908
2510	Ouvinte	14	Bloqueado	\N	3	\N	1909
2511	Ouvinte	11	Bloqueado	\N	6	\N	1910
2512	Ouvinte	14	Bloqueado	\N	9	\N	1911
2513	Ouvinte	13	Liberado	2024-12-16	5	\N	1912
2514	Ouvinte	14	Bloqueado	\N	2	\N	1913
2515	Ouvinte	15	Liberado	2024-12-12	1	\N	1914
2516	Ouvinte	14	Liberado	2024-12-10	7	\N	1915
2517	Ouvinte	13	Bloqueado	\N	9	\N	1916
2518	Ouvinte	15	Bloqueado	\N	10	\N	1917
2519	Ouvinte	11	Bloqueado	\N	4	\N	1918
2520	Ouvinte	15	Liberado	2024-12-27	2	\N	1919
2521	Ouvinte	12	Liberado	2024-12-11	8	\N	1920
2522	Ouvinte	11	Liberado	2024-12-11	2	\N	1921
2523	Ouvinte	11	Bloqueado	\N	6	\N	1922
2524	Ouvinte	12	Bloqueado	\N	1	\N	1923
2525	Ouvinte	15	Bloqueado	\N	1	\N	1924
2526	Ouvinte	13	Liberado	2024-12-30	1	\N	1925
2527	Ouvinte	14	Bloqueado	\N	10	\N	1926
2528	Ouvinte	10	Bloqueado	\N	3	\N	1927
2529	Ouvinte	11	Bloqueado	\N	6	\N	1928
2530	Ouvinte	13	Bloqueado	\N	4	\N	1929
2531	Ouvinte	13	Bloqueado	\N	9	\N	1930
2532	Ouvinte	11	Bloqueado	\N	7	\N	1931
2533	Ouvinte	12	Liberado	2024-12-19	2	\N	1932
2534	Ouvinte	13	Liberado	2024-12-27	2	\N	1933
2535	Ouvinte	10	Liberado	2024-12-14	6	\N	1934
2536	Ouvinte	12	Bloqueado	\N	2	\N	1935
2537	Ouvinte	15	Bloqueado	\N	6	\N	1936
2538	Ouvinte	13	Bloqueado	\N	4	\N	1937
2539	Ouvinte	15	Liberado	2024-12-02	8	\N	1938
2540	Ouvinte	15	Bloqueado	\N	4	\N	1939
2541	Ouvinte	13	Bloqueado	\N	1	\N	1940
2542	Ouvinte	15	Liberado	2024-12-17	5	\N	1941
2543	Ouvinte	12	Bloqueado	\N	4	\N	1942
2544	Ouvinte	15	Bloqueado	\N	6	\N	1943
2545	Ouvinte	15	Bloqueado	\N	8	\N	1944
2546	Ouvinte	12	Bloqueado	\N	10	\N	1945
2547	Ouvinte	14	Liberado	2024-12-04	8	\N	1946
2548	Ouvinte	13	Liberado	2024-12-06	5	\N	1947
2549	Ouvinte	10	Bloqueado	\N	3	\N	1948
2550	Ouvinte	14	Bloqueado	\N	10	\N	1949
2551	Ouvinte	14	Liberado	2024-12-25	1	\N	1950
2552	Ouvinte	12	Liberado	2024-12-24	7	\N	1951
2553	Ouvinte	11	Bloqueado	\N	8	\N	1952
2554	Ouvinte	10	Liberado	2024-12-30	3	\N	1953
2555	Ouvinte	15	Bloqueado	\N	7	\N	1954
2556	Ouvinte	12	Bloqueado	\N	7	\N	1955
2557	Ouvinte	13	Bloqueado	\N	3	\N	1956
2558	Ouvinte	15	Bloqueado	\N	5	\N	1957
2559	Ouvinte	10	Bloqueado	\N	8	\N	1958
2560	Ouvinte	14	Bloqueado	\N	7	\N	1959
2561	Ouvinte	13	Liberado	2024-12-17	1	\N	1960
2562	Ouvinte	13	Bloqueado	\N	4	\N	1961
2563	Ouvinte	10	Bloqueado	\N	4	\N	1962
2564	Ouvinte	14	Bloqueado	\N	1	\N	1963
2565	Ouvinte	15	Bloqueado	\N	7	\N	1964
2566	Ouvinte	10	Bloqueado	\N	9	\N	1965
2567	Ouvinte	11	Bloqueado	\N	6	\N	1966
2568	Ouvinte	14	Bloqueado	\N	5	\N	1967
2569	Ouvinte	13	Liberado	2024-12-17	4	\N	1968
2570	Ouvinte	13	Liberado	2024-12-10	7	\N	1969
2571	Ouvinte	12	Liberado	2024-12-16	7	\N	1970
2572	Ouvinte	13	Bloqueado	\N	10	\N	1971
2573	Ouvinte	13	Liberado	2024-12-12	6	\N	1972
2574	Ouvinte	15	Bloqueado	\N	9	\N	1973
2575	Ouvinte	15	Bloqueado	\N	9	\N	1974
2576	Ouvinte	10	Bloqueado	\N	3	\N	1975
2577	Ouvinte	13	Bloqueado	\N	3	\N	1976
2578	Ouvinte	14	Bloqueado	\N	5	\N	1977
2579	Ouvinte	12	Bloqueado	\N	3	\N	1978
2580	Ouvinte	12	Bloqueado	\N	6	\N	1979
2581	Ouvinte	14	Liberado	2024-12-30	1	\N	1980
2582	Ouvinte	14	Bloqueado	\N	3	\N	1981
2583	Ouvinte	13	Liberado	2024-12-14	10	\N	1982
2584	Ouvinte	10	Liberado	2024-12-30	2	\N	1983
2585	Ouvinte	11	Liberado	2024-12-28	4	\N	1984
2586	Ouvinte	13	Bloqueado	\N	7	\N	1985
2587	Ouvinte	10	Bloqueado	\N	5	\N	1986
2588	Ouvinte	13	Liberado	2024-12-16	6	\N	1987
2589	Ouvinte	15	Liberado	2024-12-14	7	\N	1988
2590	Ouvinte	15	Liberado	2024-12-15	9	\N	1989
2591	Ouvinte	13	Bloqueado	\N	6	\N	1990
2592	Ouvinte	14	Liberado	2024-12-17	9	\N	1991
2593	Ouvinte	10	Bloqueado	\N	1	\N	1992
2594	Ouvinte	12	Liberado	2024-12-13	3	\N	1993
2595	Ouvinte	13	Bloqueado	\N	2	\N	1994
2596	Ouvinte	13	Bloqueado	\N	7	\N	1995
2597	Ouvinte	13	Bloqueado	\N	2	\N	1996
2598	Ouvinte	11	Liberado	2024-12-27	6	\N	1997
2599	Ouvinte	13	Liberado	2024-12-07	1	\N	1998
2600	Ouvinte	15	Bloqueado	\N	5	\N	1999
2601	Ouvinte	13	Bloqueado	\N	5	\N	2000
2602	Ouvinte	14	Bloqueado	\N	5	\N	2001
2603	Ouvinte	10	Liberado	2024-12-23	3	\N	2002
2604	Ouvinte	13	Bloqueado	\N	10	\N	2003
2605	Ouvinte	14	Bloqueado	\N	5	\N	2004
2606	Ouvinte	13	Bloqueado	\N	4	\N	2005
2607	Ouvinte	12	Bloqueado	\N	3	\N	2006
2608	Ouvinte	12	Bloqueado	\N	6	\N	2007
2609	Ouvinte	13	Bloqueado	\N	6	\N	2008
2610	Ouvinte	15	Bloqueado	\N	10	\N	2009
2611	Ouvinte	11	Bloqueado	\N	3	\N	2010
2612	Ouvinte	11	Bloqueado	\N	2	\N	2011
2613	Ouvinte	10	Bloqueado	\N	10	\N	2012
2614	Ouvinte	14	Bloqueado	\N	10	\N	2013
2615	Ouvinte	15	Liberado	2024-12-10	4	\N	2014
2616	Ouvinte	15	Liberado	2024-12-18	1	\N	2015
2617	Ouvinte	11	Bloqueado	\N	6	\N	2016
2618	Ouvinte	14	Liberado	2024-12-18	8	\N	2017
2619	Ouvinte	12	Bloqueado	\N	2	\N	2018
2620	Ouvinte	12	Bloqueado	\N	9	\N	2019
2621	Ouvinte	10	Bloqueado	\N	6	\N	2020
2622	Ouvinte	15	Liberado	2024-12-12	6	\N	2021
2623	Ouvinte	12	Bloqueado	\N	1	\N	2022
2624	Ouvinte	10	Bloqueado	\N	4	\N	2023
2625	Ouvinte	15	Bloqueado	\N	6	\N	2024
2626	Ouvinte	10	Bloqueado	\N	2	\N	2025
2627	Ouvinte	13	Bloqueado	\N	4	\N	2026
2628	Ouvinte	15	Bloqueado	\N	1	\N	2027
2629	Ouvinte	15	Bloqueado	\N	2	\N	2028
2630	Ouvinte	11	Bloqueado	\N	9	\N	2029
2631	Ouvinte	14	Bloqueado	\N	2	\N	2030
2632	Ouvinte	13	Bloqueado	\N	6	\N	2031
2633	Ouvinte	14	Liberado	2024-12-12	1	\N	2032
2634	Ouvinte	15	Liberado	2024-12-22	5	\N	2033
2635	Ouvinte	14	Liberado	2024-12-28	8	\N	2034
2636	Ouvinte	12	Bloqueado	\N	4	\N	2035
2637	Ouvinte	10	Bloqueado	\N	4	\N	2036
2638	Ouvinte	14	Liberado	2024-12-08	5	\N	2037
2639	Ouvinte	13	Bloqueado	\N	10	\N	2038
2640	Ouvinte	11	Bloqueado	\N	7	\N	2039
2641	Ouvinte	14	Liberado	2024-12-10	3	\N	2040
2642	Ouvinte	12	Bloqueado	\N	10	\N	2041
2643	Ouvinte	12	Bloqueado	\N	3	\N	2042
2644	Ouvinte	10	Bloqueado	\N	1	\N	2043
2645	Ouvinte	10	Liberado	2024-12-07	3	\N	2044
2646	Ouvinte	14	Bloqueado	\N	7	\N	2045
2647	Ouvinte	14	Bloqueado	\N	2	\N	2046
2648	Ouvinte	14	Liberado	2024-12-25	8	\N	2047
2649	Ouvinte	14	Bloqueado	\N	5	\N	2048
2650	Ouvinte	15	Liberado	2024-12-12	3	\N	2049
2651	Ouvinte	15	Bloqueado	\N	7	\N	2050
2652	Ouvinte	10	Bloqueado	\N	10	\N	2051
2653	Ouvinte	15	Bloqueado	\N	9	\N	2052
2654	Ouvinte	14	Liberado	2024-12-27	8	\N	2053
2655	Ouvinte	12	Bloqueado	\N	5	\N	2054
2656	Ouvinte	10	Bloqueado	\N	5	\N	2055
2657	Ouvinte	13	Bloqueado	\N	10	\N	2056
2658	Ouvinte	14	Liberado	2024-12-01	4	\N	2057
2659	Ouvinte	15	Liberado	2024-12-23	5	\N	2058
2660	Ouvinte	13	Bloqueado	\N	1	\N	2059
2661	Ouvinte	10	Bloqueado	\N	7	\N	2060
2662	Ouvinte	11	Bloqueado	\N	3	\N	2061
2663	Ouvinte	10	Bloqueado	\N	10	\N	2062
2664	Ouvinte	15	Bloqueado	\N	7	\N	2063
2665	Ouvinte	13	Bloqueado	\N	6	\N	2064
2666	Ouvinte	13	Bloqueado	\N	10	\N	2065
2667	Ouvinte	14	Bloqueado	\N	2	\N	2066
2668	Ouvinte	11	Liberado	2024-12-07	6	\N	2067
2669	Ouvinte	14	Liberado	2024-12-15	8	\N	2068
2670	Ouvinte	14	Liberado	2024-12-22	10	\N	2069
2671	Ouvinte	11	Bloqueado	\N	8	\N	2070
2672	Ouvinte	12	Bloqueado	\N	6	\N	2071
2673	Ouvinte	11	Liberado	2024-12-09	7	\N	2072
2674	Ouvinte	12	Liberado	2024-12-22	8	\N	2073
2675	Ouvinte	14	Liberado	2024-12-29	5	\N	2074
2676	Ouvinte	10	Bloqueado	\N	2	\N	2075
2677	Ouvinte	11	Bloqueado	\N	10	\N	2076
2678	Ouvinte	11	Bloqueado	\N	9	\N	2077
2679	Ouvinte	10	Liberado	2024-12-28	2	\N	2078
2680	Ouvinte	13	Bloqueado	\N	10	\N	2079
2681	Ouvinte	12	Bloqueado	\N	10	\N	2080
2682	Ouvinte	15	Bloqueado	\N	9	\N	2081
2683	Ouvinte	11	Liberado	2024-12-08	3	\N	2082
2684	Ouvinte	14	Bloqueado	\N	7	\N	2083
2685	Ouvinte	14	Bloqueado	\N	9	\N	2084
2686	Ouvinte	10	Bloqueado	\N	6	\N	2085
2687	Ouvinte	10	Bloqueado	\N	8	\N	2086
2688	Ouvinte	15	Liberado	2024-12-13	2	\N	2087
2689	Ouvinte	12	Bloqueado	\N	10	\N	2088
2690	Ouvinte	14	Bloqueado	\N	10	\N	2089
2691	Ouvinte	13	Bloqueado	\N	4	\N	2090
2692	Ouvinte	12	Liberado	2024-12-06	3	\N	2091
2693	Ouvinte	10	Bloqueado	\N	8	\N	2092
2694	Ouvinte	11	Liberado	2024-12-10	8	\N	2093
2695	Ouvinte	15	Liberado	2024-12-22	7	\N	2094
2696	Ouvinte	10	Liberado	2024-12-12	6	\N	2095
2697	Ouvinte	11	Liberado	2024-12-18	3	\N	2096
2698	Ouvinte	14	Bloqueado	\N	1	\N	2097
2699	Ouvinte	10	Bloqueado	\N	6	\N	2098
2700	Ouvinte	14	Liberado	2024-12-25	10	\N	2099
2701	Ouvinte	15	Bloqueado	\N	8	\N	2100
2702	Ouvinte	14	Bloqueado	\N	10	\N	2101
2703	Ouvinte	13	Bloqueado	\N	8	\N	2102
2704	Ouvinte	13	Liberado	2024-12-22	9	\N	2103
2705	Ouvinte	10	Liberado	2024-12-21	1	\N	2104
2706	Ouvinte	15	Bloqueado	\N	1	\N	2105
2707	Ouvinte	10	Bloqueado	\N	9	\N	2106
2708	Ouvinte	15	Bloqueado	\N	7	\N	2107
2709	Ouvinte	12	Liberado	2024-12-13	9	\N	2108
2710	Ouvinte	10	Bloqueado	\N	7	\N	2109
2711	Ouvinte	11	Liberado	2024-12-11	6	\N	2110
2712	Ouvinte	10	Bloqueado	\N	9	\N	2111
2713	Ouvinte	11	Bloqueado	\N	2	\N	2112
2714	Ouvinte	12	Liberado	2024-12-20	9	\N	2113
2715	Ouvinte	12	Bloqueado	\N	1	\N	2114
2716	Ouvinte	12	Bloqueado	\N	7	\N	2115
2717	Ouvinte	12	Liberado	2024-12-23	8	\N	2116
2718	Ouvinte	12	Bloqueado	\N	7	\N	2117
2719	Ouvinte	12	Bloqueado	\N	9	\N	2118
2720	Ouvinte	13	Bloqueado	\N	4	\N	2119
2721	Ouvinte	10	Bloqueado	\N	2	\N	2120
2722	Ouvinte	11	Bloqueado	\N	8	\N	2121
2723	Ouvinte	14	Bloqueado	\N	5	\N	2122
2724	Ouvinte	10	Bloqueado	\N	7	\N	2123
2725	Ouvinte	10	Liberado	2024-12-15	10	\N	2124
2726	Ouvinte	13	Bloqueado	\N	4	\N	2125
2727	Ouvinte	15	Liberado	2024-12-16	1	\N	2126
2728	Ouvinte	10	Liberado	2024-12-29	3	\N	2127
2729	Ouvinte	12	Liberado	2024-12-23	9	\N	2128
2730	Ouvinte	10	Liberado	2024-12-10	6	\N	2129
2731	Ouvinte	13	Bloqueado	\N	9	\N	2130
2732	Ouvinte	12	Bloqueado	\N	8	\N	2131
2733	Ouvinte	13	Liberado	2024-12-11	2	\N	2132
2734	Ouvinte	13	Liberado	2024-12-14	7	\N	2133
2735	Ouvinte	10	Bloqueado	\N	5	\N	2134
2736	Ouvinte	10	Liberado	2024-12-02	3	\N	2135
2737	Ouvinte	10	Liberado	2024-12-14	8	\N	2136
2738	Ouvinte	14	Liberado	2024-12-04	6	\N	2137
2739	Ouvinte	10	Bloqueado	\N	5	\N	2138
2740	Ouvinte	10	Liberado	2024-12-09	6	\N	2139
2741	Ouvinte	11	Bloqueado	\N	7	\N	2140
2742	Ouvinte	10	Liberado	2024-12-03	10	\N	2141
2743	Ouvinte	15	Bloqueado	\N	3	\N	2142
2744	Ouvinte	11	Liberado	2024-12-02	3	\N	2143
2745	Ouvinte	10	Bloqueado	\N	7	\N	2144
2746	Ouvinte	15	Bloqueado	\N	2	\N	2145
2747	Ouvinte	10	Liberado	2024-12-25	2	\N	2146
2748	Ouvinte	13	Bloqueado	\N	8	\N	2147
2749	Ouvinte	11	Bloqueado	\N	3	\N	2148
2750	Ouvinte	13	Liberado	2024-12-15	7	\N	2149
2751	Ouvinte	15	Bloqueado	\N	7	\N	2150
2752	Ouvinte	14	Bloqueado	\N	9	\N	2151
2753	Ouvinte	11	Liberado	2024-12-02	4	\N	2152
2754	Ouvinte	10	Liberado	2024-12-16	3	\N	2153
2755	Ouvinte	12	Liberado	2024-12-17	8	\N	2154
2756	Ouvinte	13	Bloqueado	\N	3	\N	2155
2757	Ouvinte	10	Bloqueado	\N	1	\N	2156
2758	Ouvinte	14	Bloqueado	\N	2	\N	2157
2759	Ouvinte	13	Liberado	2024-12-12	6	\N	2158
2760	Ouvinte	13	Bloqueado	\N	6	\N	2159
2761	Ouvinte	15	Bloqueado	\N	6	\N	2160
2762	Ouvinte	14	Bloqueado	\N	9	\N	2161
2763	Ouvinte	13	Bloqueado	\N	10	\N	2162
2764	Ouvinte	11	Bloqueado	\N	7	\N	2163
2765	Ouvinte	15	Liberado	2024-12-12	3	\N	2164
2766	Ouvinte	12	Bloqueado	\N	9	\N	2165
2767	Ouvinte	13	Bloqueado	\N	4	\N	2166
2768	Ouvinte	10	Bloqueado	\N	3	\N	2167
2769	Ouvinte	15	Bloqueado	\N	3	\N	2168
2770	Ouvinte	13	Bloqueado	\N	10	\N	2169
2771	Ouvinte	11	Liberado	2024-12-22	6	\N	2170
2772	Ouvinte	10	Bloqueado	\N	7	\N	2171
2773	Ouvinte	10	Bloqueado	\N	9	\N	2172
2774	Ouvinte	11	Bloqueado	\N	4	\N	2173
2775	Ouvinte	10	Bloqueado	\N	2	\N	2174
2776	Ouvinte	13	Liberado	2024-12-21	6	\N	2175
2777	Ouvinte	11	Liberado	2024-12-28	8	\N	2176
2778	Ouvinte	12	Bloqueado	\N	2	\N	2177
2779	Ouvinte	11	Bloqueado	\N	5	\N	2178
2780	Ouvinte	12	Liberado	2024-12-24	6	\N	2179
2781	Ouvinte	12	Liberado	2024-12-26	2	\N	2180
2782	Ouvinte	14	Bloqueado	\N	5	\N	2181
2783	Ouvinte	10	Bloqueado	\N	4	\N	2182
2784	Ouvinte	15	Bloqueado	\N	1	\N	2183
2785	Ouvinte	15	Bloqueado	\N	4	\N	2184
2786	Ouvinte	12	Bloqueado	\N	8	\N	2185
2787	Ouvinte	15	Bloqueado	\N	9	\N	2186
2788	Ouvinte	15	Bloqueado	\N	5	\N	2187
2789	Ouvinte	15	Bloqueado	\N	2	\N	2188
2790	Ouvinte	15	Liberado	2024-12-23	5	\N	2189
2791	Ouvinte	11	Bloqueado	\N	7	\N	2190
2792	Ouvinte	10	Liberado	2024-12-22	7	\N	2191
2793	Ouvinte	11	Liberado	2024-12-03	10	\N	2192
2794	Ouvinte	13	Liberado	2024-12-17	1	\N	2193
2795	Ouvinte	15	Bloqueado	\N	2	\N	2194
2796	Ouvinte	14	Liberado	2024-12-06	5	\N	2195
2797	Ouvinte	10	Bloqueado	\N	10	\N	2196
2798	Ouvinte	10	Bloqueado	\N	10	\N	2197
2799	Ouvinte	12	Liberado	2024-12-16	6	\N	2198
2800	Ouvinte	15	Liberado	2024-12-17	4	\N	2199
2801	Ouvinte	15	Bloqueado	\N	9	\N	2200
2802	Ouvinte	13	Bloqueado	\N	6	\N	2201
2803	Ouvinte	10	Bloqueado	\N	2	\N	2202
2804	Ouvinte	15	Bloqueado	\N	10	\N	2203
2805	Ouvinte	14	Liberado	2024-12-17	5	\N	2204
2806	Ouvinte	12	Liberado	2024-12-09	8	\N	2205
2807	Ouvinte	15	Liberado	2024-12-10	7	\N	2206
2808	Ouvinte	12	Bloqueado	\N	5	\N	2207
2809	Ouvinte	14	Bloqueado	\N	10	\N	2208
2810	Ouvinte	14	Bloqueado	\N	3	\N	2209
2811	Ouvinte	13	Liberado	2024-12-10	10	\N	2210
2812	Ouvinte	11	Bloqueado	\N	5	\N	2211
2813	Ouvinte	10	Bloqueado	\N	4	\N	2212
2814	Ouvinte	13	Bloqueado	\N	6	\N	2213
2815	Ouvinte	12	Bloqueado	\N	1	\N	2214
2816	Ouvinte	15	Bloqueado	\N	2	\N	2215
2817	Ouvinte	13	Liberado	2024-12-19	8	\N	2216
2818	Ouvinte	14	Liberado	2024-12-12	10	\N	2217
2819	Ouvinte	10	Bloqueado	\N	9	\N	2218
2820	Ouvinte	15	Bloqueado	\N	5	\N	2219
2821	Ouvinte	12	Bloqueado	\N	9	\N	2220
2822	Ouvinte	10	Liberado	2024-12-08	5	\N	2221
2823	Ouvinte	11	Bloqueado	\N	6	\N	2222
2824	Ouvinte	15	Bloqueado	\N	9	\N	2223
2825	Ouvinte	12	Bloqueado	\N	7	\N	2224
2826	Ouvinte	14	Bloqueado	\N	2	\N	2225
2827	Ouvinte	10	Liberado	2024-12-02	6	\N	2226
2828	Ouvinte	14	Bloqueado	\N	7	\N	2227
2829	Ouvinte	11	Bloqueado	\N	7	\N	2228
2830	Ouvinte	10	Liberado	2024-12-16	9	\N	2229
2831	Ouvinte	10	Liberado	2024-12-28	2	\N	2230
2832	Ouvinte	13	Liberado	2024-12-11	7	\N	2231
2833	Ouvinte	12	Bloqueado	\N	7	\N	2232
2834	Ouvinte	13	Bloqueado	\N	2	\N	2233
2835	Ouvinte	10	Bloqueado	\N	7	\N	2234
2836	Ouvinte	15	Liberado	2024-12-03	7	\N	2235
2837	Ouvinte	10	Bloqueado	\N	8	\N	2236
2838	Ouvinte	12	Liberado	2024-12-30	4	\N	2237
2839	Ouvinte	13	Bloqueado	\N	2	\N	2238
2840	Ouvinte	10	Liberado	2024-12-18	3	\N	2239
2841	Ouvinte	13	Liberado	2024-12-03	3	\N	2240
2842	Ouvinte	15	Bloqueado	\N	7	\N	2241
2843	Ouvinte	12	Liberado	2024-12-16	5	\N	2242
2844	Ouvinte	13	Liberado	2024-12-22	5	\N	2243
2845	Ouvinte	15	Bloqueado	\N	1	\N	2244
2846	Ouvinte	13	Bloqueado	\N	2	\N	2245
2847	Ouvinte	14	Liberado	2024-12-02	2	\N	2246
2848	Ouvinte	13	Bloqueado	\N	4	\N	2247
2849	Ouvinte	15	Liberado	2024-12-10	4	\N	2248
2850	Ouvinte	15	Liberado	2024-12-03	4	\N	2249
2851	Ouvinte	14	Bloqueado	\N	8	\N	2250
2852	Ouvinte	14	Bloqueado	\N	7	\N	2251
2853	Ouvinte	12	Bloqueado	\N	9	\N	2252
2854	Ouvinte	14	Bloqueado	\N	10	\N	2253
2855	Ouvinte	12	Liberado	2024-12-26	7	\N	2254
2856	Ouvinte	14	Bloqueado	\N	6	\N	2255
2857	Ouvinte	14	Liberado	2024-12-18	7	\N	2256
2858	Ouvinte	14	Liberado	2024-12-22	8	\N	2257
2859	Ouvinte	14	Bloqueado	\N	5	\N	2258
2860	Ouvinte	14	Liberado	2024-12-05	8	\N	2259
2861	Ouvinte	15	Bloqueado	\N	7	\N	2260
2862	Ouvinte	11	Bloqueado	\N	2	\N	2261
2863	Ouvinte	12	Bloqueado	\N	5	\N	2262
2864	Ouvinte	10	Bloqueado	\N	6	\N	2263
2865	Ouvinte	10	Bloqueado	\N	5	\N	2264
2866	Ouvinte	15	Bloqueado	\N	5	\N	2265
2867	Ouvinte	11	Bloqueado	\N	7	\N	2266
2868	Ouvinte	11	Liberado	2024-12-17	7	\N	2267
2869	Ouvinte	12	Bloqueado	\N	2	\N	2268
2870	Ouvinte	13	Liberado	2024-12-14	7	\N	2269
2871	Ouvinte	10	Bloqueado	\N	2	\N	2270
2872	Ouvinte	10	Bloqueado	\N	6	\N	2271
2873	Ouvinte	15	Liberado	2024-12-14	7	\N	2272
2874	Ouvinte	12	Liberado	2024-12-03	10	\N	2273
2875	Ouvinte	15	Liberado	2024-12-26	4	\N	2274
2876	Ouvinte	12	Bloqueado	\N	1	\N	2275
2877	Ouvinte	12	Bloqueado	\N	5	\N	2276
2878	Ouvinte	10	Bloqueado	\N	6	\N	2277
2879	Ouvinte	13	Bloqueado	\N	9	\N	2278
2880	Ouvinte	11	Bloqueado	\N	4	\N	2279
2881	Ouvinte	12	Bloqueado	\N	3	\N	2280
2882	Ouvinte	14	Bloqueado	\N	5	\N	2281
2883	Ouvinte	11	Bloqueado	\N	2	\N	2282
2884	Ouvinte	12	Bloqueado	\N	5	\N	2283
2885	Ouvinte	11	Bloqueado	\N	4	\N	2284
2886	Ouvinte	10	Bloqueado	\N	4	\N	2285
2887	Ouvinte	10	Bloqueado	\N	1	\N	2286
2888	Ouvinte	10	Bloqueado	\N	6	\N	2287
2889	Ouvinte	13	Liberado	2024-12-12	4	\N	2288
2890	Ouvinte	13	Bloqueado	\N	5	\N	2289
2891	Ouvinte	14	Liberado	2024-12-01	2	\N	2290
2892	Ouvinte	11	Liberado	2024-12-20	1	\N	2291
2893	Ouvinte	13	Bloqueado	\N	1	\N	2292
2894	Ouvinte	13	Bloqueado	\N	5	\N	2293
2895	Ouvinte	14	Bloqueado	\N	6	\N	2294
2896	Ouvinte	14	Bloqueado	\N	4	\N	2295
2897	Ouvinte	12	Liberado	2024-12-27	5	\N	2296
2898	Ouvinte	13	Bloqueado	\N	1	\N	2297
2899	Ouvinte	13	Liberado	2024-12-14	2	\N	2298
2900	Ouvinte	15	Liberado	2024-12-18	10	\N	2299
2901	Ouvinte	15	Bloqueado	\N	2	\N	2300
2902	Ouvinte	15	Liberado	2024-12-15	6	\N	2301
2903	Ouvinte	15	Liberado	2024-12-11	8	\N	2302
2904	Ouvinte	10	Bloqueado	\N	5	\N	2303
2905	Ouvinte	10	Bloqueado	\N	3	\N	2304
2906	Ouvinte	15	Bloqueado	\N	8	\N	2305
2907	Ouvinte	13	Bloqueado	\N	10	\N	2306
2908	Ouvinte	10	Bloqueado	\N	9	\N	2307
2909	Ouvinte	14	Bloqueado	\N	4	\N	2308
2910	Ouvinte	15	Bloqueado	\N	3	\N	2309
2911	Ouvinte	13	Liberado	2024-12-21	8	\N	2310
2912	Ouvinte	10	Bloqueado	\N	10	\N	2311
2913	Ouvinte	11	Bloqueado	\N	2	\N	2312
2914	Ouvinte	15	Bloqueado	\N	2	\N	2313
2915	Ouvinte	14	Bloqueado	\N	3	\N	2314
2916	Ouvinte	15	Liberado	2024-12-14	6	\N	2315
2917	Ouvinte	11	Liberado	2024-12-11	1	\N	2316
2918	Ouvinte	15	Bloqueado	\N	4	\N	2317
2919	Ouvinte	11	Bloqueado	\N	10	\N	2318
2920	Ouvinte	15	Bloqueado	\N	4	\N	2319
2921	Ouvinte	11	Bloqueado	\N	5	\N	2320
2922	Ouvinte	14	Bloqueado	\N	4	\N	2321
2923	Ouvinte	14	Bloqueado	\N	5	\N	2322
2924	Ouvinte	12	Bloqueado	\N	5	\N	2323
2925	Ouvinte	12	Bloqueado	\N	1	\N	2324
2926	Ouvinte	15	Bloqueado	\N	8	\N	2325
2927	Ouvinte	15	Bloqueado	\N	9	\N	2326
2928	Ouvinte	13	Liberado	2024-12-04	4	\N	2327
2929	Ouvinte	13	Bloqueado	\N	1	\N	2328
2930	Ouvinte	15	Liberado	2024-12-26	3	\N	2329
2931	Ouvinte	11	Liberado	2024-12-15	3	\N	2330
2932	Ouvinte	12	Liberado	2024-12-26	2	\N	2331
2933	Ouvinte	13	Bloqueado	\N	6	\N	2332
2934	Ouvinte	15	Liberado	2024-12-16	5	\N	2333
2935	Ouvinte	14	Liberado	2024-12-18	4	\N	2334
2936	Ouvinte	15	Bloqueado	\N	10	\N	2335
2937	Ouvinte	12	Liberado	2024-12-17	1	\N	2336
2938	Ouvinte	15	Bloqueado	\N	10	\N	2337
2939	Ouvinte	12	Liberado	2024-12-13	10	\N	2338
2940	Ouvinte	10	Bloqueado	\N	7	\N	2339
2941	Ouvinte	11	Bloqueado	\N	7	\N	2340
2942	Ouvinte	10	Bloqueado	\N	4	\N	2341
2943	Ouvinte	10	Bloqueado	\N	6	\N	2342
2944	Ouvinte	11	Bloqueado	\N	10	\N	2343
2945	Ouvinte	10	Liberado	2024-12-16	10	\N	2344
2946	Ouvinte	14	Liberado	2024-12-14	2	\N	2345
2947	Ouvinte	14	Liberado	2024-12-13	5	\N	2346
2948	Ouvinte	11	Bloqueado	\N	4	\N	2347
2949	Ouvinte	15	Bloqueado	\N	9	\N	2348
2950	Ouvinte	10	Bloqueado	\N	5	\N	2349
2951	Ouvinte	14	Bloqueado	\N	8	\N	2350
2952	Ouvinte	13	Bloqueado	\N	2	\N	2351
2953	Ouvinte	15	Bloqueado	\N	8	\N	2352
2954	Ouvinte	11	Bloqueado	\N	1	\N	2353
2955	Ouvinte	10	Bloqueado	\N	1	\N	2354
2956	Ouvinte	15	Bloqueado	\N	1	\N	2355
2957	Ouvinte	15	Bloqueado	\N	3	\N	2356
2958	Ouvinte	14	Liberado	2024-12-23	1	\N	2357
2959	Ouvinte	12	Bloqueado	\N	9	\N	2358
2960	Ouvinte	10	Liberado	2024-12-12	9	\N	2359
2961	Ouvinte	12	Liberado	2024-12-08	2	\N	2360
2962	Ouvinte	11	Bloqueado	\N	5	\N	2361
2963	Ouvinte	11	Bloqueado	\N	3	\N	2362
2964	Ouvinte	14	Bloqueado	\N	8	\N	2363
2965	Ouvinte	14	Bloqueado	\N	9	\N	2364
2966	Ouvinte	10	Bloqueado	\N	10	\N	2365
2967	Ouvinte	10	Bloqueado	\N	1	\N	2366
2968	Ouvinte	10	Bloqueado	\N	2	\N	2367
2969	Ouvinte	10	Bloqueado	\N	5	\N	2368
2970	Ouvinte	15	Liberado	2024-12-13	8	\N	2369
2971	Ouvinte	11	Bloqueado	\N	9	\N	2370
2972	Ouvinte	12	Liberado	2024-12-07	3	\N	2371
2973	Ouvinte	14	Bloqueado	\N	1	\N	2372
2974	Ouvinte	11	Liberado	2024-12-03	9	\N	2373
2975	Ouvinte	11	Liberado	2024-12-02	10	\N	2374
2976	Ouvinte	15	Bloqueado	\N	6	\N	2375
2977	Ouvinte	11	Bloqueado	\N	1	\N	2376
2978	Ouvinte	10	Bloqueado	\N	7	\N	2377
2979	Ouvinte	10	Bloqueado	\N	10	\N	2378
2980	Ouvinte	13	Bloqueado	\N	9	\N	2379
2981	Ouvinte	11	Bloqueado	\N	1	\N	2380
2982	Ouvinte	11	Liberado	2024-12-09	10	\N	2381
2983	Ouvinte	13	Bloqueado	\N	1	\N	2382
2984	Ouvinte	12	Liberado	2024-12-03	4	\N	2383
2985	Ouvinte	13	Liberado	2024-12-23	10	\N	2384
2986	Ouvinte	10	Bloqueado	\N	4	\N	2385
2987	Ouvinte	14	Liberado	2024-12-07	4	\N	2386
2988	Ouvinte	11	Bloqueado	\N	9	\N	2387
2989	Ouvinte	11	Liberado	2024-12-30	3	\N	2388
2990	Ouvinte	10	Liberado	2024-12-21	8	\N	2389
2991	Ouvinte	10	Bloqueado	\N	5	\N	2390
2992	Ouvinte	11	Bloqueado	\N	2	\N	2391
2993	Ouvinte	12	Liberado	2024-12-22	1	\N	2392
2994	Ouvinte	10	Liberado	2024-12-15	3	\N	2393
2995	Ouvinte	15	Bloqueado	\N	4	\N	2394
2996	Ouvinte	10	Bloqueado	\N	2	\N	2395
2997	Ouvinte	12	Liberado	2024-12-13	8	\N	2396
2998	Ouvinte	11	Bloqueado	\N	5	\N	2397
2999	Ouvinte	15	Bloqueado	\N	6	\N	2398
3000	Ouvinte	15	Bloqueado	\N	9	\N	2399
3001	Ouvinte	14	Liberado	2024-12-21	5	\N	2400
3002	Ouvinte	10	Bloqueado	\N	4	\N	2401
3003	Ouvinte	14	Liberado	2024-12-17	9	\N	2402
3004	Ouvinte	11	Bloqueado	\N	2	\N	2403
3005	Ouvinte	11	Liberado	2024-12-10	7	\N	2404
3006	Ouvinte	10	Bloqueado	\N	7	\N	2405
3007	Ouvinte	15	Bloqueado	\N	7	\N	2406
3008	Ouvinte	15	Bloqueado	\N	2	\N	2407
3009	Ouvinte	11	Bloqueado	\N	5	\N	2408
3010	Ouvinte	14	Bloqueado	\N	8	\N	2409
3011	Ouvinte	13	Liberado	2024-12-06	10	\N	2410
3012	Ouvinte	10	Bloqueado	\N	5	\N	2411
3013	Ouvinte	13	Liberado	2024-12-22	6	\N	2412
3014	Ouvinte	13	Bloqueado	\N	3	\N	2413
3015	Ouvinte	10	Bloqueado	\N	1	\N	2414
3016	Ouvinte	14	Bloqueado	\N	8	\N	2415
3017	Ouvinte	15	Bloqueado	\N	8	\N	2416
3018	Ouvinte	10	Liberado	2024-12-16	3	\N	2417
3019	Ouvinte	13	Liberado	2024-12-28	5	\N	2418
3020	Ouvinte	11	Liberado	2024-12-22	2	\N	2419
3021	Ouvinte	11	Bloqueado	\N	5	\N	2420
3022	Ouvinte	14	Bloqueado	\N	4	\N	2421
3023	Ouvinte	11	Bloqueado	\N	9	\N	2422
3024	Ouvinte	14	Bloqueado	\N	7	\N	2423
3025	Ouvinte	15	Bloqueado	\N	3	\N	2424
3026	Ouvinte	12	Bloqueado	\N	5	\N	2425
3027	Ouvinte	14	Liberado	2024-12-13	9	\N	2426
3028	Ouvinte	12	Bloqueado	\N	7	\N	2427
3029	Ouvinte	11	Liberado	2024-12-22	9	\N	2428
3030	Ouvinte	14	Bloqueado	\N	8	\N	2429
3031	Ouvinte	14	Bloqueado	\N	9	\N	2430
3032	Ouvinte	11	Liberado	2024-12-26	1	\N	2431
3033	Ouvinte	14	Liberado	2024-12-06	9	\N	2432
3034	Ouvinte	12	Bloqueado	\N	5	\N	2433
3035	Ouvinte	15	Liberado	2024-12-16	3	\N	2434
3036	Ouvinte	15	Liberado	2024-12-28	4	\N	2435
3037	Ouvinte	11	Bloqueado	\N	9	\N	2436
3038	Ouvinte	11	Liberado	2024-12-06	2	\N	2437
3039	Ouvinte	10	Bloqueado	\N	9	\N	2438
3040	Ouvinte	10	Liberado	2024-12-18	4	\N	2439
3041	Ouvinte	11	Bloqueado	\N	3	\N	2440
3042	Ouvinte	10	Bloqueado	\N	10	\N	2441
3043	Ouvinte	12	Bloqueado	\N	3	\N	2442
3044	Ouvinte	11	Bloqueado	\N	1	\N	2443
3045	Ouvinte	13	Bloqueado	\N	4	\N	2444
3046	Ouvinte	12	Bloqueado	\N	1	\N	2445
3047	Ouvinte	12	Bloqueado	\N	4	\N	2446
3048	Ouvinte	12	Bloqueado	\N	3	\N	2447
3049	Ouvinte	10	Bloqueado	\N	3	\N	2448
3050	Ouvinte	13	Bloqueado	\N	2	\N	2449
3051	Ouvinte	14	Bloqueado	\N	5	\N	2450
3052	Ouvinte	15	Liberado	2024-12-05	6	\N	2451
3053	Ouvinte	15	Bloqueado	\N	7	\N	2452
3054	Ouvinte	13	Liberado	2024-12-07	2	\N	2453
3055	Ouvinte	13	Liberado	2024-12-28	3	\N	2454
3056	Ouvinte	14	Bloqueado	\N	9	\N	2455
3057	Ouvinte	12	Bloqueado	\N	8	\N	2456
3058	Ouvinte	12	Bloqueado	\N	2	\N	2457
3059	Ouvinte	15	Bloqueado	\N	6	\N	2458
3060	Ouvinte	15	Bloqueado	\N	10	\N	2459
3061	Ouvinte	14	Bloqueado	\N	5	\N	2460
3062	Ouvinte	12	Bloqueado	\N	4	\N	2461
3063	Ouvinte	14	Bloqueado	\N	9	\N	2462
3064	Ouvinte	13	Liberado	2024-12-06	9	\N	2463
3065	Ouvinte	11	Liberado	2024-12-09	8	\N	2464
3066	Ouvinte	14	Bloqueado	\N	1	\N	2465
3067	Ouvinte	15	Liberado	2024-12-04	1	\N	2466
3068	Ouvinte	12	Liberado	2024-12-18	10	\N	2467
3069	Ouvinte	15	Bloqueado	\N	5	\N	2468
3070	Ouvinte	13	Liberado	2024-12-16	8	\N	2469
3071	Ouvinte	14	Bloqueado	\N	8	\N	2470
3072	Ouvinte	14	Liberado	2024-12-11	10	\N	2471
3073	Ouvinte	14	Liberado	2024-12-26	9	\N	2472
3074	Ouvinte	10	Bloqueado	\N	9	\N	2473
3075	Ouvinte	12	Liberado	2024-12-10	4	\N	2474
3076	Ouvinte	10	Bloqueado	\N	6	\N	2475
3077	Ouvinte	13	Bloqueado	\N	4	\N	2476
3078	Ouvinte	15	Bloqueado	\N	1	\N	2477
3079	Ouvinte	15	Bloqueado	\N	1	\N	2478
3080	Ouvinte	13	Bloqueado	\N	2	\N	2479
3081	Ouvinte	10	Bloqueado	\N	7	\N	2480
3082	Ouvinte	14	Bloqueado	\N	2	\N	2481
3083	Ouvinte	10	Bloqueado	\N	8	\N	2482
3084	Ouvinte	12	Bloqueado	\N	1	\N	2483
3085	Ouvinte	12	Bloqueado	\N	4	\N	2484
3086	Ouvinte	14	Liberado	2024-12-29	6	\N	2485
3087	Ouvinte	14	Bloqueado	\N	1	\N	2486
3088	Ouvinte	13	Bloqueado	\N	7	\N	2487
3089	Ouvinte	13	Bloqueado	\N	4	\N	2488
3090	Ouvinte	10	Bloqueado	\N	10	\N	2489
3091	Ouvinte	13	Bloqueado	\N	4	\N	2490
3092	Ouvinte	10	Liberado	2024-12-25	7	\N	2491
3093	Ouvinte	13	Bloqueado	\N	1	\N	2492
3094	Ouvinte	14	Liberado	2024-12-29	1	\N	2493
3095	Ouvinte	11	Bloqueado	\N	7	\N	2494
3096	Ouvinte	15	Bloqueado	\N	5	\N	2495
3097	Ouvinte	11	Liberado	2024-12-25	4	\N	2496
3098	Ouvinte	14	Bloqueado	\N	7	\N	2497
3099	Ouvinte	11	Liberado	2024-12-24	7	\N	2498
3100	Ouvinte	12	Bloqueado	\N	9	\N	2499
3101	Ouvinte	11	Liberado	2024-12-18	2	\N	2500
3102	Ouvinte	14	Bloqueado	\N	7	\N	2501
3103	Ouvinte	15	Bloqueado	\N	7	\N	2502
3104	Ouvinte	13	Liberado	2024-12-08	2	\N	2503
3105	Ouvinte	15	Bloqueado	\N	7	\N	2504
3106	Ouvinte	14	Bloqueado	\N	3	\N	2505
3107	Ouvinte	11	Bloqueado	\N	1	\N	2506
3108	Ouvinte	11	Bloqueado	\N	9	\N	2507
3109	Ouvinte	12	Bloqueado	\N	9	\N	2508
3110	Ouvinte	12	Bloqueado	\N	9	\N	2509
3111	Ouvinte	15	Liberado	2024-12-08	2	\N	2510
3112	Ouvinte	10	Liberado	2024-12-04	6	\N	2511
3113	Ouvinte	14	Liberado	2024-12-10	5	\N	2512
3114	Ouvinte	14	Bloqueado	\N	10	\N	2513
3115	Ouvinte	10	Bloqueado	\N	7	\N	2514
3116	Ouvinte	14	Liberado	2024-12-08	6	\N	2515
3117	Ouvinte	12	Bloqueado	\N	4	\N	2516
3118	Ouvinte	14	Bloqueado	\N	7	\N	2517
3119	Ouvinte	10	Bloqueado	\N	7	\N	2518
3120	Ouvinte	14	Bloqueado	\N	2	\N	2519
3121	Ouvinte	11	Liberado	2024-12-09	5	\N	2520
3122	Ouvinte	14	Bloqueado	\N	6	\N	2521
3123	Ouvinte	15	Liberado	2024-12-17	1	\N	2522
3124	Ouvinte	15	Liberado	2024-12-26	3	\N	2523
3125	Ouvinte	14	Liberado	2024-12-25	3	\N	2524
2295	Mesa	18	Bloqueado	\N	1	26701	1895
2296	Roda de Conversa	24	Bloqueado	\N	9	26702	1898
2297	Artigo	10	Bloqueado	\N	2	26703	1901
2298	Artigo	16	Liberado	2024-12-09	1	26704	1903
2299	Mesa	15	Bloqueado	\N	4	26705	1904
2300	Mesa	10	Bloqueado	\N	1	26706	1906
2301	Mesa	17	Bloqueado	\N	3	26707	1909
2302	Artigo	16	Bloqueado	\N	9	26708	1916
2303	Mesa	6	Bloqueado	\N	4	26709	1918
2304	Artigo	6	Liberado	2024-12-22	8	26710	1920
2305	Palestra	6	Liberado	2024-12-16	2	26711	1921
2306	Roda de Conversa	13	Bloqueado	\N	6	26712	1922
2307	Mesa	7	Bloqueado	\N	1	26713	1924
2308	Mesa	25	Bloqueado	\N	1	26714	1925
2309	Roda de Conversa	15	Bloqueado	\N	3	26715	1927
2310	Palestra	14	Bloqueado	\N	4	26716	1929
2311	Palestra	19	Bloqueado	\N	4	26717	1937
2312	Palestra	18	Bloqueado	\N	8	26718	1938
2313	Mesa	16	Bloqueado	\N	4	26719	1939
2314	Artigo	19	Bloqueado	\N	1	26720	1940
2315	Artigo	18	Bloqueado	\N	4	26721	1942
2316	Mesa	6	Bloqueado	\N	8	26722	1944
2317	Artigo	11	Bloqueado	\N	10	26723	1945
2318	Mesa	9	Liberado	2024-12-20	8	26724	1946
2319	Roda de Conversa	11	Bloqueado	\N	5	26725	1947
2320	Mesa	11	Bloqueado	\N	10	26726	1949
2321	Palestra	12	Bloqueado	\N	1	26727	1950
2322	Mesa	25	Bloqueado	\N	8	26728	1952
2323	Artigo	15	Bloqueado	\N	7	26729	1955
2324	Palestra	19	Bloqueado	\N	3	26730	1956
2325	Mesa	19	Bloqueado	\N	7	26731	1959
2326	Mesa	14	Bloqueado	\N	4	26732	1962
2327	Mesa	23	Bloqueado	\N	1	26733	1963
2328	Palestra	12	Bloqueado	\N	6	26734	1966
2329	Mesa	25	Liberado	2024-12-03	4	26735	1968
2330	Palestra	14	Bloqueado	\N	6	26736	1972
2331	Palestra	23	Bloqueado	\N	9	26737	1973
2332	Artigo	5	Bloqueado	\N	9	26738	1974
2333	Palestra	5	Bloqueado	\N	3	26739	1975
2334	Artigo	10	Bloqueado	\N	5	26740	1977
2335	Roda de Conversa	6	Liberado	2024-12-06	1	26741	1980
2336	Roda de Conversa	9	Bloqueado	\N	10	26742	1982
2337	Mesa	6	Bloqueado	\N	2	26743	1983
2338	Artigo	23	Liberado	2024-12-20	4	26744	1984
2339	Roda de Conversa	18	Bloqueado	\N	7	26745	1985
2340	Palestra	12	Bloqueado	\N	5	26746	1986
2341	Artigo	16	Liberado	2024-12-30	9	26747	1989
2342	Mesa	6	Bloqueado	\N	6	26748	1990
2343	Palestra	15	Liberado	2024-12-15	9	26749	1991
2344	Mesa	22	Bloqueado	\N	1	26750	1992
2345	Roda de Conversa	10	Liberado	2024-12-09	3	26751	1993
2346	Artigo	5	Bloqueado	\N	6	26752	1997
2347	Palestra	16	Bloqueado	\N	5	26753	2000
2348	Artigo	8	Bloqueado	\N	3	26754	2002
2349	Roda de Conversa	15	Bloqueado	\N	10	26755	2003
2350	Mesa	8	Bloqueado	\N	6	26756	2007
2351	Artigo	5	Bloqueado	\N	3	26757	2010
2352	Artigo	9	Bloqueado	\N	10	26758	2012
2353	Mesa	10	Bloqueado	\N	10	26759	2013
2354	Palestra	22	Liberado	2024-12-18	1	26760	2015
2355	Roda de Conversa	13	Liberado	2024-12-14	8	26761	2017
2356	Artigo	24	Bloqueado	\N	9	26762	2019
2357	Palestra	12	Bloqueado	\N	1	26763	2022
2358	Artigo	18	Bloqueado	\N	4	26764	2023
2359	Palestra	24	Bloqueado	\N	2	26765	2025
2360	Artigo	21	Bloqueado	\N	2	26766	2028
2361	Roda de Conversa	7	Bloqueado	\N	9	26767	2029
2362	Artigo	19	Liberado	2024-12-17	1	26768	2032
2363	Palestra	6	Bloqueado	\N	7	26769	2039
2364	Palestra	18	Liberado	2024-12-23	3	26770	2040
2365	Artigo	24	Liberado	2024-12-23	8	26771	2047
2366	Palestra	14	Bloqueado	\N	5	26772	2048
2367	Mesa	20	Bloqueado	\N	10	26773	2051
2368	Artigo	5	Bloqueado	\N	8	26774	2053
2369	Roda de Conversa	10	Bloqueado	\N	4	26775	2057
2370	Mesa	22	Bloqueado	\N	1	26776	2059
2371	Roda de Conversa	10	Bloqueado	\N	6	26777	2064
2372	Artigo	5	Bloqueado	\N	10	26778	2065
2373	Mesa	18	Bloqueado	\N	2	26779	2066
2374	Artigo	16	Bloqueado	\N	10	26780	2069
2375	Mesa	14	Bloqueado	\N	6	26781	2071
2376	Roda de Conversa	18	Liberado	2024-12-12	7	26782	2072
2377	Artigo	25	Bloqueado	\N	5	26783	2074
2378	Mesa	18	Bloqueado	\N	9	26784	2081
2379	Mesa	23	Liberado	2024-12-27	3	26785	2082
2380	Mesa	19	Bloqueado	\N	6	26786	2085
2381	Mesa	5	Bloqueado	\N	8	26787	2086
2382	Palestra	10	Bloqueado	\N	8	26788	2092
2383	Artigo	8	Bloqueado	\N	8	26789	2093
2384	Artigo	18	Liberado	2024-12-21	7	26790	2094
2385	Artigo	17	Bloqueado	\N	3	26791	2096
2386	Palestra	14	Bloqueado	\N	1	26792	2097
2387	Palestra	11	Liberado	2024-12-16	10	26793	2099
2388	Mesa	23	Bloqueado	\N	8	26794	2100
2389	Palestra	9	Bloqueado	\N	10	26795	2101
2390	Mesa	17	Bloqueado	\N	9	26796	2103
2391	Palestra	15	Bloqueado	\N	1	26797	2104
2392	Artigo	19	Bloqueado	\N	1	26798	2105
2393	Mesa	13	Liberado	2024-12-06	9	26799	2108
2394	Palestra	9	Bloqueado	\N	7	26800	2109
2395	Intervenção Artística	25	Liberado	2024-12-11	8	26801	2116
2396	Mesa	21	Bloqueado	\N	9	26802	2118
2397	Roda de Conversa	12	Bloqueado	\N	8	26803	2121
2398	Palestra	11	Bloqueado	\N	7	26804	2123
2399	Artigo	10	Liberado	2024-12-26	3	26805	2127
2400	Roda de Conversa	6	Bloqueado	\N	9	26806	2128
2401	Artigo	7	Liberado	2024-12-23	6	26807	2129
2402	Mesa	14	Bloqueado	\N	9	26808	2130
2403	Artigo	14	Liberado	2024-12-10	2	26809	2132
2404	Mesa	17	Bloqueado	\N	3	26810	2135
2405	Mesa	13	Liberado	2024-12-09	8	26811	2136
2406	Artigo	12	Liberado	2024-12-22	6	26812	2137
2407	Artigo	15	Bloqueado	\N	5	26813	2138
2408	Mesa	22	Liberado	2024-12-27	3	26814	2143
2409	Palestra	17	Liberado	2024-12-06	2	26815	2146
2410	Mesa	21	Bloqueado	\N	3	26816	2148
2411	Mesa	14	Bloqueado	\N	7	26817	2150
2412	Artigo	16	Bloqueado	\N	9	26818	2151
2413	Artigo	13	Bloqueado	\N	3	26819	2153
2414	Mesa	19	Liberado	2024-12-14	8	26820	2154
2415	Roda de Conversa	17	Bloqueado	\N	3	26821	2155
2416	Roda de Conversa	9	Bloqueado	\N	6	26822	2160
2417	Roda de Conversa	15	Bloqueado	\N	7	26823	2163
2418	Palestra	13	Bloqueado	\N	9	26824	2165
2419	Roda de Conversa	15	Bloqueado	\N	4	26825	2166
2420	Artigo	15	Bloqueado	\N	3	26826	2168
2421	Palestra	7	Bloqueado	\N	10	26827	2169
2422	Palestra	18	Bloqueado	\N	4	26828	2173
2423	Roda de Conversa	8	Bloqueado	\N	6	26829	2175
2424	Artigo	12	Liberado	2024-12-25	8	26830	2176
2425	Roda de Conversa	8	Bloqueado	\N	2	26831	2177
2426	Roda de Conversa	24	Liberado	2024-12-01	2	26832	2180
2427	Artigo	22	Bloqueado	\N	5	26833	2181
2428	Palestra	6	Bloqueado	\N	8	26834	2185
2429	Mesa	23	Bloqueado	\N	9	26835	2186
2430	Mesa	18	Liberado	2024-12-21	5	26836	2189
2431	Artigo	17	Bloqueado	\N	7	26837	2190
2432	Palestra	24	Bloqueado	\N	5	26838	2195
2433	Roda de Conversa	15	Bloqueado	\N	10	26839	2196
2434	Palestra	24	Liberado	2024-12-11	4	26840	2199
2435	Mesa	8	Bloqueado	\N	9	26841	2200
2436	Artigo	12	Bloqueado	\N	2	26842	2202
2437	Intervenção Artística	6	Bloqueado	\N	5	26843	2204
2438	Artigo	5	Bloqueado	\N	5	26844	2207
2439	Artigo	10	Bloqueado	\N	3	26845	2209
2440	Palestra	11	Bloqueado	\N	5	26846	2211
2441	Artigo	13	Bloqueado	\N	4	26847	2212
2442	Mesa	20	Bloqueado	\N	1	26848	2214
2443	Mesa	8	Liberado	2024-12-08	10	26849	2217
2444	Artigo	9	Bloqueado	\N	7	26850	2224
2445	Palestra	19	Bloqueado	\N	7	26851	2228
2446	Mesa	23	Bloqueado	\N	7	26852	2231
2447	Intervenção Artística	11	Bloqueado	\N	7	26853	2232
2448	Roda de Conversa	18	Bloqueado	\N	8	26854	2236
2449	Roda de Conversa	23	Liberado	2024-12-15	3	26855	2240
2450	Artigo	14	Bloqueado	\N	7	26856	2241
2451	Palestra	21	Bloqueado	\N	5	26857	2242
2452	Mesa	16	Bloqueado	\N	2	26858	2245
2453	Artigo	7	Bloqueado	\N	4	26859	2247
2454	Palestra	13	Bloqueado	\N	4	26860	2248
2455	Roda de Conversa	13	Bloqueado	\N	8	26861	2250
2456	Mesa	16	Bloqueado	\N	7	26862	2251
2457	Palestra	24	Bloqueado	\N	5	26863	2258
2458	Palestra	9	Bloqueado	\N	7	26864	2266
2459	Roda de Conversa	25	Bloqueado	\N	7	26865	2267
2460	Palestra	19	Bloqueado	\N	2	26866	2270
2461	Mesa	9	Bloqueado	\N	6	26867	2271
2462	Artigo	19	Bloqueado	\N	9	26868	2278
2463	Artigo	5	Bloqueado	\N	6	26869	2287
2464	Artigo	23	Liberado	2024-12-26	4	26870	2288
2465	Mesa	16	Bloqueado	\N	4	26871	2295
2466	Intervenção Artística	6	Bloqueado	\N	1	26872	2297
2467	Artigo	12	Liberado	2024-12-03	2	26873	2298
2468	Artigo	10	Bloqueado	\N	10	26874	2299
2469	Roda de Conversa	12	Bloqueado	\N	2	26875	2300
2470	Roda de Conversa	21	Liberado	2024-12-30	8	26876	2302
2471	Mesa	14	Bloqueado	\N	5	26877	2303
2472	Artigo	17	Bloqueado	\N	3	26878	2304
2473	Intervenção Artística	7	Bloqueado	\N	10	26879	2306
2474	Artigo	7	Bloqueado	\N	9	26880	2307
2475	Artigo	8	Bloqueado	\N	4	26881	2308
2476	Roda de Conversa	7	Bloqueado	\N	10	26882	2311
2477	Mesa	24	Liberado	2024-12-27	6	26883	2315
2478	Artigo	22	Bloqueado	\N	4	26884	2317
2479	Mesa	23	Bloqueado	\N	4	26885	2321
2480	Artigo	13	Bloqueado	\N	5	26886	2323
2481	Palestra	21	Bloqueado	\N	1	26887	2324
2482	Palestra	24	Bloqueado	\N	8	26888	2325
2483	Mesa	11	Bloqueado	\N	1	26889	2328
2484	Mesa	20	Liberado	2024-12-13	3	26890	2330
2485	Mesa	16	Liberado	2024-12-07	2	26891	2331
2486	Palestra	9	Bloqueado	\N	4	26892	2334
2487	Artigo	22	Bloqueado	\N	10	26893	2335
2488	Roda de Conversa	14	Bloqueado	\N	10	26894	2338
2489	Artigo	18	Bloqueado	\N	7	26895	2339
2490	Artigo	9	Bloqueado	\N	4	26896	2341
2491	Artigo	13	Bloqueado	\N	10	26897	2343
2492	Roda de Conversa	11	Liberado	2024-12-07	2	26898	2345
2493	Mesa	15	Bloqueado	\N	5	26899	2349
2494	Artigo	9	Bloqueado	\N	8	26900	2350
\.


--
-- Data for Name: tab_evento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tab_evento (id_evento, nome_evento, data_inicio, data_termino, tipo, status, id_local, pagamento) FROM stdin;
1	Congresso Itapuã	2024-01-05	2024-01-07	Artistico	Confirmado	1	f
4	Festival de Pirajá	2024-04-10	2024-04-14	Academico	Confirmado	2	f
5	Concerto Sinfônico das Ganhadeira	2024-05-20	2024-05-22	Musical	Cancelado	3	f
6	Encontro de Negócios	2024-06-15	2024-06-16	Corporativo	Confirmado	3	f
8	Corrida de Rua dos professores de Ed.fisica	2024-08-13	2024-08-13	Esportivo	Pendente	1	f
9	Feira de Gastronomia	2024-09-05	2024-09-08	Cultural	Confirmado	2	f
10	Seminario Academico	2024-10-21	2024-10-23	Academico	Confirmado	3	f
2	Campeonato de TCC	2024-02-12	2024-02-18	Academico	Confirmado	4	t
3	Feira de Artesanato Literario	2024-03-01	2024-03-03	Cultural	Pendente	3	t
7	Concerto da escola de musica baiana	2024-07-25	2024-07-26	Musical	Confirmado	4	t
\.


--
-- Data for Name: tab_evento_funcao_pessoa; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tab_evento_funcao_pessoa (id_pessoa, id_evento, id_funcao) FROM stdin;
257	2	3
242	5	2
277	3	1
289	8	11
282	5	8
237	7	4
242	1	2
262	2	9
269	8	10
245	3	6
270	10	8
277	1	6
277	4	8
261	10	3
293	8	8
248	7	4
205	8	11
206	5	5
264	9	11
292	2	1
270	10	5
283	3	3
211	5	6
227	10	5
204	1	9
228	1	10
219	2	6
234	6	1
253	9	3
204	7	10
236	3	3
244	5	1
265	2	3
246	5	5
295	8	10
207	9	11
235	1	3
270	5	10
202	8	3
282	2	10
213	2	5
254	1	6
214	3	10
274	10	1
208	2	11
280	4	3
227	7	5
238	3	4
266	5	2
297	4	5
261	1	9
257	4	10
206	5	10
273	1	4
223	2	5
209	9	5
251	9	5
201	10	3
200	9	6
241	6	3
253	10	8
287	3	3
239	4	4
281	2	1
230	3	5
229	5	6
218	8	1
239	4	9
209	7	9
253	2	1
243	5	9
245	3	2
228	3	1
262	7	11
242	9	8
247	8	8
281	2	11
295	2	1
261	2	11
268	6	4
250	10	1
232	4	2
210	6	8
215	5	6
290	10	10
247	7	4
222	9	4
252	6	9
249	7	9
214	8	11
242	7	11
221	1	4
264	3	8
200	1	8
290	9	3
208	3	9
242	9	5
209	6	3
282	8	11
229	3	3
276	1	3
206	1	1
246	5	8
277	7	1
204	8	5
222	5	9
244	4	11
234	6	5
291	2	9
236	5	2
287	2	10
290	6	10
211	6	6
287	2	6
259	5	10
252	7	2
245	7	9
270	5	8
281	4	2
287	1	6
241	7	11
228	7	2
227	5	1
264	4	3
273	2	8
246	8	4
230	7	1
287	5	4
266	9	11
237	7	8
289	1	3
206	1	6
253	10	9
258	5	11
273	7	11
272	3	8
239	4	8
233	8	9
274	5	8
261	4	5
242	5	5
275	9	4
262	10	10
296	8	1
228	4	8
270	8	2
215	5	2
228	8	11
227	4	5
238	7	6
258	7	9
247	1	1
235	6	11
271	3	10
288	4	11
237	4	2
232	10	4
269	1	4
215	7	8
223	6	4
249	6	3
239	3	8
253	1	11
235	9	1
215	1	8
204	6	3
233	2	11
250	4	6
264	7	11
279	5	5
292	10	11
258	5	10
242	4	10
229	10	8
271	5	3
224	6	4
278	1	3
236	6	10
238	8	3
259	10	5
206	7	3
280	4	9
236	2	9
258	8	10
272	2	5
271	9	11
200	5	4
238	2	11
292	8	10
280	2	5
275	9	5
280	5	3
274	5	3
227	1	10
235	6	5
223	7	11
208	9	4
291	1	8
291	8	8
244	4	10
292	8	2
271	4	9
284	3	10
276	3	5
286	6	10
280	5	2
280	6	10
270	10	2
274	7	11
291	3	6
241	1	8
208	6	2
236	10	6
264	2	9
244	9	2
200	3	1
216	7	4
289	7	9
247	10	10
223	3	11
215	7	1
286	3	9
278	4	11
297	10	8
227	7	11
255	8	3
250	10	11
258	8	3
268	1	11
210	9	9
288	4	8
243	7	8
203	1	3
246	3	3
287	1	5
254	7	5
204	10	9
284	10	3
214	1	4
219	9	9
257	10	6
253	1	1
202	3	9
200	10	5
267	1	10
200	6	2
230	8	3
271	7	1
215	1	3
273	6	11
216	4	2
245	10	8
269	9	10
214	8	2
276	2	5
255	2	6
218	10	2
223	9	6
203	6	4
242	8	3
272	6	11
238	6	4
250	5	6
246	3	1
267	3	5
210	3	3
228	3	11
232	7	6
225	6	5
250	8	8
270	7	9
268	3	4
201	8	6
269	2	4
266	1	4
236	4	9
224	8	8
228	6	2
200	8	9
253	8	1
258	4	2
209	4	1
273	8	1
269	6	8
258	5	4
231	3	11
208	10	4
233	8	1
213	2	1
247	9	6
291	3	8
212	8	4
229	6	1
245	3	11
255	3	6
200	5	1
223	9	10
233	1	3
248	6	1
203	9	9
\.


--
-- Data for Name: tab_funcao; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tab_funcao (id_funcao, nome_funcao, horas, area) FROM stdin;
1	Apoio Tecnico	20	Audio
2	Apoio Tecnico	20	Video
3	Avaliador	5	Tecnolocia
4	Avaliador	5	Biologia
5	Avaliador	5	Medicina
6	Avaliador	5	Letras
8	Gestor	100	Administração
9	Comissão Organizadora	90	Organização
10	Comissão Cientifica	50	Avaliação
11	Orientador	0	Geral
\.


--
-- Data for Name: tab_inscrito; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tab_inscrito (id_inscrito, data_inscricao, nome_cracha, status, id_evento, id_tipo, id_pessoa) FROM stdin;
1894	2024-10-27	Participante_909	Pendente	10	4	288
1895	2023-07-25	Participante_99	Confirmada	1	1	281
1896	2024-10-03	Participante_901	Pendente	3	5	261
1897	2024-12-08	Participante_773	Pendente	9	3	207
1898	2023-05-26	Participante_884	Pendente	9	1	232
1899	2022-07-20	Participante_995	Cancelada	4	3	230
1900	2022-06-19	Participante_890	Pendente	1	3	286
1901	2022-07-27	Participante_302	Confirmada	2	1	200
1902	2024-10-27	Participante_485	Pendente	8	5	234
1903	2022-02-23	Participante_273	Confirmada	1	2	296
1904	2022-09-22	Participante_446	Cancelada	4	2	217
1905	2024-07-05	Participante_1000	Cancelada	8	4	269
1906	2023-09-14	Participante_560	Pendente	1	1	218
1907	2024-03-25	Participante_701	Cancelada	6	3	230
1908	2024-10-18	Participante_270	Confirmada	6	3	217
1909	2022-10-22	Participante_68	Cancelada	3	2	208
1910	2024-11-22	Participante_482	Pendente	6	5	221
1911	2022-04-03	Participante_964	Cancelada	9	4	223
1912	2022-10-22	Participante_292	Confirmada	5	5	281
1913	2022-01-19	Participante_279	Pendente	2	5	293
1914	2022-11-27	Participante_385	Confirmada	1	4	298
1915	2024-06-18	Participante_187	Confirmada	7	4	214
1916	2024-07-18	Participante_303	Pendente	9	1	270
1917	2022-01-28	Participante_852	Cancelada	10	3	278
1918	2022-07-23	Participante_315	Pendente	4	1	259
1919	2023-06-20	Participante_150	Confirmada	2	4	277
1920	2023-08-20	Participante_443	Confirmada	8	1	250
1921	2022-05-27	Participante_217	Confirmada	2	1	222
1922	2023-09-14	Participante_39	Pendente	6	2	276
1923	2024-10-05	Participante_197	Pendente	1	5	270
1924	2024-10-08	Participante_2	Pendente	1	1	278
1925	2023-02-01	Participante_376	Confirmada	1	2	202
1926	2022-09-21	Participante_863	Pendente	10	4	248
1927	2022-02-27	Participante_400	Cancelada	3	1	265
1928	2023-05-09	Participante_327	Cancelada	6	5	275
1929	2024-08-01	Participante_941	Cancelada	4	1	243
1930	2023-08-24	Participante_497	Cancelada	9	5	261
1931	2023-10-25	Participante_741	Cancelada	7	5	239
1932	2022-05-20	Participante_896	Confirmada	2	4	207
1933	2022-11-08	Participante_842	Confirmada	2	5	268
1934	2022-03-28	Participante_499	Confirmada	6	5	277
1935	2024-12-17	Participante_926	Pendente	2	5	252
1936	2022-07-28	Participante_510	Cancelada	6	5	218
1937	2022-05-23	Participante_275	Pendente	4	1	245
1938	2022-07-06	Participante_102	Confirmada	8	1	289
1939	2024-09-28	Participante_942	Pendente	4	2	231
1940	2024-11-03	Participante_330	Cancelada	1	1	262
1941	2022-10-02	Participante_17	Confirmada	5	4	273
1942	2022-12-15	Participante_703	Cancelada	4	1	238
1943	2024-07-27	Participante_295	Cancelada	6	3	255
1944	2023-07-19	Participante_16	Cancelada	8	2	258
1945	2022-02-15	Participante_340	Pendente	10	2	275
1946	2024-11-09	Participante_65	Confirmada	8	1	252
1947	2022-04-04	Participante_63	Confirmada	5	2	259
1948	2023-09-18	Participante_219	Pendente	3	5	270
1949	2024-11-05	Participante_116	Cancelada	10	2	267
1950	2023-04-26	Participante_726	Confirmada	1	1	251
1951	2023-09-23	Participante_653	Confirmada	7	3	267
1952	2024-04-07	Participante_296	Pendente	8	1	260
1953	2023-12-12	Participante_863	Confirmada	3	4	297
1954	2023-05-03	Participante_631	Cancelada	7	5	245
1955	2024-07-12	Participante_238	Pendente	7	1	287
1956	2024-11-28	Participante_127	Cancelada	3	1	258
1957	2023-01-12	Participante_897	Cancelada	5	4	240
1958	2022-03-25	Participante_777	Pendente	8	5	290
1959	2023-01-22	Participante_641	Cancelada	7	2	219
1960	2023-04-17	Participante_599	Confirmada	1	3	237
1961	2022-10-26	Participante_622	Pendente	4	3	278
1962	2022-12-03	Participante_642	Cancelada	4	1	200
1963	2023-01-11	Participante_958	Cancelada	1	1	215
1964	2022-12-06	Participante_866	Cancelada	7	3	248
1965	2022-01-13	Participante_148	Pendente	9	5	219
1966	2024-11-22	Participante_280	Pendente	6	1	245
1967	2023-01-27	Participante_109	Pendente	5	3	269
1968	2022-08-12	Participante_963	Confirmada	4	2	293
1969	2023-04-09	Participante_634	Confirmada	7	3	252
1970	2022-04-09	Participante_620	Confirmada	7	4	210
1971	2022-10-17	Participante_347	Pendente	10	3	226
1972	2023-12-02	Participante_960	Confirmada	6	2	284
1973	2022-03-24	Participante_251	Cancelada	9	2	289
1974	2023-08-10	Participante_207	Pendente	9	1	243
1975	2022-11-21	Participante_392	Pendente	3	2	277
1976	2023-07-19	Participante_190	Pendente	3	4	210
1977	2024-11-23	Participante_894	Cancelada	5	1	290
1978	2023-12-16	Participante_271	Pendente	3	5	202
1979	2024-08-17	Participante_929	Pendente	6	5	270
1980	2023-05-27	Participante_472	Confirmada	1	1	259
1981	2023-12-06	Participante_377	Cancelada	3	4	293
1982	2023-07-15	Participante_86	Confirmada	10	1	240
1983	2024-06-25	Participante_825	Confirmada	2	2	281
1984	2022-04-26	Participante_653	Confirmada	4	2	289
1985	2023-11-16	Participante_517	Cancelada	7	2	216
1986	2023-03-18	Participante_241	Cancelada	5	2	289
1987	2022-06-14	Participante_21	Confirmada	6	3	274
1988	2022-08-10	Participante_410	Confirmada	7	4	288
1989	2023-02-03	Participante_614	Confirmada	9	1	258
1990	2023-04-16	Participante_660	Pendente	6	1	278
1991	2023-06-16	Participante_451	Confirmada	9	1	284
1992	2024-04-20	Participante_716	Cancelada	1	1	204
1993	2023-12-17	Participante_622	Confirmada	3	1	279
1994	2022-04-20	Participante_121	Cancelada	2	5	236
1995	2023-04-07	Participante_123	Pendente	7	5	200
1996	2022-11-26	Participante_842	Pendente	2	3	259
1997	2023-12-28	Participante_741	Confirmada	6	2	213
1998	2024-06-21	Participante_620	Confirmada	1	5	294
1999	2024-03-28	Participante_447	Pendente	5	3	242
2000	2022-07-17	Participante_707	Cancelada	5	2	283
2001	2024-10-12	Participante_894	Pendente	5	4	267
2002	2023-08-04	Participante_355	Confirmada	3	1	215
2003	2024-12-19	Participante_655	Pendente	10	2	254
2004	2023-12-08	Participante_744	Cancelada	5	3	270
2005	2022-11-02	Participante_389	Cancelada	4	4	222
2006	2024-05-05	Participante_186	Cancelada	3	5	251
2007	2023-01-09	Participante_540	Cancelada	6	1	237
2008	2023-06-06	Participante_620	Pendente	6	3	238
2009	2024-08-02	Participante_763	Pendente	10	5	243
2010	2022-09-12	Participante_153	Cancelada	3	1	204
2011	2024-10-14	Participante_822	Cancelada	2	4	279
2012	2024-11-07	Participante_229	Cancelada	10	2	216
2013	2024-10-07	Participante_708	Cancelada	10	2	225
2014	2022-04-18	Participante_856	Confirmada	4	5	277
2015	2024-02-23	Participante_273	Confirmada	1	1	256
2016	2023-02-05	Participante_298	Pendente	6	4	212
2017	2023-09-06	Participante_343	Confirmada	8	1	295
2018	2024-05-10	Participante_935	Pendente	2	4	270
2019	2022-05-28	Participante_999	Cancelada	9	2	293
2020	2023-05-05	Participante_414	Pendente	6	5	200
2021	2024-08-18	Participante_662	Confirmada	6	3	243
2022	2022-05-20	Participante_225	Pendente	1	2	214
2023	2024-03-28	Participante_505	Cancelada	4	1	248
2024	2024-12-21	Participante_37	Pendente	6	5	244
2025	2023-12-13	Participante_447	Pendente	2	1	213
2026	2022-06-18	Participante_972	Pendente	4	5	292
2027	2024-09-15	Participante_336	Pendente	1	4	252
2028	2023-09-08	Participante_912	Cancelada	2	1	271
2029	2024-04-17	Participante_109	Cancelada	9	1	244
2030	2022-10-05	Participante_168	Cancelada	2	4	278
2031	2023-12-19	Participante_270	Pendente	6	5	290
2032	2023-10-15	Participante_539	Confirmada	1	1	293
2033	2024-05-10	Participante_392	Confirmada	5	5	293
2034	2023-07-14	Participante_889	Confirmada	8	4	236
2035	2024-07-22	Participante_861	Cancelada	4	5	236
2036	2022-09-12	Participante_819	Pendente	4	3	263
2037	2023-09-26	Participante_770	Confirmada	5	3	248
2038	2023-05-09	Participante_243	Pendente	10	4	269
2039	2024-02-02	Participante_940	Cancelada	7	1	270
2040	2022-04-10	Participante_71	Confirmada	3	2	262
2041	2024-12-16	Participante_522	Cancelada	10	4	236
2042	2023-02-04	Participante_560	Cancelada	3	5	244
2043	2023-10-12	Participante_802	Pendente	1	3	257
2044	2024-06-13	Participante_10	Confirmada	3	4	288
2045	2024-08-18	Participante_452	Cancelada	7	5	204
2046	2024-07-01	Participante_193	Cancelada	2	4	266
2047	2024-02-07	Participante_788	Confirmada	8	1	243
2048	2022-12-03	Participante_213	Cancelada	5	2	284
2049	2023-07-13	Participante_197	Confirmada	3	5	214
2050	2024-10-24	Participante_159	Pendente	7	4	241
2051	2024-11-05	Participante_611	Cancelada	10	1	245
2052	2022-07-14	Participante_685	Cancelada	9	4	236
2053	2023-08-11	Participante_870	Confirmada	8	2	227
2054	2022-04-23	Participante_590	Pendente	5	5	244
2055	2023-06-02	Participante_752	Pendente	5	3	234
2056	2024-07-28	Participante_829	Cancelada	10	5	247
2057	2022-12-12	Participante_926	Confirmada	4	2	221
2058	2023-07-19	Participante_339	Confirmada	5	5	260
2059	2023-05-08	Participante_602	Pendente	1	1	244
2060	2024-10-14	Participante_67	Cancelada	7	5	206
2061	2023-03-12	Participante_925	Cancelada	3	5	273
2062	2023-09-12	Participante_804	Pendente	10	3	284
2063	2022-05-20	Participante_392	Pendente	7	5	273
2064	2023-01-21	Participante_609	Cancelada	6	1	206
2065	2024-04-12	Participante_738	Cancelada	10	1	224
2066	2023-10-02	Participante_780	Cancelada	2	1	263
2067	2023-09-22	Participante_307	Confirmada	6	4	233
2068	2024-09-13	Participante_14	Confirmada	8	4	275
2069	2022-02-23	Participante_697	Confirmada	10	1	241
2070	2022-05-19	Participante_775	Pendente	8	4	298
2071	2022-12-18	Participante_985	Pendente	6	2	234
2072	2022-07-11	Participante_755	Confirmada	7	1	291
2073	2023-01-16	Participante_796	Confirmada	8	5	254
2074	2023-04-04	Participante_940	Confirmada	5	2	226
2075	2023-07-14	Participante_999	Pendente	2	4	251
2076	2022-11-20	Participante_451	Cancelada	10	4	256
2077	2022-03-03	Participante_598	Cancelada	9	4	217
2078	2023-01-16	Participante_17	Confirmada	2	3	261
2079	2022-10-11	Participante_62	Cancelada	10	3	201
2080	2022-03-17	Participante_936	Cancelada	10	4	290
2081	2023-10-16	Participante_760	Pendente	9	2	256
2082	2024-03-27	Participante_605	Confirmada	3	2	257
2083	2024-02-04	Participante_790	Pendente	7	5	256
2084	2023-01-20	Participante_998	Pendente	9	5	218
2085	2023-05-20	Participante_418	Pendente	6	1	211
2086	2023-01-06	Participante_613	Pendente	8	2	291
2087	2022-03-19	Participante_687	Confirmada	2	4	215
2088	2022-10-06	Participante_606	Cancelada	10	3	237
2089	2023-10-02	Participante_624	Cancelada	10	4	291
2090	2023-03-13	Participante_315	Pendente	4	4	201
2091	2022-04-13	Participante_543	Confirmada	3	5	268
2092	2022-10-19	Participante_455	Pendente	8	2	212
2093	2024-05-09	Participante_776	Confirmada	8	2	216
2094	2022-05-07	Participante_517	Confirmada	7	2	296
2095	2022-10-03	Participante_635	Confirmada	6	3	265
2096	2022-11-03	Participante_422	Confirmada	3	1	207
2097	2023-04-08	Participante_331	Cancelada	1	2	282
2098	2024-09-27	Participante_538	Cancelada	6	5	246
2099	2023-06-18	Participante_603	Confirmada	10	2	200
2100	2023-03-12	Participante_87	Pendente	8	2	249
2101	2023-09-28	Participante_28	Pendente	10	1	277
2102	2024-09-08	Participante_728	Cancelada	8	3	274
2103	2024-11-01	Participante_446	Confirmada	9	1	221
2104	2022-06-11	Participante_726	Confirmada	1	1	279
2105	2024-10-09	Participante_606	Cancelada	1	2	236
2106	2024-08-02	Participante_668	Pendente	9	4	277
2107	2024-12-25	Participante_711	Cancelada	7	5	283
2108	2023-07-08	Participante_145	Confirmada	9	1	255
2109	2024-12-15	Participante_853	Cancelada	7	2	294
2110	2024-07-20	Participante_481	Confirmada	6	3	257
2111	2024-02-19	Participante_752	Cancelada	9	5	208
2112	2023-09-19	Participante_294	Pendente	2	5	220
2113	2024-06-19	Participante_588	Confirmada	9	4	202
2114	2024-08-28	Participante_437	Pendente	1	5	230
2115	2023-09-05	Participante_257	Cancelada	7	4	268
2116	2022-08-22	Participante_758	Confirmada	8	1	271
2117	2022-06-05	Participante_74	Pendente	7	5	279
2118	2024-06-09	Participante_292	Pendente	9	1	287
2119	2022-09-15	Participante_226	Pendente	4	5	250
2120	2023-12-10	Participante_993	Pendente	2	4	288
2121	2022-09-20	Participante_212	Pendente	8	2	203
2122	2024-01-15	Participante_976	Cancelada	5	3	206
2123	2022-06-14	Participante_241	Cancelada	7	2	246
2124	2022-01-15	Participante_810	Confirmada	10	5	280
2125	2023-12-04	Participante_610	Pendente	4	4	286
2126	2024-01-05	Participante_497	Confirmada	1	3	238
2127	2024-01-21	Participante_715	Confirmada	3	2	275
2128	2024-06-19	Participante_140	Confirmada	9	1	297
2129	2024-05-25	Participante_209	Confirmada	6	1	209
2130	2024-09-18	Participante_694	Cancelada	9	2	204
2131	2023-01-26	Participante_61	Cancelada	8	5	263
2132	2022-03-12	Participante_306	Confirmada	2	2	297
2133	2023-11-27	Participante_188	Confirmada	7	3	286
2134	2023-03-18	Participante_868	Cancelada	5	4	227
2135	2024-01-04	Participante_244	Confirmada	3	2	285
2136	2023-03-13	Participante_75	Confirmada	8	1	221
2137	2022-01-24	Participante_370	Confirmada	6	2	202
2138	2024-03-07	Participante_896	Cancelada	5	1	279
2139	2024-05-05	Participante_332	Confirmada	6	4	264
2140	2022-09-23	Participante_622	Pendente	7	5	260
2141	2022-01-28	Participante_98	Confirmada	10	4	286
2142	2022-08-18	Participante_531	Cancelada	3	3	238
2143	2022-12-14	Participante_189	Confirmada	3	1	272
2144	2023-07-18	Participante_504	Pendente	7	5	234
2145	2023-04-15	Participante_878	Cancelada	2	3	283
2146	2022-04-28	Participante_140	Confirmada	2	2	250
2147	2024-06-07	Participante_157	Pendente	8	5	213
2148	2024-07-01	Participante_595	Cancelada	3	1	227
2149	2024-07-11	Participante_173	Confirmada	7	3	258
2150	2023-08-18	Participante_972	Cancelada	7	1	237
2151	2024-02-11	Participante_528	Pendente	9	2	274
2152	2024-04-02	Participante_4	Confirmada	4	5	242
2153	2023-12-06	Participante_803	Confirmada	3	1	236
2154	2023-03-13	Participante_400	Confirmada	8	2	294
2155	2024-10-09	Participante_917	Pendente	3	1	298
2156	2022-04-13	Participante_934	Cancelada	1	4	205
2157	2023-04-26	Participante_410	Cancelada	2	3	225
2158	2023-11-24	Participante_624	Confirmada	6	5	247
2159	2024-11-23	Participante_480	Pendente	6	3	229
2160	2023-10-23	Participante_994	Pendente	6	2	294
2161	2022-04-02	Participante_86	Cancelada	9	4	200
2162	2022-11-22	Participante_924	Cancelada	10	4	222
2163	2022-06-13	Participante_435	Pendente	7	2	262
2164	2022-06-12	Participante_738	Confirmada	3	5	254
2165	2022-04-25	Participante_523	Pendente	9	1	245
2166	2022-12-11	Participante_643	Cancelada	4	1	290
2167	2023-09-22	Participante_831	Cancelada	3	5	242
2168	2023-10-28	Participante_619	Cancelada	3	2	246
2169	2024-07-08	Participante_984	Cancelada	10	2	202
2170	2024-08-26	Participante_107	Confirmada	6	4	282
2171	2022-04-20	Participante_242	Cancelada	7	3	261
2172	2022-03-14	Participante_120	Cancelada	9	3	216
2173	2024-03-05	Participante_797	Pendente	4	2	294
2174	2022-05-01	Participante_46	Pendente	2	5	238
2175	2022-03-15	Participante_474	Confirmada	6	1	298
2176	2024-01-23	Participante_345	Confirmada	8	2	244
2177	2024-09-03	Participante_446	Pendente	2	2	247
2178	2024-01-21	Participante_827	Pendente	5	3	220
2179	2022-03-01	Participante_3	Confirmada	6	5	280
2180	2023-03-04	Participante_593	Confirmada	2	1	262
2181	2023-10-27	Participante_898	Cancelada	5	2	261
2182	2022-04-22	Participante_464	Cancelada	4	3	204
2183	2022-03-19	Participante_115	Cancelada	1	4	288
2184	2022-12-20	Participante_335	Pendente	4	4	224
2185	2022-05-03	Participante_748	Pendente	8	2	242
2186	2024-04-05	Participante_214	Pendente	9	2	264
2187	2024-08-07	Participante_169	Cancelada	5	4	237
2188	2022-06-01	Participante_139	Cancelada	2	3	233
2189	2023-12-19	Participante_202	Confirmada	5	1	232
2190	2024-04-20	Participante_316	Pendente	7	1	271
2191	2024-04-20	Participante_294	Confirmada	7	5	228
2192	2024-10-10	Participante_932	Confirmada	10	4	215
2193	2023-08-19	Participante_283	Confirmada	1	3	255
2194	2023-10-17	Participante_621	Cancelada	2	5	287
2195	2024-01-01	Participante_419	Confirmada	5	2	268
2196	2023-09-13	Participante_104	Cancelada	10	1	205
2197	2022-07-12	Participante_578	Cancelada	10	5	265
2198	2023-05-08	Participante_771	Confirmada	6	5	261
2199	2024-05-07	Participante_282	Confirmada	4	1	225
2200	2024-10-23	Participante_851	Cancelada	9	1	215
2201	2024-03-21	Participante_127	Pendente	6	4	203
2202	2022-03-10	Participante_913	Pendente	2	2	229
2203	2024-07-21	Participante_283	Pendente	10	5	232
2204	2023-04-18	Participante_100	Confirmada	5	2	217
2205	2023-06-22	Participante_25	Confirmada	8	5	209
2206	2024-02-11	Participante_173	Confirmada	7	3	201
2207	2024-09-04	Participante_201	Pendente	5	2	219
2208	2024-05-17	Participante_360	Pendente	10	3	204
2209	2024-09-06	Participante_724	Pendente	3	1	274
2210	2022-09-27	Participante_205	Confirmada	10	5	263
2211	2024-10-01	Participante_61	Cancelada	5	2	213
2212	2022-07-02	Participante_413	Pendente	4	2	282
2213	2022-12-18	Participante_566	Cancelada	6	4	231
2214	2023-02-03	Participante_172	Pendente	1	2	261
2215	2023-01-14	Participante_273	Pendente	2	3	216
2216	2024-12-03	Participante_129	Confirmada	8	3	230
2217	2023-05-25	Participante_608	Confirmada	10	1	283
2218	2023-11-28	Participante_541	Pendente	9	5	252
2219	2023-05-03	Participante_992	Cancelada	5	4	238
2220	2022-10-04	Participante_787	Pendente	9	4	211
2221	2024-06-27	Participante_868	Confirmada	5	3	200
2222	2022-03-11	Participante_646	Cancelada	6	4	267
2223	2023-07-23	Participante_564	Pendente	9	5	251
2224	2023-11-10	Participante_835	Cancelada	7	2	232
2225	2023-05-02	Participante_547	Cancelada	2	4	218
2226	2023-02-02	Participante_142	Confirmada	6	4	223
2227	2023-09-02	Participante_109	Cancelada	7	5	203
2228	2023-07-21	Participante_976	Pendente	7	1	275
2229	2024-11-11	Participante_35	Confirmada	9	3	206
2230	2024-02-04	Participante_195	Confirmada	2	4	203
2231	2024-01-18	Participante_662	Confirmada	7	2	207
2232	2023-08-01	Participante_287	Cancelada	7	1	282
2233	2024-02-15	Participante_240	Pendente	2	5	258
2234	2023-02-15	Participante_435	Pendente	7	5	297
2235	2024-05-19	Participante_977	Confirmada	7	3	211
2236	2022-06-25	Participante_305	Pendente	8	1	281
2237	2022-05-23	Participante_391	Confirmada	4	4	208
2238	2022-02-09	Participante_830	Pendente	2	3	208
2239	2023-05-05	Participante_346	Confirmada	3	4	228
2240	2022-11-19	Participante_908	Confirmada	3	2	255
2241	2023-03-02	Participante_576	Cancelada	7	1	266
2242	2022-03-20	Participante_394	Confirmada	5	1	271
2243	2024-06-27	Participante_575	Confirmada	5	5	209
2244	2024-10-25	Participante_194	Cancelada	1	5	235
2245	2024-05-12	Participante_693	Cancelada	2	1	204
2246	2024-05-15	Participante_486	Confirmada	2	5	226
2247	2024-11-16	Participante_917	Pendente	4	1	237
2248	2023-11-11	Participante_353	Confirmada	4	1	262
2249	2024-07-03	Participante_758	Confirmada	4	5	296
2250	2023-09-11	Participante_584	Pendente	8	1	264
2251	2024-05-24	Participante_35	Cancelada	7	2	222
2252	2022-01-26	Participante_201	Cancelada	9	4	239
2253	2024-04-25	Participante_783	Cancelada	10	5	230
2254	2022-06-10	Participante_143	Confirmada	7	5	253
2255	2023-05-20	Participante_729	Cancelada	6	3	242
2256	2023-01-24	Participante_14	Confirmada	7	5	292
2257	2024-09-04	Participante_800	Confirmada	8	3	207
2258	2023-03-19	Participante_88	Pendente	5	1	262
2259	2024-11-21	Participante_287	Confirmada	8	5	282
2260	2022-04-25	Participante_255	Pendente	7	3	225
2261	2024-09-11	Participante_881	Cancelada	2	4	205
2262	2023-10-28	Participante_452	Cancelada	5	5	230
2263	2023-01-22	Participante_23	Pendente	6	3	207
2264	2022-08-19	Participante_595	Cancelada	5	3	201
2265	2023-09-26	Participante_932	Pendente	5	4	202
2266	2023-08-11	Participante_122	Cancelada	7	2	249
2267	2023-05-05	Participante_979	Confirmada	7	1	272
2268	2023-10-13	Participante_552	Cancelada	2	4	245
2269	2022-08-10	Participante_408	Confirmada	7	3	251
2270	2024-02-08	Participante_887	Cancelada	2	1	240
2271	2024-07-28	Participante_836	Pendente	6	1	293
2272	2022-08-16	Participante_369	Confirmada	7	3	235
2273	2022-04-08	Participante_352	Confirmada	10	5	266
2274	2023-04-09	Participante_614	Confirmada	4	4	291
2275	2022-10-12	Participante_447	Pendente	1	4	285
2276	2024-09-01	Participante_465	Cancelada	5	4	210
2277	2024-01-01	Participante_55	Cancelada	6	5	259
2278	2024-07-21	Participante_968	Pendente	9	1	230
2279	2023-02-20	Participante_851	Pendente	4	5	273
2280	2022-12-02	Participante_205	Pendente	3	3	291
2281	2023-12-23	Participante_825	Pendente	5	3	214
2282	2022-08-22	Participante_325	Pendente	2	3	223
2283	2022-08-20	Participante_544	Cancelada	5	3	225
2284	2024-09-02	Participante_546	Pendente	4	4	249
2285	2023-10-16	Participante_394	Cancelada	4	4	234
2286	2022-02-10	Participante_683	Pendente	1	4	280
2287	2023-02-20	Participante_232	Cancelada	6	1	220
2288	2024-10-15	Participante_339	Confirmada	4	2	206
2289	2023-01-20	Participante_985	Pendente	5	3	253
2290	2024-06-28	Participante_891	Confirmada	2	5	249
2291	2024-10-24	Participante_769	Confirmada	1	5	207
2292	2023-08-24	Participante_681	Cancelada	1	3	275
2293	2023-09-22	Participante_752	Pendente	5	3	286
2294	2022-12-24	Participante_567	Pendente	6	5	248
2295	2024-06-08	Participante_252	Cancelada	4	2	216
2296	2023-09-04	Participante_510	Confirmada	5	5	264
2297	2024-01-22	Participante_582	Pendente	1	2	266
2298	2023-12-19	Participante_328	Confirmada	2	1	239
2299	2022-09-07	Participante_396	Confirmada	10	2	281
2300	2023-02-04	Participante_793	Cancelada	2	2	242
2301	2022-06-17	Participante_520	Confirmada	6	5	295
2302	2022-11-16	Participante_461	Confirmada	8	1	283
2303	2022-10-10	Participante_683	Cancelada	5	2	211
2304	2022-07-06	Participante_248	Cancelada	3	1	229
2305	2024-10-15	Participante_184	Pendente	8	4	232
2306	2024-10-26	Participante_609	Cancelada	10	2	234
2307	2022-04-12	Participante_25	Cancelada	9	1	237
2308	2022-06-19	Participante_148	Pendente	4	2	228
2309	2023-10-04	Participante_32	Pendente	3	3	253
2310	2023-06-11	Participante_556	Confirmada	8	4	229
2311	2024-08-04	Participante_39	Cancelada	10	1	227
2312	2022-06-01	Participante_910	Pendente	2	3	244
2313	2022-07-06	Participante_972	Pendente	2	3	211
2314	2022-01-05	Participante_971	Cancelada	3	3	248
2315	2022-06-27	Participante_995	Confirmada	6	1	272
2316	2023-10-07	Participante_686	Confirmada	1	5	268
2317	2024-09-05	Participante_294	Pendente	4	1	272
2318	2023-09-07	Participante_69	Pendente	10	5	231
2319	2023-01-04	Participante_254	Cancelada	4	4	207
2320	2024-07-20	Participante_773	Pendente	5	4	254
2321	2022-08-12	Participante_233	Pendente	4	2	241
2322	2023-09-19	Participante_76	Pendente	5	3	265
2323	2023-09-03	Participante_243	Cancelada	5	1	257
2324	2023-06-22	Participante_821	Pendente	1	2	273
2325	2022-05-04	Participante_356	Cancelada	8	2	220
2326	2023-11-10	Participante_226	Pendente	9	5	222
2327	2022-03-23	Participante_356	Confirmada	4	3	218
2328	2023-10-21	Participante_637	Pendente	1	2	231
2329	2024-11-04	Participante_913	Confirmada	3	4	245
2330	2022-06-18	Participante_759	Confirmada	3	2	226
2331	2023-08-02	Participante_599	Confirmada	2	2	290
2332	2024-06-05	Participante_381	Cancelada	6	5	204
2333	2022-01-20	Participante_372	Confirmada	5	5	208
2334	2023-05-07	Participante_650	Confirmada	4	2	211
2335	2022-10-01	Participante_584	Pendente	10	1	279
2336	2022-09-10	Participante_311	Confirmada	1	3	234
2337	2024-09-06	Participante_5	Cancelada	10	4	259
2338	2023-11-01	Participante_424	Confirmada	10	2	228
2339	2022-04-23	Participante_767	Pendente	7	1	238
2340	2023-01-15	Participante_140	Cancelada	7	5	255
2341	2023-09-06	Participante_989	Cancelada	4	1	298
2342	2023-02-22	Participante_184	Cancelada	6	4	216
2343	2024-10-04	Participante_754	Cancelada	10	1	297
2344	2024-10-26	Participante_178	Confirmada	10	3	294
2345	2024-04-08	Participante_148	Confirmada	2	2	214
2346	2024-06-21	Participante_310	Confirmada	5	3	285
2347	2023-04-08	Participante_520	Cancelada	4	4	212
2348	2023-10-14	Participante_565	Cancelada	9	5	209
2349	2024-11-15	Participante_352	Cancelada	5	2	282
2350	2022-07-06	Participante_408	Cancelada	8	1	240
2351	2023-03-24	Participante_980	Pendente	2	3	212
2352	2022-06-24	Participante_446	Cancelada	8	1	261
2353	2022-12-19	Participante_627	Cancelada	1	3	284
2354	2024-01-08	Participante_262	Pendente	1	4	283
2355	2024-03-20	Participante_180	Cancelada	1	4	274
2356	2024-04-17	Participante_903	Cancelada	3	2	216
2357	2023-03-28	Participante_209	Confirmada	1	2	254
2358	2023-04-23	Participante_391	Pendente	9	4	288
2359	2024-07-18	Participante_442	Confirmada	9	2	240
2360	2022-11-03	Participante_857	Confirmada	2	5	295
2361	2022-06-09	Participante_651	Pendente	5	4	239
2362	2022-10-13	Participante_56	Cancelada	3	2	295
2363	2023-06-14	Participante_419	Cancelada	8	2	288
2364	2022-01-14	Participante_507	Pendente	9	1	210
2365	2022-05-11	Participante_322	Pendente	10	3	244
2366	2022-02-12	Participante_534	Cancelada	1	5	253
2367	2023-04-07	Participante_12	Pendente	2	4	228
2368	2024-04-13	Participante_939	Cancelada	5	1	205
2369	2022-03-07	Participante_687	Confirmada	8	5	239
2370	2024-06-16	Participante_472	Cancelada	9	4	292
2371	2023-07-11	Participante_367	Confirmada	3	5	240
2372	2022-03-10	Participante_201	Cancelada	1	2	239
2373	2022-10-20	Participante_384	Confirmada	9	2	285
2374	2024-10-21	Participante_270	Confirmada	10	3	257
2375	2022-03-06	Participante_101	Cancelada	6	5	288
2376	2024-06-06	Participante_799	Pendente	1	4	219
2377	2022-05-14	Participante_40	Pendente	7	4	265
2378	2023-06-21	Participante_950	Cancelada	10	5	261
2379	2022-11-11	Participante_880	Pendente	9	4	246
2380	2024-06-27	Participante_532	Pendente	1	5	222
2381	2022-07-13	Participante_412	Confirmada	10	4	238
2382	2024-02-24	Participante_856	Pendente	1	5	242
2383	2024-08-05	Participante_163	Confirmada	4	5	260
2384	2022-01-23	Participante_443	Confirmada	10	3	255
2385	2023-09-03	Participante_146	Cancelada	4	5	203
2386	2024-12-24	Participante_178	Confirmada	4	1	275
2387	2024-02-11	Participante_213	Pendente	9	4	225
2388	2023-11-18	Participante_943	Confirmada	3	4	280
2389	2023-11-13	Participante_802	Confirmada	8	2	287
2390	2024-01-23	Participante_76	Pendente	5	5	212
2391	2022-02-10	Participante_717	Cancelada	2	1	209
2392	2024-08-20	Participante_372	Confirmada	1	5	200
2393	2024-07-20	Participante_519	Confirmada	3	1	271
2394	2023-01-08	Participante_601	Cancelada	4	4	281
2395	2024-12-04	Participante_534	Pendente	2	4	255
2396	2022-09-20	Participante_148	Confirmada	8	1	247
2397	2022-12-10	Participante_790	Pendente	5	2	288
2398	2024-08-01	Participante_352	Pendente	6	5	224
2399	2022-06-27	Participante_350	Pendente	9	4	248
2400	2022-10-08	Participante_950	Confirmada	5	1	297
2401	2024-08-16	Participante_318	Cancelada	4	4	214
2402	2023-01-19	Participante_79	Confirmada	9	1	262
2403	2022-02-18	Participante_89	Pendente	2	3	267
2404	2022-05-08	Participante_714	Confirmada	7	2	250
2405	2023-02-12	Participante_252	Cancelada	7	1	227
2406	2023-01-14	Participante_307	Pendente	7	2	289
2407	2024-02-26	Participante_963	Cancelada	2	1	292
2408	2023-03-22	Participante_367	Pendente	5	2	245
2409	2023-02-12	Participante_547	Pendente	8	3	208
2410	2022-08-10	Participante_298	Confirmada	10	5	295
2411	2024-08-08	Participante_958	Pendente	5	5	296
2412	2023-10-19	Participante_895	Confirmada	6	2	251
2413	2024-04-25	Participante_868	Cancelada	3	5	205
2414	2022-08-23	Participante_38	Pendente	1	4	206
2415	2024-05-16	Participante_564	Pendente	8	3	280
2416	2022-03-06	Participante_121	Pendente	8	3	296
2417	2023-12-22	Participante_611	Confirmada	3	5	252
2418	2022-02-04	Participante_402	Confirmada	5	4	247
2419	2023-10-28	Participante_257	Confirmada	2	3	230
2420	2022-09-20	Participante_500	Pendente	5	4	256
2421	2022-01-15	Participante_578	Cancelada	4	4	215
2422	2022-07-17	Participante_579	Pendente	9	3	254
2423	2022-11-22	Participante_831	Pendente	7	1	295
2424	2023-11-14	Participante_150	Pendente	3	5	200
2425	2022-10-26	Participante_847	Cancelada	5	4	276
2426	2024-11-23	Participante_687	Confirmada	9	4	259
2427	2024-04-21	Participante_916	Cancelada	7	4	233
2428	2024-08-19	Participante_174	Confirmada	9	1	253
2429	2024-02-19	Participante_918	Cancelada	8	4	241
2430	2022-10-19	Participante_30	Pendente	9	5	278
2431	2023-05-10	Participante_793	Confirmada	1	4	203
2432	2024-09-27	Participante_656	Confirmada	9	4	205
2433	2022-07-16	Participante_16	Cancelada	5	1	274
2434	2024-01-06	Participante_407	Confirmada	3	5	237
2435	2023-07-22	Participante_921	Confirmada	4	4	274
2436	2023-01-04	Participante_667	Cancelada	9	4	213
2437	2023-06-02	Participante_440	Confirmada	2	2	260
2438	2024-11-20	Participante_846	Cancelada	9	3	268
2439	2024-06-10	Participante_108	Confirmada	4	4	244
2440	2024-07-14	Participante_958	Cancelada	3	1	218
2441	2024-07-02	Participante_311	Pendente	10	1	209
2442	2024-03-12	Participante_317	Cancelada	3	3	284
2443	2023-01-13	Participante_648	Pendente	1	5	209
2444	2022-04-27	Participante_457	Cancelada	4	2	265
2445	2024-02-25	Participante_179	Cancelada	1	4	243
2446	2022-08-01	Participante_359	Cancelada	4	1	280
2447	2024-01-15	Participante_635	Pendente	3	4	219
2448	2022-08-26	Participante_199	Cancelada	3	2	217
2449	2024-06-16	Participante_212	Cancelada	2	5	221
2450	2022-03-06	Participante_577	Pendente	5	5	215
2451	2022-10-05	Participante_274	Confirmada	6	4	205
2452	2024-08-26	Participante_952	Pendente	7	5	205
2453	2022-05-17	Participante_376	Confirmada	2	3	232
2454	2022-04-15	Participante_186	Confirmada	3	3	278
2455	2023-04-26	Participante_917	Pendente	9	3	263
2456	2022-10-06	Participante_76	Cancelada	8	1	248
2457	2022-11-26	Participante_390	Pendente	2	2	282
2458	2024-03-27	Participante_895	Pendente	6	5	286
2459	2024-04-14	Participante_475	Cancelada	10	1	264
2460	2023-04-24	Participante_580	Pendente	5	3	235
2461	2022-03-23	Participante_689	Cancelada	4	3	270
2462	2024-06-09	Participante_102	Cancelada	9	5	298
2463	2024-10-18	Participante_252	Confirmada	9	5	281
2464	2024-01-27	Participante_668	Confirmada	8	4	238
2465	2022-02-05	Participante_668	Cancelada	1	3	271
2466	2023-03-25	Participante_737	Confirmada	1	5	289
2467	2024-10-11	Participante_574	Confirmada	10	3	292
2468	2024-12-17	Participante_236	Cancelada	5	3	203
2469	2023-06-16	Participante_92	Confirmada	8	5	200
2470	2023-04-11	Participante_829	Pendente	8	4	237
2471	2023-08-22	Participante_388	Confirmada	10	2	296
2472	2022-12-01	Participante_202	Confirmada	9	1	233
2473	2024-07-15	Participante_625	Cancelada	9	5	229
2474	2023-03-10	Participante_495	Confirmada	4	1	210
2475	2022-03-20	Participante_351	Cancelada	6	3	296
2476	2022-03-16	Participante_167	Pendente	4	3	252
2477	2024-10-21	Participante_940	Cancelada	1	2	241
2478	2023-09-11	Participante_60	Cancelada	1	5	246
2479	2022-08-20	Participante_133	Pendente	2	5	201
2480	2022-04-18	Participante_291	Pendente	7	1	220
2481	2024-03-22	Participante_675	Pendente	2	3	219
2482	2022-11-28	Participante_402	Pendente	8	1	222
2483	2023-03-02	Participante_702	Cancelada	1	1	216
2484	2024-04-18	Participante_404	Cancelada	4	2	235
2485	2022-03-06	Participante_96	Confirmada	6	2	252
2486	2022-06-01	Participante_329	Cancelada	1	3	213
2487	2024-05-20	Participante_44	Cancelada	7	1	259
2488	2023-07-22	Participante_688	Pendente	4	1	209
2489	2023-02-05	Participante_554	Cancelada	10	1	206
2490	2023-11-12	Participante_832	Cancelada	4	4	219
2491	2022-01-17	Participante_790	Confirmada	7	4	209
2492	2022-11-14	Participante_636	Pendente	1	1	297
2493	2022-04-06	Participante_58	Confirmada	1	2	250
2494	2022-06-28	Participante_21	Cancelada	7	4	202
2495	2024-02-03	Participante_313	Pendente	5	5	258
2496	2023-03-12	Participante_733	Confirmada	4	1	233
2497	2023-09-02	Participante_54	Cancelada	7	5	247
2498	2023-04-20	Participante_314	Confirmada	7	2	230
2499	2022-12-19	Participante_260	Cancelada	9	1	214
2500	2023-07-27	Participante_780	Confirmada	2	5	253
2501	2024-06-05	Participante_514	Cancelada	7	5	257
2502	2022-11-02	Participante_369	Cancelada	7	1	215
2503	2022-09-11	Participante_934	Confirmada	2	2	241
2504	2023-08-22	Participante_33	Pendente	7	4	221
2505	2022-08-11	Participante_420	Cancelada	3	2	286
2506	2023-06-15	Participante_770	Pendente	1	2	245
2507	2022-12-19	Participante_578	Pendente	9	5	203
2508	2024-11-08	Participante_479	Pendente	9	5	271
2509	2024-03-05	Participante_386	Cancelada	9	3	269
2510	2023-07-08	Participante_863	Confirmada	2	1	275
2511	2023-10-20	Participante_51	Confirmada	6	5	219
2512	2024-08-05	Participante_746	Confirmada	5	1	249
2513	2023-01-22	Participante_389	Cancelada	10	5	223
2514	2024-03-05	Participante_750	Pendente	7	5	240
2515	2022-08-11	Participante_121	Confirmada	6	5	297
2516	2024-10-22	Participante_9	Pendente	4	4	253
2517	2023-12-19	Participante_654	Cancelada	7	1	213
2518	2024-08-23	Participante_219	Pendente	7	2	264
2519	2023-03-01	Participante_473	Pendente	2	1	248
2520	2022-09-27	Participante_399	Confirmada	5	3	246
2521	2022-01-16	Participante_962	Pendente	6	1	268
2522	2022-07-07	Participante_67	Confirmada	1	2	208
2523	2024-12-14	Participante_797	Confirmada	3	2	294
2524	2023-06-15	Participante_406	Confirmada	3	5	201
\.


--
-- Data for Name: tab_local; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tab_local (id_local, endereco, capacidade, duracao, tipo_local) FROM stdin;
1	Pirajá, rua da esquina, n12	150000	10	Campo
2	Itapuã, sereia ao lado do casquinha	50000	12	Praia
3	Bairro da paz, rua da alameda, n13	100	3	Ginasio
4	Porto velho, rua da mizericordia, n666	1000	5	Campo
\.


--
-- Data for Name: tab_pagamento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tab_pagamento (id_pagamento, valor, forma_pagamento, status_pagamento, id_inscrito) FROM stdin;
453	0.00	free	pago	1894
454	0.00	free	pago	1895
455	0.00	free	pago	1897
456	0.00	free	pago	1898
457	0.00	free	pago	1899
458	0.00	free	pago	1900
459	0.00	free	pago	1902
460	0.00	free	pago	1903
461	0.00	free	pago	1904
462	0.00	free	pago	1905
463	0.00	free	pago	1906
464	0.00	free	pago	1907
465	0.00	free	pago	1908
466	0.00	free	pago	1910
467	0.00	free	pago	1911
468	0.00	free	pago	1912
469	0.00	free	pago	1914
470	0.00	free	pago	1916
471	0.00	free	pago	1917
472	0.00	free	pago	1918
473	0.00	free	pago	1920
474	0.00	free	pago	1922
475	0.00	free	pago	1923
476	0.00	free	pago	1924
477	0.00	free	pago	1925
478	0.00	free	pago	1926
479	0.00	free	pago	1928
480	0.00	free	pago	1929
481	0.00	free	pago	1930
482	0.00	free	pago	1934
483	0.00	free	pago	1936
484	0.00	free	pago	1937
485	0.00	free	pago	1938
486	0.00	free	pago	1939
487	0.00	free	pago	1940
488	0.00	free	pago	1941
489	0.00	free	pago	1942
490	0.00	free	pago	1943
491	0.00	free	pago	1944
492	0.00	free	pago	1945
493	0.00	free	pago	1946
494	0.00	free	pago	1947
495	0.00	free	pago	1949
496	0.00	free	pago	1950
497	0.00	free	pago	1952
498	0.00	free	pago	1957
499	0.00	free	pago	1958
500	0.00	free	pago	1960
501	0.00	free	pago	1961
502	0.00	free	pago	1962
503	0.00	free	pago	1963
504	0.00	free	pago	1965
505	0.00	free	pago	1966
506	0.00	free	pago	1967
507	0.00	free	pago	1968
508	0.00	free	pago	1971
509	0.00	free	pago	1972
510	0.00	free	pago	1973
511	0.00	free	pago	1974
512	0.00	free	pago	1977
513	0.00	free	pago	1979
514	0.00	free	pago	1980
515	0.00	free	pago	1982
516	0.00	free	pago	1984
517	0.00	free	pago	1986
518	0.00	free	pago	1987
519	0.00	free	pago	1989
520	0.00	free	pago	1990
521	0.00	free	pago	1991
522	0.00	free	pago	1992
523	0.00	free	pago	1997
524	0.00	free	pago	1998
525	0.00	free	pago	1999
526	0.00	free	pago	2000
527	0.00	free	pago	2001
528	0.00	free	pago	2003
529	0.00	free	pago	2004
530	0.00	free	pago	2005
531	0.00	free	pago	2007
532	0.00	free	pago	2008
533	0.00	free	pago	2009
534	0.00	free	pago	2012
535	0.00	free	pago	2013
536	0.00	free	pago	2014
537	0.00	free	pago	2015
538	0.00	free	pago	2016
539	0.00	free	pago	2017
540	0.00	free	pago	2019
541	0.00	free	pago	2020
542	0.00	free	pago	2021
543	0.00	free	pago	2022
544	0.00	free	pago	2023
545	0.00	free	pago	2024
546	0.00	free	pago	2026
547	0.00	free	pago	2027
548	0.00	free	pago	2029
549	0.00	free	pago	2031
550	0.00	free	pago	2032
551	0.00	free	pago	2033
552	0.00	free	pago	2034
553	0.00	free	pago	2035
554	0.00	free	pago	2036
555	0.00	free	pago	2037
556	0.00	free	pago	2038
557	0.00	free	pago	2041
558	0.00	free	pago	2043
559	0.00	free	pago	2047
560	0.00	free	pago	2048
561	0.00	free	pago	2051
562	0.00	free	pago	2052
563	0.00	free	pago	2053
564	0.00	free	pago	2054
565	0.00	free	pago	2055
566	0.00	free	pago	2056
567	0.00	free	pago	2057
568	0.00	free	pago	2058
569	0.00	free	pago	2059
570	0.00	free	pago	2062
571	0.00	free	pago	2064
572	0.00	free	pago	2065
573	0.00	free	pago	2067
574	0.00	free	pago	2068
575	0.00	free	pago	2069
576	0.00	free	pago	2070
577	0.00	free	pago	2071
578	0.00	free	pago	2073
579	0.00	free	pago	2074
580	0.00	free	pago	2076
581	0.00	free	pago	2077
582	0.00	free	pago	2079
583	0.00	free	pago	2080
584	0.00	free	pago	2081
585	0.00	free	pago	2084
586	0.00	free	pago	2085
587	0.00	free	pago	2086
588	0.00	free	pago	2088
589	0.00	free	pago	2089
590	0.00	free	pago	2090
591	0.00	free	pago	2092
592	0.00	free	pago	2093
593	0.00	free	pago	2095
594	0.00	free	pago	2097
595	0.00	free	pago	2098
596	0.00	free	pago	2099
597	0.00	free	pago	2100
598	0.00	free	pago	2101
599	0.00	free	pago	2102
600	0.00	free	pago	2103
601	0.00	free	pago	2104
602	0.00	free	pago	2105
603	0.00	free	pago	2106
604	0.00	free	pago	2108
605	0.00	free	pago	2110
606	0.00	free	pago	2111
607	0.00	free	pago	2113
608	0.00	free	pago	2114
609	0.00	free	pago	2116
610	0.00	free	pago	2118
611	0.00	free	pago	2119
612	0.00	free	pago	2121
613	0.00	free	pago	2122
614	0.00	free	pago	2124
615	0.00	free	pago	2125
616	0.00	free	pago	2126
617	0.00	free	pago	2128
618	0.00	free	pago	2129
619	0.00	free	pago	2130
620	0.00	free	pago	2131
621	0.00	free	pago	2134
622	0.00	free	pago	2136
623	0.00	free	pago	2137
624	0.00	free	pago	2138
625	0.00	free	pago	2139
626	0.00	free	pago	2141
627	0.00	free	pago	2147
628	0.00	free	pago	2151
629	0.00	free	pago	2152
630	0.00	free	pago	2154
631	0.00	free	pago	2156
632	0.00	free	pago	2158
633	0.00	free	pago	2159
634	0.00	free	pago	2160
635	0.00	free	pago	2161
636	0.00	free	pago	2162
637	0.00	free	pago	2165
638	0.00	free	pago	2166
639	0.00	free	pago	2169
640	0.00	free	pago	2170
641	0.00	free	pago	2172
642	0.00	free	pago	2173
643	0.00	free	pago	2175
644	0.00	free	pago	2176
645	0.00	free	pago	2178
646	0.00	free	pago	2179
647	0.00	free	pago	2181
648	0.00	free	pago	2182
649	0.00	free	pago	2183
650	0.00	free	pago	2184
651	0.00	free	pago	2185
652	0.00	free	pago	2186
653	0.00	free	pago	2187
654	0.00	free	pago	2189
655	0.00	free	pago	2192
656	0.00	free	pago	2193
657	0.00	free	pago	2195
658	0.00	free	pago	2196
659	0.00	free	pago	2197
660	0.00	free	pago	2198
661	0.00	free	pago	2199
662	0.00	free	pago	2200
663	0.00	free	pago	2201
664	0.00	free	pago	2203
665	0.00	free	pago	2204
666	0.00	free	pago	2205
667	0.00	free	pago	2207
668	0.00	free	pago	2208
669	0.00	free	pago	2210
670	0.00	free	pago	2211
671	0.00	free	pago	2212
672	0.00	free	pago	2213
673	0.00	free	pago	2214
674	0.00	free	pago	2216
675	0.00	free	pago	2217
676	0.00	free	pago	2218
677	0.00	free	pago	2219
678	0.00	free	pago	2220
679	0.00	free	pago	2221
680	0.00	free	pago	2222
681	0.00	free	pago	2223
682	0.00	free	pago	2226
683	0.00	free	pago	2229
684	0.00	free	pago	2236
685	0.00	free	pago	2237
686	0.00	free	pago	2242
687	0.00	free	pago	2243
688	0.00	free	pago	2244
689	0.00	free	pago	2247
690	0.00	free	pago	2248
691	0.00	free	pago	2249
692	0.00	free	pago	2250
693	0.00	free	pago	2252
694	0.00	free	pago	2253
695	0.00	free	pago	2255
696	0.00	free	pago	2257
697	0.00	free	pago	2258
698	0.00	free	pago	2259
699	0.00	free	pago	2262
700	0.00	free	pago	2263
701	0.00	free	pago	2264
702	0.00	free	pago	2265
703	0.00	free	pago	2271
704	0.00	free	pago	2273
705	0.00	free	pago	2274
706	0.00	free	pago	2275
707	0.00	free	pago	2276
708	0.00	free	pago	2277
709	0.00	free	pago	2278
710	0.00	free	pago	2279
711	0.00	free	pago	2281
712	0.00	free	pago	2283
713	0.00	free	pago	2284
714	0.00	free	pago	2285
715	0.00	free	pago	2286
716	0.00	free	pago	2287
717	0.00	free	pago	2288
718	0.00	free	pago	2289
719	0.00	free	pago	2291
720	0.00	free	pago	2292
721	0.00	free	pago	2293
722	0.00	free	pago	2294
723	0.00	free	pago	2295
724	0.00	free	pago	2296
725	0.00	free	pago	2297
726	0.00	free	pago	2299
727	0.00	free	pago	2301
728	0.00	free	pago	2302
729	0.00	free	pago	2303
730	0.00	free	pago	2305
731	0.00	free	pago	2306
732	0.00	free	pago	2307
733	0.00	free	pago	2308
734	0.00	free	pago	2310
735	0.00	free	pago	2311
736	0.00	free	pago	2315
737	0.00	free	pago	2316
738	0.00	free	pago	2317
739	0.00	free	pago	2318
740	0.00	free	pago	2319
741	0.00	free	pago	2320
742	0.00	free	pago	2321
743	0.00	free	pago	2322
744	0.00	free	pago	2323
745	0.00	free	pago	2324
746	0.00	free	pago	2325
747	0.00	free	pago	2326
748	0.00	free	pago	2327
749	0.00	free	pago	2328
750	0.00	free	pago	2332
751	0.00	free	pago	2333
752	0.00	free	pago	2334
753	0.00	free	pago	2335
754	0.00	free	pago	2336
755	0.00	free	pago	2337
756	0.00	free	pago	2338
757	0.00	free	pago	2341
758	0.00	free	pago	2342
759	0.00	free	pago	2343
760	0.00	free	pago	2344
761	0.00	free	pago	2346
762	0.00	free	pago	2347
763	0.00	free	pago	2348
764	0.00	free	pago	2349
765	0.00	free	pago	2350
766	0.00	free	pago	2352
767	0.00	free	pago	2353
768	0.00	free	pago	2354
769	0.00	free	pago	2355
770	0.00	free	pago	2357
771	0.00	free	pago	2358
772	0.00	free	pago	2359
773	0.00	free	pago	2361
774	0.00	free	pago	2363
775	0.00	free	pago	2364
776	0.00	free	pago	2365
777	0.00	free	pago	2366
778	0.00	free	pago	2368
779	0.00	free	pago	2369
780	0.00	free	pago	2370
781	0.00	free	pago	2372
782	0.00	free	pago	2373
783	0.00	free	pago	2374
784	0.00	free	pago	2375
785	0.00	free	pago	2376
786	0.00	free	pago	2378
787	0.00	free	pago	2379
788	0.00	free	pago	2380
789	0.00	free	pago	2381
790	0.00	free	pago	2382
791	0.00	free	pago	2383
792	0.00	free	pago	2384
793	0.00	free	pago	2385
794	0.00	free	pago	2386
795	0.00	free	pago	2387
796	0.00	free	pago	2389
797	0.00	free	pago	2390
798	0.00	free	pago	2392
799	0.00	free	pago	2394
800	0.00	free	pago	2396
801	0.00	free	pago	2397
802	0.00	free	pago	2398
803	0.00	free	pago	2399
804	0.00	free	pago	2400
805	0.00	free	pago	2401
806	0.00	free	pago	2402
807	0.00	free	pago	2408
808	0.00	free	pago	2409
809	0.00	free	pago	2410
810	0.00	free	pago	2411
811	0.00	free	pago	2412
812	0.00	free	pago	2414
813	0.00	free	pago	2415
814	0.00	free	pago	2416
815	0.00	free	pago	2418
816	0.00	free	pago	2420
817	0.00	free	pago	2421
818	0.00	free	pago	2422
819	0.00	free	pago	2425
820	0.00	free	pago	2426
821	0.00	free	pago	2428
822	0.00	free	pago	2429
823	0.00	free	pago	2430
824	0.00	free	pago	2431
825	0.00	free	pago	2432
826	0.00	free	pago	2433
827	0.00	free	pago	2435
828	0.00	free	pago	2436
829	0.00	free	pago	2438
830	0.00	free	pago	2439
831	0.00	free	pago	2441
832	0.00	free	pago	2443
833	0.00	free	pago	2444
834	0.00	free	pago	2445
835	0.00	free	pago	2446
836	0.00	free	pago	2450
837	0.00	free	pago	2451
838	0.00	free	pago	2455
839	0.00	free	pago	2456
840	0.00	free	pago	2458
841	0.00	free	pago	2459
842	0.00	free	pago	2460
843	0.00	free	pago	2461
844	0.00	free	pago	2462
845	0.00	free	pago	2463
846	0.00	free	pago	2464
847	0.00	free	pago	2465
848	0.00	free	pago	2466
849	0.00	free	pago	2467
850	0.00	free	pago	2468
851	0.00	free	pago	2469
852	0.00	free	pago	2470
853	0.00	free	pago	2471
854	0.00	free	pago	2472
855	0.00	free	pago	2473
856	0.00	free	pago	2474
857	0.00	free	pago	2475
858	0.00	free	pago	2476
859	0.00	free	pago	2477
860	0.00	free	pago	2478
861	0.00	free	pago	2482
862	0.00	free	pago	2483
863	0.00	free	pago	2484
864	0.00	free	pago	2485
865	0.00	free	pago	2486
866	0.00	free	pago	2488
867	0.00	free	pago	2489
868	0.00	free	pago	2490
869	0.00	free	pago	2492
870	0.00	free	pago	2493
871	0.00	free	pago	2495
872	0.00	free	pago	2496
873	0.00	free	pago	2499
874	0.00	free	pago	2506
875	0.00	free	pago	2507
876	0.00	free	pago	2508
877	0.00	free	pago	2509
878	0.00	free	pago	2511
879	0.00	free	pago	2512
880	0.00	free	pago	2513
881	0.00	free	pago	2515
882	0.00	free	pago	2516
883	0.00	free	pago	2520
884	0.00	free	pago	2521
885	0.00	free	pago	2522
886	60.00	boleto	pendente	1896
887	55.53	boleto	pago	1901
888	51.00	boleto	pago	1909
889	60.00	cartão	pago	1913
890	50.00	boleto	pendente	1915
891	50.00	boleto	pendente	1919
892	58.44	boleto	pago	1921
893	131.09	boleto	pendente	1927
894	60.00	cartão	pendente	1931
895	50.00	pix	pago	1932
896	60.00	boleto	pago	1933
897	60.00	pix	pago	1935
898	60.00	cartão	pendente	1948
899	54.38	cartão	pendente	1951
900	50.00	boleto	pendente	1953
901	60.00	boleto	pago	1954
902	137.52	boleto	pago	1955
903	145.36	cartão	pago	1956
904	67.41	cartão	pendente	1959
905	85.08	boleto	pago	1964
906	58.66	boleto	pago	1969
907	50.00	pix	pago	1970
908	127.81	boleto	pago	1975
909	50.00	cartão	pago	1976
910	60.00	pix	pendente	1978
911	50.00	pix	pago	1981
912	64.95	pix	pendente	1983
913	109.82	cartão	pendente	1985
914	50.00	boleto	pago	1988
915	77.16	boleto	pendente	1993
916	60.00	boleto	pago	1994
917	60.00	boleto	pendente	1995
918	68.59	boleto	pendente	1996
919	76.60	boleto	pago	2002
920	60.00	cartão	pago	2006
921	125.41	cartão	pago	2010
922	50.00	boleto	pago	2011
923	50.00	cartão	pendente	2018
924	134.94	boleto	pago	2025
925	93.50	pix	pago	2028
926	50.00	cartão	pago	2030
927	94.01	boleto	pendente	2039
928	141.49	cartão	pago	2040
929	60.00	boleto	pago	2042
930	50.00	boleto	pendente	2044
931	60.00	boleto	pago	2045
932	50.00	boleto	pago	2046
933	60.00	cartão	pendente	2049
934	50.00	cartão	pendente	2050
935	60.00	cartão	pendente	2060
936	60.00	boleto	pendente	2061
937	60.00	pix	pendente	2063
938	126.17	pix	pago	2066
939	111.30	boleto	pago	2072
940	50.00	boleto	pendente	2075
941	72.29	cartão	pago	2078
942	110.98	cartão	pago	2082
943	60.00	boleto	pendente	2083
944	50.00	boleto	pendente	2087
945	60.00	pix	pendente	2091
946	65.46	boleto	pago	2094
947	88.07	boleto	pendente	2096
948	60.00	cartão	pago	2107
949	119.38	pix	pago	2109
950	60.00	pix	pendente	2112
951	50.00	cartão	pago	2115
952	60.00	boleto	pendente	2117
953	50.00	cartão	pago	2120
954	97.84	cartão	pendente	2123
955	133.59	boleto	pago	2127
956	103.66	cartão	pendente	2132
957	117.31	pix	pendente	2133
958	140.18	cartão	pendente	2135
959	60.00	boleto	pago	2140
960	148.61	boleto	pago	2142
961	66.62	cartão	pendente	2143
962	60.00	boleto	pago	2144
963	125.95	cartão	pendente	2145
964	103.70	cartão	pendente	2146
965	101.42	pix	pago	2148
966	147.72	cartão	pago	2149
967	87.19	boleto	pago	2150
968	142.18	pix	pendente	2153
969	68.43	boleto	pendente	2155
970	66.52	cartão	pendente	2157
971	76.43	cartão	pendente	2163
972	60.00	boleto	pago	2164
973	60.00	boleto	pendente	2167
974	134.25	boleto	pago	2168
975	133.69	pix	pendente	2171
976	60.00	boleto	pago	2174
977	67.24	cartão	pendente	2177
978	134.52	cartão	pendente	2180
979	144.83	boleto	pendente	2188
980	134.58	boleto	pendente	2190
981	60.00	cartão	pendente	2191
982	60.00	cartão	pendente	2194
983	89.04	cartão	pendente	2202
984	137.16	cartão	pago	2206
985	81.11	boleto	pago	2209
986	111.60	boleto	pago	2215
987	78.94	boleto	pendente	2224
988	50.00	boleto	pendente	2225
989	60.00	boleto	pendente	2227
990	139.14	pix	pendente	2228
991	50.00	boleto	pago	2230
992	90.58	cartão	pago	2231
993	118.74	boleto	pago	2232
994	60.00	pix	pendente	2233
995	60.00	cartão	pendente	2234
996	104.68	boleto	pendente	2235
997	114.66	pix	pendente	2238
998	50.00	pix	pago	2239
999	128.25	cartão	pendente	2240
1000	111.99	boleto	pendente	2241
1001	133.88	boleto	pendente	2245
1002	60.00	pix	pago	2246
1003	147.23	pix	pago	2251
1004	60.00	boleto	pendente	2254
1005	60.00	boleto	pago	2256
1006	105.86	cartão	pendente	2260
1007	50.00	cartão	pago	2261
1008	140.99	pix	pago	2266
1009	90.52	boleto	pendente	2267
1010	50.00	boleto	pendente	2268
1011	136.20	cartão	pendente	2269
1012	116.72	cartão	pago	2270
1013	148.01	boleto	pago	2272
1014	73.28	boleto	pago	2280
1015	115.36	boleto	pendente	2282
1016	60.00	boleto	pago	2290
1017	53.14	boleto	pendente	2298
1018	64.24	pix	pago	2300
1019	136.47	pix	pendente	2304
1020	86.35	boleto	pago	2309
1021	57.53	boleto	pendente	2312
1022	54.03	pix	pago	2313
1023	108.44	boleto	pendente	2314
1024	50.00	boleto	pendente	2329
1025	142.13	boleto	pendente	2330
1026	109.19	boleto	pago	2331
1027	113.87	pix	pago	2339
1028	60.00	cartão	pago	2340
1029	82.48	cartão	pendente	2345
1030	119.90	boleto	pago	2351
1031	98.82	pix	pendente	2356
1032	60.00	pix	pago	2360
1033	130.72	pix	pendente	2362
1034	50.00	boleto	pendente	2367
1035	60.00	pix	pago	2371
1036	50.00	cartão	pago	2377
1037	50.00	boleto	pendente	2388
1038	139.31	cartão	pendente	2391
1039	59.86	boleto	pago	2393
1040	50.00	boleto	pago	2395
1041	70.56	boleto	pago	2403
1042	79.53	boleto	pago	2404
1043	88.30	cartão	pago	2405
1044	61.39	boleto	pago	2406
1045	63.85	boleto	pago	2407
1046	60.00	pix	pendente	2413
1047	60.00	boleto	pendente	2417
1048	110.90	boleto	pendente	2419
1049	117.47	boleto	pendente	2423
1050	60.00	boleto	pago	2424
1051	50.00	pix	pago	2427
1052	60.00	boleto	pago	2434
1053	75.13	cartão	pendente	2437
1054	51.62	pix	pendente	2440
1055	136.91	boleto	pendente	2442
1056	50.00	pix	pago	2447
1057	141.24	boleto	pendente	2448
1058	60.00	boleto	pendente	2449
1059	60.00	boleto	pago	2452
1060	53.69	cartão	pendente	2453
1061	117.17	boleto	pendente	2454
1062	56.86	cartão	pendente	2457
1063	60.00	boleto	pendente	2479
1064	109.45	boleto	pago	2480
1065	64.85	boleto	pago	2481
1066	94.77	boleto	pago	2487
1067	50.00	boleto	pago	2491
1068	50.00	boleto	pendente	2494
1069	60.00	boleto	pendente	2497
1070	102.30	boleto	pago	2498
1071	60.00	boleto	pago	2500
1072	60.00	boleto	pendente	2501
1073	102.09	cartão	pendente	2502
1074	83.50	boleto	pendente	2503
1075	50.00	boleto	pago	2504
1076	96.82	boleto	pago	2505
1077	101.23	boleto	pendente	2510
1078	60.00	cartão	pendente	2514
1079	113.87	pix	pago	2517
1080	104.36	cartão	pendente	2518
1081	58.31	boleto	pago	2519
1082	145.97	pix	pendente	2523
1083	60.00	boleto	pendente	2524
\.


--
-- Data for Name: tab_pessoa; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tab_pessoa (id_pessoa, cpf, senha, dica_senha, nome_sobrenome, ultimo_nome, escolaridade, telefone, email, sexo) FROM stdin;
208	12345678909	senha0009	Minha série favorita	Nome 9	Sobrenome 9	Ensino Fundamental Completo	11999999909	nome9.sobrenome9@96@email.com	M
209	12345678910	senha0010		Nome 10	Sobrenome 10	Ensino Médio Completo	11999999910	nome10.sobrenome10@95@email.com	F
210	12345678911	senha0011	Minha cor preferida	Nome 11	Sobrenome 11	Pós-Graduação	11999999911	nome11.sobrenome11@36@email.com	M
211	12345678912	senha0012		Nome 12	Sobrenome 12	Pós-Graduação	11999999912	nome12.sobrenome12@51@email.com	M
213	12345678914	senha0014	Minha primeira escola	Nome 14	Sobrenome 14	Ensino Médio Completo	11999999914	nome14.sobrenome14@72@email.com	M
214	12345678915	senha0015	Minha comida favorita	Nome 15	Sobrenome 15	Pós-Graduação	11999999915	nome15.sobrenome15@99@email.com	M
215	12345678916	senha0016	Minha cor preferida	Nome 16	Sobrenome 16	Ensino Fundamental Completo	11999999916	nome16.sobrenome16@76@email.com	F
216	12345678917	senha0017	Nome do meu primeiro carro	Nome 17	Sobrenome 17	Ensino Fundamental Completo	11999999917	nome17.sobrenome17@33@email.com	M
217	12345678918	senha0018	Cidade natal	Nome 18	Sobrenome 18	Pós-Graduação	11999999918	nome18.sobrenome18@38@email.com	M
218	12345678919	senha0019		Nome 19	Sobrenome 19	Ensino Superior Completo	11999999919	nome19.sobrenome19@99@email.com	F
219	12345678920	senha0020	Meu professor favorito	Nome 20	Sobrenome 20	Ensino Fundamental Completo	11999999920	nome20.sobrenome20@45@email.com	F
220	12345678921	senha0021		Nome 21	Sobrenome 21	Ensino Médio Completo	11999999921	nome21.sobrenome21@94@email.com	M
221	12345678922	senha0022	Ano do meu nascimento	Nome 22	Sobrenome 22	Ensino Superior Completo	11999999922	nome22.sobrenome22@28@email.com	M
222	12345678923	senha0023		Nome 23	Sobrenome 23	Ensino Superior Completo	11999999923	nome23.sobrenome23@23@email.com	F
223	12345678924	senha0024	Meu professor favorito	Nome 24	Sobrenome 24	Ensino Superior Completo	11999999924	nome24.sobrenome24@12@email.com	F
224	12345678925	senha0025		Nome 25	Sobrenome 25	Pós-Graduação	11999999925	nome25.sobrenome25@51@email.com	M
225	12345678926	senha0026		Nome 26	Sobrenome 26	Ensino Médio Completo	11999999926	nome26.sobrenome26@64@email.com	M
226	12345678927	senha0027	Nome do meu primeiro carro	Nome 27	Sobrenome 27	Ensino Médio Completo	11999999927	nome27.sobrenome27@43@email.com	F
227	12345678928	senha0028		Nome 28	Sobrenome 28	Ensino Superior Completo	11999999928	nome28.sobrenome28@86@email.com	F
228	12345678929	senha0029	Minha série favorita	Nome 29	Sobrenome 29	Ensino Superior Completo	11999999929	nome29.sobrenome29@58@email.com	F
229	12345678930	senha0030	Minha primeira escola	Nome 30	Sobrenome 30	Ensino Fundamental Completo	11999999930	nome30.sobrenome30@64@email.com	F
230	12345678931	senha0031	Meu professor favorito	Nome 31	Sobrenome 31	Pós-Graduação	11999999931	nome31.sobrenome31@28@email.com	M
231	12345678932	senha0032		Nome 32	Sobrenome 32	Ensino Médio Completo	11999999932	nome32.sobrenome32@26@email.com	F
232	12345678933	senha0033	Minha série favorita	Nome 33	Sobrenome 33	Pós-Graduação	11999999933	nome33.sobrenome33@25@email.com	F
233	12345678934	senha0034		Nome 34	Sobrenome 34	Ensino Médio Completo	11999999934	nome34.sobrenome34@84@email.com	M
234	12345678935	senha0035	Minha cor preferida	Nome 35	Sobrenome 35	Ensino Superior Completo	11999999935	nome35.sobrenome35@58@email.com	M
235	12345678936	senha0036		Nome 36	Sobrenome 36	Ensino Fundamental Completo	11999999936	nome36.sobrenome36@98@email.com	F
236	12345678937	senha0037		Nome 37	Sobrenome 37	Ensino Superior Completo	11999999937	nome37.sobrenome37@48@email.com	M
237	12345678938	senha0038	Minha cor preferida	Nome 38	Sobrenome 38	Ensino Médio Completo	11999999938	nome38.sobrenome38@66@email.com	F
238	12345678939	senha0039	Nome do meu primeiro carro	Nome 39	Sobrenome 39	Ensino Superior Completo	11999999939	nome39.sobrenome39@36@email.com	F
239	12345678940	senha0040		Nome 40	Sobrenome 40	Pós-Graduação	11999999940	nome40.sobrenome40@55@email.com	F
240	12345678941	senha0041		Nome 41	Sobrenome 41	Ensino Médio Completo	11999999941	nome41.sobrenome41@89@email.com	F
241	12345678942	senha0042		Nome 42	Sobrenome 42	Pós-Graduação	11999999942	nome42.sobrenome42@60@email.com	M
242	12345678943	senha0043	Minha série favorita	Nome 43	Sobrenome 43	Ensino Fundamental Completo	11999999943	nome43.sobrenome43@76@email.com	M
243	12345678944	senha0044	Minha comida favorita	Nome 44	Sobrenome 44	Ensino Médio Completo	11999999944	nome44.sobrenome44@20@email.com	F
244	12345678945	senha0045		Nome 45	Sobrenome 45	Ensino Superior Completo	11999999945	nome45.sobrenome45@18@email.com	M
245	12345678946	senha0046	Cidade natal	Nome 46	Sobrenome 46	Ensino Médio Completo	11999999946	nome46.sobrenome46@21@email.com	F
246	12345678947	senha0047		Nome 47	Sobrenome 47	Pós-Graduação	11999999947	nome47.sobrenome47@47@email.com	M
247	12345678948	senha0048		Nome 48	Sobrenome 48	Ensino Fundamental Completo	11999999948	nome48.sobrenome48@77@email.com	F
200	12345678901	senha0001	Minha cor preferida	Lucas Fernandes	Sobrenome 1	Pós-Graduação	11999999901	nome1.sobrenome1@64@email.com	F
248	12345678949	senha0049		Nome 49	Sobrenome 49	Ensino Fundamental Completo	11999999949	nome49.sobrenome49@89@email.com	M
249	12345678950	senha0050	Nome do meu primeiro carro	Nome 50	Sobrenome 50	Ensino Superior Completo	11999999950	nome50.sobrenome50@38@email.com	M
250	12345678951	senha0051		Nome 51	Sobrenome 51	Pós-Graduação	11999999951	nome51.sobrenome51@93@email.com	M
251	12345678952	senha0052		Nome 52	Sobrenome 52	Ensino Fundamental Completo	11999999952	nome52.sobrenome52@69@email.com	F
252	12345678953	senha0053		Nome 53	Sobrenome 53	Ensino Fundamental Completo	11999999953	nome53.sobrenome53@43@email.com	M
253	12345678954	senha0054		Nome 54	Sobrenome 54	Ensino Médio Completo	11999999954	nome54.sobrenome54@55@email.com	F
254	12345678955	senha0055	Nome do meu primeiro carro	Nome 55	Sobrenome 55	Ensino Médio Completo	11999999955	nome55.sobrenome55@67@email.com	F
255	12345678956	senha0056		Nome 56	Sobrenome 56	Ensino Superior Completo	11999999956	nome56.sobrenome56@52@email.com	F
256	12345678957	senha0057		Nome 57	Sobrenome 57	Pós-Graduação	11999999957	nome57.sobrenome57@79@email.com	M
257	12345678958	senha0058	Meu professor favorito	Nome 58	Sobrenome 58	Ensino Fundamental Completo	11999999958	nome58.sobrenome58@96@email.com	F
258	12345678959	senha0059		Nome 59	Sobrenome 59	Ensino Médio Completo	11999999959	nome59.sobrenome59@55@email.com	M
259	12345678960	senha0060		Nome 60	Sobrenome 60	Pós-Graduação	11999999960	nome60.sobrenome60@32@email.com	F
260	12345678961	senha0061	Minha primeira escola	Nome 61	Sobrenome 61	Ensino Fundamental Completo	11999999961	nome61.sobrenome61@91@email.com	F
261	12345678962	senha0062	Minha cor preferida	Nome 62	Sobrenome 62	Pós-Graduação	11999999962	nome62.sobrenome62@53@email.com	M
262	12345678963	senha0063	Nome do meu primeiro carro	Nome 63	Sobrenome 63	Ensino Superior Completo	11999999963	nome63.sobrenome63@90@email.com	M
263	12345678964	senha0064	Minha comida favorita	Nome 64	Sobrenome 64	Ensino Superior Completo	11999999964	nome64.sobrenome64@64@email.com	F
264	12345678965	senha0065	Minha série favorita	Nome 65	Sobrenome 65	Ensino Fundamental Completo	11999999965	nome65.sobrenome65@97@email.com	F
265	12345678966	senha0066		Nome 66	Sobrenome 66	Ensino Superior Completo	11999999966	nome66.sobrenome66@14@email.com	F
266	12345678967	senha0067		Nome 67	Sobrenome 67	Ensino Médio Completo	11999999967	nome67.sobrenome67@43@email.com	M
267	12345678968	senha0068		Nome 68	Sobrenome 68	Ensino Superior Completo	11999999968	nome68.sobrenome68@29@email.com	M
268	12345678969	senha0069		Nome 69	Sobrenome 69	Ensino Médio Completo	11999999969	nome69.sobrenome69@33@email.com	F
269	12345678970	senha0070	Meu animal de estimação	Nome 70	Sobrenome 70	Ensino Superior Completo	11999999970	nome70.sobrenome70@63@email.com	M
270	12345678971	senha0071		Nome 71	Sobrenome 71	Ensino Fundamental Completo	11999999971	nome71.sobrenome71@25@email.com	F
271	12345678972	senha0072		Nome 72	Sobrenome 72	Ensino Fundamental Completo	11999999972	nome72.sobrenome72@28@email.com	M
272	12345678973	senha0073	Minha primeira escola	Nome 73	Sobrenome 73	Ensino Superior Completo	11999999973	nome73.sobrenome73@98@email.com	M
273	12345678974	senha0074		Nome 74	Sobrenome 74	Ensino Médio Completo	11999999974	nome74.sobrenome74@27@email.com	M
274	12345678975	senha0075		Nome 75	Sobrenome 75	Ensino Médio Completo	11999999975	nome75.sobrenome75@81@email.com	M
275	12345678976	senha0076	Ano do meu nascimento	Nome 76	Sobrenome 76	Pós-Graduação	11999999976	nome76.sobrenome76@70@email.com	F
276	12345678977	senha0077	Ano do meu nascimento	Nome 77	Sobrenome 77	Ensino Superior Completo	11999999977	nome77.sobrenome77@22@email.com	F
277	12345678978	senha0078	Meu professor favorito	Nome 78	Sobrenome 78	Pós-Graduação	11999999978	nome78.sobrenome78@55@email.com	M
278	12345678979	senha0079	Nome do meu primeiro carro	Nome 79	Sobrenome 79	Ensino Médio Completo	11999999979	nome79.sobrenome79@88@email.com	F
279	12345678980	senha0080	Meu professor favorito	Nome 80	Sobrenome 80	Ensino Superior Completo	11999999980	nome80.sobrenome80@48@email.com	F
280	12345678981	senha0081	Meu professor favorito	Nome 81	Sobrenome 81	Ensino Fundamental Completo	11999999981	nome81.sobrenome81@54@email.com	M
281	12345678982	senha0082	Meu professor favorito	Nome 82	Sobrenome 82	Ensino Superior Completo	11999999982	nome82.sobrenome82@62@email.com	F
282	12345678983	senha0083		Nome 83	Sobrenome 83	Pós-Graduação	11999999983	nome83.sobrenome83@35@email.com	M
283	12345678984	senha0084	Meu professor favorito	Nome 84	Sobrenome 84	Ensino Médio Completo	11999999984	nome84.sobrenome84@78@email.com	M
284	12345678985	senha0085	Minha série favorita	Nome 85	Sobrenome 85	Pós-Graduação	11999999985	nome85.sobrenome85@31@email.com	M
285	12345678986	senha0086		Nome 86	Sobrenome 86	Ensino Médio Completo	11999999986	nome86.sobrenome86@98@email.com	M
286	12345678987	senha0087	Meu professor favorito	Nome 87	Sobrenome 87	Ensino Superior Completo	11999999987	nome87.sobrenome87@37@email.com	M
287	12345678988	senha0088	Ano do meu nascimento	Nome 88	Sobrenome 88	Ensino Fundamental Completo	11999999988	nome88.sobrenome88@17@email.com	M
288	12345678989	senha0089	Meu animal de estimação	Nome 89	Sobrenome 89	Ensino Fundamental Completo	11999999989	nome89.sobrenome89@66@email.com	F
289	12345678990	senha0090		Nome 90	Sobrenome 90	Ensino Superior Completo	11999999990	nome90.sobrenome90@11@email.com	M
290	12345678991	senha0091		Nome 91	Sobrenome 91	Pós-Graduação	11999999991	nome91.sobrenome91@72@email.com	M
291	12345678992	senha0092	Minha comida favorita	Nome 92	Sobrenome 92	Pós-Graduação	11999999992	nome92.sobrenome92@92@email.com	M
292	12345678993	senha0093	Minha comida favorita	Nome 93	Sobrenome 93	Ensino Superior Completo	11999999993	nome93.sobrenome93@53@email.com	M
293	12345678994	senha0094		Nome 94	Sobrenome 94	Ensino Médio Completo	11999999994	nome94.sobrenome94@34@email.com	F
294	12345678995	senha0095	Minha cor preferida	Nome 95	Sobrenome 95	Ensino Médio Completo	11999999995	nome95.sobrenome95@82@email.com	M
295	12345678996	senha0096		Nome 96	Sobrenome 96	Pós-Graduação	11999999996	nome96.sobrenome96@79@email.com	M
296	12345678997	senha0097		Nome 97	Sobrenome 97	Ensino Fundamental Completo	11999999997	nome97.sobrenome97@99@email.com	M
297	12345678998	senha0098	Minha primeira escola	Nome 98	Sobrenome 98	Pós-Graduação	11999999998	nome98.sobrenome98@47@email.com	F
298	12345678999	senha0099	Meu animal de estimação	Nome 99	Sobrenome 99	Ensino Médio Completo	11999999999	nome99.sobrenome99@42@email.com	F
212	12345678913	senha0013	PT	Nome 13	Sobrenome 13	Pós-Graduação	11999999913	nome13.sobrenome13@17@email.com	F
201	12345678902	senha0002		Mariana Silva	Sobrenome 2	Ensino Superior Completo	11999999902	nome2.sobrenome2@78@email.com	M
202	12345678903	senha0003	Minha cor preferida	João Almeida	Sobrenome 3	Ensino Superior Incompleto	11999999903	nome3.sobrenome3@68@email.com	M
203	12345678904	senha0004	Minha comida favorita	Ana Beatriz	Sobrenome 4	Ensino Fundamental Completo	11999999904	nome4.sobrenome4@89@email.com	M
204	12345678905	senha0005		Pedro Santos	Sobrenome 5	Ensino Superior Completo	11999999905	nome5.sobrenome5@31@email.com	F
205	12345678906	senha0006	Nome do meu primeiro carro	Juliana Costa	Sobrenome 6	Pós-Graduação	11999999906	nome6.sobrenome6@92@email.com	F
206	12345678907	senha0007		Fernando Rocha	Sobrenome 7	Ensino Superior Completo	11999999907	nome7.sobrenome7@82@email.com	F
207	12345678908	senha0008	Ano do meu nascimento	Larissa Oliveira	Sobrenome 8	Ensino Superior Completo	11999999908	nome8.sobrenome8@10@email.com	M
309	01234567891	senhaForte123	minha comida favorita	Fernanda Dias	Dias	Ensino Superior	31987654321	fernanda.dias@gmail.com	F
\.


--
-- Data for Name: tab_tipo_inscrito; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tab_tipo_inscrito (id_tipo, nome_tipo, permissao_submissao, limite_vaga) FROM stdin;
1	Graduação	t	100
2	Mestrado	t	50
3	Ouvinte	f	300
4	Doutorado	f	25
5	Pós-Doutorado	f	10
\.


--
-- Name: tab_atividade_id_atividade_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tab_atividade_id_atividade_seq', 26900, true);


--
-- Name: tab_autores_id_autor_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tab_autores_id_autor_seq', 99, true);


--
-- Name: tab_certificado_id_certificado_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tab_certificado_id_certificado_seq', 3125, true);


--
-- Name: tab_evento_id_evento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tab_evento_id_evento_seq', 10, true);


--
-- Name: tab_funcao_id_funcao_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tab_funcao_id_funcao_seq', 11, true);


--
-- Name: tab_inscrito_id_inscrito_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tab_inscrito_id_inscrito_seq', 2524, true);


--
-- Name: tab_local_id_local_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tab_local_id_local_seq', 4, true);


--
-- Name: tab_pagamento_id_pagamento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tab_pagamento_id_pagamento_seq', 1083, true);


--
-- Name: tab_pessoa_id_pessoa_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tab_pessoa_id_pessoa_seq', 309, true);


--
-- Name: tab_tipo_pessoa_id_tipo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tab_tipo_pessoa_id_tipo_seq', 5, true);


--
-- Name: tab_atividade pk_atividade; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_atividade
    ADD CONSTRAINT pk_atividade PRIMARY KEY (id_atividade);


--
-- Name: tab_certificado pk_certificado; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_certificado
    ADD CONSTRAINT pk_certificado PRIMARY KEY (id_certificado);


--
-- Name: tab_evento pk_evento; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_evento
    ADD CONSTRAINT pk_evento PRIMARY KEY (id_evento);


--
-- Name: tab_funcao pk_funcao; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_funcao
    ADD CONSTRAINT pk_funcao PRIMARY KEY (id_funcao);


--
-- Name: tab_inscrito pk_inscrito; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_inscrito
    ADD CONSTRAINT pk_inscrito PRIMARY KEY (id_inscrito);


--
-- Name: tab_local pk_local; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_local
    ADD CONSTRAINT pk_local PRIMARY KEY (id_local);


--
-- Name: tab_pagamento pk_pagamento; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_pagamento
    ADD CONSTRAINT pk_pagamento PRIMARY KEY (id_pagamento);


--
-- Name: tab_pessoa pk_pessoa; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_pessoa
    ADD CONSTRAINT pk_pessoa PRIMARY KEY (id_pessoa);


--
-- Name: tab_tipo_inscrito pk_tipo_inscrito; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_tipo_inscrito
    ADD CONSTRAINT pk_tipo_inscrito PRIMARY KEY (id_tipo);


--
-- Name: tab_atividade_autor tab_atividade_autor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_atividade_autor
    ADD CONSTRAINT tab_atividade_autor_pkey PRIMARY KEY (id_autor, id_atividade);


--
-- Name: tab_atividade_funcao_pessoa tab_atividade_funcao_pessoa_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_atividade_funcao_pessoa
    ADD CONSTRAINT tab_atividade_funcao_pessoa_pkey PRIMARY KEY (id_funcao, id_pessoa, id_atividade);


--
-- Name: tab_autores tab_autores_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_autores
    ADD CONSTRAINT tab_autores_pkey PRIMARY KEY (id_autor);


--
-- Name: tab_evento_funcao_pessoa tab_evento_funcao_pessoa_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_evento_funcao_pessoa
    ADD CONSTRAINT tab_evento_funcao_pessoa_pkey PRIMARY KEY (id_pessoa, id_evento, id_funcao);


--
-- Name: tab_pessoa tab_pessoa_cpf_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_pessoa
    ADD CONSTRAINT tab_pessoa_cpf_key UNIQUE (cpf);


--
-- Name: tab_pessoa tab_pessoa_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_pessoa
    ADD CONSTRAINT tab_pessoa_email_key UNIQUE (email);


--
-- Name: tab_certificado unico_certificado; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_certificado
    ADD CONSTRAINT unico_certificado UNIQUE (id_inscrito, id_atividade, id_evento);


--
-- Name: idx_cpf_pessoa; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_cpf_pessoa ON public.tab_pessoa USING btree (cpf);


--
-- Name: idx_id_certificado; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_id_certificado ON public.tab_certificado USING btree (id_certificado);


--
-- Name: idx_id_inscrito; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_id_inscrito ON public.tab_inscrito USING btree (id_inscrito);


--
-- Name: idx_id_pagamento; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_id_pagamento ON public.tab_pagamento USING btree (id_pagamento);


--
-- Name: idx_id_pessoa; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_id_pessoa ON public.tab_pessoa USING btree (id_pessoa);


--
-- Name: tab_pessoa monitor_sensitive_access; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER monitor_sensitive_access BEFORE DELETE OR UPDATE ON public.tab_pessoa FOR EACH ROW EXECUTE FUNCTION public.log_sensitive_access();


--
-- Name: tab_certificado fk_atividade; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_certificado
    ADD CONSTRAINT fk_atividade FOREIGN KEY (id_atividade) REFERENCES public.tab_atividade(id_atividade) ON DELETE CASCADE;


--
-- Name: tab_atividade fk_evento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_atividade
    ADD CONSTRAINT fk_evento FOREIGN KEY (id_evento) REFERENCES public.tab_evento(id_evento) ON DELETE CASCADE;


--
-- Name: tab_inscrito fk_evento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_inscrito
    ADD CONSTRAINT fk_evento FOREIGN KEY (id_evento) REFERENCES public.tab_evento(id_evento) ON DELETE CASCADE;


--
-- Name: tab_certificado fk_evento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_certificado
    ADD CONSTRAINT fk_evento FOREIGN KEY (id_evento) REFERENCES public.tab_evento(id_evento) ON DELETE CASCADE;


--
-- Name: tab_pagamento fk_inscrito; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_pagamento
    ADD CONSTRAINT fk_inscrito FOREIGN KEY (id_inscrito) REFERENCES public.tab_inscrito(id_inscrito) ON DELETE CASCADE;


--
-- Name: tab_atividade fk_inscrito; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_atividade
    ADD CONSTRAINT fk_inscrito FOREIGN KEY (id_inscrito) REFERENCES public.tab_inscrito(id_inscrito) ON DELETE CASCADE;


--
-- Name: tab_certificado fk_inscrito; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_certificado
    ADD CONSTRAINT fk_inscrito FOREIGN KEY (id_inscrito) REFERENCES public.tab_inscrito(id_inscrito) ON DELETE CASCADE;


--
-- Name: tab_evento fk_local; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_evento
    ADD CONSTRAINT fk_local FOREIGN KEY (id_local) REFERENCES public.tab_local(id_local) ON DELETE CASCADE;


--
-- Name: tab_inscrito fk_pessoa; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_inscrito
    ADD CONSTRAINT fk_pessoa FOREIGN KEY (id_pessoa) REFERENCES public.tab_pessoa(id_pessoa) ON DELETE CASCADE;


--
-- Name: tab_inscrito fk_tipo_inscrito; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_inscrito
    ADD CONSTRAINT fk_tipo_inscrito FOREIGN KEY (id_tipo) REFERENCES public.tab_tipo_inscrito(id_tipo) ON DELETE CASCADE;


--
-- Name: tab_atividade_autor tab_atividade_autor_id_atividade_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_atividade_autor
    ADD CONSTRAINT tab_atividade_autor_id_atividade_fkey FOREIGN KEY (id_atividade) REFERENCES public.tab_atividade(id_atividade) ON DELETE CASCADE;


--
-- Name: tab_atividade_autor tab_atividade_autor_id_autor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_atividade_autor
    ADD CONSTRAINT tab_atividade_autor_id_autor_fkey FOREIGN KEY (id_autor) REFERENCES public.tab_autores(id_autor) ON DELETE CASCADE;


--
-- Name: tab_atividade_funcao_pessoa tab_atividade_funcao_pessoa_id_atividade_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_atividade_funcao_pessoa
    ADD CONSTRAINT tab_atividade_funcao_pessoa_id_atividade_fkey FOREIGN KEY (id_atividade) REFERENCES public.tab_atividade(id_atividade) ON DELETE CASCADE;


--
-- Name: tab_atividade_funcao_pessoa tab_atividade_funcao_pessoa_id_funcao_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_atividade_funcao_pessoa
    ADD CONSTRAINT tab_atividade_funcao_pessoa_id_funcao_fkey FOREIGN KEY (id_funcao) REFERENCES public.tab_funcao(id_funcao) ON DELETE CASCADE;


--
-- Name: tab_atividade_funcao_pessoa tab_atividade_funcao_pessoa_id_pessoa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_atividade_funcao_pessoa
    ADD CONSTRAINT tab_atividade_funcao_pessoa_id_pessoa_fkey FOREIGN KEY (id_pessoa) REFERENCES public.tab_pessoa(id_pessoa) ON DELETE CASCADE;


--
-- Name: tab_autores tab_autores_id_pessoa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_autores
    ADD CONSTRAINT tab_autores_id_pessoa_fkey FOREIGN KEY (id_pessoa) REFERENCES public.tab_pessoa(id_pessoa) ON DELETE CASCADE;


--
-- Name: tab_evento_funcao_pessoa tab_evento_funcao_pessoa_id_evento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_evento_funcao_pessoa
    ADD CONSTRAINT tab_evento_funcao_pessoa_id_evento_fkey FOREIGN KEY (id_evento) REFERENCES public.tab_evento(id_evento);


--
-- Name: tab_evento_funcao_pessoa tab_evento_funcao_pessoa_id_funcao_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_evento_funcao_pessoa
    ADD CONSTRAINT tab_evento_funcao_pessoa_id_funcao_fkey FOREIGN KEY (id_funcao) REFERENCES public.tab_funcao(id_funcao);


--
-- Name: tab_evento_funcao_pessoa tab_evento_funcao_pessoa_id_pessoa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tab_evento_funcao_pessoa
    ADD CONSTRAINT tab_evento_funcao_pessoa_id_pessoa_fkey FOREIGN KEY (id_pessoa) REFERENCES public.tab_pessoa(id_pessoa);


--
-- Name: tab_certificado admin_policy_certificado; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY admin_policy_certificado ON public.tab_certificado TO admin USING (true);


--
-- Name: tab_pessoa; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.tab_pessoa ENABLE ROW LEVEL SECURITY;

--
-- Name: PROCEDURE adicionarfuncao(IN p_nome_funcao character varying, IN p_horas integer, IN p_area character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.adicionarfuncao(IN p_nome_funcao character varying, IN p_horas integer, IN p_area character varying) TO admin;
GRANT ALL ON PROCEDURE public.adicionarfuncao(IN p_nome_funcao character varying, IN p_horas integer, IN p_area character varying) TO inscrito;


--
-- Name: PROCEDURE adicionarpessoa(IN p_cpf character varying, IN p_senha character varying, IN p_dica_senha character varying, IN p_nome_sobrenome character varying, IN p_ultimo_nome character varying, IN p_escolaridade character varying, IN p_telefone character varying, IN p_email character varying, IN p_sexo character); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.adicionarpessoa(IN p_cpf character varying, IN p_senha character varying, IN p_dica_senha character varying, IN p_nome_sobrenome character varying, IN p_ultimo_nome character varying, IN p_escolaridade character varying, IN p_telefone character varying, IN p_email character varying, IN p_sexo character) TO admin;
GRANT ALL ON PROCEDURE public.adicionarpessoa(IN p_cpf character varying, IN p_senha character varying, IN p_dica_senha character varying, IN p_nome_sobrenome character varying, IN p_ultimo_nome character varying, IN p_escolaridade character varying, IN p_telefone character varying, IN p_email character varying, IN p_sexo character) TO inscrito;


--
-- Name: TABLE tab_evento; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.tab_evento TO admin;
GRANT SELECT ON TABLE public.tab_evento TO auditor;
GRANT SELECT ON TABLE public.tab_evento TO inscrito;


--
-- Name: TABLE tab_evento_funcao_pessoa; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.tab_evento_funcao_pessoa TO admin;
GRANT SELECT ON TABLE public.tab_evento_funcao_pessoa TO auditor;


--
-- Name: TABLE tab_funcao; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.tab_funcao TO admin;
GRANT SELECT ON TABLE public.tab_funcao TO auditor;


--
-- Name: TABLE tab_pessoa; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.tab_pessoa TO admin;


--
-- Name: TABLE evento_pessoa_funcao; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.evento_pessoa_funcao TO auditor;
GRANT SELECT ON TABLE public.evento_pessoa_funcao TO admin;


--
-- Name: TABLE tab_inscrito; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.tab_inscrito TO admin;
GRANT SELECT ON TABLE public.tab_inscrito TO auditor;


--
-- Name: TABLE tab_pagamento; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.tab_pagamento TO admin;
GRANT SELECT ON TABLE public.tab_pagamento TO auditor;


--
-- Name: TABLE nome_cpf_valor_evento; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.nome_cpf_valor_evento TO inscrito;
GRANT SELECT ON TABLE public.nome_cpf_valor_evento TO auditor;
GRANT SELECT ON TABLE public.nome_cpf_valor_evento TO admin;


--
-- Name: TABLE tab_atividade; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.tab_atividade TO admin;
GRANT SELECT ON TABLE public.tab_atividade TO auditor;
GRANT SELECT ON TABLE public.tab_atividade TO inscrito;


--
-- Name: TABLE tab_atividade_autor; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.tab_atividade_autor TO admin;
GRANT SELECT ON TABLE public.tab_atividade_autor TO auditor;


--
-- Name: TABLE tab_atividade_funcao_pessoa; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.tab_atividade_funcao_pessoa TO admin;
GRANT SELECT ON TABLE public.tab_atividade_funcao_pessoa TO auditor;


--
-- Name: TABLE tab_autores; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.tab_autores TO admin;
GRANT SELECT ON TABLE public.tab_autores TO auditor;


--
-- Name: TABLE tab_certificado; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.tab_certificado TO admin;
GRANT SELECT ON TABLE public.tab_certificado TO auditor;
GRANT SELECT ON TABLE public.tab_certificado TO inscrito;


--
-- Name: TABLE tab_local; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.tab_local TO admin;
GRANT SELECT ON TABLE public.tab_local TO auditor;
GRANT SELECT ON TABLE public.tab_local TO inscrito;


--
-- Name: TABLE tab_pessoa_masked; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tab_pessoa_masked TO auditor;
GRANT SELECT ON TABLE public.tab_pessoa_masked TO inscrito;


--
-- Name: TABLE tab_tipo_inscrito; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.tab_tipo_inscrito TO admin;
GRANT SELECT ON TABLE public.tab_tipo_inscrito TO auditor;
GRANT SELECT ON TABLE public.tab_tipo_inscrito TO inscrito;


--
-- Name: evento_pessoa_funcao; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.evento_pessoa_funcao;


--
-- Name: nome_cpf_valor_evento; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.nome_cpf_valor_evento;


--
-- Name: tab_pessoa_masked; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.tab_pessoa_masked;


--
-- PostgreSQL database dump complete
--

