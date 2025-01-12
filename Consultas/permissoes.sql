-- Criando os usuários no PostgreSQL
CREATE USER ADM WITH PASSWORD 'SenhaADM123';
CREATE USER Responsavel WITH PASSWORD 'SenhaResponsavel123';
CREATE USER Usuario WITH PASSWORD 'SenhaUsuario123';

-- Concedendo permissões ao ADM (acesso total a todas as tabelas)
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ADM;

-- Concedendo permissões ao Responsavel (acesso a todas as tabelas, exceto TAB_PAGAMENTO)
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO Responsavel;
REVOKE ALL PRIVILEGES ON TABLE public.TAB_PAGAMENTO FROM Responsavel;

-- Concedendo permissões ao Usuario (apenas visualização de TAB_USUARIO e TAB_ATIVIDADE)
GRANT SELECT ON public.TAB_USUARIO TO Usuario;
GRANT SELECT ON public.TAB_ATIVIDADE TO Usuario;

-- Garantindo que os privilégios futuros sejam automaticamente atribuídos (opcional)
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO ADM;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO Usuario;
