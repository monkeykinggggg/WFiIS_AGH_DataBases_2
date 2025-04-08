using System;
using System.Data;
using Microsoft.Data.SqlClient;
using System.IO;

namespace Lab6
{
	class Program
	{
		static string connectionString = @"Data Source=WINSERV01;Initial Catalog=Lab6db;User ID=Lab6user;Password=Passw0rd;TrustServerCertificate=True;";

		static void Main()
		{
			try
			{
				using (var connection = new SqlConnection(connectionString))
				{
					connection.Open();
					Console.WriteLine("Połączono z bazą danych.");
				}
				Console.WriteLine("Current directory: " + Environment.CurrentDirectory);
				ImportFromCSV();

				GetStudentCountPerLecturer();
				GetStudentCountForSubject(1);
			}
			catch (Exception ex)
			{
				Console.WriteLine("Błąd: " + ex.Message);
			}

			Console.WriteLine("Naciśnij dowolny klawisz, aby zakończyć...");
			Console.ReadKey();
		}

		static void ImportFromCSV()
		{
			var importDefinitions = new (string file, string query, Action<SqlCommand, string[]> addParams)[]
			{
				("student.csv", "INSERT INTO student (id, fname, lname) VALUES (@id, @fname, @lname)", (cmd, parts) => {
					cmd.Parameters.AddWithValue("@id", int.Parse(parts[0]));
					cmd.Parameters.AddWithValue("@fname", parts[1]);
					cmd.Parameters.AddWithValue("@lname", parts[2]);
				}),

				("wykladowca.csv", "INSERT INTO wykladowca (id, fname, lname) VALUES (@id, @fname, @lname)", (cmd, parts) => {
					cmd.Parameters.AddWithValue("@id", int.Parse(parts[0]));
					cmd.Parameters.AddWithValue("@fname", parts[1]);
					cmd.Parameters.AddWithValue("@lname", parts[2]);
				}),

				("przedmiot.csv", "INSERT INTO przedmiot (id, name) VALUES (@id, @name)", (cmd, parts) => {
					cmd.Parameters.AddWithValue("@id", int.Parse(parts[0]));
					cmd.Parameters.AddWithValue("@name", parts[1]);
				}),

				("grupa.csv", "INSERT INTO grupa (id_wykl, id_stud, id_przed) VALUES (@id_wykl, @id_stud, @id_przed)", (cmd, parts) => {
					cmd.Parameters.AddWithValue("@id_wykl", int.Parse(parts[0]));
					cmd.Parameters.AddWithValue("@id_stud", int.Parse(parts[1]));
					cmd.Parameters.AddWithValue("@id_przed", int.Parse(parts[2]));
				}),
			};

			foreach (var (file, query, addParams) in importDefinitions)
			{
				ImportData(file, query, addParams);
			}
		}

		static void ImportData(string filename, string query, Action<SqlCommand, string[]> addParams)
		{
			string baseDir = AppDomain.CurrentDomain.BaseDirectory;
			string projectDir = Path.GetFullPath(Path.Combine(baseDir, @"..\..\..\"));
			string fullPath = Path.Combine(projectDir, filename);

			Console.WriteLine(fullPath);
			if (!File.Exists(fullPath))
			{
				Console.WriteLine($"Nie odnaleziono pliku: {filename}!");
				return;
			}

			var lines = File.ReadAllLines(fullPath);
			using var conn = new SqlConnection(connectionString);
			conn.Open();

			foreach (var line in lines)
			{
				if (string.IsNullOrWhiteSpace(line)) continue;

				var parts = line.Split(',');
				using var cmd = new SqlCommand(query, conn);
				addParams(cmd, parts);
				cmd.ExecuteNonQuery();
			}

			Console.WriteLine($"Wczytano dane z: {filename}!");
		}

		static void GetStudentCountPerLecturer()
		{
			const string query = @"
                SELECT w.id, w.fname, w.lname, COUNT(g.id_stud) AS StudentCount
                FROM wykladowca w
                LEFT JOIN grupa g ON w.id = g.id_wykl
                GROUP BY w.id, w.fname, w.lname";

			ExecuteReader(query, reader =>
			{
				Console.WriteLine("Liczba studentów per wykładowca:");
				while (reader.Read())
				{
					Console.WriteLine($"ID: {reader["id"]}, Imię i nazwisko: {reader["fname"]} {reader["lname"]}, Studenci: {reader["StudentCount"]}");
				}
			});
		}

		static void GetStudentCountForSubject(int subjectId)
		{
			const string query = @"
                SELECT p.id, p.name, COUNT(g.id_stud) AS StudentCount
                FROM przedmiot p
                LEFT JOIN grupa g ON p.id = g.id_przed
                WHERE p.id = @subjectId
                GROUP BY p.id, p.name";

			ExecuteReader(query, reader =>
			{
				if (reader.Read())
				{
					Console.WriteLine($"ID przedmiotu: {reader["id"]}, nazwa: {reader["name"]}, liczba studentów: {reader["StudentCount"]}");
				}
				else
				{
					Console.WriteLine($"Brak studentów dla przedmiotu o ID {subjectId}.");
				}
			}, cmd => cmd.Parameters.AddWithValue("@subjectId", subjectId));
		}

		static void ExecuteReader(string query, Action<SqlDataReader> handleData, Action<SqlCommand> addParams = null)
		{
			using var conn = new SqlConnection(connectionString);
			using var cmd = new SqlCommand(query, conn);
			addParams?.Invoke(cmd);
			conn.Open();

			using var reader = cmd.ExecuteReader();
			handleData(reader);
		}
	}
}
