// Zadanie Z1
// Proszę zbudować 3 zapytania przy pomocy nie użytych do tej pory operatorów (Tabela 1) 
// dla przykładu przedstawionego w punkcie czwartym laboratorium.

var query1 = samochody
    .Select(s => s.Kolor)
    .Distinct();

Console.WriteLine("Query 1 - Dostepne kolory samochodów:");
foreach (string q in query1)
{
Console.WriteLine(q);
}

bool isThereBlackAudi = samochody.Where(s => s.IDMarka == marki.First(m => m.Nazwa == "Audi").ID).Any(s => s.Kolor == "Czarny");


Console.WriteLine("Query 2 - Czy jest Czarne Audi?:");
Console.WriteLine(isThereBlackAudi);

var liczbaSamochodow = from s in samochody
                       group s by s.IDMarka into g
                       join m in marki on g.Key equals m.ID
                       select new
                       {
                           Marka = m.Nazwa,
                           Ilosc = g.Count()
                       };

Console.WriteLine("Query 3 - Ilosc samochodow kazdej marki:");
foreach (var i in liczbaSamochodow)
{
    Console.WriteLine($"{i.Marka} ilosc : {i.Ilosc}");
}
