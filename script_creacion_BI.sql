

/* FUNCIONES */
CREATE FUNCTION los_angeles_de_dante.idFecha(@fecha DATETIME)
RETURNS int
AS
BEGIN
	RETURN (SELECT t.tiempo_id FROM los_angeles_de_dante.BI_tiempo t WHERE YEAR(@fecha) = t.anio AND MONTH(@fecha) = t.mes) 
END
GO

CREATE FUNCTION los_angeles_de_dante.rangoPersona(@fecha DATETIME)
RETURNS INT
AS
BEGIN
    DECLARE @age INT;
    DECLARE @RangoEtarioID INT;
    
    SET @age = DATEDIFF(YEAR, @fecha, GETDATE());

    SET @RangoEtarioID = (
        SELECT RangoEtarioID 
        FROM los_angeles_de_dante.BI_rango_etario 
        WHERE 
            (@age < 25 AND Descripcion = '>25') OR
            (@age BETWEEN 25 AND 34 AND Descripcion = '25-35') OR
            (@age BETWEEN 35 AND 49 AND Descripcion = '35-50') OR
            (@age >= 50 AND Descripcion = '>50')
    );

    RETURN @RangoEtarioID;
END;
GO

CREATE FUNCTION los_angeles_de_dante.obtenerTurno(@fecha TIME)
RETURNS INT
AS
BEGIN
    DECLARE @rango_horario_id INT;

    SELECT @rango_horario_id = rango_horario_id
    FROM los_angeles_de_dante.BI_turnos 
    WHERE @fecha >= hora_inicial AND @fecha < hora_final;

    RETURN @rango_horario_id;
END;
GO

CREATE FUNCTION los_angeles_de_dante.obtenerCategoriasDeProducto(@producto_id INT)
RETURNS INT
AS

BEGIN
	DECLARE @categoria_id INT	
	 
    SELECT 
        @categoria_id = s.categoria_id 
    FROM 
        los_angeles_de_dante.producto p
	INNER JOIN los_angeles_de_dante.subcategoria s ON s.sub_categoria_id = p.subcategoria_id
    WHERE p.producto_id = @producto_id
	
	RETURN @categoria_id
END
GO

CREATE FUNCTION los_angeles_de_dante.obtenerSubCategoriaDeProducto(@producto_id INT)
RETURNS INT
AS
BEGIN
	DECLARE @subcategoria_id INT	

    SELECT 
        @subcategoria_id = p.subcategoria_id 
    FROM 
        los_angeles_de_dante.producto p
    WHERE p.producto_id = @producto_id

	RETURN @subcategoria_id
END
GO


/* TABLAS */
CREATE TABLE los_angeles_de_dante.BI_tiempo (
	tiempo_id INT IDENTITY(1, 1) PRIMARY KEY,
	anio DECIMAL(4),
	mes DECIMAL(2),
	cuatrimestre DECIMAL(1)
	)

INSERT INTO los_angeles_de_dante.BI_tiempo 
	SELECT DISTINCT YEAR(ticket_fecha_hora) AS anio, MONTH(ticket_fecha_hora) AS mes, DATEPART(QUARTER, ticket_fecha_hora) as cuatrimestre 
	FROM los_angeles_de_dante.ticket
	UNION
	SELECT DISTINCT YEAR(pago_fecha) AS anio, MONTH(pago_fecha) AS mes, DATEPART(QUARTER, pago_fecha) as cuatrimestre 
	FROM los_angeles_de_dante.pago
	UNION
	SELECT DISTINCT YEAR(envio_fecha_entrega) AS anio, MONTH(envio_fecha_entrega) AS mes, DATEPART(QUARTER, envio_fecha_entrega) as cuatrimestre 
	FROM los_angeles_de_dante.envio
	UNION
	SELECT DISTINCT YEAR(envio_fecha_programada) AS anio, MONTH(envio_fecha_programada) AS mes, DATEPART(QUARTER, envio_fecha_programada) as cuatrimestre 
	FROM los_angeles_de_dante.envio
	UNION
	SELECT DISTINCT YEAR(promocion_fecha_fin) AS anio, MONTH(promocion_fecha_fin) AS mes, DATEPART(QUARTER, promocion_fecha_fin) as cuatrimestre 
	FROM los_angeles_de_dante.promocion
	UNION
	SELECT DISTINCT YEAR(promocion_fecha_inicio) AS anio, MONTH(promocion_fecha_inicio) AS mes, DATEPART(QUARTER, promocion_fecha_inicio) as cuatrimestre 
	FROM los_angeles_de_dante.promocion

CREATE TABLE los_angeles_de_dante.BI_ubicacion(
	provincia_id INT, 
	provincia_nombre varchar(255),
	localidad_id INT,
	localidad_nombre varchar(255),
	PRIMARY KEY(provincia_id, localidad_id)
	)

	INSERT INTO los_angeles_de_dante.BI_ubicacion
	SELECT DISTINCT p.provincia_id, p.nombre, l.localidad_id, l.nombre FROM los_angeles_de_dante.sucursal s
	INNER JOIN los_angeles_de_dante.direccion d ON direccion_id = s.sucursal_direccion_id
	INNER JOIN los_angeles_de_dante.localidad l ON d.localidad_id = l.localidad_id
	INNER JOIN los_angeles_de_dante.provincia p ON p.provincia_id = l.provincia_id

	UNION
	SELECT DISTINCT p.provincia_id, p.nombre, l.localidad_id, l.nombre FROM los_angeles_de_dante.direccionXcliente dxc
	INNER JOIN los_angeles_de_dante.direccion d ON d.direccion_id = dxc.direccion_id
	INNER JOIN los_angeles_de_dante.localidad l ON d.localidad_id = l.localidad_id
	INNER JOIN los_angeles_de_dante.provincia p ON p.provincia_id = l.provincia_id



CREATE TABLE los_angeles_de_dante.BI_sucursal(
	sucursal_id INT PRIMARY KEY,
	nombre_sucursal VARCHAR(50)
	)
INSERT INTO los_angeles_de_dante.BI_sucursal 
SELECT sucursal_id, sucursal_nombre FROM los_angeles_de_dante.sucursal



CREATE TABLE los_angeles_de_dante.BI_rango_etario(
	RangoEtarioID INT IDENTITY(1, 1) PRIMARY KEY,
    Descripcion VARCHAR(50)
	)
INSERT INTO los_angeles_de_dante.BI_rango_etario (Descripcion)
VALUES ('>25'), ('25-35'), ('35-50'), ('>50');

CREATE TABLE los_angeles_de_dante.BI_turnos(
	rango_horario_id INT IDENTITY(1, 1) PRIMARY KEY,
	hora_inicial TIME, 
	hora_final TIME
	)
INSERT INTO los_angeles_de_dante.BI_turnos (hora_inicial , hora_final)
VALUES ('08:00:00', '12:00:00'), ('12:00:00', '16:00:00'), ('16:00:00', '20:00:00');


CREATE TABLE los_angeles_de_dante.BI_medio_de_pago(
	medio_de_pago_id INT PRIMARY KEY,
	descripcion_mp VARCHAR(50)
	)

INSERT INTO los_angeles_de_dante.BI_medio_de_pago (medio_de_pago_id , descripcion_mp)
SELECT medio_pago_id, medio_pago_descripcion FROM los_angeles_de_dante.medio_pago

CREATE TABLE los_angeles_de_dante.BI_categoria_subcategoria(
	categoria_id INT,
	categoria_descripcion varchar(255),
	subcategoria_id INT,
	subcategoria_descripcion varchar(255),
	PRIMARY KEY (categoria_id, subcategoria_id)
	)

INSERT INTO los_angeles_de_dante.BI_categoria_subcategoria (categoria_id, categoria_descripcion, subcategoria_id, subcategoria_descripcion)
SELECT c.categoria_id, c.categoria_descripcion, s.sub_categoria_id, s.sub_categoria_descripcion FROM los_angeles_de_dante.subcategoria s
INNER JOIN los_angeles_de_dante.categoria c ON c.categoria_id = s.categoria_id




/*TABLAS DE HECHOS*/

CREATE TABLE los_angeles_de_dante.BI_hechos_ventas (
    venta_id INT IDENTITY(1, 1) PRIMARY KEY,
    tiempo_id INT,
    ubicacion_provincia_id INT,
    ubicacion_localidad_id INT,
    sucursal_id INT,
    rango_etario_empleado_id INT,
    turno_id INT,
    importe_venta DECIMAL(10, 2),
    cantidad_articulos INT,
    descuento DECIMAL(10, 2),
    fecha_venta DATE,
	tipo_caja varchar(255)
    FOREIGN KEY (tiempo_id) REFERENCES los_angeles_de_dante.BI_tiempo(tiempo_id),
    FOREIGN KEY (ubicacion_provincia_id, ubicacion_localidad_id) REFERENCES los_angeles_de_dante.BI_ubicacion(provincia_id, localidad_id),
    FOREIGN KEY (sucursal_id) REFERENCES los_angeles_de_dante.BI_sucursal(sucursal_id),
    FOREIGN KEY (rango_etario_empleado_id) REFERENCES los_angeles_de_dante.BI_rango_etario(RangoEtarioID),
    FOREIGN KEY (turno_id) REFERENCES los_angeles_de_dante.BI_turnos(rango_horario_id),
   );

   INSERT INTO los_angeles_de_dante.BI_hechos_ventas SELECT
   los_angeles_de_dante.idFecha(t.ticket_fecha_hora) AS tiempo_id,
   l.provincia_id AS ubicacion_provincia_id, 
   l.localidad_id AS ubicacion_localidad_id ,
   s.sucursal_id AS sucursal_id,
   los_angeles_de_dante.rangoPersona(e.empleado_fecha_nacimiento) AS rango_etario_empleado_id, 
   los_angeles_de_dante.obtenerTurno(t.ticket_fecha_hora) AS turno_id,
   t.ticket_total_ticket AS importe_venta, 
   SUM(dt.ticket_det_cantidad) AS cantidad_articulos,
   d.descuento_porcentaje_desc AS descuento,
   t.ticket_fecha_hora AS fecha_venta,
   tc.tipo_caja AS tipo_caja
	FROM los_angeles_de_dante.venta v
   INNER JOIN los_angeles_de_dante.ticket t ON v.ticket_numero = t.ticket_numero AND t.ticket_id = v.ticket_id
   INNER JOIN los_angeles_de_dante.detalle_ticket dt ON dt.ticket_id = t.ticket_id AND dt.ticket_numero = t.ticket_numero
    INNER JOIN los_angeles_de_dante.pago p ON p.numero_venta = v.numero_venta
	INNER JOIN los_angeles_de_dante.descuento d ON d.descuento_codigo = p.descuento_codigo 
	INNER JOIN los_angeles_de_dante.sucursal s ON s.sucursal_id = v.sucursal_id 
	INNER JOIN los_angeles_de_dante.direccion dir ON direccion_id = s.sucursal_direccion_id
	INNER JOIN los_angeles_de_dante.localidad l ON dir.localidad_id = l.localidad_id
	INNER JOIN los_angeles_de_dante.empleado e ON e.empleado_id = v.empleado_id
	INNER JOIN los_angeles_de_dante.caja c ON c.caja_numero = v.caja_numero
	INNER JOIN los_angeles_de_dante.tipo_caja tc ON tc.tipo_caja_id = c.tipo_caja_id
	GROUP BY
    t.ticket_total_ticket, 
    t.ticket_fecha_hora,
	d.descuento_porcentaje_desc,
	l.provincia_id,
	l.localidad_id,
	s.sucursal_id,
	e.empleado_fecha_nacimiento,
	tc.tipo_caja
	ORDER BY tiempo_id DESC

CREATE TABLE los_angeles_de_dante.BI_hechos_pagos (
    pago_id INT IDENTITY(1, 1) PRIMARY KEY,
    tiempo_id INT,
    sucursal_id INT,
    medio_pago_id INT,
    rango_etario_cliente_id INT,
    importe_pago DECIMAL(10, 2),
	pago_descuento_aplicado DECIMAL(18,0),
    cuotas INT,
    fecha_pago DATE,
    FOREIGN KEY (tiempo_id) REFERENCES los_angeles_de_dante.BI_tiempo(tiempo_id),
    FOREIGN KEY (sucursal_id) REFERENCES los_angeles_de_dante.BI_sucursal(sucursal_id),
    FOREIGN KEY (medio_pago_id) REFERENCES los_angeles_de_dante.BI_medio_de_pago(medio_de_pago_id),
    FOREIGN KEY (rango_etario_cliente_id) REFERENCES los_angeles_de_dante.BI_rango_etario(RangoEtarioID)
);
   INSERT INTO los_angeles_de_dante.BI_hechos_pagos 
   SELECT los_angeles_de_dante.idFecha(p.pago_fecha) AS tiempo_id, 
   s.sucursal_id AS sucursal_id,
   p.pago_medio_pago_id AS medio_pago_id, 
   los_angeles_de_dante.rangoPersona(c.cliente_fecha_nacimiento) AS rango_etario_cliente_id,
   p.pago_importe AS importe_pago,
   p.pago_descuento_aplicado AS pago_descuento_aplicado,
   dp.tarjeta_cuotas AS cuotas,
   p.pago_fecha as fecha_pago
   FROM los_angeles_de_dante.pago p
    INNER JOIN los_angeles_de_dante.venta v ON p.numero_venta = v.numero_venta
	INNER JOIN los_angeles_de_dante.sucursal s ON s.sucursal_id = v.sucursal_id 
	INNER JOIN los_angeles_de_dante.ticket t ON t.ticket_id = v.ticket_id 
	LEFT JOIN los_angeles_de_dante.detalle_pago dp ON dp.pago_id = p.pago_id 
	LEFT JOIN los_angeles_de_dante.cliente c ON c.cliente_id = t.cliente_id








CREATE TABLE los_angeles_de_dante.BI_hechos_promociones (
    promocion_id INT IDENTITY(1, 1) PRIMARY KEY,
    tiempo_id_inicio INT,
	tiempo_id_fin INT,
    categoria_id INT,
    subcategoria_id INT,
    fecha_promocion_inicio DATE,
	fecha_promocion_fin DATE,
	promo_descuento_aplicado DECIMAL(18,2)
    FOREIGN KEY (tiempo_id_inicio) REFERENCES los_angeles_de_dante.BI_tiempo(tiempo_id),
	FOREIGN KEY (tiempo_id_fin) REFERENCES los_angeles_de_dante.BI_tiempo(tiempo_id),
    FOREIGN KEY (categoria_id, subcategoria_id) REFERENCES los_angeles_de_dante.BI_categoria_subcategoria(categoria_id, subcategoria_id)
);
   INSERT INTO los_angeles_de_dante.BI_hechos_promociones
   SELECT los_angeles_de_dante.idFecha(p.promocion_fecha_inicio) AS tiempo_id_inicio,
   los_angeles_de_dante.idFecha(p.promocion_fecha_fin) AS tiempo_id_fin,
   los_angeles_de_dante.obtenerCategoriasDeProducto(pr.producto_id) AS categoria_id,
   los_angeles_de_dante.obtenerSubCategoriaDeProducto(pr.producto_id) AS subcategoria_id,
   p.promocion_fecha_inicio AS fecha_promocion_inicio,
   p.promocion_fecha_fin AS fecha_promocion_fin,
   dt.promo_aplicado_descuento AS promo_descuento_aplicado
   FROM los_angeles_de_dante.promocion p
   INNER JOIN los_angeles_de_dante.detalle_ticket dt ON dt.promo_codigo = p.promo_codigo
   INNER JOIN los_angeles_de_dante.producto pr ON dt.producto_id = pr.producto_id


CREATE TABLE los_angeles_de_dante.BI_hechos_envios (
    envio_id INT IDENTITY(1, 1) PRIMARY KEY,
    ubicacion_provincia_id INT,
    ubicacion_localidad_id INT,
    tiempo_id_entrega INT,
    tiempo_id_programada INT,
    sucursal_id INT,
    rango_etario_cliente_id INT,
    costo_envio DECIMAL(10, 2),
    fecha_entrega DATE,
    fecha_programada DATE,
    FOREIGN KEY (ubicacion_provincia_id, ubicacion_localidad_id) REFERENCES los_angeles_de_dante.BI_ubicacion(provincia_id, localidad_id),
    FOREIGN KEY (tiempo_id_entrega) REFERENCES los_angeles_de_dante.BI_tiempo(tiempo_id),
    FOREIGN KEY (tiempo_id_programada) REFERENCES los_angeles_de_dante.BI_tiempo(tiempo_id),
    FOREIGN KEY (sucursal_id) REFERENCES los_angeles_de_dante.BI_sucursal(sucursal_id),
    FOREIGN KEY (rango_etario_cliente_id) REFERENCES los_angeles_de_dante.BI_rango_etario(RangoEtarioID)
);
INSERT INTO los_angeles_de_dante.BI_hechos_envios
   SELECT 
   l.provincia_id AS ubicacion_provincia_id, 
   l.localidad_id AS ubicacion_localidad_id ,
   los_angeles_de_dante.idFecha(e.envio_fecha_entrega) AS tiempo_id_entrega,
   los_angeles_de_dante.idFecha(e.envio_fecha_programada) AS tiempo_id_programada,
   s.sucursal_id AS sucursal_id,
   los_angeles_de_dante.rangoPersona(c.cliente_fecha_nacimiento) AS rango_etario_cliente_id,
   e.envio_costo AS costo_envio,
   e.envio_fecha_entrega AS fecha_entrega,
   e.envio_fecha_programada AS fecha_programada

   FROM los_angeles_de_dante.envio e
   INNER JOIN los_angeles_de_dante.ticket t ON t.ticket_id = e.ticket_id AND t.ticket_numero = e.ticket_numero
   INNER JOIN los_angeles_de_dante.venta v ON v.ticket_id = t.ticket_id AND v.ticket_numero = t.ticket_numero
   INNER JOIN los_angeles_de_dante.sucursal s ON s.sucursal_id  = v.sucursal_id
   INNER JOIN los_angeles_de_dante.cliente c ON c.cliente_id = e.cliente_id
   INNER JOIN los_angeles_de_dante.direccion d ON d.direccion_id = e.direccion_id
   INNER JOIN los_angeles_de_dante.localidad l ON d.localidad_id = l.localidad_id
 GO

/* VISTAS */
CREATE VIEW los_angeles_de_dante.vista1 AS
SELECT 
    u.localidad_nombre AS localidad, 
    t.anio AS anio, 
    t.mes AS mes, 
    AVG(hv.importe_venta) AS promedio_venta
FROM 
    los_angeles_de_dante.BI_hechos_ventas hv
INNER JOIN 
    los_angeles_de_dante.bi_tiempo t ON t.tiempo_id = hv.tiempo_id
INNER JOIN 
    los_angeles_de_dante.bi_ubicacion u ON u.provincia_id = hv.ubicacion_provincia_id AND u.localidad_id = hv.ubicacion_localidad_id
GROUP BY 
    u.localidad_nombre, t.anio, t.mes;
GO


CREATE VIEW los_angeles_de_dante.vista2 AS
SELECT 
	CONVERT(CHAR(8), tu.hora_inicial, 108) + ' - ' + CONVERT(CHAR(8), tu.hora_final, 108) AS turno,
	ti.anio AS anio, 
    ti.cuatrimestre AS cuatrimestre, 
    AVG(hv.cantidad_articulos) AS promedio_articulos
FROM 
    los_angeles_de_dante.BI_hechos_ventas hv
INNER JOIN 
    los_angeles_de_dante.bi_tiempo ti ON ti.tiempo_id = hv.tiempo_id
INNER JOIN 
    los_angeles_de_dante.bi_turnos tu ON tu.rango_horario_id = hv.turno_id
	GROUP BY 
    tu.hora_inicial,tu.hora_final, ti.anio, ti.cuatrimestre;
GO

CREATE VIEW los_angeles_de_dante.vista3 AS
SELECT 
    hv.tipo_caja AS tipo_caja,
    r.Descripcion AS rango_etario,
    t.cuatrimestre AS cuatrimestre,
    CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM los_angeles_de_dante.BI_hechos_ventas), 2) AS DECIMAL(5,2)) AS porcentaje_ventas
FROM 
    los_angeles_de_dante.BI_hechos_ventas hv
INNER JOIN 
    los_angeles_de_dante.bi_tiempo t ON t.tiempo_id = hv.tiempo_id
INNER JOIN 
    los_angeles_de_dante.bi_rango_etario r ON r.RangoEtarioId = hv.rango_etario_empleado_id
GROUP BY 
    hv.tipo_caja, r.Descripcion, t.cuatrimestre;
GO


CREATE VIEW los_angeles_de_dante.vista4 AS
SELECT 
	CONVERT(CHAR(8), tu.hora_inicial, 108) + ' - ' + CONVERT(CHAR(8), tu.hora_final, 108) AS turno,
    u.localidad_nombre AS localidad, 
    t.anio AS anio, 
    t.mes AS mes, 
	COUNT(*) AS cantidad_ventas
FROM 
    los_angeles_de_dante.BI_hechos_ventas hv
INNER JOIN 
    los_angeles_de_dante.bi_tiempo t ON t.tiempo_id = hv.tiempo_id
INNER JOIN 
    los_angeles_de_dante.bi_turnos tu ON tu.rango_horario_id = hv.turno_id
INNER JOIN 
    los_angeles_de_dante.bi_ubicacion u ON u.provincia_id = hv.ubicacion_provincia_id AND u.localidad_id = hv.ubicacion_localidad_id
GROUP BY 
    tu.hora_inicial,tu.hora_final, t.anio, t.mes, u.localidad_nombre;
GO

CREATE VIEW los_angeles_de_dante.vista5 AS
SELECT 
    t.anio AS anio, 
    t.mes AS mes, 
    AVG(hv.descuento) AS promedio_descuento
FROM 
    los_angeles_de_dante.BI_hechos_ventas hv
INNER JOIN 
    los_angeles_de_dante.bi_tiempo t ON t.tiempo_id = hv.tiempo_id
GROUP BY 
     t.anio, t.mes;
GO

CREATE VIEW los_angeles_de_dante.vista6 AS
SELECT TOP 3
    t.anio AS anio, 
    t.cuatrimestre AS cuatrimestre, 
	cs.categoria_descripcion AS descripcion_categoria,
	SUM(hp.promo_descuento_aplicado) AS descuento_total
FROM 
    los_angeles_de_dante.BI_hechos_promociones hp
INNER JOIN 
    los_angeles_de_dante.bi_tiempo t ON t.tiempo_id = hp.tiempo_id_inicio
INNER JOIN 
    los_angeles_de_dante.bi_categoria_subcategoria cs ON cs.categoria_id = hp.categoria_id AND cs.subcategoria_id = hp.subcategoria_id
GROUP BY 
     t.anio, t.cuatrimestre,cs.categoria_descripcion
ORDER BY descuento_total DESC
GO


CREATE VIEW los_angeles_de_dante.vista7 AS
SELECT 
    t.anio AS anio, 
    t.mes AS mes, 
    s.nombre_sucursal AS sucursal, 
    COUNT(*) * 100.0 / (SELECT COUNT(*) 
                        FROM los_angeles_de_dante.BI_hechos_envios he1
                        WHERE he1.tiempo_id_programada = he.tiempo_id_programada 
                          AND he1.sucursal_id = he.sucursal_id) 
    AS porcentaje_cumplimiento
FROM 
    los_angeles_de_dante.BI_hechos_envios he
INNER JOIN 
    los_angeles_de_dante.bi_tiempo t ON t.tiempo_id = he.tiempo_id_programada
INNER JOIN 
    los_angeles_de_dante.bi_sucursal s ON s.sucursal_id = he.sucursal_id
WHERE 
    he.fecha_entrega = he.fecha_programada
GROUP BY 
    t.anio, t.mes, s.nombre_sucursal, he.tiempo_id_programada, he.sucursal_id;
GO

CREATE VIEW los_angeles_de_dante.vista8 AS
SELECT 
    t.anio AS anio, 
    t.cuatrimestre AS cuatrimestre, 
    r.Descripcion AS rango_etario, 
    COUNT(*) AS cantidad_envios
FROM 
    los_angeles_de_dante.BI_hechos_envios he
INNER JOIN 
    los_angeles_de_dante.bi_tiempo t ON t.tiempo_id = he.tiempo_id_programada
INNER JOIN 
    los_angeles_de_dante.bi_rango_etario r ON r.RangoEtarioId = he.rango_etario_cliente_id
GROUP BY 
    t.anio, t.cuatrimestre,r.Descripcion
GO

CREATE VIEW los_angeles_de_dante.vista9 AS
SELECT TOP 5
    u.localidad_nombre AS localidad, 
    SUM(he.costo_envio) AS costo_envio
FROM 
    los_angeles_de_dante.BI_hechos_envios he
INNER JOIN 
    los_angeles_de_dante.bi_ubicacion u ON u.provincia_id = he.ubicacion_provincia_id AND u.localidad_id = he.ubicacion_localidad_id
GROUP BY 
    u.localidad_nombre
ORDER BY costo_envio DESC
GO

CREATE VIEW los_angeles_de_dante.vista10 AS
SELECT TOP 3
    t.anio AS anio, 
    t.mes AS mes,
	s.nombre_sucursal AS sucursal,
	mp.descripcion_mp AS medio_de_pago,
	SUM(hp.importe_pago) AS importe_total
FROM 
    los_angeles_de_dante.BI_hechos_pagos hp
INNER JOIN 
    los_angeles_de_dante.bi_tiempo t ON t.tiempo_id = hp.tiempo_id
INNER JOIN 
    los_angeles_de_dante.BI_medio_de_pago mp ON mp.medio_de_pago_id = hp.medio_pago_id
INNER JOIN 
    los_angeles_de_dante.BI_sucursal s ON s.sucursal_id = hp.sucursal_id
WHERE hp.cuotas IS NOT NULL
GROUP BY t.anio,t.mes,mp.descripcion_mp,s.nombre_sucursal
ORDER BY importe_total DESC
GO

CREATE VIEW los_angeles_de_dante.vista11 AS
SELECT 
    r.Descripcion AS rango_etareo, 
    AVG(importe_pago / COALESCE(cuotas,1)) AS promedio_cuota
FROM 
    los_angeles_de_dante.BI_hechos_pagos hp
INNER JOIN 
    los_angeles_de_dante.bi_rango_etario r ON r.RangoEtarioId = hp.rango_etario_cliente_id
GROUP BY 
    r.Descripcion
GO

CREATE VIEW los_angeles_de_dante.vista12 AS
SELECT 
    mp.descripcion_mp AS medio_de_pago, 
    SUM(hp.pago_descuento_aplicado) / (SUM(hp.Importe_pago) +  SUM(hp.pago_descuento_aplicado)) AS porcentaje_descuento_aplicado
FROM 
    los_angeles_de_dante.BI_hechos_pagos hp
INNER JOIN 
    los_angeles_de_dante.BI_medio_de_pago mp ON mp.medio_de_pago_id = hp.medio_pago_id
GROUP BY 
	mp.descripcion_mp
GO



/*
DROP TABLE los_angeles_de_dante.BI_hechos_envios;
DROP TABLE los_angeles_de_dante.BI_hechos_promociones;
DROP TABLE los_angeles_de_dante.BI_hechos_pagos;
DROP TABLE los_angeles_de_dante.BI_hechos_ventas;
DROP TABLE los_angeles_de_dante.BI_categoria_subcategoria;
DROP TABLE los_angeles_de_dante.BI_medio_de_pago;
DROP TABLE los_angeles_de_dante.BI_turnos;
DROP TABLE los_angeles_de_dante.BI_rango_etario;
DROP TABLE los_angeles_de_dante.BI_sucursal;
DROP TABLE los_angeles_de_dante.BI_ubicacion;
DROP TABLE los_angeles_de_dante.BI_tiempo;

/* FUNCTIONS */
DROP FUNCTION IF EXISTS los_angeles_de_dante.idFecha;
DROP FUNCTION IF EXISTS los_angeles_de_dante.rangoPersona;
DROP FUNCTION IF EXISTS los_angeles_de_dante.obtenerTurno;
DROP FUNCTION IF EXISTS los_angeles_de_dante.obtenerCategoriasDeProducto;
DROP FUNCTION IF EXISTS los_angeles_de_dante.obtenerSubCategoriaDeProducto;

/* VIEWS */
DROP VIEW IF EXISTS los_angeles_de_dante.vista1;
DROP VIEW IF EXISTS los_angeles_de_dante.vista2;
DROP VIEW IF EXISTS los_angeles_de_dante.vista3;
DROP VIEW IF EXISTS los_angeles_de_dante.vista4;
DROP VIEW IF EXISTS los_angeles_de_dante.vista5;
DROP VIEW IF EXISTS los_angeles_de_dante.vista6;
DROP VIEW IF EXISTS los_angeles_de_dante.vista7;
DROP VIEW IF EXISTS los_angeles_de_dante.vista8;
DROP VIEW IF EXISTS los_angeles_de_dante.vista9;
DROP VIEW IF EXISTS los_angeles_de_dante.vista10;
DROP VIEW IF EXISTS los_angeles_de_dante.vista11;
DROP VIEW IF EXISTS los_angeles_de_dante.vista12;
*/