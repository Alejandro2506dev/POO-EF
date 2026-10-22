--------------------------------------------------------------------------------
-- BASE DE DATOS: ExamenFinal
-- Examen Final - Programacion Orientada a Objetos / Entity Framework
-- Tablas, restricciones y procedimientos almacenados
-- Motor: SQL Server Express (instancia SQLEXPRESS)
--
-- Este script es idempotente: se puede volver a ejecutar sin romper la base.
-- Generado a partir de la base de datos en ejecucion.
--------------------------------------------------------------------------------

IF DB_ID('ExamenFinal') IS NULL
BEGIN
    CREATE DATABASE ExamenFinal
END
GO

USE ExamenFinal
GO

--------------------------------------------------------------------------------
-- TABLAS
--------------------------------------------------------------------------------

IF OBJECT_ID('tb_paises', 'U') IS NULL
CREATE TABLE tb_paises (
    idpais char(3) PRIMARY KEY,
    nompais varchar(20)
)
GO

IF OBJECT_ID('tb_consumidor', 'U') IS NULL
CREATE TABLE tb_consumidor (
    dnicont char(8) PRIMARY KEY,
    nomcont varchar(40) NOT NULL,
    apecont varchar(40) NOT NULL,
    emailcont varchar(250) UNIQUE,
    idpais char(3) REFERENCES tb_paises
)
GO

--------------------------------------------------------------------------------
-- PROCEDIMIENTOS ALMACENADOS
--------------------------------------------------------------------------------

CREATE OR ALTER PROC usp_agrega_consumidor
@dnicont char(8),
@nomcont varchar(40),
@apecont varchar(40),
@emailcont varchar(250),
@idpais char(3),
@mensaje varchar(100) OUTPUT
AS
BEGIN
    INSERT INTO tb_consumidor (dnicont, nomcont, apecont, emailcont, idpais)
    SELECT @dnicont, @nomcont, @apecont, @emailcont, @idpais
    WHERE LEN(@dnicont) = 8
    AND @dnicont NOT LIKE '%[^0-9]%'
    AND @nomcont <> ''
    AND @apecont <> ''
    AND @idpais NOT LIKE '%[0-9]%'

    SELECT @mensaje = CASE
        WHEN @@ROWCOUNT = 1 THEN 'Consumidor registrado correctamente'
        WHEN LEN(@dnicont) <> 8 OR @dnicont LIKE '%[^0-9]%' THEN 'El DNI debe ser numerico de 8 digitos'
        WHEN @nomcont = '' OR @apecont = '' THEN 'Nombre y apellido no deben estar vacios'
        ELSE 'El pais debe ser de tipo texto'
    END
END

GO

CREATE OR ALTER PROCEDURE usp_listar_consumidor
AS
BEGIN
    SELECT c.dnicont, c.nomcont, c.apecont, c.emailcont, c.idpais, p.nompais
    FROM tb_consumidor c
    LEFT JOIN tb_paises p ON p.idpais = c.idpais
END
GO

CREATE OR ALTER PROC usp_eliminar_consumidor
@dnicont char(8),
@mensaje varchar(100) OUTPUT
AS
BEGIN
    DELETE FROM tb_consumidor
    WHERE dnicont = @dnicont
    AND EXISTS (SELECT 1 FROM tb_consumidor WHERE dnicont = @dnicont)

    SELECT @mensaje = CASE
        WHEN @@ROWCOUNT = 1 THEN 'Consumidor eliminado correctamente'
        ELSE 'El DNI no se encuentra en la tabla'
    END
END

GO

CREATE OR ALTER PROC usp_actualiza_consumidor
@dnicont char(8),
@nomcont varchar(40),
@apecont varchar(40),
@emailcont varchar(250),
@idpais char(3),
@mensaje varchar(100) OUTPUT
AS
BEGIN
    IF LEN(@dnicont) <> 8 OR @dnicont LIKE '%[^0-9]%'
    BEGIN
        SELECT @mensaje = 'El DNI debe ser numerico de 8 digitos'
        RETURN
    END

    IF @nomcont = '' OR @apecont = ''
    BEGIN
        SELECT @mensaje = 'Nombre y apellido no deben estar vacios'
        RETURN
    END

    IF @idpais LIKE '%[0-9]%'
    BEGIN
        SELECT @mensaje = 'El pais debe ser de tipo texto'
        RETURN
    END

    IF NOT EXISTS (SELECT 1 FROM tb_paises WHERE idpais = @idpais)
    BEGIN
        SELECT @mensaje = 'El pais no existe en la tabla de paises'
        RETURN
    END

    IF NOT EXISTS (SELECT 1 FROM tb_consumidor WHERE dnicont = @dnicont)
    BEGIN
        SELECT @mensaje = 'El DNI no se encuentra en la tabla'
        RETURN
    END

    IF @emailcont IS NOT NULL AND EXISTS (SELECT 1 FROM tb_consumidor WHERE emailcont = @emailcont AND dnicont <> @dnicont)
    BEGIN
        SELECT @mensaje = 'El email ya esta registrado'
        RETURN
    END

    UPDATE tb_consumidor
    SET nomcont = @nomcont,
        apecont = @apecont,
        emailcont = NULLIF(@emailcont, ''),
        idpais = @idpais
    WHERE dnicont = @dnicont

    SELECT @mensaje = 'Consumidor actualizado correctamente'
END

GO

CREATE OR ALTER PROCEDURE usp_obtener_consumidor
@dnicont char(8),
@mensaje varchar(100) OUTPUT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM tb_consumidor WHERE dnicont = @dnicont)
    BEGIN
        SELECT c.dnicont, c.nomcont, c.apecont, c.emailcont, c.idpais, p.nompais
        FROM tb_consumidor c
        LEFT JOIN tb_paises p ON p.idpais = c.idpais
        WHERE c.dnicont = @dnicont

        SELECT @mensaje = 'Consumidor encontrado correctamente'
    END
    ELSE
    BEGIN
        SELECT @mensaje = 'El DNI no se encuentra en la tabla'
    END
END
GO

CREATE OR ALTER PROC usp_registrar_pais
@nompais varchar(20),
@idpais char(3) OUTPUT,
@mensaje varchar(100) OUTPUT
AS
BEGIN
    DECLARE @nombre varchar(20) = LTRIM(RTRIM(@nompais))
    DECLARE @base varchar(20)
    DECLARE @codigo char(3)
    DECLARE @letras char(26) = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    DECLARE @i int = 0

    IF @nombre = '' OR @nombre IS NULL
    BEGIN
        SET @idpais = ''
        SELECT @mensaje = 'El pais no debe estar vacio'
        RETURN
    END

    SET @base = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(@nombre),'Á','A'),'É','E'),'Í','I'),'Ó','O'),'Ú','U'),'Ñ','N')
    SET @base = REPLACE(@base, ' ', '')

    SELECT @codigo = idpais
    FROM tb_paises
    WHERE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(nompais),'Á','A'),'É','E'),'Í','I'),'Ó','O'),'Ú','U'),'Ñ','N') = @base

    IF @codigo IS NULL
    BEGIN
        SET @codigo = LEFT(@base, 3)

        IF EXISTS (SELECT 1 FROM tb_paises WHERE idpais = @codigo)
        BEGIN
            WHILE @i < 26 AND EXISTS (SELECT 1 FROM tb_paises WHERE idpais = LEFT(@base, 2) + SUBSTRING(@letras, @i + 1, 1))
                SET @i = @i + 1
            SET @codigo = LEFT(@base, 2) + SUBSTRING(@letras, @i + 1, 1)
        END

        INSERT INTO tb_paises (idpais, nompais) VALUES (@codigo, @nombre)
        SELECT @mensaje = 'Pais registrado correctamente'
    END
    ELSE
    BEGIN
        SELECT @mensaje = 'Pais encontrado correctamente'
    END

    SET @idpais = @codigo
END
GO

--------------------------------------------------------------------------------
-- DATOS INICIALES
--------------------------------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM tb_paises WHERE idpais = 'PER')
BEGIN
    INSERT INTO tb_paises (idpais, nompais)
    VALUES ('PER', N'Perú')
END
GO

