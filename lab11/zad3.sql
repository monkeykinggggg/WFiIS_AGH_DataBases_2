-- Opracować zapytanie zwracające rekordy zawierające wartość elementu TotalChildren większe od 1
-- znajdującego się w dokumencie XML w atrybucie Demographics typu XML w widoku Sales.vIndividualCustomer. 

use AdventureWorks2019;
go

select BusinessEntityID, FirstName, LastName, Demographics
from Sales.vIndividualCustomer
where Demographics.exist('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";
                         /IndividualSurvey[TotalChildren > 1]') = 1;
go