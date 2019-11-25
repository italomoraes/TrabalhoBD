CREATE OR REPLACE FUNCTION compras_por_mes
	(IN P_MES INTEGER)
RETURNS TABLE (cliente VARCHAR, valor NUMERIC, ano INTEGER) AS $$
DECLARE var_r record;
BEGIN
	FOR var_r IN(
	   	SELECT CL.nome, SUM(CC.valor_com_desconto) AS total_comprado, EXTRACT(YEAR FROM CC.data_compra) AS ano
		FROM cliente CL, carrinho_compra CC
		WHERE EXTRACT(MONTH FROM CC.data_compra) = P_MES AND CL.cpf = CC.cliente
		GROUP BY CL.nome, CC.data_compra
		ORDER BY CC.data_compra
	)
	LOOP
		cliente := var_r.nome; 
		valor := var_r.total_comprado;
		ano := var_r.ano;
		RETURN NEXT;
	END LOOP;
END; $$ 
LANGUAGE 'plpgsql';

SELECT * FROM compras_por_mes('11');