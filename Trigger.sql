CREATE OR REPLACE FUNCTION produto_log()
	RETURNS trigger AS $produto_trigger$
	BEGIN
	IF (new.preco_venda <> old.preco_venda) THEN
		INSERT INTO produto_auditoria
		(preco_novo, preco_antigo, data_modificacao, produto_id, usuario)
		VALUES
		(new.preco_venda, old.preco_venda, current_timestamp, old.num_produto, current_user);
		RETURN NEW;
	END IF;
	RETURN NULL;
	END;
	$produto_trigger$
LANGUAGE 'plpgsql';

CREATE TRIGGER produto_auditoria
BEFORE UPDATE 
ON produto
FOR EACH ROW
EXECUTE PROCEDURE produto_log();