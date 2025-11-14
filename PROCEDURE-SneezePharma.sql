
USE SneezePharma
GO

-- CRIAÇÃO DAS PROCEDURES

-- Cadastrar Fornecedores
CREATE OR ALTER PROCEDURE sp_CreatSuppliers
@CNPJ VARCHAR(14),
@RazaoSocial NVARCHAR(50),
@Pais NVARCHAR(20),
@DataAbertura DATE,
@Situacao CHAR(1)
AS
BEGIN
	INSERT INTO Suppliers (CNPJ, RazaoSocial, Pais, DataAbertura, DataCadastro, Situacao)
	VALUES (@CNPJ, @RazaoSocial, @Pais, @DataAbertura, GETDATE(), @Situacao )
END;
GO

-- Cadastrar Forncededores Restritos
CREATE OR ALTER PROCEDURE sp_CreatRestrictedSuppliers
@CNPJ VARCHAR(14)
AS
BEGIN
	INSERT INTO RestrictedSuppliers (CNPJ)
	VALUES (@CNPJ)
END;
GO

-- Cadastrar Clientes
CREATE OR ALTER PROCEDURE sp_CreatCustomers
@Nome NVARCHAR(50),
@DataNascimento DATE,
@Telefone VARCHAR(11),
@Situacao CHAR(1),
@CPF VARCHAR(11)
AS
BEGIN
	INSERT INTO Customers (Nome, DataNascimento, Telefone, DataCadastro, Situacao, CPF)
	VALUES (@Nome, @DataNascimento, @Telefone, GETDATE(), @Situacao, @CPF)
END;
GO


-- Cadastrar Clientes Restritos
CREATE OR ALTER PROCEDURE sp_CreatRestrictedCustomers
@CPF VARCHAR(11)
AS
BEGIN
	INSERT INTO RestrictedCustomers (CPF)
	VALUES (@CPF)
END;
GO


-- Cadastrar Ingrediente
CREATE OR ALTER PROCEDURE sp_CreatIngredients
@idIngredient VARCHAR(6),
@Nome NVARCHAR(20),
@Situacao CHAR(1)
AS
BEGIN
	INSERT INTO Ingredients(idIngredient, Nome, DataCadastro, Situacao)
	VALUES (@idIngredient, @Nome, GETDATE(), @Situacao)
END;
GO

-- Cadastrar Categorias
CREATE OR ALTER PROCEDURE sp_CreatCategorias
@Nome CHAR(1)
AS
BEGIN
	INSERT INTO Categorias (Nome)
	VALUES (@Nome)
END;
GO


-- Cadastrar Medicamento
CREATE OR ALTER PROCEDURE sp_CreatMedicines
@CDB VARCHAR(13),
@Nome NVARCHAR(40),
@ValorVenda DECIMAL(18,2),
@Situacao CHAR(1),
@idCategoria INT
AS
BEGIN
	INSERT INTO Medicines (CDB, Nome, ValorVenda, DataCadastro, Situacao)
	VALUES (@CDB, @Nome, @ValorVenda, GETDATE(), @Situacao)

	DECLARE @idMedicine INT = SCOPE_IDENTITY();

	INSERT INTO CategoriaMedicines (idMedicine, idCategoria)
	VALUES (@idMedicine, @idCategoria)
END;
GO


-- Cadastrar Produção
CREATE OR ALTER PROCEDURE sp_CreatProduces
@idIngredient VARCHAR(6),
@QuantidadePrincipio INT,
@Quantidade INT,
@idMedicine INT
AS
BEGIN
	INSERT INTO Produces(DataProducao, Quantidade, idMedicine)
	VALUES (GETDATE(), @Quantidade, @idMedicine);

	DECLARE @idProduce INT = SCOPE_IDENTITY();

	INSERT INTO ProduceItems(idIngredient, QuantidadePrincipio, idProduce)
	VALUES (@idIngredient, @QuantidadePrincipio, @idProduce);
END;
GO


-- Realizar Compras
CREATE TYPE tp_PurchaseItems AS TABLE(
	idIngredient VARCHAR(6),
	Quantidade INT,
	ValorUnitario DECIMAL
)
GO

 
CREATE OR ALTER PROCEDURE sp_CreatPurchase
@idSupplier INT,
@Items tp_PurchaseItems READONLY
AS
BEGIN
	DECLARE @idPurchase INT
	DECLARE @TotalCompra DECIMAL(18,2)

	SELECT @TotalCompra = SUM(Quantidade * ValorUnitario)	
	FROM @Items
 
	INSERT INTO Purchases(DataCompra, ValorTotal, idSupplier)
	VALUES(GETDATE(), @TotalCompra, @idSupplier)
 
	SET @idPurchase = SCOPE_IDENTITY();
 
	DECLARE @TabelaItemsIds TABLE (id INT)
 
	INSERT INTO PurchaseItems (Quantidade, ValorUnitario, idIngredient)
	OUTPUT INSERTED.IdPurchaseItem INTO @TabelaItemsIds
	SELECT Quantidade, ValorUnitario, IdIngredient
	FROM @Items
 
	INSERT INTO PurchaseAndItems
	SELECT @idPurchase, id FROM @TabelaItemsIds
 
END;
GO


-- Realizar Vendas
CREATE TYPE tp_SaleItems AS TABLE(
	idMedicine INT,
	Quantidade INT,
	ValorUnitario DECIMAL
)
GO


CREATE OR ALTER PROCEDURE sp_CreatSales
@idCustomer INT,
@Items tp_SaleItems READONLY
AS
BEGIN
	DECLARE @idSale INT
	DECLARE @TotalVenda DECIMAL(18,2)

	SELECT @TotalVenda = SUM(Quantidade * ValorUnitario)
	FROM @Items;
 
	INSERT INTO Sales(DataVenda, ValorTotal, idCustomer)
	VALUES(GETDATE(), @TotalVenda, @idCustomer)
 
	SET @idSale = SCOPE_IDENTITY();
 
	DECLARE @TabelaItemsIds TABLE (id INT)
 
	INSERT INTO SaleItems (Quantidade, ValorUnitario, idMedicine, idSale)
	OUTPUT INSERTED.idSaleItem INTO @TabelaItemsIds
	SELECT Quantidade, ValorUnitario, IdMedicine, @idSale
	FROM @Items
 
	INSERT INTO SaleAndItems
	SELECT @idSale, id FROM @TabelaItemsIds
 
END;
GO


-- EXECUÇÃO DAS PROCEDURES

--Adicionando Supllier
EXEC sp_CreatSuppliers '10512926000110','PharmIngredients LTDA','Brasil','2021-02-17','A';
EXEC sp_CreatSuppliers '09897077000180','PróPharmacos','Brasil','2000-06-23','A';
EXEC sp_CreatSuppliers '81000190000149','PN farmaceutica LTDA', 'Brasil', '1998-05-29','A';
EXEC sp_CreatSuppliers '69997862000137','Coopermag Coop de Farmácias','Brasil','2014-11-02','A';


--Adicionando RestrictedSupllier
EXEC sp_CreatRestrictedSuppliers '10512926000110'; 


--Adicionando Customer
EXEC sp_CreatCustomers 'Sueli Louise Drumond', '1980-09-21', '16992585475', 'A', '04605229817';
EXEC sp_CreatCustomers 'Vitória Galvão','2005-07-13','16999704599','A','07849484886'
EXEC sp_CreatCustomers 'Adriana Luiza Rodrigues', '2000-03-10', '16988603217','A','62405119862';
EXEC sp_CreatCustomers 'Fernando Roberto Assunção', '1995-04-19', '1639311739', 'A', '66866079837';
EXEC sp_CreatCustomers 'Diogo Almeida', '2007-08-30', '16983137880', 'A', '03704255882';


--Adicionando RestrictedCustomer
EXEC sp_CreatRestrictedCustomers '62405119862';


--Adicionando Categorias
EXEC sp_CreatCategorias 'A';
EXEC sp_CreatCategorias 'B';
EXEC sp_CreatCategorias 'I';
EXEC sp_CreatCategorias 'V';


--Adicionando Medicine
EXEC sp_CreatMedicines '7893216549878', 'Tramal', 79.99,'A', 1;
EXEC sp_CreatMedicines '7899876543216', 'Zitromax ', 47.65,'A', 2;
EXEC sp_CreatMedicines '7894561237893', 'Nisulid', 10.50,'A', 3;
EXEC sp_CreatMedicines '7891234567890', 'Centrum', 55.50,'A', 4;


--Adicionando Ingredient
EXEC sp_CreatIngredients 'AI0001', 'Complex Vitaminico', 'A';
EXEC sp_CreatIngredients 'AI0002', 'Azitromicina', 'A';
EXEC sp_CreatIngredients 'AI0003', 'Nimesulida', 'A';
EXEC sp_CreatIngredients 'AI0004', 'Tramadol', 'A';


--Adicionando Compra
DECLARE @PItems tp_PurchaseItems; 
INSERT INTO @PItems VALUES ('AI0001', 100, 26.70);
EXEC sp_CreatPurchase 2, @PItems
GO

DECLARE @PItems tp_PurchaseItems; 
INSERT INTO @PItems VALUES ('AI0002', 200, 19.90);
EXEC sp_CreatPurchase 2, @PItems
GO

DECLARE @PItems tp_PurchaseItems;
INSERT INTO @PItems VALUES ('AI0003', 80, 3.75);
EXEC sp_CreatPurchase 3, @PItems
GO

DECLARE @PItems tp_PurchaseItems;
INSERT INTO @PItems VALUES ('AI0004', 30, 42.00);
EXEC sp_CreatPurchase 4, @PItems
GO


--Adicionando Produção 
EXEC sp_CreatProduces 'AI0001', 50, 50, 4;
EXEC sp_CreatProduces 'AI0002', 100, 100, 2;
EXEC sp_CreatProduces 'AI0003', 80, 80, 3;


--Adicionando Venda
DECLARE @SItems tp_SaleItems;
INSERT INTO @SItems VALUES ('2', 20, 47.65);
EXEC sp_CreatSales '1', @SItems;
GO

DECLARE @SItems tp_SaleItems;
INSERT INTO @SItems VALUES ('3', 35, 10.50);
EXEC sp_CreatSales '2', @SItems;
GO

DECLARE @SItems tp_SaleItems;
INSERT INTO @SItems VALUES ('4', 60, 55.50);
EXEC sp_CreatSales '4', @SItems;
GO