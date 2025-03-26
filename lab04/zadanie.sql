

-- Zadanie 1
/*
 Opracować przykład procedury składowanej z wykorzystaniem kursora
 tworzący wydruk z dowolnej tabeli w bazie danych AdventureWorks w
 określonym formacie.

*/
use AdventureWorks2019;
go

if OBJECT_ID('dbo.usp_getUserDetails') is not null
	drop proc dbo.usp_getUserDetails;
go

create proc dbo.usp_getUserDetails
as
begin
set nocount on;
	declare @id int;
	declare @firstName nvarchar(20);
	declare @lastName nvarchar(20);
	declare @phone phone;
	declare @email nvarchar(50);

	declare personCursor cursor fast_forward for 
											select top 5 
											p.BusinessEntityID,
											p.FirstName,
											p.LastName,
											pp.PhoneNumber,
											ea.EmailAddress
											from Person.Person p
                                            join Person.PersonPhone pp on p.BusinessEntityID = pp.BusinessEntityID
                                            join Person.EmailAddress ea on p.BusinessEntityID = ea.BusinessEntityID
											order by FirstName,LastName;


	open personCursor;
	fetch next from personCursor into @id,@firstName,@lastName,@phone,@email;

	while @@FETCH_STATUS = 0 begin
		print('ID: '+ cast(@id as nvarchar) + ', Name: '+@firstName+' '+@lastName+char(13)+'	- Phone: '+@phone+char(13)+'	- Email: '+@email);
		fetch next from personCursor into @id,@firstName,@lastName,@phone,@email;
	end

	close personCuror;
	deallocate personCursor;
end
go

exec dbo.usp_getUserDetails;
go



-- Zadanie 2
/*
 Opracować przykład wyzwalacza typu DML dla dowolnego obiektu (tabeli
 lub widoku) w bazie danych AdventureWorks.
*/

use tempdb;
go

if object_id('dbo.Person') is not null
	drop table dbo.Person;
go

create table dbo.Person(
	ID int not null primary key,
	LastName nvarchar(20) default 'Kowalski',
	Age int default 50
);
go

if object_id('dbo.tr_task2') is not null
    drop trigger dbo.tr_task2
go

create trigger dbo.tr_task2 on dbo.Person after insert
as
begin
set nocount on;
	declare @out varchar(100);
	
	select @out =  'Wprowadzono dane do tabeli dbo.Person: ' + lastName + ' ' + cast(age as nvarchar) from inserted;
    print(@out);
end;
go

-- sprawdzenie dizalania triggera
insert into dbo.Person( ID, LastName, age)
values (1, 'Smith', 40);
go


-- Zadanie 3
/*
 Opracować przykład procedury składowanej z wykorzystaniem struktury
 RAISERROR przesłania informacji o niemożliwości zrealizowania
 określonego zadania w bazie danych AdvantureWorks.
 */
use AdventureWorks2019;
go

if object_id('dbo.usp_task3') is not null
    drop procedure dbo.usp_task3;
go

create procedure dbo.usp_task3(@ProductID int) 
as
begin
    set nocount on;
    if @ProductID < 0
        begin
            raiserror (N'ID produktu nie moze byc ujemne! Podales:  %d.', 16, 1, @ProductID);
            return;
        end;
    if not exists ( select 1
                    from Production.Product
                    where ProductID = @ProductID )
        begin
            raiserror (N'Nie ma takiego ID w tabeli! Podales: %d', 16, 1, @ProductID);
            return;
        end;
    select ProductID, Name
    from Production.Product
    where ProductID = @ProductID;
end;

-- sprawdzenie każdego z trzech warunkow 
exec dbo.usp_task3 -1;
go

exec dbo.usp_task3 10;
go

exec dbo.usp_task3 4;
go
