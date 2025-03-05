-- 1. Listar usuários com aniversário hoje e mais de 1500 vendas em janeiro de 2020
SELECT 
 c.customer_id
,c.first_name
,c.last_name
,COUNT(o.order_id) AS total_sales

	FROM Customer c
	JOIN `Order` o ON c.customer_id = o.customer_id

		WHERE EXTRACT(MONTH FROM c.birth_date) = EXTRACT(MONTH FROM CURRENT_DATE)
		AND EXTRACT(DAY FROM c.birth_date) = EXTRACT(DAY FROM CURRENT_DATE)
		AND EXTRACT(YEAR FROM o.order_date) = 2020
		AND EXTRACT(MONTH FROM o.order_date) = 1
GROUP BY c.customer_id
		,c.first_name
		,c.last_name
HAVING COUNT(o.order_id) > 1500;

-- 2. Para cada mês de 2020, listar os 5 principais vendedores de Celulares
WITH MonthlySales AS (
    SELECT 
	 c.first_name
	,c.last_name
	,EXTRACT(MONTH FROM o.order_date) AS sale_month
	,EXTRACT(YEAR FROM o.order_date) AS sale_year
	,COUNT(o.order_id) AS total_orders
	,SUM(o.quantity) AS total_products
	,SUM(o.total_price) AS total_value
	,RANK() OVER (PARTITION BY EXTRACT(MONTH FROM o.order_date) ORDER BY SUM(o.total_price) DESC) AS rank
    
		FROM `Order` o
		JOIN Item i ON o.item_id = i.item_id
		JOIN Category cat ON i.category_id = cat.category_id
		JOIN Customer c ON i.seller_id = c.customer_id
			WHERE cat.category_name = 'Celulares' AND EXTRACT(YEAR FROM o.order_date) = 2020
    GROUP BY c.first_name
			,c.last_name
			,sale_month
			,sale_year
)
SELECT * FROM MonthlySales WHERE rank <= 5;

-- 3. Stored Procedure para capturar o status e preço mais recente dos itens no final do dia
DELIMITER //

CREATE PROCEDURE UpdateItemStatusHistory()
BEGIN
    -- Atualiza o end_date do último registro apenas para os itens que tiveram alteração
    UPDATE Item_History ih
    JOIN Item i ON ih.item_id = i.item_id
    SET ih.end_date = CURDATE() - INTERVAL 1 DAY
    WHERE ih.end_date = '2100-12-31'
    AND (i.price <> ih.price OR i.status <> ih.status);

    -- Insere um novo registro apenas para os itens que tiveram alteração
    INSERT INTO Item_History (item_id, price, status, start_date, end_date)
    SELECT i.item_id, i.price, i.status, CURDATE(), '2100-12-31'
    FROM Item i
    LEFT JOIN Item_History ih ON i.item_id = ih.item_id
    WHERE ih.end_date = CURDATE() - INTERVAL 1 DAY
    AND (i.price <> ih.price OR i.status <> ih.status);

END //

DELIMITER ;
