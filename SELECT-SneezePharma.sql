USE SneezePharma
GO

SELECT * FROM Suppliers;

SELECT * FROM RestrictedSuppliers;

SELECT * FROM Customers;

SELECT * FROM RestrictedCustomers;

SELECT * FROM Categorias;

SELECT * FROM CategoriaMedicines;

SELECT * FROM Ingredients;

SELECT * FROM Purchases;

SELECT * FROM PurchaseItems;

SELECT * FROM PurchaseAndItems;

SELECT * FROM Produces;

SELECT * FROM ProduceItems;

SELECT * FROM Medicines;

SELECT * FROM Sales;

SELECT * FROM SaleItems;

SELECT * FROM SaleAndItems;


--Medicamentos com categoria
SELECT m.Nome, c.Nome
FROM CategoriaMedicines cm
INNER JOIN Categorias c ON cm.idCategoria = c.idCategoria
INNER JOIN Medicines m ON cm.idMedicine = m.idMedicine;

--ingredientes usados na produção

SELECT m.Nome, i.Nome, pit.QuantidadePrincipio
FROM ProduceItems pit
INNER JOIN Produces p ON pit.idProduce = p.idProduce
INNER JOIN Medicines m ON p.idMedicine = m.idMedicine
INNER JOIN Ingredients i ON pit.idIngredient = i.idIngredient;

--compras + fornecedores

SELECT s.RazaoSocial, i.Nome, p.DataCompra, pit.Quantidade
FROM Purchases p
INNER JOIN Suppliers s ON p.idSupplier = s.idSupplier
INNER JOIN PurchaseAndItems pai ON p.idPurchase = pai.idPurchase
INNER JOIN PurchaseItems pit ON pai.idPurchaseItem = pit.idPurchaseItem
INNER JOIN Ingredients i ON pit.idIngredient = i.idIngredient;



-- vendas + cliente


SELECT c.Nome, m.Nome, si.ValorUnitario, si.Quantidade, si.TotalItem
FROM Sales s
INNER JOIN Customers c ON s.idCustomer = c.idCustomer
INNER JOIN SaleItems si ON s.idSale = si.idSale
INNER JOIN Medicines m ON si.idMedicine = m.idMedicine;

-- Relatório de vendas por período
SELECT c.CPF, c.Nome, s.DataVenda, m.Nome, si.Quantidade, si.ValorUnitario, s.ValorTotal
FROM Sales s
JOIN Customers c
ON s.idCustomer = c.idCustomer
JOIN SaleAndItems sai
ON s.idSale = sai.idSale
JOIN SaleItems si
ON sai.idSaleItem = si.idSaleItem
JOIN Medicines m
ON si.idMedicine = m.idMedicine
WHERE s.DataVenda BETWEEN '2025-01-01' AND '2025-12-31'
ORDER BY s.DataVenda;



-- Relatório de medicamentos mais vendidos
SELECT SUM(si.Quantidade) AS Quantidade, m.Nome
FROM SaleItems si
JOIN Medicines m
ON si.idMedicine = m.idMedicine
GROUP BY m.Nome
ORDER BY Quantidade;



-- Relatório de compras por fornecedor
SELECT s.CNPJ, s.RazaoSocial, p.DataCompra, pit.Quantidade, pit.ValorUnitario, pit.TotalItem
FROM Purchases p
JOIN Suppliers s
ON p.idSupplier = s.idSupplier
JOIN PurchaseAndItems pai
ON p.idPurchase = pai.idPurchase
JOIN PurchaseItems pit
ON pai.idPurchaseItem = pit.idPurchaseItem
JOIN Ingredients i
ON pit.idIngredient = i.idIngredient
WHERE p.DataCompra BETWEEN '2025-01-01' AND '2025-12-31'
ORDER BY p.DataCompra;





