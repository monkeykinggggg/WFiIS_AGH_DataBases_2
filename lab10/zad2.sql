--  Zadanie 2
--  Opracować kod SQL zawierający dwie tabele połączone zależnością n-m z tablicą asocjacyjną wraz
--  z procedurą CLR wstawiająca dane do tych trzech tabel w ramach transakcji. 

use lab10;
go

drop table if exists a;
go

create table a
(
    a_id int identity (1,1) primary key,
    data nvarchar(100) not null
);
go

drop table if exists b;
go

create table b
(
    b_id int identity (1,1) primary key,
    data nvarchar(100) not null
);
go

drop table if exists a_b;
go

create table a_b
(
    ab_a_id int not null foreign key references a (a_id),
    ab_b_id int not null foreign key references b (b_id),
    primary key (ab_a_id, ab_b_id)
);
go




-- testowanie
use lab10;
go

exec sp_InsertAandB @a_data = 'aaaa', @b_data = 'bbbb';
go

select * from [dbo].[a];

select * from [dbo].[b];

select * from [dbo].[a_b];
go


exec sp_InsertAandB @a_data = 'a2', @b_data = 'b2';
go

select * from [dbo].[a];

select * from [dbo].[b];

select * from [dbo].[a_b];
go
