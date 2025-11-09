--POPULAR BANCO DE DADOS

USE SneezePharma
GO

INSERT INTO Customers(Nome, DataNascimento, Telefone, DataCadastro, Situacao, CPF)
VALUES 
('César Albuquerque', '1998-11-02', '16998745986', GETDATE(), 'A', '64956717253'),
('Andrea Figueredo', '1966-11-19', '67971305941', GETDATE(), 'A', '58432333166'),
('Zacarias Vaz Neto', '1985-10-05', '61975131387', GETDATE(), 'A', '25544113106'),
('Elizabeth Carmoriz', '1998-10-15', '82979977769', GETDATE(), 'A', '74354500493'),
('Julia Pontes', '1996-05-02', '82979978569', GETDATE(), 'A', '74354508597');

SELECT * FROM Customers

INSERT INTO RestrictedCustomers(CPF)
VALUES
(74354500493);

SELECT * FROM RestrictedCustomers

INSERT INTO Suppliers(CNPJ, RazaoSocial, Pais, DataAbertura, DataCadastro, Situacao)
VALUES
('93429523000139', 'Perfumaria Brum', 'Brasil', '1975-04-30', GETDATE(), 'A'),
('84064074000181', 'Rode Vilar Indústria EPP', 'Brasil', '2019-04-04', GETDATE(), 'A'),
('40081260000153', 'Siqueira Andrade Engenharia EPP', 'Brasil', '1992-02-11', GETDATE(), 'A'),
('84111274000148', 'Fonseca Distribuidora EPP', 'Brasil', '1991-02-20', GETDATE(), 'A'),
('66487632000130', 'Dias Distribuidora EPP', 'Brasil', '2000-10-29', GETDATE(), 'A');

SELECT * FROM Suppliers

INSERT INTO RestrictedSuppliers(CNPJ)
VALUES
(66487632000130);

SELECT * FROM RestrictedSuppliers


INSERT INTO Ingredients(idIngredient, Nome, UltimaCompra, DataCadastro, Situacao)
VALUES
('AI0001', 'Ibuprofeno', GETDATE(), GETDATE(), 'A'),
('AI0002','Dipirona', GETDATE(), GETDATE(), 'A'),
('AI0003','Omeoprazol', GETDATE(), GETDATE(), 'A'),
('AI0004','Amoxicilina', GETDATE(), GETDATE(), 'A'),
('AI0005','Paracetamol', GETDATE(), GETDATE(), 'A');

SELECT * FROM Ingredients

INSERT INTO Categorias(Nome)
VALUES
('A'), ('B'), ('C'), ('I'), ('V');

SELECT * FROM Categorias

INSERT INTO Medicines(CDB, Nome, ValorVenda, DataCadastro, Situacao)
VALUES
('7891234567895', 'Advil', 25.00, GETDATE(), 'A'),
('7894561230125', 'Novalgina', 20.00, GETDATE(), 'A'),
('7896549873212', 'Losec', 40.00, GETDATE(), 'A'),
('7899876543211', 'Amoxil', 50.00, GETDATE(), 'A'),
('7891112223332 ', 'Tylenol', 35.00, GETDATE(), 'A');

INSERT INTO CategoriaMedicines
VALUES
(4,1),(1,2),(5,3),(2,4),(4,5);

SELECT * FROM Medicines

SELECT * FROM CategoriaMedicines

--REALIZANDO COMPRAS

--1
INSERT INTO Purchases (DataCompra, ValorTotal, idSupplier)
VALUES (GETDATE(), 0, 1);


DECLARE @idPurchase INT = SCOPE_IDENTITY();


INSERT INTO PurchaseItems (Quantidade, ValorUnitario, idIngredient)
VALUES (10, 5.50, 'AI0001'); 


INSERT INTO PurchaseAndItems (idPurchase, idPurchaseItem)
VALUES (@idPurchase, SCOPE_IDENTITY());

UPDATE Purchases
SET ValorTotal = (
    SELECT SUM(TotalItem)
    FROM PurchaseItems
    WHERE idPurchase = @idPurchase
)
WHERE idPurchase = @idPurchase;

--2
INSERT INTO Purchases (DataCompra, ValorTotal, idSupplier)
VALUES (GETDATE(), 0, 2);


DECLARE @idPurchase1 INT = SCOPE_IDENTITY();


INSERT INTO PurchaseItems (Quantidade, ValorUnitario, idIngredient)
VALUES (10, 5.50, 'AI0005');  


INSERT INTO PurchaseAndItems (idPurchase, idPurchaseItem)
VALUES (@idPurchase1, SCOPE_IDENTITY());

UPDATE Purchases
SET ValorTotal = (
    SELECT SUM(TotalItem)
    FROM PurchaseItems
    WHERE idPurchase = @idPurchase1
)
WHERE idPurchase = @idPurchase1;

--3
INSERT INTO Purchases (DataCompra, ValorTotal, idSupplier)
VALUES (GETDATE(), 0, 4);


DECLARE @idPurchase2 INT = SCOPE_IDENTITY();


INSERT INTO PurchaseItems (Quantidade, ValorUnitario, idIngredient)
VALUES (10, 15, 'AI0004');  


INSERT INTO PurchaseAndItems (idPurchase, idPurchaseItem)
VALUES (@idPurchase2, SCOPE_IDENTITY());

UPDATE Purchases
SET ValorTotal = (
    SELECT SUM(TotalItem)
    FROM PurchaseItems
    WHERE idPurchase = @idPurchase2
)
WHERE idPurchase = @idPurchase2;

--4

INSERT INTO Purchases (DataCompra, ValorTotal, idSupplier)
VALUES (GETDATE(), 0, 5);


DECLARE @idPurchase3 INT = SCOPE_IDENTITY();


INSERT INTO PurchaseItems (Quantidade, ValorUnitario, idIngredient)
VALUES (40, 5.50, 'AI0005'); 


INSERT INTO PurchaseAndItems (idPurchase, idPurchaseItem)
VALUES (@idPurchase3, SCOPE_IDENTITY());

UPDATE Purchases
SET ValorTotal = (
    SELECT SUM(TotalItem)
    FROM PurchaseItems
    WHERE idPurchase = @idPurchase3
)
WHERE idPurchase = @idPurchase3;




SELECT * FROM Purchases



--REALIZANDO PRODUÇÃO




INSERT INTO Produces (DataProducao, Quantidade, idMedicine)
VALUES (GETDATE(), 50, 1);


DECLARE @idProduce INT = SCOPE_IDENTITY();


INSERT INTO ProduceItems (idIngredient, QuantidadePrincipio, idProduce)
VALUES ('AI0001', 30, @idProduce);

INSERT INTO ProduceItems (idIngredient, QuantidadePrincipio, idProduce)
VALUES ('AI0002', 20, @idProduce);



---2

INSERT INTO Produces (DataProducao, Quantidade, idMedicine)
VALUES (GETDATE(), 70, 2);


DECLARE @idProduce1 INT = SCOPE_IDENTITY();


INSERT INTO ProduceItems (idIngredient, QuantidadePrincipio, idProduce)
VALUES ('AI0004', 10, @idProduce1);

INSERT INTO ProduceItems (idIngredient, QuantidadePrincipio, idProduce)
VALUES ('AI0003', 50, @idProduce1);


--3

INSERT INTO Produces (DataProducao, Quantidade, idMedicine)
VALUES (GETDATE(), 100, 3);


DECLARE @idProduce2 INT = SCOPE_IDENTITY();


INSERT INTO ProduceItems (idIngredient, QuantidadePrincipio, idProduce)
VALUES ('AI0004', 20, @idProduce2);

INSERT INTO ProduceItems (idIngredient, QuantidadePrincipio, idProduce)
VALUES ('AI0001', 40, @idProduce2);


SELECT * FROM Produces
SELECT * FROM ProduceItems

--REALIZANDO VENDA

--1


INSERT INTO Sales (DataVenda, ValorTotal, idCustomer)
VALUES (GETDATE(), 0, 1);


DECLARE @idSale INT = SCOPE_IDENTITY();


INSERT INTO SaleItems (Quantidade, ValorUnitario, idMedicine, idSale)
VALUES (5, 25.00, 1, @idSale);

INSERT INTO SaleAndItems (idSale, idSaleItem)
VALUES (@idSale, SCOPE_IDENTITY());

UPDATE Sales
SET ValorTotal = (
    SELECT SUM(TotalItem)
    FROM SaleItems
    WHERE idSale = @idSale
)
WHERE idSale = @idSale;


--2


INSERT INTO Sales (DataVenda, ValorTotal, idCustomer)
VALUES (GETDATE(), 0, 5);


DECLARE @idSale1 INT = SCOPE_IDENTITY();


INSERT INTO SaleItems (Quantidade, ValorUnitario, idMedicine, idSale)
VALUES (5, 20.00, 2, @idSale1);

INSERT INTO SaleAndItems (idSale, idSaleItem)
VALUES (@idSale1, SCOPE_IDENTITY());

UPDATE Sales
SET ValorTotal = (
    SELECT SUM(TotalItem)
    FROM SaleItems
    WHERE idSale = @idSale1
)
WHERE idSale = @idSale1;

--3

INSERT INTO Sales (DataVenda, ValorTotal, idCustomer)
VALUES (GETDATE(), 0, 3);


DECLARE @idSale2 INT = SCOPE_IDENTITY();


INSERT INTO SaleItems (Quantidade, ValorUnitario, idMedicine, idSale)
VALUES (5, 50.00, 4, @idSale2);

INSERT INTO SaleAndItems (idSale, idSaleItem)
VALUES (@idSale2, SCOPE_IDENTITY());

UPDATE Sales
SET ValorTotal = (
    SELECT SUM(TotalItem)
    FROM SaleItems
    WHERE idSale = @idSale2
)
WHERE idSale = @idSale2;

SELECT * FROM Sales
SELECT * FROM SaleItems
SELECT * FROM SaleAndItems;