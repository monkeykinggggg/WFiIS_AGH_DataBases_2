-- W ramach zadania należy opracować skrypt T-SQL tworzący tabelę zawierającą następujące atrybuty:
-- id integer PK, nazwisko varchar(30), imie varchar(20), adres XML. 
-- Typ dokument XML powinien zawierać element <adres> oraz elementy potomne <miejscowość>, <kod>, <ulica> oraz <numer_domu> i <numer_mieszkania>.
-- Należy przygotować XML Schema do dokumentu XML (numer_mieszkania może być opcjonalny).
-- W ramach skryptu należy dodać przykładowy rekord danych i sprawdzający poprawność wstawienia danych do tabeli. 

use lab11;
go

create xml schema collection AddressSchema as N'
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xs:element name="adres">
        <xs:complexType>
            <xs:sequence>
                <xs:element name="miejscowosc" type="xs:string"/>
                <xs:element name="kod" type="xs:string"/>
                <xs:element name="ulica" type="xs:string"/>
                <xs:element name="numer_domu" type="xs:nonNegativeInteger"/>
                <xs:element name="numer_mieszkania" type="xs:nonNegativeInteger" minOccurs="0"/>
            </xs:sequence>
        </xs:complexType>
    </xs:element>
</xs:schema>';
go

create table Osoby(
	id int primary key,
	nazwisko varchar(30) not null,
	imie varchar(20) not null,
	adres xml(AddressSchema) not null
);
go


insert into Osoby(id, nazwisko, imie, adres)
values
    (1, 'Lis', 'Jerzy', N'
    <adres>
        <miejscowosc>Kraków</miejscowosc>
        <kod>30-059</kod>
        <ulica>Adama Mickiewicza</ulica>
        <numer_domu>30</numer_domu>
    </adres>');
go

select * from osoby;
go