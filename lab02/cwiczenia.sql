-- 1. Funkcje pozycjonujące: Row_Number, Rank, Dense_Rank, NTile
SELECT Row_Number() OVER (ORDER BY LastName) AS RowNumber
     , Rank() OVER (ORDER BY LastName)       AS Rank
     , Dense_Rank() OVER (ORDER BY LastName) AS DenseRank
     , NTile(3) OVER (ORDER BY LastName)     AS NTile_3
     , NTile(4) OVER (ORDER BY LastName)     AS NTile_4
     , BusinessEntityID
     , FirstName
     , LastName
FROM Person.Person;

-- Programowanie proceduralne w T-SQL
declare @integerExpression int = 4;
select PostalCode, StateProvinceID, NTILE(@integerExpression) over(order by PostalCode) as NTileValue
from Person.Address
where StateProvinceID in (23,46);

-- Definiowanie zmiennych w T-SQL
declare @Imie varchar(50);	-- has to specify length --> default: varchar(1)
set @Imie = 'Joanna';
select @Imie as Imie;


-- 2. Grupowanie danych

-- Grouping Sets

SELECT MONTH(OrderDate), TerritoryID, CustomerID, SUM(TotalDue)
FROM Sales.SalesOrderHeader
WHERE SalesPersonID = 277 AND YEAR(OrderDate) = 2011
GROUP BY MONTH(OrderDate), TerritoryID, CustomerID	-- dany klient w danym miesiacy w danym miejscu
UNION ALL
SELECT MONTH(OrderDate), TerritoryID, NULL, SUM(TotalDue)
FROM Sales.SalesOrderHeader
WHERE SalesPersonID = 277 AND YEAR(OrderDate) = 2011
GROUP BY MONTH(OrderDate), TerritoryID
UNION ALL
SELECT MONTH(OrderDate), NULL, CustomerID, SUM(TotalDue)
FROM Sales.SalesOrderHeader
WHERE SalesPersonID = 277 AND YEAR(OrderDate) = 2011
GROUP BY MONTH(OrderDate), CustomerID
UNION ALL
SELECT NULL, NULL, NULL, SUM(TotalDue)
FROM Sales.SalesOrderHeader
WHERE SalesPersonID = 277 AND YEAR(OrderDate) = 2011

-- to samo co powyzej, ale z uzyciem GROUPING SETS
SELECT MONTH(OrderDate), TerritoryID, CustomerID, SUM(TotalDue)
FROM Sales.SalesOrderHeader
WHERE SalesPersonID = 277 AND YEAR(OrderDate) = 2011
GROUP BY GROUPING SETS(
(MONTH(OrderDate), TerritoryID, CustomerID),
(MONTH(OrderDate), TerritoryID),
(MONTH(OrderDate), CustomerID),
()
);

-- Tak samo mamy również operatory grupujące: ROLLUP, CUBE

-- CTE oraz recusrive CTE w T-SQL
USE AdventureWorks2019
GO

-- zobacz rozszerzone dane o każdym z pracowników
select OrganizationNode, OrganizationNode.ToString() as Node, OrganizationLevel,
p.BusinessEntityID, Firstname, Lastname, JobTitle
from Person.person p join HumanResources.Employee e
on p.BusinessEntityID = e.BusinessEntityID


-- utwórz tabelę cherarchii pracowników
WITH
EmployeeManager 
AS(
	SELECT Firstname + ' ' + Lastname as Employee,
	Firstname + ' ' + Lastname as Manager,
	0 as EmployeeLevel,
	CAST('/' AS hierarchyid) as OrgNode
	FROM HumanResources.Employee e JOIN Person.Person p ON p.BusinessEntityID = e.BusinessEntityID
	WHERE e.OrganizationLevel is null

	UNION ALL

	SELECT p.Firstname + ' ' + p.Lastname as Employee,
	man.Employee as Manager,
	man.EmployeeLevel + 1 as EmployeeLevel,
	OrganizationNode as OrgNode
	FROM HumanResources.Employee e JOIN Person.Person p ON p.BusinessEntityID = e.BusinessEntityID, EmployeeManager man
	WHERE OrganizationNode.GetAncestor(1) = man.OrgNode
)
SELECT Employee, Manager FROM EmployeeManager;