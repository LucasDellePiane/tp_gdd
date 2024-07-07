CREATE SCHEMA los_angeles_de_dante AUTHORIZATION dbo
GO
BEGIN TRANSACTION;
	/*CREO Y INSERTO PROVINCIAS*/

CREATE TABLE los_angeles_de_dante.provincia (
	provincia_id INT IDENTITY(1,1) PRIMARY KEY,
	nombre VARCHAR(255));

INSERT INTO los_angeles_de_dante.provincia  (nombre)
	SELECT DISTINCT super_provincia AS nombre FROM gd_esquema.Maestra
	WHERE super_provincia IS NOT NULL
	UNION
	SELECT DISTINCT sucursal_provincia AS nombre FROM gd_esquema.Maestra
	WHERE sucursal_provincia IS NOT NULL
	UNION
	SELECT DISTINCT cliente_provincia AS nombre FROM gd_esquema.Maestra
	WHERE cliente_provincia IS NOT NULL;

	/*CREO Y INSERTO LOCALIDAD*/

CREATE TABLE los_angeles_de_dante.localidad (
	localidad_id INT IDENTITY(1,1) PRIMARY KEY,
	provincia_id INT,
	nombre VARCHAR(255),
	CONSTRAINT fk_pronvicia_id FOREIGN KEY (provincia_id) REFERENCES los_angeles_de_dante.provincia(provincia_id));

INSERT INTO los_angeles_de_dante.localidad (nombre, provincia_id) SELECT DISTINCT maestra.super_localidad, provincia.provincia_id
	FROM gd_esquema.Maestra AS maestra
	JOIN los_angeles_de_dante.provincia ON maestra.super_provincia = provincia.nombre
	WHERE maestra.super_localidad IS NOT NULL
	UNION 
	SELECT DISTINCT maestra.sucursal_localidad, provincia.provincia_id
	FROM gd_esquema.Maestra AS maestra
	JOIN los_angeles_de_dante.provincia ON maestra.sucursal_provincia = provincia.nombre
	WHERE maestra.sucursal_localidad IS NOT NULL
	UNION
	SELECT DISTINCT maestra.cliente_localidad, provincia.provincia_id
	FROM gd_esquema.Maestra AS maestra
	JOIN los_angeles_de_dante.provincia ON maestra.cliente_provincia = provincia.nombre
	WHERE maestra.cliente_localidad IS NOT NULL;
	
   /*CREO E INSERTO DIRECCION*/

CREATE TABLE los_angeles_de_dante.direccion (
    direccion_id INT IDENTITY(1,1) PRIMARY KEY,
    direccion_nombre VARCHAR(255),
    localidad_id INT,
    CONSTRAINT fk_localidad FOREIGN KEY (localidad_id) REFERENCES los_angeles_de_dante.localidad(localidad_id)
);

INSERT INTO los_angeles_de_dante.direccion (
    direccion_nombre, 
    localidad_id
)
 SELECT DISTINCT m.super_domicilio, l.localidad_id
	FROM gd_esquema.Maestra AS m
	JOIN los_angeles_de_dante.localidad l ON m.super_localidad = l.nombre
	WHERE m.super_domicilio IS NOT NULL
	UNION 
	SELECT DISTINCT m.sucursal_direccion, l.localidad_id
	FROM gd_esquema.Maestra AS m
	JOIN los_angeles_de_dante.localidad l ON m.SUCURSAL_LOCALIDAD = l.nombre
	WHERE m.sucursal_direccion IS NOT NULL
	UNION
	SELECT DISTINCT m.cliente_domicilio, l.localidad_id
	FROM gd_esquema.Maestra AS m
	JOIN los_angeles_de_dante.localidad l ON m.cliente_localidad = l.nombre
	WHERE m.cliente_domicilio IS NOT NULL;
	
	/*CREO Y INSERTO supermercados*/

CREATE TABLE los_angeles_de_dante.supermercado (
	super_id INT IDENTITY(1,1) PRIMARY KEY,
	super_direccion_id INT,
	super_nombre VARCHAR(255),
	super_razon_soc VARCHAR(255),
	super_cuit VARCHAR(255),
	super_iibb VARCHAR(255),
	super_fecha_ini_actividad DATETIME,
	super_condicion_fiscal VARCHAR(255),
	CONSTRAINT super_direccion_id FOREIGN KEY (super_direccion_id) REFERENCES los_angeles_de_dante.direccion(direccion_id)
	);

INSERT INTO los_angeles_de_dante.supermercado (
    super_direccion_id, 
    super_nombre, 
    super_razon_soc, 
    super_cuit, 
    super_fecha_ini_actividad, 
    super_condicion_fiscal,
	super_iibb
)
SELECT DISTINCT
    direccion.direccion_id, 
    maestra.SUPER_NOMBRE, 
    maestra.SUPER_RAZON_SOC, 
    maestra.SUPER_CUIT, 
    maestra.SUPER_FECHA_INI_ACTIVIDAD, 
    maestra.SUPER_CONDICION_FISCAL,
	maestra.SUPER_IIBB
FROM 
    gd_esquema.Maestra AS maestra
JOIN 
    los_angeles_de_dante.direccion ON maestra.SUPER_DOMICILIO = direccion.direccion_nombre
WHERE 
    maestra.SUPER_LOCALIDAD IS NOT NULL

	/*CREO Y INSERTO SUCURSAL*/

CREATE TABLE los_angeles_de_dante.sucursal (
	sucursal_id INT IDENTITY(1,1) PRIMARY KEY,
	super_id INT, 
	sucursal_nombre VARCHAR(255),
	sucursal_direccion_id INT,
	CONSTRAINT super_id FOREIGN KEY (super_id) REFERENCES los_angeles_de_dante.supermercado(super_id),
	CONSTRAINT sucursal_direccion_id FOREIGN KEY (sucursal_direccion_id) REFERENCES los_angeles_de_dante.direccion(direccion_id)
	);

INSERT INTO los_angeles_de_dante.sucursal (	
	super_id,
	sucursal_nombre,
	sucursal_direccion_id 
)
SELECT DISTINCT
	1,
	maestra.SUCURSAL_NOMBRE, 
    direccion.direccion_id
FROM 
    gd_esquema.Maestra AS maestra
JOIN 
    los_angeles_de_dante.direccion ON maestra.sucursal_direccion = direccion.direccion_nombre
WHERE 
    maestra.sucursal_direccion IS NOT NULL;

	/*CREO E INSERTO TIPO CAJA*/

CREATE TABLE los_angeles_de_dante.tipo_caja (
	tipo_caja_id INT IDENTITY(1,1) PRIMARY KEY,
	tipo_caja VARCHAR(255));

INSERT INTO los_angeles_de_dante.tipo_caja (
	tipo_caja
	) SELECT DISTINCT CAJA_TIPO 
	FROM gd_esquema.Maestra 
	WHERE CAJA_TIPO IS NOT NULL

	/*CREO E INSERTO CAJA*/

CREATE TABLE los_angeles_de_dante.caja (
	caja_numero DECIMAL,
	sucursal_id INT,
	tipo_caja_id INT,
	CONSTRAINT pk_caja PRIMARY KEY (caja_numero, sucursal_id),
	CONSTRAINT fk_sucursal FOREIGN KEY (sucursal_id) REFERENCES los_angeles_de_dante.sucursal(sucursal_id),
	CONSTRAINT fk_tipo_caja_id FOREIGN KEY (tipo_caja_id) REFERENCES los_angeles_de_dante.tipo_caja(tipo_caja_id));

INSERT INTO los_angeles_de_dante.caja (
	caja_numero, 
	sucursal_id,
	tipo_caja_id
	) SELECT DISTINCT m.CAJA_NUMERO, s.sucursal_id, t.tipo_caja_id
	FROM gd_esquema.Maestra AS m
	LEFT JOIN los_angeles_de_dante.sucursal S ON m.SUCURSAL_NOMBRE = s.sucursal_nombre
	LEFT JOIN los_angeles_de_dante.tipo_caja t ON m.CAJA_TIPO = t.tipo_caja
	WHERE m.SUCURSAL_NOMBRE IS NOT NULL AND m.CAJA_TIPO IS NOT NULL
	order by sucursal_id

	/*CREO E INSERTO EMPLEADOS*/

CREATE TABLE los_angeles_de_dante.empleado (
	empleado_id INT IDENTITY(1,1) PRIMARY KEY, 
	empleado_nombre VARCHAR(255),
	empleado_apellido VARCHAR(255),
	sucursal_id INT,
	empleado_dni DECIMAL,
	empleado_fecha_registro DATETIME,
	empleado_mail VARCHAR(255),
	empleado_telefono DECIMAL,
	empleado_fecha_nacimiento DATETIME,
	CONSTRAINT fk_sucursal_id FOREIGN KEY (sucursal_id) REFERENCES los_angeles_de_dante.sucursal(sucursal_id));

INSERT INTO los_angeles_de_dante.empleado (
	empleado_nombre,
	empleado_apellido,
	sucursal_id,
	empleado_dni,
	empleado_fecha_registro,
	empleado_mail,
	empleado_telefono,
	empleado_fecha_nacimiento
	) SELECT DISTINCT m.EMPLEADO_NOMBRE, m.EMPLEADO_APELLIDO, s.sucursal_id, 
	m.EMPLEADO_DNI, m.EMPLEADO_FECHA_REGISTRO, m.EMPLEADO_MAIL, m.EMPLEADO_TELEFONO,
	m.EMPLEADO_FECHA_NACIMIENTO
	FROM gd_esquema.Maestra m
	LEFT JOIN los_angeles_de_dante.sucursal s ON m.SUCURSAL_NOMBRE = s.sucursal_nombre
	WHERE m.EMPLEADO_NOMBRE IS NOT NULL

			/*CREO E INSERTO CLIENTE*/
CREATE TABLE los_angeles_de_dante.cliente (
    cliente_id INT IDENTITY(1,1) PRIMARY KEY,
    cliente_dni DECIMAL,
    cliente_nombre VARCHAR(255),
    cliente_apellido VARCHAR(255),
    cliente_fecha_registro DATETIME,
    cliente_fecha_nacimiento DATETIME,
    cliente_telefono DECIMAL
);
INSERT INTO los_angeles_de_dante.cliente (
	cliente_dni,
	cliente_nombre,
	cliente_apellido,
	cliente_fecha_registro,
	cliente_fecha_nacimiento,
	cliente_telefono
	) SELECT DISTINCT m.cliente_dni, m.cliente_nombre, m.cliente_apellido,m.cliente_fecha_registro,m.cliente_fecha_nacimiento,m.cliente_telefono
	FROM gd_esquema.Maestra m
	WHERE m.cliente_dni IS NOT NULL
	ORDER BY m.cliente_dni

/*CREO E INSERTO TICKET*/
CREATE TABLE los_angeles_de_dante.ticket (
	ticket_id INT IDENTITY(1,1), 
	cliente_id INT,
    ticket_numero DECIMAL,
    ticket_fecha_hora DATETIME,
    ticket_tipo_comprobante VARCHAR(255),
    ticket_subtotal_productos DECIMAL,
    ticket_total_descuento_aplicado DECIMAL,
    ticket_total_descuento_aplicado_mp DECIMAL,
    ticket_total_envio DECIMAL,
    ticket_total_ticket DECIMAL(18,2),
	CONSTRAINT pk_ticket PRIMARY KEY (ticket_numero, ticket_id)
);


INSERT INTO los_angeles_de_dante.ticket (
	cliente_id,
	ticket_numero,
	ticket_fecha_hora,
	ticket_tipo_comprobante,
	ticket_subtotal_productos,
	ticket_total_descuento_aplicado,
	ticket_total_descuento_aplicado_mp,
	ticket_total_envio,
	ticket_total_ticket 
	) SELECT DISTINCT c.cliente_id,
	m.TICKET_NUMERO, m.TICKET_FECHA_HORA, m.TICKET_TIPO_COMPROBANTE, 
	m.TICKET_SUBTOTAL_PRODUCTOS, m.TICKET_TOTAL_DESCUENTO_APLICADO, m.TICKET_TOTAL_DESCUENTO_APLICADO_MP, m.TICKET_TOTAL_ENVIO,
	m.TICKET_TOTAL_TICKET
	FROM gd_esquema.Maestra m
	LEFT JOIN (SELECT m.cliente_dni, m.ticket_numero FROM gd_esquema.Maestra m WHERE m.CLIENTE_DNI IS NOT NULL AND m.TICKET_NUMERO is not null ) AS x ON x.TICKET_NUMERO = m.TICKET_NUMERO
	LEFT JOIN los_angeles_de_dante.cliente c ON c.cliente_dni = x.CLIENTE_DNI
	ORDER BY m.TICKET_NUMERO



	/*CREO E INSERTO VENTA*/

CREATE TABLE los_angeles_de_dante.venta (
	numero_venta INT IDENTITY(1,1) PRIMARY KEY,
	sucursal_id INT,
	caja_numero DECIMAL,
	ticket_numero DECIMAL,
	ticket_id INT,
	empleado_id INT,
    CONSTRAINT fk_caja FOREIGN KEY (caja_numero, sucursal_id) REFERENCES los_angeles_de_dante.caja(caja_numero, sucursal_id),
	CONSTRAINT fk_ticket FOREIGN KEY (ticket_numero, ticket_id) REFERENCES los_angeles_de_dante.ticket(ticket_numero, ticket_id),
	CONSTRAINT fk_empleado FOREIGN KEY (empleado_id) REFERENCES los_angeles_de_dante.empleado(empleado_id));

	INSERT INTO los_angeles_de_dante.venta (
	sucursal_id,
	caja_numero,
	ticket_numero,
	ticket_id,
	empleado_id
	) SELECT DISTINCT c.sucursal_id, c.caja_numero, t.ticket_numero, t.ticket_id, e.empleado_id
	FROM gd_esquema.Maestra m
	inner JOIN los_angeles_de_dante.sucursal s ON m.sucursal_nombre = s.sucursal_nombre
	inner JOIN los_angeles_de_dante.ticket t ON m.TICKET_NUMERO = t.ticket_numero and m.TICKET_TOTAL_TICKET = t.ticket_total_ticket
	inner JOIN los_angeles_de_dante.caja c ON m.CAJA_NUMERO = c.caja_numero AND s.sucursal_id = c.sucursal_id
	inner JOIN los_angeles_de_dante.empleado e ON m.EMPLEADO_DNI = e.empleado_dni 
	ORDER BY t.ticket_numero

	/*CREO E INSERTO DESCUENTO*/

CREATE TABLE los_angeles_de_dante.descuento (
    descuento_codigo DECIMAL PRIMARY KEY,
    descuento_fecha_inicio DATETIME,
    descuento_fecha_fin DATETIME,
    descuento_porcentaje_desc DECIMAL(8,2),
    descuento_tope DECIMAL,
    descuento_descripcion VARCHAR(255)
);
	INSERT INTO los_angeles_de_dante.descuento (
	descuento_codigo,
	descuento_fecha_inicio,
	descuento_fecha_fin,
	descuento_porcentaje_desc,
	descuento_tope,
	descuento_descripcion
	) SELECT DISTINCT m.descuento_codigo, m.descuento_fecha_inicio, m.descuento_fecha_fin, 
	m.descuento_porcentaje_desc, m.descuento_tope, m.descuento_descripcion
	FROM gd_esquema.Maestra m
	WHERE m.descuento_codigo IS NOT NULL
	ORDER BY m.descuento_codigo


		/*CREO E INSERTO MEDIO_PAGO*/

CREATE TABLE los_angeles_de_dante.medio_pago (
    medio_pago_id INT IDENTITY(1,1) PRIMARY KEY,
    medio_pago_descripcion VARCHAR(255),
    medio_pago_tipo VARCHAR(255),
    descuento_codigo DECIMAL,
    descuento_tope DECIMAL,
    CONSTRAINT fk_descuento FOREIGN KEY (descuento_codigo) REFERENCES los_angeles_de_dante.descuento(descuento_codigo)
);	
	INSERT INTO los_angeles_de_dante.medio_pago (
	medio_pago_descripcion,
	medio_pago_tipo,
	descuento_codigo,
	descuento_tope
	) SELECT DISTINCT m.PAGO_MEDIO_PAGO, m.pago_tipo_medio_pago, m.descuento_codigo,m.descuento_tope
	FROM gd_esquema.Maestra m
	WHERE m.pago_medio_pago IS NOT NULL
	ORDER BY m.descuento_codigo


			/*CREO E INSERTO PAGO*/

CREATE TABLE los_angeles_de_dante.pago (
    pago_id INT IDENTITY(1,1) PRIMARY KEY,
    pago_fecha DATETIME,
    pago_medio_pago_id INT,
    numero_venta INT,
    pago_importe DECIMAL,
    pago_descuento_aplicado DECIMAL,
	descuento_codigo DECIMAL,
	CONSTRAINT fk_descuento_pago FOREIGN KEY (descuento_codigo) REFERENCES los_angeles_de_dante.descuento(descuento_codigo),
    CONSTRAINT fk_medio_pago FOREIGN KEY (pago_medio_pago_id) REFERENCES los_angeles_de_dante.medio_pago(medio_pago_id),
    CONSTRAINT fk_numero_venta FOREIGN KEY (numero_venta) REFERENCES los_angeles_de_dante.venta(numero_venta)
);

INSERT INTO los_angeles_de_dante.pago (
	pago_fecha,
	pago_medio_pago_id,
	numero_venta, 
	pago_importe,
	pago_descuento_aplicado,
	descuento_codigo
	) SELECT m.PAGO_FECHA, mp.medio_pago_id, v.numero_venta, m.PAGO_IMPORTE,m.PAGO_DESCUENTO_APLICADO,d.descuento_codigo
	FROM gd_esquema.Maestra m
	inner JOIN los_angeles_de_dante.ticket t ON m.TICKET_NUMERO = t.ticket_numero and m.TICKET_TOTAL_TICKET = t.ticket_total_ticket
	inner JOIN los_angeles_de_dante.venta v ON v.ticket_id = t.ticket_id
	inner JOIN los_angeles_de_dante.descuento d ON m.DESCUENTO_CODIGO = d.descuento_codigo
	inner JOIN los_angeles_de_dante.medio_pago mp ON m.PAGO_MEDIO_PAGO = mp.medio_pago_descripcion AND m.PAGO_TIPO_MEDIO_PAGO = mp.medio_pago_tipo AND m.descuento_codigo = mp.descuento_codigo
	inner JOIN los_angeles_de_dante.sucursal s ON m.SUCURSAL_NOMBRE= s.sucursal_nombre
	ORDER BY v.numero_venta


			/*CREO E INSERTO DETALLE PAGO*/
CREATE TABLE los_angeles_de_dante.detalle_pago (
    detalle_pago_id INT IDENTITY(1,1) PRIMARY KEY,
	pago_id INT,
	cliente_id INT,
	tarjeta_nro VARCHAR(255),
	tarjeta_fecha_venc DATETIME,
	tarjeta_cuotas DECIMAL,
	CONSTRAINT fk_pago FOREIGN KEY (pago_id) REFERENCES los_angeles_de_dante.pago(pago_id), 
	CONSTRAINT fk_cliente_id FOREIGN KEY (cliente_id) REFERENCES los_angeles_de_dante.cliente(cliente_id)
	);

INSERT INTO los_angeles_de_dante.detalle_pago (
	pago_id, 
	cliente_id,
	tarjeta_nro, 
	tarjeta_fecha_venc,
	tarjeta_cuotas
	)SELECT p.pago_id, NULL, m.PAGO_TARJETA_NRO, m.PAGO_TARJETA_FECHA_VENC, m.PAGO_TARJETA_CUOTAS
	FROM gd_esquema.Maestra m
	INNER JOIN los_angeles_de_dante.ticket t ON m.TICKET_NUMERO = t.ticket_numero AND m.TICKET_TOTAL_TICKET = t.ticket_total_ticket
	INNER JOIN los_angeles_de_dante.venta v ON t.ticket_id = v.ticket_id
	INNER JOIN los_angeles_de_dante.pago p ON v.numero_venta = p.numero_venta 
	WHERE m.PAGO_TARJETA_NRO IS NOT NULL
	ORDER BY pago_id



			/*CREO E INSERTO DIRECCIONXCLIENTE*/

CREATE TABLE los_angeles_de_dante.direccionXcliente (
    direccion_id INT,
    cliente_id INT,
	CONSTRAINT pk_direccionXcliente PRIMARY KEY (direccion_id, cliente_id),
    CONSTRAINT fk_direccion FOREIGN KEY (direccion_id) REFERENCES los_angeles_de_dante.direccion(direccion_id),
    CONSTRAINT fk_numero_cliente FOREIGN KEY (cliente_id) REFERENCES los_angeles_de_dante.cliente(cliente_id)
);
INSERT INTO los_angeles_de_dante.direccionXcliente (
	direccion_id,
	cliente_id
	) SELECT DISTINCT d.direccion_id, c.cliente_id
	FROM gd_esquema.Maestra m
	inner JOIN los_angeles_de_dante.direccion d ON m.CLIENTE_DOMICILIO = d.direccion_nombre
	inner JOIN los_angeles_de_dante.cliente c ON m.CLIENTE_DNI = c.cliente_dni
	ORDER BY c.cliente_id

			/*CREO E INSERTO ENVIO*/

CREATE TABLE los_angeles_de_dante.envio (
    numero_envio INT IDENTITY(1,1) PRIMARY KEY,
	direccion_id INT,
    ticket_id INT,
	ticket_numero DECIMAL,
    cliente_id INT,
    envio_fecha_programada DATETIME,
    envio_hora_inicio DATETIME,
    envio_hora_fin DATETIME,
    envio_costo DECIMAL,
    envio_estado VARCHAR(255),
    envio_fecha_entrega DATETIME,
	CONSTRAINT fk_ticket_envio FOREIGN KEY (ticket_numero, ticket_id) REFERENCES los_angeles_de_dante.ticket(ticket_numero, ticket_id),
    CONSTRAINT fk_numero_cliente_envio FOREIGN KEY (cliente_id) REFERENCES los_angeles_de_dante.cliente(cliente_id)
);
INSERT INTO los_angeles_de_dante.envio (
	direccion_id,
	ticket_id,
	ticket_numero,
	cliente_id,
	envio_fecha_programada,
	envio_hora_inicio,
	envio_hora_fin,
	envio_costo,
	envio_estado,
	envio_fecha_entrega
	) SELECT DISTINCT d.direccion_id, t.ticket_id, t.ticket_numero, c.cliente_id, m.envio_fecha_programada,m.envio_hora_inicio,m.envio_hora_fin,
	m.envio_costo,m.envio_estado,m.envio_fecha_entrega
	FROM gd_esquema.Maestra m
	inner JOIN los_angeles_de_dante.ticket t ON m.TICKET_NUMERO = t.ticket_numero AND m.TICKET_TOTAL_TICKET = t.ticket_total_ticket
	inner JOIN los_angeles_de_dante.cliente c ON m.CLIENTE_DNI = c.cliente_dni
	inner JOIN los_angeles_de_dante.provincia p ON p.nombre = m.CLIENTE_PROVINCIA
	inner JOIN los_angeles_de_dante.localidad l ON l.nombre = m.CLIENTE_LOCALIDAD AND p.provincia_id = l.provincia_id
	inner JOIN los_angeles_de_dante.direccion d ON m.cliente_domicilio = d.direccion_nombre AND d.localidad_id = l.localidad_id
	ORDER BY c.cliente_id

	/*CREO E INSERTO CATEGORIA*/

CREATE TABLE los_angeles_de_dante.categoria (
    categoria_id INT IDENTITY(1,1) PRIMARY KEY,
    categoria_descripcion VARCHAR(255)
); 
INSERT INTO los_angeles_de_dante.categoria (
	categoria_descripcion
	) SELECT DISTINCT m.PRODUCTO_CATEGORIA
	FROM gd_esquema.Maestra m
	WHERE m.PRODUCTO_CATEGORIA IS NOT NULL
	ORDER BY m.PRODUCTO_CATEGORIA

			/*CREO E INSERTO SUBCATEGORIA*/

CREATE TABLE los_angeles_de_dante.subcategoria (
    sub_categoria_id INT IDENTITY(1,1) PRIMARY KEY,
    sub_categoria_descripcion VARCHAR(255),
    categoria_id INT,
    CONSTRAINT fk_categoria FOREIGN KEY (categoria_id) REFERENCES los_angeles_de_dante.categoria(categoria_id)
);
INSERT INTO los_angeles_de_dante.subcategoria (
	sub_categoria_descripcion,
	categoria_id
	) SELECT DISTINCT m.PRODUCTO_SUB_CATEGORIA, c.categoria_id
	FROM gd_esquema.Maestra m
	inner JOIN los_angeles_de_dante.categoria c ON m.PRODUCTO_CATEGORIA= c.categoria_descripcion
	ORDER BY c.categoria_id
			/*CREO E INSERTO MARCA*/

CREATE TABLE los_angeles_de_dante.marca (
    marca_id INT IDENTITY(1,1) PRIMARY KEY,
    marca_nombre VARCHAR(255)
);
INSERT INTO los_angeles_de_dante.marca (
	marca_nombre
	) SELECT DISTINCT m.PRODUCTO_MARCA
	FROM gd_esquema.Maestra m
	WHERE m.PRODUCTO_MARCA IS NOT NULL
	ORDER BY m.PRODUCTO_MARCA

			/*CREO E INSERTO PROMOCION*/

CREATE TABLE los_angeles_de_dante.promocion (
    promo_codigo DECIMAL PRIMARY KEY,
    promocion_descripcion VARCHAR(255),
    promocion_fecha_inicio DATETIME,
    promocion_fecha_fin DATETIME
);
INSERT INTO los_angeles_de_dante.promocion (
	promo_codigo,
	promocion_descripcion,
	promocion_fecha_inicio,
	promocion_fecha_fin
	) SELECT DISTINCT m.promo_codigo, m.promocion_descripcion,m.promocion_fecha_inicio,m.promocion_fecha_fin
	FROM gd_esquema.Maestra m
	WHERE m.promo_codigo IS NOT NULL
	ORDER BY m.promocion_descripcion
				
				/*CREO E INSERTO REGLA*/

CREATE TABLE los_angeles_de_dante.regla (
    regla_id INT IDENTITY(1,1) PRIMARY KEY,
    promo_codigo DECIMAL,
    regla_descuento_aplicable_prod DECIMAL(18,2),
    regla_descripcion VARCHAR(255),
    regla_cant_aplica_descuento DECIMAL,
    regla_cant_max_prod DECIMAL,
    regla_aplica_mismo_producto DECIMAL,
    regla_aplica_misma_marca DECIMAL,
    CONSTRAINT fk_promocion FOREIGN KEY (promo_codigo) REFERENCES los_angeles_de_dante.promocion(promo_codigo)
);

INSERT INTO los_angeles_de_dante.regla (
	promo_codigo,
	regla_descuento_aplicable_prod,
	regla_descripcion,
	regla_cant_aplica_descuento,
	regla_cant_max_prod,
	regla_aplica_mismo_producto,
	regla_aplica_misma_marca
	) SELECT DISTINCT p.promo_codigo, m.regla_descuento_aplicable_prod, 
	m.regla_descripcion, m.regla_cant_aplica_descuento,m.regla_cant_max_prod,m.regla_aplica_mismo_prod,
	m.regla_aplica_misma_marca
	FROM gd_esquema.Maestra m
	inner JOIN los_angeles_de_dante.promocion p ON m.PROMO_CODIGO = p.promo_codigo
	ORDER BY p.promo_codigo

		/*CREO E INSERTO PRODUCTO*/

CREATE TABLE los_angeles_de_dante.producto (
    producto_id INT IDENTITY(1,1) PRIMARY KEY,
    producto_nombre VARCHAR(255),
    producto_descripcion VARCHAR(255),
	marca_id INT,
	subcategoria_id INT,
	producto_precio DECIMAL,
	CONSTRAINT fk_marca_producto FOREIGN KEY (marca_id) REFERENCES los_angeles_de_dante.marca(marca_id),
	CONSTRAINT fk_subcategoria_producto FOREIGN KEY (subcategoria_id) REFERENCES los_angeles_de_dante.subcategoria(sub_categoria_id)
);

INSERT INTO los_angeles_de_dante.producto (
	producto_nombre,
	producto_descripcion,
	marca_id,
	subcategoria_id,
	producto_precio
	) SELECT DISTINCT m.producto_nombre,m.PRODUCTO_DESCRIPCION,ma.marca_id, s.sub_categoria_id,m.PRODUCTO_PRECIO
	FROM gd_esquema.Maestra m
	inner JOIN los_angeles_de_dante.marca ma ON m.PRODUCTO_MARCA= ma.marca_nombre
	inner JOIN los_angeles_de_dante.categoria c ON m.PRODUCTO_CATEGORIA = c.categoria_descripcion
	inner JOIN los_angeles_de_dante.subcategoria s ON m.PRODUCTO_SUB_CATEGORIA = s.sub_categoria_descripcion AND c.categoria_id = s.categoria_id
	ORDER BY m.PRODUCTO_PRECIO


/*CREO E INSERTO DETALLE_TICKET*/

CREATE TABLE los_angeles_de_dante.detalle_ticket (
    detalle_ticket_id INT IDENTITY(1,1) PRIMARY KEY,
	ticket_id INT,
	ticket_numero DECIMAL,
	producto_id INT,
	ticket_det_precio DECIMAL,
	ticket_det_cantidad DECIMAL,
	ticket_det_total DECIMAL,
	promo_codigo DECIMAL,
	promo_aplicado_descuento DECIMAL(18,2)
	CONSTRAINT fk_promo FOREIGN KEY (promo_codigo) REFERENCES los_angeles_de_dante.promocion(promo_codigo),
	CONSTRAINT fk_ticket_detalle FOREIGN KEY (ticket_numero, ticket_id) REFERENCES los_angeles_de_dante.ticket(ticket_numero, ticket_id),
	CONSTRAINT fk_producto_id FOREIGN KEY (producto_id) REFERENCES los_angeles_de_dante.producto(producto_id)
	);

INSERT INTO los_angeles_de_dante.detalle_ticket (
	ticket_id,
	ticket_numero,
	producto_id,
	ticket_det_precio,
	ticket_det_cantidad,
	ticket_det_total,
	promo_codigo,
	promo_aplicado_descuento
	) SELECT DISTINCT t.ticket_id,t.ticket_numero,p.producto_id,m.TICKET_DET_PRECIO, m.TICKET_DET_CANTIDAD, m.TICKET_DET_TOTAL, m.PROMO_CODIGO, m.PROMO_APLICADA_DESCUENTO
	FROM gd_esquema.Maestra m
	inner JOIN los_angeles_de_dante.ticket t ON m.TICKET_NUMERO = t.ticket_numero AND m.TICKET_TOTAL_TICKET = t.ticket_total_ticket AND m.TICKET_DET_CANTIDAD IS NOT NULL
	inner JOIN los_angeles_de_dante.subcategoria s ON m.PRODUCTO_SUB_CATEGORIA = s.sub_categoria_descripcion
	inner JOIN los_angeles_de_dante.marca ma ON m.PRODUCTO_MARCA= ma.marca_nombre
	inner JOIN los_angeles_de_dante.producto p ON m.PRODUCTO_NOMBRE = p.producto_nombre AND s.sub_categoria_id = p.subcategoria_id AND ma.marca_id = p.marca_id
	ORDER BY t.ticket_id, p.producto_id
	
COMMIT TRANSACTION
	
	/*
	 DROP TABLE  los_angeles_de_dante.detalle_ticket,
	 los_angeles_de_dante.producto,
	 los_angeles_de_dante.regla,
	 los_angeles_de_dante.promocion,
    los_angeles_de_dante.marca
	,los_angeles_de_dante.subcategoria
	,los_angeles_de_dante.categoria
	,los_angeles_de_dante.envio
	,los_angeles_de_dante.direccionXcliente
	, los_angeles_de_dante.detalle_pago
	,los_angeles_de_dante.cliente
	,los_angeles_de_dante.pago
	,los_angeles_de_dante.medio_pago
	,los_angeles_de_dante.descuento
	,los_angeles_de_dante.venta
	,los_angeles_de_dante.ticket
	,los_angeles_de_dante.empleado
	,los_angeles_de_dante.caja
	,los_angeles_de_dante.tipo_caja
	,los_angeles_de_dante.sucursal
	,los_angeles_de_dante.supermercado
	,los_angeles_de_dante.direccion
	,los_angeles_de_dante.localidad
	,los_angeles_de_dante.provincia*/