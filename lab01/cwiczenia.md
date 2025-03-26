Połączenie do wirtualnego Windowsa poprzez RDP (Remote Desktop Protocol).
Na linuxie wydziałowym uruchom w terminalu:
```bash
rdesktop my_rdp_server_IP [-u username] [-p password]
```

Aby uruchomić i połączyć się do instancji MS SQL Server na wirtualnym Windowsie, należy użyć programu SSMS (SQL Server Management Studio) - zakładka Tools.

Aby wyświetlić listę baz danych, użyj:
```sql
SELECT Name from sys.Databases;

/*
Dostajemy:
master  
tempdb  
model  
msdb
AdventureWorks2019
AdventureWorksDW2019
*/

```

Aby wybrać bazę danych, użyj:
```sql
USE AdventureWorks2017;
```