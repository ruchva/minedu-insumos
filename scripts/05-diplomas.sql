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










			
			
			