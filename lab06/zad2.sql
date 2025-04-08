-- Zadanie 2
-- Opracować procedurę T-SQL tworzącą następujące tabele w utworzonej bazie danych
-- Lab6db oraz odpowiednie relacje pomiędzy tabelami:
-- student ( id int PK, fname varchar(30), lname varchar(30) )
-- wykladowca ( id int PK , fname varchar(30), lname varchar(30) )
-- przedmiot ( id int PK , name varchar(50) )
-- grupa ( id_wykl int, id_stud int, id_przed int )
-- (id_wykl FK(wykladowca id), id_stud FK(student id), id_przed FK(przedmiot id)) PK

use [Lab6db];
go

drop table if exists grupa;
drop table if exists student;
drop table if exists wykladowca;
drop table if exists przedmiot;
go

create table student(
	id int primary key,
	fname varchar(30),
	lname varchar(30)
);
go
create table wykladowca(
	id int primary key,
	fname varchar(30),
	lname varchar(30)
);
go
create table przedmiot(
	id int primary key,
	name varchar(50)
);
go
create table grupa(
	id_wykl int references wykladowca(id),
	id_stud int references student(id),
	id_przed int references przedmiot(id),
	primary key (id_wykl, id_stud, id_przed)
);
go
