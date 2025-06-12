-- Zadanie 1
-- Opracować dodatkowe metody do przedstawionego w przykładzie Lab09.05 typu użytkownika (UDT) reprezentującego liczbę zespoloną realizujące następujące zadania:
-- liczba zespolona sprzężona i moduł z liczby zespolonej. 
declare @t_complex table
(
    z dbo.ComplexNumber
);

insert into @t_complex
values
    ('3+5i'),
    ('-1+1i'),
    (null);

select z.ToString() as number from @t_complex;

select z.ToString() as number,
		z.Conjugate().ToString() as sprzezenie,
		z.Modulus() as modul
from @t_complex;
go