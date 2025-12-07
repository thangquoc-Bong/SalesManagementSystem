IF DB_ID(N'SalesManagementSystem') IS NULL
BEGIN
    CREATE DATABASE SalesManagementSystem;
END;
GO

USE SalesManagementSystem;
GO
CREATE TABLE dbo.Employee (
    EmployeeID   INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeName NVARCHAR(150) NOT NULL,
    Position     NVARCHAR(100) NULL,
    AuthorityLevel TINYINT NOT NULL DEFAULT(1),
    Username     NVARCHAR(100) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    IsActive     BIT NOT NULL DEFAULT(1),
    CreatedAt    DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

-- Customer table
CREATE TABLE dbo.Customer (
    CustomerID   INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName NVARCHAR(200) NOT NULL,
    PhoneNumber  VARCHAR(20) NULL,
    Email        NVARCHAR(150) NULL,
    Address      NVARCHAR(300) NULL,
    CreatedAt    DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
-- Unique phone nếu có giá trị
CREATE UNIQUE INDEX UX_Customer_Phone 
    ON dbo.Customer(PhoneNumber) 
    WHERE PhoneNumber IS NOT NULL;
GO

-- Supplier table
CREATE TABLE dbo.Supplier (
    SupplierID    INT IDENTITY(1,1) PRIMARY KEY,
    SupplierName  NVARCHAR(200) NOT NULL,
    ContactNumber VARCHAR(20) NULL,
    Email         NVARCHAR(150) NULL,
    Address       NVARCHAR(300) NULL,
    CreatedAt     DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

-- Category table
CREATE TABLE dbo.Category (
    CategoryID   INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(150) NOT NULL,
    Description  NVARCHAR(500) NULL
);
GO

-- PaymentMethod table
CREATE TABLE dbo.PaymentMethod (
    PaymentMethodID INT IDENTITY(1,1) PRIMARY KEY,
    MethodName      NVARCHAR(100) NOT NULL,
    Description     NVARCHAR(500) NULL
);
GO

-- Product table
CREATE TABLE dbo.Product (
    ProductID     INT IDENTITY(1,1) PRIMARY KEY,
    ProductName   NVARCHAR(300) NOT NULL,
    CategoryID    INT NOT NULL,
    SupplierID    INT NULL,
    CostPrice     DECIMAL(18,2) NOT NULL DEFAULT(0),
    SellingPrice  DECIMAL(18,2) NOT NULL DEFAULT(0),
    StockQuantity INT NOT NULL DEFAULT(0),
    CreatedAt     DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

-- Foreign keys -> Category, Supplier
ALTER TABLE dbo.Product
    ADD CONSTRAINT FK_Product_Category FOREIGN KEY (CategoryID)
        REFERENCES dbo.Category(CategoryID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION;

ALTER TABLE dbo.Product
    ADD CONSTRAINT FK_Product_Supplier FOREIGN KEY (SupplierID)
        REFERENCES dbo.Supplier(SupplierID)
        ON DELETE SET NULL
        ON UPDATE NO ACTION;
GO

-- Order table
CREATE TABLE dbo.[Order] (
    OrderID        INT IDENTITY(1,1) PRIMARY KEY,
    OrderDate      DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CustomerID     INT NOT NULL,
    EmployeeID     INT NULL,
    PaymentMethodID INT NULL,
    OrderStatus    NVARCHAR(30) NOT NULL DEFAULT 'Pending', -- Pending, Completed, Cancelled ...
    TotalAmount    DECIMAL(18,2) NOT NULL DEFAULT(0),
    TotalProfit    DECIMAL(18,2) NOT NULL DEFAULT(0),
    Notes          NVARCHAR(1000) NULL,
    CreatedAt      DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

-- Foreign keys for Order
ALTER TABLE dbo.[Order]
    ADD CONSTRAINT FK_Order_Customer FOREIGN KEY (CustomerID)
        REFERENCES dbo.Customer(CustomerID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION;

ALTER TABLE dbo.[Order]
    ADD CONSTRAINT FK_Order_Employee FOREIGN KEY (EmployeeID)
        REFERENCES dbo.Employee(EmployeeID)
        ON DELETE SET NULL
        ON UPDATE NO ACTION;

ALTER TABLE dbo.[Order]
    ADD CONSTRAINT FK_Order_PaymentMethod FOREIGN KEY (PaymentMethodID)
        REFERENCES dbo.PaymentMethod(PaymentMethodID)
        ON DELETE SET NULL
        ON UPDATE NO ACTION;
GO

-- OrderDetail table
CREATE TABLE dbo.OrderDetail (
    OrderID      INT NOT NULL,
    ProductID    INT NOT NULL,
    Quantity     INT NOT NULL CHECK (Quantity >= 0),
    UnitPrice    DECIMAL(18,2) NOT NULL DEFAULT(0),
    LineDiscount DECIMAL(18,2) NOT NULL DEFAULT(0),
    LineTotal AS (Quantity * UnitPrice - LineDiscount) PERSISTED, -- Computed column
    LineProfit   DECIMAL(18,2) NULL,
    PRIMARY KEY (OrderID, ProductID)
);
GO

-- Foreign keys for OrderDetail
ALTER TABLE dbo.OrderDetail
    ADD CONSTRAINT FK_OrderDetail_Order FOREIGN KEY (OrderID)
        REFERENCES dbo.[Order](OrderID)
        ON DELETE CASCADE
        ON UPDATE NO ACTION;

ALTER TABLE dbo.OrderDetail
    ADD CONSTRAINT FK_OrderDetail_Product FOREIGN KEY (ProductID)
        REFERENCES dbo.Product(ProductID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION;
GO

------------------------------------------------------------
-- 4. INDEXES
------------------------------------------------------------
CREATE INDEX IX_Order_Customer     ON dbo.[Order](CustomerID);
CREATE INDEX IX_Order_Employee     ON dbo.[Order](EmployeeID);
CREATE INDEX IX_Order_PaymentMethod ON dbo.[Order](PaymentMethodID);

CREATE INDEX IX_Product_Category   ON dbo.Product(CategoryID);
CREATE INDEX IX_Product_Supplier   ON dbo.Product(SupplierID);
GO

USE SalesManagementSystem;
GO

------------------------------------------------------------
-- EMPLOYEE – login accounts
------------------------------------------------------------
INSERT INTO dbo.Employee (EmployeeName, Position, AuthorityLevel, Username, PasswordHash)
VALUES
(N'Nguyen Van Duc',   N'Manager',        10, N'admin',       N'admin123'),
(N'Tran Thi Lam',     N'Cashier',         1, N'cashier1',    N'cashier123'),
(N'Le Thanh Binh',    N'Sales Staff',     1, N'sales1',      N'sales123'),
(N'Bui Xuan Huan',    N'Warehouse Staff', 2, N'warehouse1',  N'ware123'),
(N'Pham Anh Quan',    N'Supervisor',      5, N'super1',      N'super123');
GO

------------------------------------------------------------
-- CUSTOMER
------------------------------------------------------------
INSERT INTO dbo.Customer (CustomerName, PhoneNumber, Email, Address)
VALUES
(N'Nguyen Van A',  '0901111001', N'nguyenvana@example.com', N'Cau Giay, Ha Noi'),
(N'Tran Thi B',    '0901111002', N'tranthib@example.com',   N'Dong Da, Ha Noi'),
(N'Le Van C',      '0901111003', N'levanc@example.com',     N'Hai Chau, Da Nang'),
(N'Pham Thi D',    '0901111004', N'phamthid@example.com',   N'District 1, Ho Chi Minh City'),
(N'Ho Minh E',     '0901111005', N'hominhe@example.com',    N'Thu Duc, Ho Chi Minh City'),
(N'Do Thi F',      '0901111006', N'dothif@example.com',     N'Nha Trang'),
(N'Vu Quoc G',     '0901111007', N'vuquocg@example.com',    N'Hai Phong'),
(N'Dinh Thi H',    '0901111008', N'dinhthih@example.com',   N'Bien Hoa');
GO

------------------------------------------------------------
-- SUPPLIER
------------------------------------------------------------
INSERT INTO dbo.Supplier (SupplierName, ContactNumber, Email, Address)
VALUES
(N'Dell Vietnam',    '1800-1111', N'contact-vn@dell.com',    N'Ha Noi'),
(N'Samsung Vietnam', '1800-2222', N'contact-vn@samsung.com', N'Ho Chi Minh City'),
(N'Apple Vietnam',   '1800-3333', N'contact-vn@apple.com',   N'Ha Noi'),
(N'ASUS Vietnam',    '1800-4444', N'info@asus.com',          N'Da Nang'),
(N'HP Vietnam',      '1800-5555', N'support@hp.com',         N'Ho Chi Minh City');
GO

------------------------------------------------------------
-- CATEGORY – product categories
------------------------------------------------------------
INSERT INTO dbo.Category (CategoryName, Description)
VALUES
(N'Laptop',    N'Laptop computers'),
(N'Desktop',   N'Desktop computers'),
(N'Monitor',   N'External monitors'),
(N'Phone',     N'Smartphones'),
(N'Accessory', N'Computer and phone accessories'),
(N'Tablet',    N'Tablet devices');
GO

------------------------------------------------------------
-- PAYMENT METHOD
------------------------------------------------------------
INSERT INTO dbo.PaymentMethod (MethodName, Description)
VALUES
(N'Cash',          N'Cash payment at the store'),
(N'Bank Transfer', N'Bank transfer'),
(N'Credit Card',   N'Credit or debit card'),
(N'E-Wallet',      N'E-wallet (Momo, ZaloPay, etc.)'),
(N'Installment',   N'Installment payment via bank');
GO

------------------------------------------------------------
-- PRODUCT  (make sure CategoryID & SupplierID exist)
------------------------------------------------------------
INSERT INTO dbo.Product (ProductName, CategoryID, SupplierID, CostPrice, SellingPrice, StockQuantity)
VALUES
(N'Dell Inspiron 15',        1, 1, 12000000, 14500000, 12),  -- ID 1
(N'HP Pavilion 14',          1, 5, 11000000, 13800000,  8),  -- ID 2
(N'ASUS TUF Gaming A15',     1, 4, 20000000, 23500000,  5),  -- ID 3
(N'Samsung 24-inch Monitor', 3, 2,  2500000,  3200000, 20),  -- ID 4
(N'Samsung 27-inch Monitor', 3, 2,  3500000,  4500000, 15),  -- ID 5
(N'iPhone 15 128GB',         4, 3, 21000000, 24500000, 10),  -- ID 6
(N'Samsung Galaxy S24',      4, 2, 18000000, 21500000,  9),  -- ID 7
(N'Logitech Wireless Mouse', 5, NULL, 250000,  390000, 50),  -- ID 8
(N'Dell Office Desktop',     2, 1, 9000000, 11500000,  6),   -- ID 9
(N'iPad 10th Gen 64GB',      6, 3, 12000000, 14500000,  7);  -- ID 10
GO

------------------------------------------------------------
-- ORDER – orders (totals will be updated by trigger)
------------------------------------------------------------
INSERT INTO dbo.[Order]
    (OrderDate, CustomerID, EmployeeID, PaymentMethodID, OrderStatus, TotalAmount, TotalProfit, Notes)
VALUES
(SYSUTCDATETIME(), 1, 2, 1, N'Completed', 0, 0, N'Buy laptop and mouse'),
(SYSUTCDATETIME(), 2, 3, 3, N'Completed', 0, 0, N'Buy smartphone'),
(SYSUTCDATETIME(), 3, 2, 2, N'Pending',   0, 0, N'Customer ordered monitors and accessories'),
(SYSUTCDATETIME(), 4, 3, 4, N'Completed', 0, 0, N'Buy iPad for online learning'),
(SYSUTCDATETIME(), 5, 2, 1, N'Cancelled', 0, 0, N'Order cancelled by customer');
GO
-- Assume these orders get IDs 1..5 in order

------------------------------------------------------------
-- ORDER DETAIL – order line items
------------------------------------------------------------

-- Order 1: Dell laptop + wireless mouse
INSERT INTO dbo.OrderDetail (OrderID, ProductID, Quantity, UnitPrice, LineDiscount, LineProfit)
VALUES
(1, 1, 1, 14500000,      0, 2500000),   -- Dell Inspiron 15
(1, 8, 1,   390000,  50000,  90000);    -- Logitech mouse, 50k discount

-- Order 2: iPhone 15
INSERT INTO dbo.OrderDetail (OrderID, ProductID, Quantity, UnitPrice, LineDiscount, LineProfit)
VALUES
(2, 6, 1, 24500000,  0, 3500000);       -- iPhone 15

-- Order 3: 2 monitors + 1 mouse
INSERT INTO dbo.OrderDetail (OrderID, ProductID, Quantity, UnitPrice, LineDiscount, LineProfit)
VALUES
(3, 4, 1, 3200000,   0, 700000),        -- 24" monitor
(3, 5, 1, 4500000, 200000, 800000),     -- 27" monitor with 200k discount
(3, 8, 1,  390000,   0, 140000);        -- mouse

-- Order 4: iPad + Galaxy S24
INSERT INTO dbo.OrderDetail (OrderID, ProductID, Quantity, UnitPrice, LineDiscount, LineProfit)
VALUES
(4, 10, 1, 14500000, 0, 2500000),
(4, 7,  1, 21500000, 0, 3500000);

-- Order 5: cancelled order (still keep detail for reporting)
INSERT INTO dbo.OrderDetail (OrderID, ProductID, Quantity, UnitPrice, LineDiscount, LineProfit)
VALUES
(5, 2, 1, 13800000, 0, 2800000);
GO


