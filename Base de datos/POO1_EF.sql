CREATE DATABASE ExamenFinal
GO

USE ExamenFinal
GO

CREATE TABLE tb_paises (
idpais char (3) PRIMARY KEY,
)
GO

CREATE TABLE tb_Consumidor (
dnicont char(8) PRIMARY KEY,
nomcont varchar(40) NOT NULL,
apecont varchar(40) NOT NULL,
emailcont varchar(250) UNIQUE,
idpais char(3) REFERENCES tb_paises
)
GO


CREATE PROC usp_agrega_consumidor
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

CREATE PROC usp_eliminar_consumidor
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

CREATE PROC usp_listar_consumidor
AS
BEGIN
SELECT dnicont, nomcont, apecont, emailcont, idpais
FROM tb_consumidor
END
GO

CREATE PROC usp_actualiza_consumidor
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

UPDATE tb_consumidor
SET nomcont = @nomcont,
apecont = @apecont,
emailcont = NULLIF(@emailcont, ''),
idpais = @idpais
WHERE dnicont = @dnicont

SELECT @mensaje = 'Consumidor actualizado correctamente'
END
