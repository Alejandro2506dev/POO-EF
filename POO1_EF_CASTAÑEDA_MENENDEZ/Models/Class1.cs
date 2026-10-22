using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace POO1_EF_CASTAÑEDA_MENENDEZ.Models
{
    public class Consumidor

    {
        public string dnicont { get; set; }
    
        public string nomcont { get; set; }

        public string apecont { get; set; }

        public string emailcont { get; set; }

        public string idpais { get; set; }

        public string nompais { get; set; }

        public Consumidor()
        {
        }

        public Consumidor(string dnicont, string nomcont, string apecont, string emailcont, string idpais)
        {
            this.dnicont = dnicont;
            this.nomcont = nomcont;
            this.apecont = apecont;
            this.emailcont = emailcont;
            this.idpais = idpais;
        }

        public Consumidor(string dnicont, string nomcont, string apecont, string emailcont, string idpais, string nompais)
        {
            this.dnicont = dnicont;
            this.nomcont = nomcont;
            this.apecont = apecont;
            this.emailcont = emailcont;
            this.idpais = idpais;
            this.nompais = nompais;
        }
    }

    public class Pais
    {
        public string idpais { get; set; }

        public string nompais { get; set; }

        public Pais()
        {
        }

        public Pais(string idpais, string nompais)
        {
            this.idpais = idpais;
            this.nompais = nompais;
        }
    }
}