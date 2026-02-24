
-- # RESET OPERATIVO
delete from operativo.diploma_documentos;
delete from operativo.tramites_historial;
delete from operativo.tramite_observaciones;
delete from operativo.lotes_impresion;
delete from operativo.notificaciones;
update operativo.serie_secuencias set secuencial=1;
update operativo.serie_secuencias set gestion = 2026;
update operativo.tramites set estado = 'PC' 
where codigo_rude in (
	select t.codigo_rude
	from operativo.tramites t
	where t.estado <> 'PC'
);

-- # RELOAD TRAMITES
delete from operativo.tramites;
INSERT INTO operativo.tramites (codigo_rude, estado, fecha_registro, fecha_limite, observacion, id_revisor, tipo_tramite, usuario_registro, fecha_modificacion, usuario_modificacion)
SELECT codigo_rude,
    'PC' AS estado,
    CURRENT_DATE AS fecha_registro,
    (date_trunc('year', CURRENT_DATE) + interval '1 year - 1 day')::date  AS fecha_limite,
    NULL AS observacion,
    NULL AS id_revisor,
    1 AS tipo_tramite,
    'Migracion' AS usuario_registro,
    NULL AS fecha_modificacion,
    NULL AS usuario_modificacion
FROM sie_fdw.vw_datos_estudiantes_6to;


-- REVISION
SELECT v.codigo_rude,
    v.cod_ue_id,
    ue.gestion,
    ue.desc_ue AS nombre_unidad_educativa,
    v.paterno AS ap_paterno,
    v.materno AS ap_materno,
    v.nombre,
    v.fecha_nacimiento,
    v.genero,
    v.empareja_sereci,
    v.carnet AS cedula,
    v.expedido_id,
    v.dni,
    v.paralelo,
    v.estado_matricula,
    v.estado_proceso,
    v.provincia,
    v.localidad,
    v.pais,
    v.nombre_departamento,
    ue.nombre_departamento AS nombre_departamento_ue,
    v.codigo_departamento,
    v.nombre_distrito,
    v.codigo_distrito,
        CASE
            WHEN f.file_path IS NOT NULL THEN true
            ELSE false
        END AS archivo_foto_digital_estado,
    f.file_path AS archivo_foto_digital,
        CASE
            WHEN d.file_path IS NOT NULL THEN true
            ELSE false
        END AS archivo_declaracion_jurada_estado,
    d.file_path AS archivo_declaracion_jurada,
        CASE
            WHEN df.file_path IS NOT NULL THEN true
            ELSE false
        END AS archivo_declaracion_jurada_firmada_estado,
    df.file_path AS archivo_declaracion_jurada_firmada,
    t.id_tramite,
    t.estado AS estado_tramite,
    t.es_rezagado
   FROM sie_fdw.vw_datos_estudiantes_6to v
     LEFT JOIN operativo.diploma_documentos f ON v.codigo_rude::text = f.codigo_rude::text AND f.tipo_documento::text = 'FOTOGRAFIA'::text AND f.estado::text = 'ACTIVO'::text
     LEFT JOIN operativo.diploma_documentos d ON v.codigo_rude::text = d.codigo_rude::text AND d.tipo_documento::text = 'DECLARACION_JURADA'::text AND d.estado::text = 'ACTIVO'::text
     LEFT JOIN operativo.diploma_documentos df ON v.codigo_rude::text = df.codigo_rude::text AND df.tipo_documento::text = 'DECLARACION_JURADA_FIRMADA'::text AND df.estado::text = 'ACTIVO'::text
     LEFT JOIN operativo.tramites t ON v.codigo_rude::text = t.codigo_rude::text
     LEFT JOIN sie_fdw.vw_unidades_educativas_usuario_persona_paralelos_6to ue ON v.cod_ue_id = ue.cod_ue_id
where v.codigo_distrito =4001 
--and v.estado_matricula = 'PROMOVIDO' 
and v.cod_ue_id =81230386
;