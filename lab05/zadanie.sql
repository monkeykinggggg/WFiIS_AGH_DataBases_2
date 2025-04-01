-- Zadanie 1
USE [master]
GO

-- loginy dla grup: grupa1, grupa2
CREATE LOGIN [WINSERV01\grupa1] FROM WINDOWS WITH DEFAULT_DATABASE=[AdventureWorks2019], DEFAULT_LANGUAGE=[us_english]
GO

GARNT CONNECT SQL TO [WINSERV01\grupa1]
GO


CREATE LOGIN [WINSERV01\grupa2] FROM WINDOWS WITH DEFAULT_DATABASE=[AdventureWorks2019], DEFAULT_LANGUAGE=[us_english]
GO

DENY CONNECT SQL TO [WINSERV01\grupa2]
GO

-- sprawdzamy nadane uprawnienia
select name, princ.type_desc, princ.default_database_name, perm.permission_name, perm.state_desc
from sys.server_principals as princ
left join sys.server_permissions as perm on princ.principal_id = perm.grantee_principal_id and perm.class_desc = 'SERVER'
where princ.name in ('WINSERV01\grupa1', 'WINSERV01\grupa2');



-- Odpowiedzi na pytania:
-- Jakie jest efektywne uprawnienie dla użytkownika należącego do obu grup?
/*
 grupa1 ma zagwarantowane logowanie, a grupa2 ma zablokowane. Użytkownik tester3 należy do obu grup.
 Deny ma wyższy priorytet, niż grant.
 Zatem tester3 nie może się zalogować.
 Mamy to zaprezentowane na obrazku 'zad1b.ong', gdzie próbuje się zalogować jako tester3.
 */

-- Jakie są uprawnienia (jaka rola) do domyślnej bazy danych?
/*
 Zanim użytkownik nie zostanie utworzony i zmapowany do loginu, nie ma żadnych uprawnień do bazy.
 My na razie utworzyliśmy tylko loginy (na poziomie serwera), a nie użytkowników.
 Jeśli utworzymy tylko login, ale nie stworzymy odpowiadającego mu usera w bazie,
to login nie ma dostępu do tej bazy.
 Dopiero gdy wykonamy CREATE USER w bazie i powiążemy go z loginem, to będzie on miał uprawnienia roli public w tej bazie.

Efekt aktualnych uprawnień można zobaczyć na obrazku : 'zad1c.png', gdzie próbuję wykonać select na bazie domśylnej AdventureWorks2019 jako tester1
 
 */

-- jako tester1 próbuję:
use AdventureWorks2019;
go

select top 2 * from Person.Address;
-- dostaję zad1c.png

-- tworzę użytkownika w bazie AdventureWorks2019
-- i mapuję go do loginu
USE [AdventureWorks2019]
GO

CREATE USER [WINSERV01\grupa1] FOR LOGIN [WINSERV01\grupa1]
GO

CREATE USER [WINSERV01\grupa2] FOR LOGIN [WINSERV01\grupa2]
GO

-- teraz tester1 widzi bazę AdventureWorks2019, ale nie ma do niej uprawnień, bo uprawnienia domyślne są public
ALTER ROLE db_datareader ADD MEMBER [WINSERV01\grupa1];

-- teraz tester1 widzi bazę AdventureWorks2019, widzi tabele (wcześniej się nie rozwiłały) 


-- napisany wyzwalacz:
USE master;
GO

IF OBJECT_ID('dbo.LoginStatus') IS NOT NULL
	DROP TABLE dbo.LoginStatus;
GO

CREATE TABLE dbo.LoginStatus (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    LoginName NVARCHAR(100),
    LoginTime DATETIME DEFAULT GETDATE(),
    HostName NVARCHAR(100)
);
GO

IF EXISTS (SELECT * FROM sys.server_triggers WHERE name = 'trg_LogonAudit')
    DROP TRIGGER trg_LogonAudit ON ALL SERVER;
GO

CREATE TRIGGER trg_LogonAudit
ON ALL SERVER
FOR LOGON
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT * FROM master.dbo.LoginStatus WHERE LoginName = ORIGINAL_LOGIN())
        BEGIN
            INSERT INTO master.dbo.LoginStatus (LoginName, LoginTime, HostName)
            VALUES (ORIGINAL_LOGIN(), GETDATE(), HOST_NAME());
        END
    END TRY
    BEGIN CATCH
        -- Silently handle errors to prevent login failures
    END CATCH;
END;


SELECT * FROM master.dbo.LoginStatus;
GO

DISABLE TRIGGER trg_LogonAudit ON ALL SERVER;
GO

-- Zadanie 2
use [master];
go

-- Utworzenie loginu dla grupa3
create login [WINSERV01\grupa3] from windows with default_database = [master];
go

exec sp_addsrvrolemember @loginame = N'WinServ01\grupa3', @rolename = N'dbcreator';
go

exec sp_addsrvrolemember @loginame = N'WinServ01\grupa3', @rolename = N'serveradmin';
go

-- sprawdzamy ustawienia:
select 'grupa3'                                            as ServerLogin,
       is_srvrolemember('dbcreator', 'WINSERV01\grupa3')   as IsDbCreator,
       is_srvrolemember('serveradmin', 'WINSERV01\grupa3') as IsServerAdmin;
go

-- wynik: 'zad2a.png'

-- loguje się jako tester6, wykonuje dwa testy, których wyniki znajdują się w plikach 'zad2b.png' i 'zad2c.png'
create database TestDatabase1;
go
drop database TestDatabase1;
go
exec sp_configure 'show advanced options', 1;
go
reconfigure;
go


-- Zadanie 3
use [AdventureWorks2019];
go

-- Przydzielamy dla grup uprawnienia roli: db_datawriter.
exec sp_addrolemember 'db_datawriter', 'WINSERV01\grupa1';
go

exec sp_addrolemember 'db_datawriter', 'WINSERV01\grupa2';
go

-- Użytkownik tester3 ma uprawnienia sysadmin.
create login [WINSERV01\tester3] from windows with default_database = [AdventureWorks2019];
go

exec sp_addsrvrolemember @loginame = N'WINSERV01\tester3', @rolename = N'sysadmin';
go

-- Użytkownicy tester2 i tester4 posiadają tylko uprawnienia do SELECT.
create login [WINSERV01\tester2] from windows with default_database = [AdventureWorks2019];
go

create login [WINSERV01\tester4] from windows with default_database = [AdventureWorks2019];
go

create user [WINSERV01\tester2] for login [WINSERV01\tester2];
go

create user [WINSERV01\tester4] for login [WINSERV01\tester4];
go

exec sp_addrolemember 'db_datareader', 'WINSERV01\tester2';
go
exec sp_addrolemember 'db_datareader', 'WINSERV01\tester4';
go

exec sp_addrolemember 'db_denydatawriter', 'WINSERV01\tester2';
go
exec sp_addrolemember 'db_denydatawriter', 'WINSERV01\tester4';
go

-- Realizacja lab04.26
deny select on object::Person.PersonPhone to [WINSERV01\tester2];
go

grant execute on dbo.usp_GetSortedPersons to [WINSERV01\tester2];
go

-- testy ustawień w plikach 'zad3*.png'
