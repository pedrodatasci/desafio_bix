-- TABELAS PARA CRIAR
CREATE TABLE IF NOT EXISTS silver.categoria (
    id BIGINT NOT NULL,
    nome_categoria VARCHAR(100),
    PRIMARY KEY (id)
)
DISTSTYLE ALL
SORTKEY (id);

CREATE TABLE IF NOT EXISTS silver.funcionario (
    id BIGINT NOT NULL,
    nome VARCHAR(100),
    PRIMARY KEY (id)
)
DISTSTYLE ALL
SORTKEY (id);

CREATE TABLE IF NOT EXISTS silver.venda (
    id_venda INT NOT NULL,
    id_funcionario INT NOT NULL,
    id_categoria INT NOT NULL,
    data_venda DATE,
    venda DOUBLE PRECISION,
    PRIMARY KEY (id_venda)
)
DISTSTYLE KEY
DISTKEY (id_funcionario)
SORTKEY (id_categoria, id_funcionario);

-- GRANT PARA LAMBDA DE COPY FUNCIONAR
GRANT USAGE ON SCHEMA silver TO "IAMR:lambda-redshift-exec-role";
GRANT ALL ON ALL TABLES IN SCHEMA silver TO "IAMR:lambda-redshift-exec-role";