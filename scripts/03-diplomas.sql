-- ACTUALIZAR LAS VISTAS MATERIALIZADAS DE SIE_PROD
CREATE OR REPLACE FUNCTION operativo.refrescante_remoto()
RETURNS void
LANGUAGE plpgsql
AS $function$
BEGIN
    -- PERFORM dblink_exec('sie_remoto_fdw', 'SELECT public.refrescar_vw_distritos()');
	PERFORM dblink_exec('sie_remoto_fdw', 'DO $$ BEGIN PERFORM public.refrescar_vw_distritos(); END $$');
	PERFORM dblink_exec('sie_remoto_fdw', 'DO $$ BEGIN PERFORM public.refrescar_vw_datos_estudiantes_6to(); END $$');
	PERFORM dblink_exec('sie_remoto_fdw', 'DO $$ BEGIN PERFORM public.refrescar_vw_estudiantes_historial_academico(); END $$');
END;
$function$;
--
-- drop function operativo.ejecutar_refresco_remoto;
select operativo.refrescante_remoto(); 

-- ## ESQUEMA PARA FLUJO DE ENTREGA FISICA DE DIPLOMAS IMPRESOS
-- ## SOLO PARA LA PRIMERA GESTION DE EMISION 
 
CREATE TABLE operativo.derivaciones (
    id_derivacion SERIAL PRIMARY KEY,
    id_tramite INT NOT NULL,
    usuario_origen INT NOT NULL, -- DDEP
    usuario_destino INT NOT NULL, -- TECSDE
    fecha_derivacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(50) NOT NULL DEFAULT 'Pendiente',
    observaciones TEXT,
    CONSTRAINT fk_tramite FOREIGN KEY (id_tramite)
        REFERENCES operativo.tramites(id_tramite) ON DELETE CASCADE
    -- ,CONSTRAINT fk_director_departamental FOREIGN KEY (id_director_departamental)
        -- REFERENCES Revisores(id_revisor) ON DELETE CASCADE
    -- ,CONSTRAINT fk_tecnico_departamental FOREIGN KEY (id_tecnico_departamental)
        -- REFERENCES Revisores(id_revisor) ON DELETE CASCADE
);

-- #################################################################################

CREATE TABLE operativo.paquetes (
    id_paquete SERIAL PRIMARY KEY,    
    usuario_creacion INT NOT NULL, -- TECSDE
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    etiqueta_contenido TEXT NOT NULL,
    estado VARCHAR(50) NOT NULL DEFAULT 'Creado'
    -- ,CONSTRAINT fk_tecnico_departamental FOREIGN KEY (id_tecnico_departamental)
        -- REFERENCES Revisores(id_revisor) ON DELETE CASCADE
);
select * from operativo.diploma_documentos; -- docigo-rude
select * from operativo.diplomas; -- id-tramite

CREATE TABLE operativo.paquete_documentos (
    id_paquete_documento SERIAL PRIMARY KEY,
    id_paquete INT NOT NULL,
    id_derivacion INT NOT NULL,
    id_documento INT4 NULL, -- operativo.diploma_documentos
    id_diploma INT4 NULL, -- operativo.diplomas
    CONSTRAINT fk_paquete FOREIGN KEY (id_paquete)
        REFERENCES operativo.paquetes(id_paquete) ON DELETE cascade
    ,CONSTRAINT fk_derivacion FOREIGN KEY (id_derivacion)
        REFERENCES operativo.derivaciones(id_derivacion) ON DELETE CASCADE
    -- ,CONSTRAINT fk_documento FOREIGN KEY (id_documento)
        -- REFERENCES documentos(id_documento) ON DELETE CASCADE
);

-- #################################################################################

CREATE TABLE operativo.entregas_distrital (
    id_entrega_distrital SERIAL PRIMARY KEY,
    id_paquete INT NOT NULL,
    usuario_destino INT NOT NULL, -- TECSDI
    fecha_recepcion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(50) NOT NULL DEFAULT 'Recibido',
    CONSTRAINT fk_paquete FOREIGN KEY (id_paquete)
        REFERENCES operativo.paquetes(id_paquete) ON DELETE CASCADE
    -- ,CONSTRAINT fk_tecnico_distrital FOREIGN KEY (id_tecnico_distrital)
        -- REFERENCES Revisores(id_revisor) ON DELETE CASCADE
);

CREATE TABLE operativo.entregas_unidad_educativa (
    id_entrega_ue SERIAL PRIMARY KEY,
    id_entrega_distrital INT NOT NULL,
    cod_sie_ue INT NOT NULL,
    usuario_destino INT NOT NULL, -- DIR
    etiqueta_contenido TEXT NOT NULL,
    fecha_entrega TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(50) NOT NULL DEFAULT 'Entregado',
    CONSTRAINT fk_entrega_distrital FOREIGN KEY (id_entrega_distrital)
        REFERENCES operativo.entregas_distrital(id_entrega_distrital) ON DELETE CASCADE
    -- ,CONSTRAINT fk_unidad_educativa FOREIGN KEY (id_unidad_educativa)
        -- REFERENCES Colegios(id_colegio) ON DELETE CASCADE
);
