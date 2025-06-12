// ============================================================

// Zadanie Z3
// Napisać kod tworzący dokument XML z następującą zawartością:

// <lista>, 
//   <-- kilka elelmentów osoba -->
//   <osoba> <nazwisko> <imie> 
//      <adres> <miejscowość> <kod> <ulica> <numer_domu> </adres> 
//   </osoba>
// </lista>

using System;
using System.IO;
using System.Xml.Linq;

namespace LinqToXmlExample
{
    class Program
    {
        static void Main(string[] args)
        {
            XDocument xmlDocument = CreatePersonListXml();
            DisplayXml(xmlDocument);
        }

        static XDocument CreatePersonListXml()
        {
            return new XDocument(
                new XElement("lista",
                    CreatePersonElement("Fiutowski", "Przemek", "Krakow", "32-004", "Jubilska", "30/15"),
                    CreatePersonElement("Bal", "Aleksandra", "Warszawa", "00-000", "Krakowska", "7")
                )
            );
        }

        static XElement CreatePersonElement(string lastName, string firstName,
                                          string city, string zipCode,
                                          string street, string houseNumber)
        {
            return new XElement("osoba",
                new XElement("nazwisko", lastName),
                new XElement("imie", firstName),
                new XElement("adres",
                    new XElement("miejscowosc", city),
                    new XElement("kod", zipCode),
                    new XElement("ulica", street),
                    new XElement("numer_domu", houseNumber)
                )
            );
        }


        static void DisplayXml(XDocument xmlDocument)
        {
            using (StringWriter sw = new StringWriter())
            {
                xmlDocument.Save(sw);
                Console.WriteLine(sw.ToString());
            }
        }
    }
}