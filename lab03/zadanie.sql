-- Zadanie 1
/*
 Baza danych: AdventureWorks2019
 Temat: Funkcja UDF, która zwraca nchar z danymi określonymi przez
 BusinessEntityID. Każda z kolumn zwracanych jest oddzielona od pozostałych
 średnikiem.
 Dane: nazwisko, imię, email, adres.
 Tabele: Person.Person, Person.EmailAddress, Person.BussinessEntity,
 Person.BussinessEntityAddress, Person.Address.
 Kolumny: PersonID, BusinessEntityID.
 */

use AdventureWorks2019;
go


if object_id('dbo.GetPersonDetails') is not null
	drop function dbo.GetPersonDetails;
go

create function dbo.GetPersonDetails(@id int)
returns nvarchar(1500)
as
begin
	declare @info nvarchar(1500);

	select @info = p.LastName +';' + p.FirstName +';' +  coalesce(ea.EmailAddress,'') +';' +  coalesce(a.AddressLine1,'') +';' +  coalesce(a.City,'')
	from Person.Person p
	left join Person.EmailAddress ea ON p.BusinessEntityID=ea.BusinessEntityID                      -- używamy left join, żeby zawsze dostać dane osoby
	left join Person.BusinessEntityAddress bea on ea.BusinessEntityID=bea.BusinessEntityID
	left join Person.Address a on bea.AddressID=a.AddressID
	where p.BusinessEntityID = @id;

	return @info;
end;
go

declare @test_id int;
set @test_id = 2000;

select dbo.GetPersonDetails(@test_id);

select LastName, FirstName from Person.Person where BusinessEntityID=@test_id;
go


-- Zadanie 2
/*
 Baza danych: AdventureWorks2019
 Temat: Funkcja UDF, która zwraca zestaw rekordów: nazwisko, imię, email, adres,
 uporządkowanych nazwisko, imię, adres. Z pełnego zestawu funkcja zwraca
 podzbiór określony przez numer rekordu w zakresie ustalonym przez argumenty
 funkcji.
 */
 
if object_id('dbo.GetPersonDetailsRange') is not null
	drop function dbo.GetPersonDetailsRange;
go

create function dbo.GetPersonDetailsRange(@first int,@last int)
returns table
as
return
	with cte as(
		select row_number() over (order by LastName, FirstName) as row_number,
		p.LastName,
		p.FirstName,
		coalesce(ea.EmailAddress,'') as email_address,
		coalesce(a.AddressLine1,'') + ' ' +  coalesce(a.City,'') as address
		from Person.Person p
		left join Person.EmailAddress ea ON p.BusinessEntityID=ea.BusinessEntityID                      -- używamy left join, żeby zawsze dostać dane osoby
		left join Person.BusinessEntityAddress bea on ea.BusinessEntityID=bea.BusinessEntityID
		left join Person.Address a on bea.AddressID=a.AddressID
	)
	select * from cte
	where row_number between @first and @last;
go

select * from dbo.GetPersonDetailsRange(10,20);
go


-- Zadanie 3
/*
 Baza danych: AdventureWorks2019
 Temat: Funkcja UDF, która zwraca tabelę z danymi zamówień dla zadanego
 odbiorcy. Odbiorcę zadajemy przez jego nazwę.
 Tabele: Sales.Customer, Sales.SalesOrderHeader, Person.Person
 Kolumny: CustomerID, PersonID,BusinessEntityID
 */

if object_id('dbo.getCustomerOrders') is not null
	drop function dbo.getCustomerOrders;
go

create function dbo.getCustomerOrders(@customerDetails nvarchar(500))
returns table as
return
	select p.FirstName+' '+p.LastName as customer,
	c.CustomerID,
	soh.SalesOrderID,
	soh.OrderDate,
	soh.TotalDue
	from Sales.Customer c 
	join Sales.SalesOrderHeader soh on c.CustomerID = soh.CustomerID
	join Person.Person p on p.BusinessEntityID = c.PersonID
	where p.FirstName + ' ' + p.LastName =@customerDetails;
go

select * from dbo.getCustomerOrders('James Hendergart');
go
select * from dbo.getCustomerOrders('Robin McGuigan');
go