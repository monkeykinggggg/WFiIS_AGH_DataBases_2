-- Przykładowe procedury składowane

-- 1. Procedura składowana z parametrem wejściowym
USE AdventureWorks2019;
GO
IF OBJECT_ID('dbo.usp_GetSortedPersons') IS NOT NULL
DROP PROC dbo.usp_GetSortedPersons;
GO

CREATE PROC dbo.usp_GetSortedPersons
@colname AS sysname = NULL  /* sysname to zmienna systemova nvarchar(128) 
    tutaj robimy tyle co:
    delcare @colname sysnamel
    set @colname = NULL
    */
AS
DECLARE @msg AS NVARCHAR(500);
-- Input validation
IF @colname IS NULL
BEGIN
    SET @msg = N'A value must be supplied for parameter @colname.';
    RAISERROR(@msg, 16, 1);
    RETURN;
END
IF @colname NOT IN(N'BusinessEntityID', N'LastName', N'PhoneNumber')
    BEGIN
    SET @msg = N'Valid values for @colname are: '
    + N'N''BusinessEntityID'', N''LastName'', N''PhoneNumber''.';
    RAISERROR(@msg, 16, 1);
    RETURN;
END
-- Return person sorted by requested sort column
IF @colname = N'BusinessEntityID'
    SELECT p.BusinessEntityID, LastName, PhoneNumber
    FROM Person.Person p JOIN Person.PersonPhone a ON ( a.BusinessEntityID =
    p.BusinessEntityID )
    ORDER BY p.BusinessEntityID;
ELSE IF @colname = N'LastName'
    SELECT p.BusinessEntityID, LastName, PhoneNumber
    FROM Person.Person p JOIN Person.PersonPhone a ON ( a.BusinessEntityID =
    p.BusinessEntityID )
    ORDER BY LastName;
ELSE IF @colname = N'PhoneNumber'
    SELECT p.BusinessEntityID, LastName, PhoneNumber
    FROM Person.Person p JOIN Person.PersonPhone a ON ( a.BusinessEntityID =
    p.BusinessEntityID )
    ORDER BY PhoneNumber;
GO

-- 2. Procedura składowana z parametrami input
USE AdventureWorks2019;
GO

IF OBJECT_ID('dbo.usp_GetCustOrders') IS NOT NULL
DROP PROC dbo.usp_GetCustOrders;
GO

CREATE PROC dbo.usp_GetCustOrders
    @custid AS NCHAR(5),
    @fromdate AS DATETIME = '19000101',
    @todate AS DATETIME = '99991231'
AS
SET NOCOUNT ON;
    SELECT SalesOrderID, CustomerID, SalesPersonID, OrderDate
    FROM Sales.SalesOrderHeader
    WHERE CustomerID = @custid
    AND OrderDate >= @fromdate
    AND OrderDate < @todate;
GO

EXEC dbo.usp_GetCustOrders N'30052';
EXEC dbo.usp_GetCustOrders N'30052',DEFAULT, '20111201';
EXEC dbo.usp_GetCustOrders N'30052','20110801', '20111201';
EXEC dbo.usp_GetCustOrders @custid = N'30052', fromdate = '20110801', @todate = '20111102';


-- 3. Procedura składowana z parametrami input i output
ALTER PROC dbo.usp_GetCustOrders
    @custid AS NCHAR(5),
    @fromdate AS DATETIME = '19000101',
    @todate AS DATETIME = '99991231',
    @numrows AS INT OUTPUT
AS
SET NOCOUNT ON;
DECLARE @err AS INT;
    SELECT SalesOrderID, CustomerID, SalesPersonID, OrderDate
    FROM Sales.SalesOrderHeader
    WHERE CustomerID = @custid
    AND OrderDate >= @fromdate
    AND OrderDate < @todate;
    SELECT @numrows=@@ROWCOUNT,@err=@@ERROR;        -- @@ROWCOUNT - zwraca ilość wierszy zwróconych przez ostatnie polecenie SELECT
                                                    -- @@ERROR - zwraca kod błędu ostatniego polecenia, 0 jeżlei nie ma błędu
    RETURN @err;
Go

-- tmp table to store output
IF OBJECT_ID('tempdb..#CustOrders') IS NOT NULL
DROP TABLE #CustOrders;
GO
CREATE TABLE #CustOrders
(
SalesOrderID INT NOT NULL PRIMARY KEY,
CustomerID NCHAR(5) NOT NULL,
SalesPersonID INT NOT NULL,
OrderDate DATETIME NOT NULL
);

-- tworzenie triggerów - prosty przykład
USE tempdb
go
CREATE TABLE ddltest( a int not null) ;
go
CREATE TRIGGER safety on database for drop_table
AS
print 'Musisz wylaczyc trigger przed usunieciem tabeli'
ROLLBACK
GO
DROP TABLE ddltest
GO

-- trigger zapisujacy zmiany w bazie

USE tempdb;  -- Change to your target database
GO

IF OBJECT_ID('dbo.EventLog', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.EventLog (
        LogID INT IDENTITY PRIMARY KEY,
        PostTime DATETIME NOT NULL,
        DBUser NVARCHAR(100) NOT NULL,
        Event NVARCHAR(100) NOT NULL,
        TSQL NVARCHAR(2000) NOT NULL
    );
END;
GO

-- tworzenie wyzwalacza, ktory bedzie zapisywał do tabeli wszystkie zmiany w bazie
ALTER TRIGGER safety 
ON DATABASE 
FOR DDL_DATABASE_LEVEL_EVENTS  -- Captures all database-level DDL events
AS
BEGIN
    DECLARE @data XML;
    SET @data = EVENTDATA();  -- Captures event details

    INSERT INTO EventLog (PostTime, DBUser, Event, TSQL)
    VALUES (
        GETDATE(),
        CONVERT(NVARCHAR(100), CURRENT_USER),  -- User who triggered the event
        CONVERT(NVARCHAR(100), @data.query('data(//EventType)')),  -- Type of event
        CONVERT(NVARCHAR(2000), @data.query('data(//TSQLCommand)'))  -- The actual SQL command
    );
END;
GO
