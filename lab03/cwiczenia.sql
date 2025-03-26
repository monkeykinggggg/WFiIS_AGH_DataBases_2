-- UDF : Funkcja skalarna
use AdventureWorks2019;
go

set nocount on;			-- how many rows affected not displayed

if object_id('dbo.fn_ConcatOrders') is not null
    drop function dbo.fn_ConcatOrders;
go

create function dbo.fn_ConcatOrders(@cid as nchar(5)) returns varchar(8000) as
begin
    declare @orders as varchar(8000);
    set @orders = '';

    select @orders = @orders + cast(SalesOrderID as varchar(10)) + ';'
    from Sales.SalesOrderHeader
    where CustomerID = @cid;

    return @orders;
end
go

select CustomerID, dbo.fn_ConcatOrders(CustomerID) as Orders    -- UWAGA! użuywamy 'from' , nie zapisujemy select nazwa_funkcji, bo to nieeleganckie
from Sales.SalesOrderHeader;


go

if object_id('dbo.fn_ConcatOrders') is not null
    drop function dbo.fn_ConcatOrders;


-- UDF : skalarna z więzami integralności do tabelki
use tempdb;
go

if object_id('dbo.T1') is not null
    drop table dbo.T1;
go

create table dbo.T1
(
    keycol  int not null constraint PK_T1 primary key check (keycol > 0),
    datacol varchar(10) not null
);
go

if object_id('dbo.fn_T1_getkey') is not null
    drop function dbo.fn_T1_getkey;
go

select min(keycol + 1)
from dbo.T1 as A
where not exists ( select *
                   from dbo.T1 as B
                   where B.keycol = A.keycol + 1);

go

create function dbo.fn_T1_getkey() 
returns int as
begin
    return case when not exists ( select *
                                  from dbo.T1
                                  where keycol = 1 ) then 1
                else ( select min(keycol + 1)
                       from dbo.T1 as A
                       where not exists ( select *
                                          from dbo.T1 as B
                                          where B.keycol = A.keycol + 1 ) ) 
			end;
end
go

alter table dbo.T1
    add default (dbo.fn_T1_getkey()) for keycol;				-- tworzymy wiezy integralnosci default, wartości następne będzie brać z tej funkcji
go

-- Test the function:
insert into dbo.T1(datacol) values ('a');

insert into dbo.T1(datacol) values ('b');
 
insert into dbo.T1(datacol) values('c');

---
select keycol+1
from dbo.T1 as A
where not exists ( select *
                   from dbo.T1 as B
                   where B.keycol = A.keycol + 1);

---

delete from dbo.T1 where keycol = 2;

insert into dbo.T1(datacol) values ('d');

select *
from dbo.T1;
go



-- UDF : zwracająca tablicę

set nocount on;

use AdventureWorks2019;
go

if object_id('dbo.fn_GetCustOrders') is not null
    drop function dbo.fn_GetCustOrders;
go

create function dbo.fn_GetCustOrders(@cid as nchar(5))
    returns table as 
                return select SalesOrderID, CustomerID, SalesPersonID, OrderDate, Duedate, ShipDate, Freight
                from sales.salesorderheader
                where CustomerID = @cid;
go

-- Test the function:
select O.SalesOrderID, O.CustomerID, OD.ProductID, OD.OrderQty
from dbo.fn_GetCustOrders('29533') as O
join sales.salesorderdetail as OD on O.SalesOrderID = OD.SalesOrderID;
go


-- UDF : zwracająca tablicę

use tempdb;
go

if object_id('dbo.Employees') is not null
    drop table dbo.Employees;
go

create table dbo.Employees
(
    empid   int         not null primary key,
    mgrid   int         null references dbo.Employees,
    empname varchar(25) not null,
    salary  money       not null
);
go

insert into dbo.Employees(empid, mgrid, empname, salary)
values
    (1, null, 'David', 10000.00),
    (2, 1, 'Eitan', 7000.00),
    (3, 1, 'Ina', 7500.00),
    (4, 2, 'Seraph', 5000.00),
    (5, 2, 'Jiru', 5500.00),
    (6, 2, 'Steve', 4500.00),
    (7, 3, 'Aaron', 5000.00),
    (8, 5, 'Lilach', 3500.00),
    (9, 7, 'Rita', 3000.00),
    (10, 5, 'Sean', 3000.00),
    (11, 7, 'Gabriel', 3000.00),
    (12, 9, 'Emilia', 2000.00),
    (13, 9, 'Michael', 2000.00),
    (14, 9, 'Didi', 1500.00);
go

create unique index idx_unc_mgrid_empid on dbo.Employees (mgrid, empid);
go

if object_id('dbo.fn_subordinates') is not null
    drop function dbo.fn_subordinates;
go

create function dbo.fn_subordinates(@mgrid as int)
    returns @Subs table
                  (
                      empid   int         not null primary key nonclustered,
                      mgrid   int         null,
                      empname varchar(25) not null,
                      salary  money       not null,
                      lvl     int         not null,
                      unique clustered (lvl, empid)
                  ) as
begin
    declare @lvl as int;
    set @lvl = 0;

    insert into @Subs(empid, mgrid, empname, salary, lvl)
    select empid, mgrid, empname, salary, @lvl
    from dbo.Employees
    where empid = @mgrid;

    while @@rowcount > 0 begin
        set @lvl = @lvl + 1;
        insert into @Subs(empid, mgrid, empname, salary, lvl)
        select C.empid, C.mgrid, C.empname, C.salary, @lvl
        from @Subs                  as P
                 join dbo.Employees as C on p.lvl = @lvl - 1 and C.mgrid = p.empid;
    end
    return;
end
go

-- Test the function:
select empid, mgrid, empname, salary, lvl
from dbo.fn_subordinates(3) as S;
go

use tempdb;
go

if object_id('dbo.Employees') is not null
    drop table dbo.Employees;
go

if object_id('dbo.fn_subordinates') is not null
    drop function dbo.fn_subordinates;