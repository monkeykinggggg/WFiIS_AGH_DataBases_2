-- Zadanie 1

/*
 Jeśli RowNumber to nazwa kolumny, na której wywołaliśmy ROW_NUMBER(),
 to wyrażenie "WHERE (RowNumber > 51) AND (RowNumber < 100)"
 wybiera nam wiersze od 52 (włącznie) do 99 (włącznie).
*/

-- sposob wykorzystania z tabela tymczasowa
select dense_rank() over ( order by LastName ) as RowNumber, FirstName, LastName 
into #Rowstmp       -- temporary, local table
from Person.Person;

select * from #Rowstmp
where ( RowNumber > 51) AND (RowNumber < 100);

-- sposob z cte
with RowsCTE(RowNumber,FirstName,LastName) as(
	select dense_rank() over ( order by LastName ), FirstName, LastName
	from Person.Person
)
select * from RowsCTE where ( RowNumber > 51) AND (RowNumber < 100);


-- Zadanie 2

/*
 Utwórz raport podający ilość dostawców o adresie głównej siedziby
 podzielony wg stanu i miasta. Dane pochodzą z tabel Purchasing.Vendor,
 Purchasing.VendorAddress, Person.Address, Person.StateProvince.
*/

--  select * from Person.AddressType;
-- AdressTypeID to Main Office = siedziba główna

 select sp.StateProvinceID,
		sp.Name as [Province Name], 
		a.City,
		count(v.BusinessEntityID) as [Number of Vendors]		-- ilość dostawców w danym mieście w danej prowincji
 from Purchasing.Vendor v
 join Person.BusinessEntityAddress bea on v.BusinessEntityID = bea.BusinessEntityID
 join Person.Address a on bea.AddressID=a.AddressID
 join Person.StateProvince sp on a.StateProvinceID = sp.StateProvinceID
 where bea.AddressTypeID = 3
 group by sp.StateProvinceID,sp.Name,a.City		-- podział wdg stanu(nr+nazwa_stanu) i miasta (nazwa_miasta)
 order by sp.StateProvinceID,a.City;


-- Zadanie 3
/*
 a)
 Wykorzystaj instrukcję case w celu wygenerowania raportu takiego jak w instrukcji pivot poniżej.
*/

CREATE TABLE SalesOrderTotalsYearly
(
CustomerID int NOT NULL,
OrderYear int NOT NULL,
SubTotal money NOT NULL
)
GO
INSERT SalesOrderTotalsYearly
SELECT CustomerID, YEAR(OrderDate), SubTotal
FROM Sales.SalesOrderHeader
WHERE CustomerID IN (SELECT DISTINCT(CustomerID) FROM
Sales.SalesOrderHeader ) ;
GO

-- instrukcja pivot
SELECT * FROM SalesOrderTotalsYearly
PIVOT (SUM(SubTotal) FOR OrderYear IN ([2011], [2012], [2013], [2014])) AS a
GO

-- intrukcja z case
select CustomerId,
sum(case when OrderYear = 2011 then SubTotal end) as [2011],
sum(case when OrderYear = 2012 then SubTotal end) as [2012],
sum(case when OrderYear = 2013 then SubTotal end) as [2013],
sum(case when OrderYear = 2014 then SubTotal end) as [2014]			-- nie potrzeba else, jezeli by bylo to wyszloby nam ladne 0.0
from SalesOrderTotalsYearly
group by CustomerID;

/*
 b)
 W bazie tempdb ( powinna być, jeżeli nie utworzyć ) utworzyć tabelę z
 kolumnami dla godziny i minuty pomiaru ( dwie osobne kolumny) oraz
 dwie następne kolumny dla wartości mierzonych zawartość CO2 i ilość
 przejeżdżających pojazdów. Wypełnić tabelę danymi. Wykorzystać
 PIVOT dla pokazania agregatów MIN, MAX, SUM w kolejnych
 godzinach ( kolejne godziny powinny być w nagłówkach) dla obu
 mierzonych wartości.
*/


use tempdb
go
create table Measurements(
	Hour int not null check(Hour between 0 and 23),
	Minute int not null check(Minute between 0 and 59),
	CO2 numeric(7,2) check(CO2 >= 0),
	NoCars int check(NoCars>=0),
	constraint measurement_PK primary key(Hour,Minute)
);
insert into Measurements values
(0, 5, 10.15, 3),
(0, 15, 12.20, 5),
(0, 45, 11.90, 10),
(1, 10, 15.00, 8),
(1, 33, 16.50, 12),
(2, 0, 18.30, 20),
(2, 30, 19.10, 25),
(3, 5, 25.70, 40),
(3, 20, 28.55, 45);


select 'CO2 MIN' as Measure,*
from (select Hour,CO2 from Measurements) as src
pivot (min(CO2) for Hour in ([0],[1],[2],[3])) as PivotTable
union
select 'CO2 MAX' ,*
from (select Hour,CO2 from Measurements) as src
pivot (max(CO2) for Hour in ([0],[1],[2],[3])) as PivotTable
union
select 'CO2 SUM' ,*
from (select Hour,CO2 from Measurements) as src
pivot (sum(CO2) for Hour in ([0],[1],[2],[3])) as PivotTable
union
select 'Vehicle MIN',*
from (select Hour,NoCars from Measurements) as src
pivot (min(NoCars) for Hour in ([0],[1],[2],[3])) as PivotTable
union
select 'Vehicle MAX',*
from (select Hour,NoCars from Measurements) as src
pivot (max(NoCars) for Hour in ([0],[1],[2],[3])) as PivotTable
union
select 'Vehicle SUM',*
from (select Hour,NoCars from Measurements) as src
pivot (sum(NoCars) for Hour in ([0],[1],[2],[3])) as PivotTable;



