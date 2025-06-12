using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using Microsoft.SqlServer.Server;

public partial class Triggers
{
    [SqlTrigger(Event = "after insert", Name = "trigger_test1_insert_log", Target = "test1")]
    public static void LogInsertOnTest1()
    {
        SqlContext.Pipe.Send("Trigger trigger_test1_insert_log FIRED");

        using (SqlConnection conn = new SqlConnection("context connection = true"))
        {
            conn.Open();

            SqlCommand cmdUserLogin = conn.CreateCommand();
            cmdUserLogin.CommandText = "select suser_name()";
            string userLogin = (string)cmdUserLogin.ExecuteScalar();

            List<string> insertedValues = new List<string>();
            var cmdSelectInserted = conn.CreateCommand();
            cmdSelectInserted.CommandText = "select data from inserted";
            using (SqlDataReader reader = cmdSelectInserted.ExecuteReader())
            {
                while (reader.Read())
                {
                    insertedValues.Add(reader.GetString(0));
                }
            }

            var cmdInsertToLog = conn.CreateCommand();
            cmdInsertToLog.CommandText = @"insert into test1_log (user_login, data) values (@user_login, @data)";
            cmdInsertToLog.Parameters.AddWithValue("@user_login", userLogin);
            var dataParameter = cmdInsertToLog.Parameters.Add("@data", SqlDbType.NVarChar);

            foreach (var dataValue in insertedValues)
            {
                dataParameter.Value = dataValue;
                cmdInsertToLog.ExecuteNonQuery();
            }
        }
    }
}