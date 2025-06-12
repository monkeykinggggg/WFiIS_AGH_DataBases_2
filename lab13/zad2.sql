-- Utworzenie procedury do utworzenia odpowiednich tabelek

use [pomiary];
go

drop procedure if exists usp_create_tables;
go

create procedure usp_create_tables as
begin
    set nocount on;

    drop table if exists Pomiary;

    create table Pomiary (
		id int identity(1,1) primary key,
		[data] date not null,
		ch4 decimal(10,2) not null,
		co2 int not null,
		pm1 int not null,
		pm25 int not null,
		pm10 int not null,
	);
end
go