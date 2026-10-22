using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Mvc;
using POO1_EF_CASTAÑEDA_MENENDEZ.Models;

namespace POO1_EF_CASTAÑEDA_MENENDEZ.Controllers
{
    public class ConsumidorController : Controller
    {
        string cadenaConexion = ConfigurationManager.ConnectionStrings["cadenaConexion"].ConnectionString;

        public ActionResult Index()
        {
            ViewBag.Mensaje = TempData["Mensaje"];
            return View(listarConsumidores());
        }

        public ActionResult Create()
        {
            return View(new Consumidor());
        }

        [HttpPost]
        public ActionResult Create(Consumidor consumidor)
        {
            TempData["Mensaje"] = agregarConsumidor(consumidor);
            return RedirectToAction("Index");
        }

        [HttpPost]
        public ActionResult Delete(string dnicont)
        {
            TempData["Mensaje"] = eliminarConsumidor(dnicont);
            return RedirectToAction("Index");
        }

        public ActionResult Update(string dnicont)
        {
            string mensaje;
            Consumidor consumidor = obtenerConsumidor(dnicont, out mensaje);

            if (consumidor == null)
            {
                TempData["Mensaje"] = mensaje;
                return RedirectToAction("Index");
            }

            ViewBag.Mensaje = mensaje;
            return View(consumidor);
        }

        [HttpPost]
        public ActionResult Update(Consumidor consumidor)
        {
            TempData["Mensaje"] = actualizarConsumidor(consumidor);
            return RedirectToAction("Index");
        }

        List<Consumidor> listarConsumidores()
        {
            List<Consumidor> listaConsumidores = new List<Consumidor>();

            SqlConnection sqlConnection = new SqlConnection(cadenaConexion);
            sqlConnection.Open();

            SqlCommand sqlCommand = new SqlCommand("usp_listar_consumidor", sqlConnection);
            sqlCommand.CommandType = CommandType.StoredProcedure;

            SqlDataReader sqlDataReader = sqlCommand.ExecuteReader();
            while (sqlDataReader.Read())
            {
                listaConsumidores.Add(new Consumidor(
                    sqlDataReader.GetString(0),
                    sqlDataReader.GetString(1),
                    sqlDataReader.GetString(2),
                    sqlDataReader.IsDBNull(3) ? "" : sqlDataReader.GetString(3),
                    sqlDataReader.GetString(4),
                    sqlDataReader.IsDBNull(5) ? "" : sqlDataReader.GetString(5)
                ));
            }

            sqlDataReader.Close();
            sqlConnection.Close();

            return listaConsumidores;
        }

        string agregarConsumidor(Consumidor consumidor)
        {
            string mensajePais;
            string idpais = registrarPais(consumidor.nompais, out mensajePais);

            if (idpais == "")
            {
                return mensajePais;
            }

            consumidor.idpais = idpais;

            SqlConnection sqlConnection = new SqlConnection(cadenaConexion);
            sqlConnection.Open();

            SqlCommand sqlCommand = new SqlCommand("usp_agrega_consumidor", sqlConnection);
            sqlCommand.CommandType = CommandType.StoredProcedure;

            sqlCommand.Parameters.AddWithValue("@dnicont", consumidor.dnicont ?? "");
            sqlCommand.Parameters.AddWithValue("@nomcont", consumidor.nomcont ?? "");
            sqlCommand.Parameters.AddWithValue("@apecont", consumidor.apecont ?? "");
            sqlCommand.Parameters.AddWithValue("@emailcont", (object)consumidor.emailcont ?? DBNull.Value);
            sqlCommand.Parameters.AddWithValue("@idpais", consumidor.idpais ?? "");
            sqlCommand.Parameters.Add("@mensaje", SqlDbType.VarChar, 100).Direction = ParameterDirection.Output;

            sqlCommand.ExecuteNonQuery();
            string mensaje = sqlCommand.Parameters["@mensaje"].Value.ToString();

            sqlConnection.Close();

            return mensaje;
        }

        string eliminarConsumidor(string dnicont)
        {
            SqlConnection sqlConnection = new SqlConnection(cadenaConexion);
            sqlConnection.Open();

            SqlCommand sqlCommand = new SqlCommand("usp_eliminar_consumidor", sqlConnection);
            sqlCommand.CommandType = CommandType.StoredProcedure;

            sqlCommand.Parameters.AddWithValue("@dnicont", dnicont);
            sqlCommand.Parameters.Add("@mensaje", SqlDbType.VarChar, 100).Direction = ParameterDirection.Output;

            sqlCommand.ExecuteNonQuery();
            string mensaje = sqlCommand.Parameters["@mensaje"].Value.ToString();

            sqlConnection.Close();

            return mensaje;
        }

        string registrarPais(string nompais, out string mensaje)
        {
            SqlConnection sqlConnection = new SqlConnection(cadenaConexion);
            sqlConnection.Open();

            SqlCommand sqlCommand = new SqlCommand("usp_registrar_pais", sqlConnection);
            sqlCommand.CommandType = CommandType.StoredProcedure;

            sqlCommand.Parameters.AddWithValue("@nompais", nompais ?? "");
            sqlCommand.Parameters.Add("@idpais", SqlDbType.Char, 3).Direction = ParameterDirection.Output;
            sqlCommand.Parameters.Add("@mensaje", SqlDbType.VarChar, 100).Direction = ParameterDirection.Output;

            sqlCommand.ExecuteNonQuery();
            string idpais = sqlCommand.Parameters["@idpais"].Value.ToString().Trim();
            mensaje = sqlCommand.Parameters["@mensaje"].Value.ToString();

            sqlConnection.Close();

            return idpais;
        }

        Consumidor obtenerConsumidor(string dnicont, out string mensaje)
        {
            Consumidor consumidor = null;

            SqlConnection sqlConnection = new SqlConnection(cadenaConexion);
            sqlConnection.Open();

            SqlCommand sqlCommand = new SqlCommand("usp_obtener_consumidor", sqlConnection);
            sqlCommand.CommandType = CommandType.StoredProcedure;

            sqlCommand.Parameters.AddWithValue("@dnicont", dnicont);
            sqlCommand.Parameters.Add("@mensaje", SqlDbType.VarChar, 100).Direction = ParameterDirection.Output;

            SqlDataReader sqlDataReader = sqlCommand.ExecuteReader();
            if (sqlDataReader.Read())
            {
                consumidor = new Consumidor(
                    sqlDataReader.GetString(0),
                    sqlDataReader.GetString(1),
                    sqlDataReader.GetString(2),
                    sqlDataReader.IsDBNull(3) ? "" : sqlDataReader.GetString(3),
                    sqlDataReader.GetString(4),
                    sqlDataReader.IsDBNull(5) ? "" : sqlDataReader.GetString(5)
                );
            }

            sqlDataReader.Close();
            mensaje = sqlCommand.Parameters["@mensaje"].Value.ToString();

            sqlConnection.Close();

            return consumidor;
        }

        string actualizarConsumidor(Consumidor consumidor)
        {
            string mensajePais;
            string idpais = registrarPais(consumidor.nompais, out mensajePais);

            if (idpais == "")
            {
                return mensajePais;
            }

            consumidor.idpais = idpais;

            SqlConnection sqlConnection = new SqlConnection(cadenaConexion);
            sqlConnection.Open();

            SqlCommand sqlCommand = new SqlCommand("usp_actualiza_consumidor", sqlConnection);
            sqlCommand.CommandType = CommandType.StoredProcedure;

            sqlCommand.Parameters.AddWithValue("@dnicont", consumidor.dnicont ?? "");
            sqlCommand.Parameters.AddWithValue("@nomcont", consumidor.nomcont ?? "");
            sqlCommand.Parameters.AddWithValue("@apecont", consumidor.apecont ?? "");
            sqlCommand.Parameters.AddWithValue("@emailcont", string.IsNullOrEmpty(consumidor.emailcont) ? (object)DBNull.Value : consumidor.emailcont);
            sqlCommand.Parameters.AddWithValue("@idpais", consumidor.idpais ?? "");
            sqlCommand.Parameters.Add("@mensaje", SqlDbType.VarChar, 100).Direction = ParameterDirection.Output;

            sqlCommand.ExecuteNonQuery();
            string mensaje = sqlCommand.Parameters["@mensaje"].Value.ToString();

            sqlConnection.Close();

            return mensaje;
        }
    }
}
