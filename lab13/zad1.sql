-- Zadanie 1
/*
W ramach serwera MS SQL Server utworzyć bazę danych „pomiary” – użytkownik SQL
„pomiar”. Należy podać polecenia T-SQL tworzące użytkownika i bazę danych
*/

use [master];
go

-- tworzymy nowy login
if exists ( select name
            from sys.server_principals
            where name = 'pomiar' )
    begin
        drop login [pomiar];
    end;
go

create login [pomiar] with password = 'Passw0rd';
go

-- tworzymy nową bazę danych
if exists ( select name
            from sys.databases
            where name = 'pomiary' )
    begin
        -- dla bezpieczeństwa rozłączmy wszystkich poza nami
        alter database pomiary set single_user with rollback immediate;
        drop database pomiary;
    end;
go

create database pomiary;
go

-- tworzymy nowego użytkownika w bazie
use [pomiary];
go

drop user if exists [pomiar];
go

create user [pomiar] for login [pomiar];
go

-- przypisujemy użytkownika do roli
alter role [db_owner] add member [pomiar];
go