# Examen Final — Consumidores (ASP.NET MVC 5 + SQL Server)

Aplicación web **ASP.NET MVC 5** (C#) que opera sobre la base de datos `ExamenFinal`
mediante **procedimientos almacenados** en SQL Server.

## Qué hace

- **Agregar** consumidor (valida DNI numérico de 8 dígitos, nombre y apellido no vacíos).
- **Listar** consumidores en la vista `Index` (con etiqueta `No hay registros` si no hay datos).
- **Eliminar** consumidor por su código (`dnicont`), mostrando el mensaje del procedimiento.
- **Actualizar** consumidor: vista precargada + POST que actualiza y devuelve el mensaje.
- **País por nombre completo**: se escribe el nombre (ej. `Peru`) y queda guardado en
  `tb_paises.nompais`; el código de 3 letras se deriva solo (`Peru` → `PER`).

## Requisitos

| | |
|---|---|
| Visual Studio | 2022 (carga de trabajo ASP.NET y web) |
| .NET Framework | 4.7.2 |
| Base de datos | SQL Server Express, instancia `SQLEXPRESS` |

## Puesta en marcha

1. Ejecutar el script `Base de datos/ExamenFinal.sql` (crea la base, las tablas y los 6 procedimientos).
2. Revisar la cadena de conexión en `Web.config`:

   ```xml
   <connectionStrings>
     <add name="cadenaConexion"
          connectionString="Data Source=.\SQLEXPRESS;Initial Catalog=ExamenFinal;Integrated Security=True;TrustServerCertificate=True"
          providerName="System.Data.SqlClient" />
   </connectionStrings>
   ```

3. Abrir la solución y restaurar los paquetes NuGet (`packages.config`).
4. Ejecutar (F5) y entrar a `/Consumidor`.

## Estructura

```
POO1_EF_CASTAÑEDA_MENENDEZ/
├── Controllers/ConsumidorController.cs   # Index, Create (GET/POST), Delete, Update (GET/POST)
├── Models/Class1.cs                       # clases Consumidor y Pais
├── Views/Consumidor/                      # Index.cshtml, Create.cshtml, Update.cshtml
├── Web.config                              # cadena de conexión
└── packages.config                         # paquetes NuGet

Base de datos/ExamenFinal.sql               # script de la base de datos
```

## Procedimientos almacenados

| Procedimiento | Descripción |
|---|---|
| `usp_agrega_consumidor` | Inserta un consumidor y devuelve el mensaje de la operación. |
| `usp_listar_consumidor` | Lista los consumidores con el nombre del país. |
| `usp_eliminar_consumidor` | Elimina un consumidor por `dnicont`. |
| `usp_actualiza_consumidor` | Actualiza un consumidor validando los datos. |
| `usp_obtener_consumidor` | Obtiene un consumidor por `dnicont`. |
| `usp_registrar_pais` | Busca el país por nombre y lo crea si no existe. |
