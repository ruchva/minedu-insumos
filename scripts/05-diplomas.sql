select * from operativo.vw_estudiantes_diploma_documento_6to
where codigo_distrito =4001
and estado_matricula = 'PROMOVIDO'           
and archivo_declaracion_jurada_estado 
--and archivo_declaracion_jurada_firmada_estado    
;

SELECT v.codigo_rude, 	v.cod_ue_id, 	ue.gestion,
    ue.desc_ue AS nombre_unidad_educativa,
    v.paterno AS ap_paterno,
    v.materno AS ap_materno,
    v.nombre, v.fecha_nacimiento, 	v.genero, 	v.empareja_sereci,
    v.carnet AS cedula,
    v.expedido_id,  v.dni,    v.paralelo,    v.estado_matricula,    v.estado_proceso,    v.provincia,    v.localidad,    v.pais,    v.nombre_departamento,
    ue.nombre_departamento AS nombre_departamento_ue,
    v.codigo_departamento,    v.nombre_distrito,    v.codigo_distrito,
    CASE WHEN f.file_path IS NOT NULL THEN true ELSE false END AS archivo_foto_digital_estado,
    f.file_path AS archivo_foto_digital,
    CASE WHEN d.file_path IS NOT NULL THEN true ELSE false END AS archivo_declaracion_jurada_estado,
    d.file_path AS archivo_declaracion_jurada,
    CASE WHEN df.file_path IS NOT NULL THEN true ELSE false END AS archivo_declaracion_jurada_firmada_estado,
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
WHERE v.cod_ue_id =81230066 and v.paralelo ='A' and v.estado_matricula = 'EFECTIVO';
-- ############################################################################
-- DocumentosController api/documentos/declaracion-jurada-revision-tramites/unidad-educativa/{codigoRue}
SELECT e.codigo_rude as codigo_rude, e.archivo_declaracion_jurada as filepath
FROM operativo.vw_estudiantes_diploma_documento_6to e
WHERE e.cod_ue_id = 81230066
			AND e.paralelo = 'A'
			--AND e.archivo_declaracion_jurada_estado = true
			AND e.estado_matricula = 'EFECTIVO'
ORDER BY e.ap_paterno ASC, e.ap_materno ASC, e.nombre asc;
--
select * FROM operativo.vw_estudiantes_diploma_documento_6to e 
where e.archivo_declaracion_jurada_estado =false;
--
   select * 
    from operativo.vw_estudiantes_diploma_documento_6to e 
    WHERE
        e.cod_ue_id = 81230066
        AND e.estado_matricula = 'EFECTIVO'          
    ORDER BY
        e.paralelo ASC,
        e.ap_paterno ASC,
        e.ap_materno ASC,
        e.nombre asc;  

update tramites set estado ='PC';

with totalestudiantesgeneral as (
     SELECT COUNT(*) AS total_estudiantes_general
     FROM operativo.vw_estudiantes_diploma_documento_6to v
     WHERE v.codigo_departamento = 4
)
SELECT
    MAX(v.nombre_departamento_ue) AS departamento,
    v.codigo_distrito as id_distrito,
    v.nombre_distrito as distrito,
    COUNT(distinct v.cod_ue_id)   AS total_unidades_educativas,
    COUNT(distinct v.cod_ue_id)   AS unidades_educativas,
    COUNT(distinct v.codigo_rude) AS total_estudiantes,
    COUNT(distinct v.codigo_rude) filter (where v.estado_tramite = 'RZ')                AS total_rezagados,
    COUNT(distinct v.codigo_rude) filter (where v.estado_tramite in ('JL', 'DP', 'DG')) AS total_validos,
    COUNT(distinct v.codigo_rude) filter (where v.estado_tramite in ('OD'))             AS total_observados,
    COUNT(*) over() AS total_registros,
    MAX(t.total_estudiantes_general) AS total_estudiantes_general,
    (dd.file_path is not null) AS firma_digital_estado,
    dd.file_path AS firma_digital_path,
    SUM(li.cantidad) AS cantidad_impresion,
    CASE
        WHEN COUNT(*) FILTER (WHERE li.estado IS NULL) > 0 THEN NULL
        ELSE MIN(li.estado)
    END AS estado,
    COUNT(*) FILTER (WHERE v.estado_tramite NOT IN ('PC')) AS revision_tecnica,
    COUNT(*) FILTER (WHERE v.estado_matricula IN ('PROMOVIDO', 'REPROBADO')) AS notas_finales
FROM operativo.vw_estudiantes_diploma_documento_6to v
    LEFT JOIN operativo.diploma_documentos dd on dd.file_path = 2026||'/'||replace(v.nombre_departamento_ue, '%20', ' ')||'/'||v.codigo_distrito||'/firmado_acta_autorizacion_emision_distrito_'||v.codigo_distrito||'.pdf'
    LEFT JOIN operativo.lotes_impresion li ON v.codigo_distrito = li.id_distrito
    CROSS JOIN totalestudiantesgeneral t
WHERE v.codigo_departamento = 4
    GROUP BY v.codigo_distrito, v.nombre_distrito, dd.file_path
    ORDER BY v.nombre_distrito asc
LIMIT 21 OFFSET 0;

select * from operativo.diploma_documentos where file_path ilike '%firmado_%';


SELECT 
    id,
    codigo_rol,
    bandeja_codigo,
    estado_codigo,
    estado_matricula AS filtro_estado_matricula
FROM operativo.v_bandeja_regla_detalle
WHERE codigo_rol = 22
  AND bandeja_codigo = :bandeja
  AND activo = true
  ;

select *
from operativo.vw_estudiantes_diploma_documento_6to
where estado_tramite <>'PC'
;

select * 
from operativo.tramites 
where estado <>'PC'
;

SELECT e.cod_ue_id as id_unidad_educativa,
	e.nombre_unidad_educativa as nombre_unidad_educativa,
	e.cod_ue_id as rue,
	e.codigo_rude as codigo_rude,
	e.cedula as ci,
	e.nombre as nombre,
	e.ap_paterno as paterno,
	e.ap_materno as materno
FROM operativo.vw_estudiantes_diploma_documento_6to e
WHERE e.cod_ue_id = 81230251 AND e.estado_matricula = 'EFECTIVO';

select *
from operativo.vw_estudiantes_diploma_documento_6to e 
where e.cod_ue_id = 81230251 AND e.estado_matricula = 'EFECTIVO'          
ORDER BY e.paralelo ASC, e.ap_paterno ASC, e.ap_materno ASC, e.nombre asc; 

SELECT
    e.cod_ue_id AS idUnidadEducativa,
    e.nombre_unidad_educativa AS nombreUnidadEducativa,
    e.cod_ue_id AS codSieUe,
    COUNT(DISTINCT e.codigo_rude) AS totalEstudiantes,
    COUNT(DISTINCT e.codigo_rude) FILTER (WHERE e.estado_tramite IN ('JL', 'ER', 'VA')) AS enviadosJefeLegalizaciones,
    COUNT(DISTINCT e.codigo_rude) FILTER (WHERE e.estado_tramite IN ('OD', 'FR')) AS observados,
    COUNT(DISTINCT e.codigo_rude) FILTER (WHERE e.estado_tramite = 'RZ') AS rezagados
FROM operativo.vw_estudiantes_diploma_documento_6to e
WHERE 1=1
  --and e.estado_matricula = 'EFECTIVO'
  AND e.codigo_distrito = 4001
GROUP BY e.cod_ue_id, e.nombre_unidad_educativa
ORDER BY e.nombre_unidad_educativa;

SELECT
  id AS id,
  nombre AS nombre,
  label AS label,
  inicio AS inicio,
  fin AS fin,
  estado AS estado
FROM operativo.periodos
ORDER BY id asc;










			
			
			