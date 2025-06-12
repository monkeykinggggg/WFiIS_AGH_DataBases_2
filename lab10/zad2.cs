using System;
using System.Data.SqlClient;
using System.Transactions;
using Microsoft.SqlServer.Server;

public partial class StoredProcedures
{
    [SqlProcedure(Name = "sp_InsertAandB")]
    public static void InsertAandB(string a_data, string b_data)
    {
        using (var tx = new TransactionScope())
        using (var conn = new SqlConnection("context connection = true"))
        {
            conn.Open();

            var cmdA = new SqlCommand("insert a(data) values(@a_data); select scope_identity();", conn);
            cmdA.Parameters.AddWithValue("@a_data", a_data);
            int newA = Convert.ToInt32(cmdA.ExecuteScalar());

            var cmdB = new SqlCommand("insert b(data) values(@b_data); select scope_identity();", conn);
            cmdB.Parameters.AddWithValue("@b_data", b_data);
            int newB = Convert.ToInt32(cmdB.ExecuteScalar());

            var cmdAB = new SqlCommand("insert a_b(ab_a_id, ab_b_id) values(@a, @b);", conn);
            cmdAB.Parameters.AddWithValue("@a", newA);
            cmdAB.Parameters.AddWithValue("@b", newB);
            cmdAB.ExecuteNonQuery();

            tx.Complete();
        }
    }
}