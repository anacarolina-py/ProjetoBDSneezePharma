
------------- CRIAÇÃO DO BANCO DE DADOS -------------

CREATE DATABASE SneezePharma
GO

USE SneezePharma
GO

------------- CONSTRUÇÃO DAS TABELAS -------------

CREATE TABLE Suppliers(
	idSupplier INT NOT NULL PRIMARY KEY IDENTITY (1,1),
	CNPJ VARCHAR(14) NOT NULL UNIQUE,
	RazaoSocial NVARCHAR(50) NOT NULL,
	Pais NVARCHAR(20) NOT NULL,
	DataAbertura DATE NOT NULL,
	UltimoFornecimento DATE,
	DataCadastro DATE NOT NULL,
	Situacao CHAR(1) NOT NULL CHECK (Situacao IN ('A','I'))
);

CREATE TABLE RestrictedSuppliers(
	idRestrictedSupplier INT NOT NULL PRIMARY KEY IDENTITY (1,1),
	CNPJ VARCHAR(14) UNIQUE
);

CREATE TABLE Customers(
	idCustomer INT NOT NULL PRIMARY KEY IDENTITY (1,1),
	Nome NVARCHAR(50) NOT NULL,
	DataNascimento DATE NOT NULL,
	Telefone VARCHAR(11),
	UltimaCompra DATE,
	DataCadastro DATE NOT NULL,
	Situacao CHAR(1) NOT NULL CHECK (Situacao IN ('A','I')),
	CPF VARCHAR(11) UNIQUE
);



CREATE TABLE RestrictedCustomers(
	idRestrictedCustomer INT NOT NULL PRIMARY KEY IDENTITY (1,1),
	CPF VARCHAR(11) UNIQUE
);


CREATE TABLE Medicines(
	idMedicine INT NOT NULL PRIMARY KEY IDENTITY (1,1),
	CDB VARCHAR(13) NOT NULL UNIQUE,
	Nome NVARCHAR(40) NOT NULL,
	ValorVenda DECIMAL(18,2) NOT NULL,
	UltimaVenda DATE, 
	DataCadastro DATE NOT NULL, 
	Situacao CHAR(1) NOT NULL CHECK (Situacao IN ('A','I'))
);

CREATE TABLE Categorias(
	idCategoria INT NOT NULL PRIMARY KEY IDENTITY (1,1),
	Nome CHAR(1)
);

CREATE TABLE CategoriaMedicines(
	idCategoriaAndMedicine INT NOT NULL PRIMARY KEY IDENTITY (1,1),
	idCategoria INT NOT NULL, 
	idMedicine INT NOT NULL,
);


CREATE TABLE Ingredients(
	idIngredient VARCHAR(6) NOT NULL PRIMARY KEY, 
	Nome NVARCHAR(20) NOT NULL,
	UltimaCompra DATE, 
	DataCadastro DATE NOT NULL, 
	Situacao CHAR(1) NOT NULL CHECK (Situacao IN ('A','I'))
);


CREATE TABLE Purchases(
	idPurchase INT NOT NULL PRIMARY KEY IDENTITY (1,1),
	DataCompra DATE NOT NULL, 
	ValorTotal DECIMAL(18,2),
	idSupplier INT NOT NULL
);

CREATE TABLE PurchaseItems(
	idPurchaseItem INT NOT NULL PRIMARY KEY IDENTITY (10000,1),
	Quantidade INT NOT NULL,
	ValorUnitario DECIMAL(18,2) NOT NULL,
	TotalItem AS (Quantidade * ValorUnitario) PERSISTED,
	idIngredient VARCHAR(6) NOT NULL
);

CREATE TABLE PurchaseAndItems(
	id INT NOT NULL PRIMARY KEY IDENTITY (10000,1),
	idPurchase INT,
	idPurchaseItem INT
);


CREATE TABLE Produces(
	idProduce INT NOT NULL PRIMARY KEY IDENTITY (10000,1),
	DataProducao DATE,
	Quantidade INT NOT NULL,
	idMedicine INT NOT NULL
);

CREATE TABLE ProduceItems(
	idProduceItem INT NOT NULL PRIMARY KEY IDENTITY (10000,1),
	idIngredient VARCHAR(6) NOT NULL,
	QuantidadePrincipio INT NOT NULL,
	idProduce INT
);


CREATE TABLE Sales(
	idSale INT NOT NULL PRIMARY KEY IDENTITY (10000,1),
	DataVenda DATE NOT NULL,
	ValorTotal DECIMAL(18,2) NOT NULL,
	idCustomer INT NOT NULL
);

CREATE TABLE SaleItems(
	idSaleItem INT NOT NULL PRIMARY KEY IDENTITY (10000,1),
	Quantidade INT NOT NULL,
	ValorUnitario DECIMAL(18,2) NOT NULL,
	TotalItem AS (Quantidade * ValorUnitario) PERSISTED,
	idMedicine INT NOT NULL,
	idSale INT NOT NULL
);

CREATE TABLE SaleAndItems(
	id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	idSale INT NOT NULL,
	idSaleItem INT NOT NULL
	);

------------- CRIAÇÃO DAS FK -------------

ALTER TABLE RestrictedSuppliers
ADD FOREIGN KEY (CNPJ) REFERENCES Suppliers(CNPJ);

ALTER TABLE RestrictedCustomers
ADD FOREIGN KEY (CPF) REFERENCES Customers(CPF);

ALTER TABLE CategoriaMedicines
ADD FOREIGN KEY (idCategoria) REFERENCES Categorias(idCategoria),
FOREIGN KEY(idMedicine) REFERENCES Medicines(idMedicine);

ALTER TABLE Purchases
ADD FOREIGN KEY (idSupplier) REFERENCES Suppliers(idSupplier);

ALTER TABLE PurchaseItems
ADD FOREIGN KEY (idIngredient) REFERENCES Ingredients(idIngredient);

ALTER TABLE PurchaseAndItems
ADD FOREIGN KEY (idPurchase) REFERENCES Purchases(idPurchase),
FOREIGN KEY (idPurchaseItem) REFERENCES PurchaseItems(idPurchaseItem);

ALTER TABLE Produces
ADD FOREIGN KEY (idMedicine) REFERENCES Medicines(idMedicine);

ALTER TABLE ProduceItems 
ADD FOREIGN KEY (idIngredient) REFERENCES Ingredients(idIngredient),
FOREIGN KEY (idProduce) REFERENCES Produces(idProduce);

ALTER TABLE Sales
ADD FOREIGN KEY (idCustomer) REFERENCES Customers(idCustomer);

ALTER TABLE SaleItems
ADD FOREIGN KEY (idMedicine) REFERENCES Medicines(idMedicine),
FOREIGN KEY (idSale) REFERENCES Sales(idSale);

ALTER TABLE SaleAndItems
ADD FOREIGN KEY (idSale) REFERENCES Sales(idSale),
FOREIGN KEY (idSaleItem) REFERENCES SaleItems(idSaleItem);

--ALTERAÇÕES 

ALTER TABLE Customers
ADD CONSTRAINT CK_Cliente_Maior18
CHECK (DATEADD(YEAR, 18, DataNascimento) <= GETDATE());

ALTER TABLE Suppliers
ADD CONSTRAINT CK_Supplier_MaisDe2Anos
CHECK (DATEADD(YEAR, 2, DataAbertura) <= GETDATE());


--TRIGGERS


---bloquear fornecedores restritos

GO
CREATE OR ALTER TRIGGER trg_BloqueiaFornecedorRestrito
ON Purchases
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED i
        JOIN Suppliers s ON s.idSupplier = i.idSupplier
        JOIN RestrictedSuppliers r ON r.CNPJ = s.CNPJ
    )
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('Fornecedor está na lista restrita. Compra não permitida.', 16, 1);
    END
END;
GO

--bloquear clientes restritos

CREATE OR ALTER TRIGGER trg_BloqueiaClienteRestrito
ON Sales
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED i
        JOIN Customers c ON c.idCustomer = i.idCustomer
        JOIN RestrictedCustomers r ON r.CPF = c.CPF
    )
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('Cliente está na lista restrita. Venda não permitida.', 16, 1);
    END
END;
GO

-- limitar qntdade compra

CREATE OR ALTER TRIGGER trg_LimitaItensPorCompra
ON PurchaseAndItems
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT idPurchase
        FROM PurchaseAndItems
        WHERE idPurchase IN (SELECT idPurchase FROM INSERTED)
        GROUP BY idPurchase
        HAVING COUNT(*) > 3
    )
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('Uma compra não pode conter mais de 3 itens.', 16, 1);
    END
END;
GO



---limitar qntidade venda

CREATE OR ALTER TRIGGER trg_LimitaItensPorVenda
ON SaleAndItems
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT idSale
        FROM SaleAndItems
        WHERE idSale IN (SELECT idSale FROM INSERTED)
        GROUP BY idSale
        HAVING COUNT(*) > 3
    )
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('Uma venda não pode conter mais de 3 itens.', 16, 1);
    END
END;
GO

--atualizar ultima compra de ingredient

CREATE OR ALTER TRIGGER trg_AtualizaUltimaCompra
ON PurchaseAndItems
AFTER INSERT
AS
BEGIN
    UPDATE Ingredients
    SET UltimaCompra = p.DataCompra
    FROM Ingredients i
    JOIN PurchaseItems pi ON pi.idIngredient = i.idIngredient
    JOIN INSERTED ins ON ins.idPurchaseItem = pi.idPurchaseItem
    JOIN Purchases p ON p.idPurchase = ins.idPurchase;
END;
GO

--- atualizar ultimo forneceimento do fornecedor 

CREATE OR ALTER TRIGGER trg_AtualizaUltimoFornecimento
ON Purchases
AFTER INSERT
AS
BEGIN
    UPDATE Suppliers
    SET UltimoFornecimento = i.DataCompra
    FROM Suppliers s
    JOIN INSERTED i ON s.idSupplier = i.idSupplier;
END;
GO

-- atualizar ultima compra de cliente

CREATE OR ALTER TRIGGER trg_AtualizaUltimaCompraCliente
ON Sales
AFTER INSERT
AS
BEGIN
    UPDATE Customers
    SET UltimaCompra = i.DataVenda
    FROM Customers c
    JOIN INSERTED i ON c.idCustomer = i.idCustomer;
END;
GO

--atualizar ultima venda em medicamento

CREATE OR ALTER TRIGGER trg_AtualizaUltimaVendaMedicamento
ON SaleAndItems
AFTER INSERT
AS
BEGIN
    UPDATE Medicines
    SET UltimaVenda = s.DataVenda
    FROM Medicines m
    JOIN SaleItems si ON si.idMedicine = m.idMedicine
    JOIN INSERTED ins ON ins.idSaleItem = si.idSaleItem
    JOIN Sales s ON s.idSale = ins.idSale;
END;
GO


