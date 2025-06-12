using Microsoft.Data.SqlClient;
using System;
using System.Data;
using System.Globalization;
using System.IO;
using System.Xml.Linq;

namespace Lab14
{
    class Program
    {
        static string connectionString = @" Persist Security Info=False;Trusted_Connection=True; Encrypt=False; database=Pomiary;server=(local)";
        static void Main(string[] args)
        {
            try
            {
                Console.WriteLine("0. Utworz tabele");
                Console.WriteLine("1. Import CSV");
                Console.WriteLine("2. Pokaż statystyki");
                Console.Write("Wybierz opcję: ");
                string choice = Console.ReadLine();

                if (choice == "0")
                    CreateTables();
                else if (choice == "1")
                    ImportCSV();
                else if (choice == "2")
                    ShowStats();
                else
                    Console.WriteLine("Nieznana opcja.");
;
            }
            catch (Exception ex)
            {
                Console.WriteLine("Exception: " + ex.Message);
            }

            Console.WriteLine("Wcisnij klawisz...");
            Console.ReadKey();
        }

        static void CreateTables()
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                Console.WriteLine("Polaczono z baza");

                using (SqlCommand cmd = new SqlCommand("usp_create_tables", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.ExecuteNonQuery();
                    Console.WriteLine("Utworzono tabele!");
                }
            }
        }

        static void ImportCSV()
        {
            ImportData("C:\\Users\\Administrator\\Desktop\\Lab11\\LINQ_Console_Application\\LINQ_Console_Application\\pomiary2.csv", "INSERT INTO Pomiary (data, ch4, co2, pm1, pm25, pm10) VALUES (@data, @ch4, @co2,@pm1, @pm25, @pm10)", (cmd, parts) =>
            {
                DateTime fullDate = DateTime.ParseExact(parts[0], "dd-MM-yyyy HH:mm:ss", CultureInfo.InvariantCulture);
                //DateTime onlyDate = fullDate.Date;
             
                cmd.Parameters.AddWithValue("@data", fullDate);
               
                decimal ch4Value = Math.Round(decimal.Parse(parts[12], CultureInfo.InvariantCulture), 2);
                cmd.Parameters.AddWithValue("@ch4", ch4Value);

              
                cmd.Parameters.AddWithValue("@co2", (int)double.Parse(parts[22], CultureInfo.InvariantCulture));

                cmd.Parameters.AddWithValue("@pm1", (int)double.Parse(parts[13], CultureInfo.InvariantCulture));
                
                cmd.Parameters.AddWithValue("@pm25", (int)double.Parse(parts[14], CultureInfo.InvariantCulture));
                
                cmd.Parameters.AddWithValue("@pm10", (int)double.Parse(parts[15], CultureInfo.InvariantCulture));
            });

        }

        static void ImportData(string filename, string query, Action<SqlCommand, string[]> addParam)
        {
            if (!File.Exists(filename))
            {
                Console.WriteLine("Nie odnaleziono pliku: " + filename + "!");
                return;
            }

            string[] lines = File.ReadAllLines(filename);

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                foreach (string line in lines)
                {
                    if (string.IsNullOrWhiteSpace(line))
                    {
                        continue;
                    }

                    string[] parts = line.Split(';');

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        addParam(cmd, parts);
                        cmd.ExecuteNonQuery();
                    }
                }

                Console.WriteLine("Wczytano dane z: " + filename + "!");
            }
        }

        static void GetStudentCountPerLecturer()
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                string query = @"
                    select w.id, w.fname, w.lname, count(g.id_stud) as StudentCount
                    from wykladowca w
                    left join grupa g on w.id = g.id_wykl
                    group by w.id, w.fname, w.lname";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        Console.WriteLine("Liczba studentow per wykladowca:");
                        while (reader.Read())
                        {
                            Console.WriteLine("ID wykladowcy: {0}, imie i nazwisko: {1} {2}, liczba studentow: {3}", reader["id"], reader["fname"], reader["lname"], reader["StudentCount"]);
                        }
                    }
                }
            }
        }

        static void ShowStats()
        {
            Console.Write("Podaj datę początkową (format: yyyy-MM-dd HH:mm:ss): ");
            DateTime from = DateTime.ParseExact(Console.ReadLine(), "yyyy-MM-dd HH:mm:ss", CultureInfo.InvariantCulture);

            Console.Write("Podaj datę końcową (format: yyyy-MM-dd HH:mm:ss): ");
            DateTime to = DateTime.ParseExact(Console.ReadLine(), "yyyy-MM-dd HH:mm:ss", CultureInfo.InvariantCulture);

            Console.Write("Podaj długość przedziału czasowego w minutach (np. 10): ");
            int interval = int.Parse(Console.ReadLine());

            string query = @"
                SELECT 
                    DATEADD(MINUTE, DATEDIFF(MINUTE, 0, data) / @interval * @interval, 0) AS IntervalStart,
                    COUNT(*) AS MeasurementCount,
                    MIN(ch4) AS MinValue,
                    MAX(ch4) AS MaxValue
                FROM Pomiary
                WHERE data BETWEEN @from AND @to
                GROUP BY DATEADD(MINUTE, DATEDIFF(MINUTE, 0, data) / @interval * @interval, 0)
                ORDER BY IntervalStart;";

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@from", from);
                    cmd.Parameters.AddWithValue("@to", to);
                    cmd.Parameters.AddWithValue("@interval", interval);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        Console.WriteLine("\nInterval Start\t\tCount\tMin\tMax");

                        while (reader.Read())
                        {
                            DateTime intervalStart = reader.GetDateTime(0);
                            int count = reader.GetInt32(1);
                            double min = reader.GetDouble(2);
                            double max = reader.GetDouble(3);

                            Console.WriteLine($"{intervalStart:yyyy-MM-dd HH:mm}\t{count}\t{min}\t{max}");
                        }
                    }
                }
            }
        }


       
    }
}
