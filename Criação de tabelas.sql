CREATE SCHEMA trabalhobd;
SET search_path TO trabalhobd;

CREATE TABLE categoria(
	cod_cat integer PRIMARY KEY,
	descricao text
);

CREATE TABLE secao(
	cod_secao varchar(5) PRIMARY KEY,
	nome varchar(200)
);

CREATE TABLE fabricante(
	cnpj varchar(14) PRIMARY KEY,
	nome varchar(50) NOT NULL,
	razao_social varchar(100) NOT NULL,
	email varchar(50),
	logradouro varchar(100),
	numero integer,
	complemento varchar(50),
	bairro varchar(50),
	cidade varchar(50),
	estado varchar(2),
	cep  varchar(9)
);

CREATE TABLE produto (
	num_produto integer PRIMARY KEY,
	descricao varchar(200), 
	fabricante varchar(14),
	unidade_venda varchar(2),
	imagem text NOT NULL, -- salvar em base64
	categoria integer NOT NULL,
	preco_venda numeric(7,2) NOT NULL,
	qtd_estoque integer NOT NULL,
	secao varchar(5) NOT NULL,
	CONSTRAINT categoriaFK FOREIGN KEY (categoria) REFERENCES categoria ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT secaoFK FOREIGN KEY (secao) REFERENCES secao ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fabricanteFK FOREIGN KEY (fabricante) REFERENCES fabricante ON UPDATE CASCADE ON DELETE NO ACTION
);

CREATE TABLE relacao_categorias(
	cod_cat_superior integer NOT NULL,
	cod_cat_inferior integer NOT NULL,
	CONSTRAINT relacao_categorias_PK PRIMARY KEY (cod_cat_superior, cod_cat_inferior),
	CONSTRAINT cod_cat_superior_fk FOREIGN KEY (cod_cat_superior) REFERENCES categoria ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT cod_cat_inferior_FK FOREIGN KEY (cod_cat_inferior) REFERENCES categoria ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE fornecedor (
	cnpj varchar(14) PRIMARY KEY,
	razao_social varchar(100) NOT NULL,
	num_cad integer NOT NULL,
	logradouro varchar(100),
	numero integer,
	complemento varchar(50),
	bairro varchar(50),
	cidade varchar(50),
	estado varchar(2),
	cep  varchar(9),
	email varchar(100),
	pessoa_contato varchar(100) NOT NULL
);

CREATE TABLE telefones_fornecedor(
	fornecedor varchar(14) NOT NULL,
	telefone varchar(11) NOT NULL,
	CONSTRAINT numero_incompleto CHECK (LENGTH(telefone) = 11),
	CONSTRAINT telefones_fornecedor_pk PRIMARY KEY (fornecedor, telefone),
	CONSTRAINT fornecedor_fk FOREIGN KEY (fornecedor) REFERENCES fornecedor ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE fornecedor_produto(
	num_prod integer NOT NULL,
	cod_fornecedor varchar(14) NOT NULL,
	valor numeric(7,2) NOT NULL,
	CONSTRAINT valor_min CHECK (valor > 0),
	CONSTRAINT fornecedor_produto_pk PRIMARY KEY (num_prod, cod_fornecedor),
	CONSTRAINT fornecedor_fk FOREIGN KEY (cod_fornecedor) REFERENCES fornecedor ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT produto_fk FOREIGN KEY (num_prod) REFERENCES produto ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE promocao(
	id integer PRIMARY KEY,
	data_inicio date NOT NULL DEFAULT CURRENT_DATE,
	data_fim date,
	nome varchar(100) NOT NULL,
	descricao text NOT NULL
);

CREATE TABLE produtos_promocao(
	id_promocao integer NOT NULL,
	num_prod integer NOT NULL,
	-- descontos percentuais
	desconto_cliente_comum numeric(4,2) NOT NULL,
	desconto_cliente_diamante numeric(4,2) NOT NULL,
	desconto_cliente_ouro numeric(4,2) NOT NULL,
	desconto_cliente_prata numeric(4,2) NOT NULL,
	CONSTRAINT desconto_negativo CHECK (desconto_cliente_comum > 0 AND desconto_cliente_diamante > 0 AND desconto_cliente_ouro > 0 AND desconto_cliente_prata > 0),
	CONSTRAINT produto_fk FOREIGN KEY (num_prod) REFERENCES produto ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT promocao_fk FOREIGN KEY (id_promocao) REFERENCES promocao ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT produtos_promocao_pk PRIMARY KEY (id_promocao, num_prod)
);

CREATE TABLE categoria_cliente(
	nome varchar(50) PRIMARY KEY,
	gasto_anual_minimo numeric(7,2)
);

CREATE TABLE cliente(
	cpf varchar(11) PRIMARY KEY,
	nome varchar(100) NOT NULL,
	data_nascimento date,
	profissao varchar(50),
	categoria varchar(50) DEFAULT 'COMUM' NOT NULL,
	CONSTRAINT categoria_fk FOREIGN KEY (categoria) REFERENCES categoria_cliente ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE enderecos_cliente(
	cod_cliente varchar(11) NOT NULL,
	logradouro varchar(100),
	numero integer NOT NULL,
	complemento varchar(50) NOT NULL,
	bairro varchar(50),
	cidade varchar(50),
	estado varchar(2),
	cep varchar(9) NOT NULL,
	CONSTRAINT enderecos_cliente_pk PRIMARY KEY (cod_cliente, numero, complemento, cep),
	CONSTRAINT cod_cliente_FK FOREIGN KEY (cod_cliente) REFERENCES cliente ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE telefones_cliente(
	cod_cliente varchar(11) NOT NULL,
	numero varchar(11) NOT NULL,
	CONSTRAINT numero_incompleto CHECK (LENGTH(numero) = 11),
	CONSTRAINT cliente_fk FOREIGN KEY (cod_cliente) REFERENCES cliente ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT telefones_cliente_PK PRIMARY KEY (cod_cliente, numero)
);

CREATE TABLE colaborador(
	cpf varchar(11) PRIMARY KEY,
	salario numeric(7,2) NOT NULL,
	valor_hr_extra numeric(7,2),
	jornada integer NOT NULL,
	funcao varchar(100) NOT NULL,
	gerente varchar(11)
);

CREATE TABLE gerente(
	colaborador varchar(11) PRIMARY KEY,
	nome varchar(100) NOT NULL,
	logradouro varchar(100) NOT NULL,
	numero integer NOT NULL,
	complemento varchar(20),
	bairro varchar(50) NOT NULL,
	cep varchar(9) NOT NULL,
	telefone varchar(11) NOT NULL,
	data_nasc date NOT NULL,
	escolaridade varchar(100) NOT NULL,
	estado_civil varchar(50) NOT NULL,
	data_ingresso date NOT NULL DEFAULT CURRENT_DATE,
	formacao_gerencia boolean,
	CONSTRAINT colaborador_FK FOREIGN KEY (colaborador) REFERENCES colaborador ON DELETE CASCADE ON UPDATE CASCADE
);
ALTER TABLE colaborador ADD CONSTRAINT gerente_FK FOREIGN KEY (gerente) REFERENCES gerente ON DELETE NO ACTION ON UPDATE CASCADE;

CREATE TABLE pedido(
	num_pedido integer PRIMARY KEY,
	data_pedido date NOT NULL DEFAULT CURRENT_DATE,
	data_prevista_entrega date NOT NULL,
	data_entrega_efetuada date,
	cod_fornecedor varchar(14) NOT NULL,
	condicao_pagamento varchar(200) NOT NULL,
	desconto numeric(4,2) NOT NULL,
	devolvido boolean,
	gerente_responsavel VARCHAR(100) NOT NULL,
	CONSTRAINT fornecedor_fk FOREIGN KEY (cod_fornecedor) REFERENCES fornecedor ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT gerente_fk FOREIGN KEY (gerente_responsavel) REFERENCES gerente ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE produtos_pedido(
	num_pedido integer NOT NULL,
	num_prod integer NOT NULL,
	quantidade integer NOT NULL,
	CONSTRAINT pedido_fk FOREIGN KEY (num_pedido) REFERENCES pedido ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT prod_fk FOREIGN KEY (num_prod) REFERENCES produto ON DELETE NO ACTION ON UPDATE CASCADE,
	CONSTRAINT produtos_pedido_pk PRIMARY KEY (num_pedido, num_prod),
	CONSTRAINT quantidade_min CHECK (quantidade > 0)
);

CREATE TABLE atendente(
	colaborador varchar(11) PRIMARY KEY,
	nome varchar(100) NOT NULL,
	logradouro varchar(100) NOT NULL,
	numero integer NOT NULL,
	complemento varchar(20),
	bairro varchar(50) NOT NULL,
	cep varchar(9) NOT NULL,
	telefone varchar(11) NOT NULL,
	data_nasc date NOT NULL,
	escolaridade varchar(100) NOT NULL,
	estado_civil varchar(50) NOT NULL,
	padaria boolean,
	caixa boolean,
	CONSTRAINT apenas_uma_area CHECK (NOT(padaria = True AND caixa = True)),
	CONSTRAINT nenhuma_area CHECK (padaria = False OR caixa = False),
	CONSTRAINT colaborador_FK FOREIGN KEY (colaborador) REFERENCES colaborador ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE repositor(
	colaborador varchar(11) PRIMARY KEY,
	nome varchar(100) NOT NULL,
	logradouro varchar(100) NOT NULL,
	numero integer NOT NULL,
	complemento varchar(20),
	bairro varchar(50) NOT NULL,
	cep varchar(9) NOT NULL,
	telefone varchar(11) NOT NULL,
	data_nasc date NOT NULL,
	escolaridade varchar(100) NOT NULL,
	estado_civil varchar(50) NOT NULL,
	CONSTRAINT colaborador_FK FOREIGN KEY (colaborador) REFERENCES colaborador ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE vigia(
	colaborador varchar(11) PRIMARY KEY,
	nome varchar(100) NOT NULL,
	curso_seguranca boolean NOT NULL,
	logradouro varchar(100) NOT NULL,
	numero integer NOT NULL,
	complemento varchar(20),
	bairro varchar(50) NOT NULL,
	cep varchar(9) NOT NULL,
	telefone varchar(11) NOT NULL,
	data_nasc date NOT NULL,
	escolaridade varchar(100) NOT NULL,
	estado_civil varchar(50) NOT NULL,
	CONSTRAINT colaborador_FK FOREIGN KEY (colaborador) REFERENCES colaborador ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE responsabilidade_repositor(
	colaborador varchar(11) NOT NULL,
	secao varchar(5) NOT NULL,
	CONSTRAINT responsabilidade_repositor_pk PRIMARY KEY (colaborador, secao),
	CONSTRAINT colaborador_FK FOREIGN KEY (colaborador) REFERENCES repositor ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT secao_FK FOREIGN KEY (secao) REFERENCES secao ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE carrinho_compra(
	num_cupom_fiscal varchar(50) PRIMARY KEY,
	cliente varchar(11) NOT NULL,
	operador varchar(11) NOT NULL,
	data_compra date NOT NULL DEFAULT CURRENT_DATE,
	horario time NOT NULL DEFAULT CURRENT_TIME,
	valor_total numeric(7,2) NOT NULL,
	valor_com_desconto numeric(7,2) NOT NULL,
	forma_pagamento varchar(50),
	CONSTRAINT valor_final CHECK (valor_com_desconto >= 0),
	CONSTRAINT cliente_FK FOREIGN KEY (cliente) REFERENCES cliente ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT operador_fk FOREIGN KEY (operador) REFERENCES atendente ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE produtos_Carrinho(
	num_cupom_fiscal varchar(50) NOT NULL,
	produto integer NOT NULL,
	quantidade integer NOT NULL,
	CONSTRAINT quantidade CHECK (quantidade > 0),
	CONSTRAINT produtos_carrinho_pk PRIMARY KEY (num_cupom_fiscal, produto),
	CONSTRAINT num_cupom_fiscal_FK FOREIGN KEY (num_cupom_fiscal) REFERENCES carrinho_compra ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT produto_fk FOREIGN KEY (produto) REFERENCES produto ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE produto_auditoria (
	id serial PRIMARY KEY,
	preco_novo numeric(7,2) NOT NULL,
	preco_antigo numeric(7,2) NOT NULL,
	data_modificacao date NOT NULL,
	produto_id integer NOT NULL,
	usuario varchar(100) NOT NULL,
	CONSTRAINT fk_produto_id FOREIGN KEY (produto_id) REFERENCES produto ON UPDATE CASCADE ON DELETE NO ACTION
);