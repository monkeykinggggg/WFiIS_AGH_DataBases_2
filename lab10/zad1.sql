-- Zadanie 1
-- Opracować wyzwalacz, który po dodaniu rekordu do tablicy „test1” 
-- wprowadzi rekord do utworzonej na potrzeby zadania tablicy logu zawierający datę
-- wprowadzenia rekordu, wprowadzone dane oraz nazwę użytkownika. 

use lab10;
go
drop table if exists test1;
go

create table test1
(
    id int identity (1,1) primary key,
    data nvarchar(max) not null
);
go

drop table if exists test1_log;
go

create table test1_log
(
    log_id     int identity (1,1) primary key,
    log_date   datetimeoffset default sysdatetimeoffset() not null,
    user_login nvarchar(max)                              not null,
    data       nvarchar(max)                              not null
);
go

-- testowanie wyzwalacza
use lab10;
go

insert into test1(data) values
    (N'My First line'),
    (N'Hi!!!');
go

select * from test1;
go

select * from test1_log;
go

