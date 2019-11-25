-- Relação de entregas que chegaram atrasadas
SELECT FO.razao_social, PE.num_pedido, (PE.data_prevista_entrega - PE.data_pedido) AS entrega_prevista_dias, (PE.data_entrega_efetuada - PE.data_pedido) AS entrega_realizada, (PE.data_entrega_efetuada - PE.data_prevista_entrega) AS dias_de_atraso, PE.devolvido
FROM pedido PE INNER JOIN fornecedor FO ON FO.cnpj = PE.cod_fornecedor
WHERE PE.data_entrega_efetuada > PE.data_prevista_entrega

-- A consulta para o fornecedor mais barato de certo produto. Aqui a consulta é representada com um nome genérico que poderia ser preenchido dinamicamente pelo frontend
SELECT FO.razao_social, FO.pessoa_contato, FO.num_cad, FO.email, FP.valor, PR.preco_venda
FROM produto PR, fornecedor_produto FP, fornecedor FO
WHERE PR.descricao = 'Condicionador Pantene Brilho Extremo 175ml'
	AND FP.num_prod = PR.num_produto AND FO.cnpj = FP.cod_fornecedor
	AND FP.valor = (SELECT MIN(valor)
				   	FROM fornecedor_produto FP INNER JOIN produto PR ON PR.num_produto = FP.num_prod
				   	WHERE PR.descricao = 'Condicionador Pantene Brilho Extremo 175ml')

-- Consulta produtos com estoque baixo em ordem crescente para realização de pedidos, exibindo os fornecedores o valor de compra e o valor de venda no hipermercado.
SELECT PR.descricao AS produto, PR.qtd_estoque, FO.razao_social AS Fornecedor, FP.valor, PR.preco_venda
FROM produto PR FULL OUTER JOIN fornecedor_produto FP ON FP.num_prod = PR.num_produto, fornecedor FO
WHERE PR.qtd_estoque < 40 AND FO.cnpj = FP.cod_fornecedor
ORDER BY PR.qtd_estoque, PR.descricao, FP.valor

-- Calcular a folha de pagamentos por funcao, área e total
SELECT cpf, funcao, SUM(salario) 
FROM colaborador
GROUP BY ROLLUP(funcao, cpf)
ORDER BY funcao

-- Calcula o total comprado de um fornecedor
SELECT FO.razao_social, PE.num_pedido, ROUND(SUM((PP.quantidade*FP.valor)*(1-(PE.desconto/100))),2) AS valor
FROM fornecedor FO, pedido PE, produtos_pedido PP, fornecedor_produto FP
WHERE FO.razao_social = 'Spathiflorae Pelew' AND PE.devolvido = false
	AND FO.cnpj = PE.cod_fornecedor
	AND PP.num_pedido = PE.num_pedido
	AND FP.cod_fornecedor = FO.cnpj AND FP.num_prod = PP.num_prod
GROUP BY PE.num_pedido, FO.razao_social

-- Desconto para clientes ouro em produtos de promoções realizadas no mês de fevereiro de 2019
SELECT PO.id AS Promocao_id, PO.descricao AS Promocao, PR.num_produto, PR.descricao AS Produto, PP.desconto_cliente_ouro AS desconto_ouro_percentual
FROM promocao PO, produto PR, produtos_promocao PP
WHERE PO.data_inicio BETWEEN '2019-02-01' AND '2019-02-28'
	AND PP.num_prod = PR.num_produto
	AND PO.id = PP.id_promocao

-- Total em compras realizadas por certo cliente nos ultimos 365 dias, ou seja, ultimo ano por cliente
SELECT CL.nome, SUM(CC.valor_com_desconto) AS total_ultimo_ano, COUNT(CC.num_cupom_fiscal) AS numero_compras
FROM carrinho_compra CC, cliente CL
WHERE CL.nome LIKE 'Reyes Ra%' AND CC.cliente = CL.cpf
	AND CC.data_compra BETWEEN (CURRENT_DATE-365) AND CURRENT_DATE
GROUP BY CL.nome

--Selecionar clientes que gastaram menos que Celinda.
SELECT CLI.nome, SUM(CC.valor_total)
FROM cliente CLI, carrinho_compra CC
WHERE CC.cliente = CLI.cpf
	AND CC.valor_total < (	SELECT SUM(CC.valor_total)
							FROM cliente CLI, carrinho_compra CC
							WHERE CLI.nome LIKE 'Celinda%' AND CC.cliente = CLI.cpf
							GROUP BY CLI.nome
						)
GROUP BY CLI.nome

-- Exibe os clientes que fazem aniversário no mês seguinte e seus endereços de correspondência
SELECT CL.nome, CL.data_nascimento, EC.logradouro, EC.numero, EC.complemento, EC.bairro, EC.cidade, EC.estado, EC.cep
FROM cliente CL FULL OUTER JOIN enderecos_cliente EC ON EC.cod_cliente = CL.cpf
WHERE EXTRACT(MONTH FROM CL.data_nascimento) = EXTRACT(MONTH FROM CURRENT_DATE+30)
ORDER BY CL.nome

-- Selecionar os repositores de cada seção
SELECT SE.nome, RE.nome
FROM  responsabilidade_repositor RR, secao SE, repositor RE
WHERE RR.secao = SE.cod_secao AND 
      RR.colaborador = RE.colaborador

