// Zadanie Z2
// W ramach zadania przygotować program, które utworzy bazę danych student, następnie utworzy dwie tabele "student" i "kierunek".
// Studenci należą do określonego kierunku. Do opracowanej bazy danych należy dodać kierunki oraz studentów do określonych kierunków.
// W ramach zadania należy przyjąć, że relacja pomiędzy kierunkiem i studentami jest 1-N. W kolejnym etapie należy opracować program, 
// który odczyta studentów wraz z odpowiadającym mu kierunkiem.


using System;
using System.Data.Linq;
using System.Data.Linq.Mapping;
using System.Linq;

namespace StudentDatabase
{
    [Table(Name = "Kierunek")]
    public class Kierunek
    {
        [Column(IsPrimaryKey = true, IsDbGenerated = true)]
        public int Id { get; set; }

        [Column]
        public string Nazwa { get; set; }
    }

    [Table(Name = "Student")]
    public class Student
    {
        [Column(IsPrimaryKey = true, IsDbGenerated = true)]
        public int Id { get; set; }

        [Column]
        public string Imie { get; set; }

        [Column]
        public string Nazwisko { get; set; }

        [Column]
        public int KierunekId { get; set; }
    }

    public class StudentDataContext : DataContext
    {
        public Table<Kierunek> Kierunki;
        public Table<Student> Studenci;

        public StudentDataContext(string connection) : base(connection) { }
    }

    class Program
    {
        static void Main()
        {
            string connectionString = @"Data Source=.;Initial Catalog=StudentDB;Integrated Security=True";

            using (var db = new StudentDataContext(connectionString))
            {
                if (db.DatabaseExists())
                    db.DeleteDatabase();

                db.CreateDatabase();

                var kierunki = new Kierunek[]
                {
                    new Kierunek { Nazwa = "Informatyka" },
                    new Kierunek { Nazwa = "Matematyka" },
                    new Kierunek { Nazwa = "Fizyka" }
                };

                db.Kierunki.InsertAllOnSubmit(kierunki);
                db.SubmitChanges();

                var studenci = new Student[]
                {
                    new Student { Imie = "Anna", Nazwisko = "Kulka", KierunekId = 1 },
                    new Student { Imie = "Joanna", Nazwisko = "Nowak", KierunekId = 1 },
                    new Student { Imie = "Ewelina", Nazwisko = "Kowalska", KierunekId = 2 },
                    new Student { Imie = "Bartosz", Nazwisko = "Rydzak", KierunekId = 3 }
                };

                db.Studenci.InsertAllOnSubmit(studenci);
                db.SubmitChanges();

                var query = from student in db.Studenci
                                join kierunek in db.Kierunki on student.KierunekId equals kierunek.Id
                                select new
                                {
                                    student.Imie,
                                    student.Nazwisko,
                                    Kierunek = kierunek.Nazwa
                                };

                Console.WriteLine("Studenci z kierunkami:");

                foreach (var q in query)
                {
                    Console.WriteLine($"{q.Imie} {q.Nazwisko} - {q.Kierunek}");
                }
            }
        }
    }
}