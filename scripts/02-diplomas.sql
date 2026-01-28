-- REPORTE CODIGO DE VERIFICACION 
select d.gestion
	,ve.codigo_rude as rude
	,ve.cedula as cedulaIdentidad
	,ve.ap_paterno as apellidoPaterno
	,ve.ap_materno as apellidoMaterno
	,ve.nombre as nombres
	,ve.fecha_nacimiento as fechaNacimiento
	,ve.nombre_departamento as departamento
	,ve.provincia 
	,ve.localidad 
	,ve.empareja_sereci as contrastado
	,d.cod_verificacion_amigable as codigoCertificacion
from operativo.diplomas d
	join operativo.tramites t on d.id_tramite = t.id_tramite 
	join operativo.vw_estudiantes_diploma_documento_6to ve on t.codigo_rude = ve.codigo_rude 	
where ve.codigo_distrito = 2002
limit 100
;
-- 
WITH data AS (
    SELECT
        v.nombre_departamento AS departamento,
        v.codigo_distrito AS id_distrito,
        v.nombre_distrito AS distrito,
        COUNT(DISTINCT v.cod_ue_id) AS total_unidades_educativas,
        COUNT(*) FILTER (WHERE v.estado_tramite = 'RZ') AS total_rezagados,
        COUNT(*) FILTER (WHERE v.estado_tramite = 'JL') AS total_validos,
        COUNT(*) FILTER (WHERE v.estado_tramite IN ('OD')) AS total_observados,
        COUNT(*) AS total_estudiantes,
        '2025/' ||
        REPLACE(v.nombre_departamento, '%20', ' ') || '/' ||
        v.codigo_distrito || '/firmado_acta_autorizacion_emision_distrito_' ||
        v.codigo_distrito || '.pdf' AS path_archivo
    FROM operativo.vw_estudiantes_diploma_documento_6to v
    WHERE v.codigo_departamento = 2
    --""" + filtro + """
    GROUP BY v.nombre_departamento, v.codigo_distrito, v.nombre_distrito
)
SELECT
    d.departamento,
    d.id_distrito,
    d.distrito,
    d.total_unidades_educativas,
    d.total_unidades_educativas AS unidades_educativas,
    d.total_estudiantes,
    d.total_rezagados,
    d.total_validos,
    d.total_observados,
    COUNT(*) OVER() AS total_registros,
    SUM(total_estudiantes) OVER() AS total_estudiantes_general,
    CASE WHEN dd.file_path IS NOT NULL THEN TRUE ELSE FALSE END AS firma_digital_estado,
    dd.file_path AS firma_digital_path                    
    ,li.estado
FROM data d
LEFT JOIN operativo.diploma_documentos dd
    ON dd.file_path = d.path_archivo
   AND dd.estado = 'ACTIVO'
LEFT JOIN operativo.lotes_impresion li on d.id_distrito = li.id_distrito
ORDER BY d.total_unidades_educativas DESC, d.total_estudiantes DESC
LIMIT 20 OFFSET 1
;
--
select
	u.id_persona as id_persona,
	u.usuario as usuario,
	r.nombre as rol_nombre,
	r.rol as role,
	p.nombres as nombres,
	p.primer_apellido as primer_apellido,
	p.segundo_apellido as segundo_apellido,
	dep.nombre_departamento as nombre_departamento,
	dis.nombre_distrito as nombre_distrito
from usuarios.usuarios u
	join usuarios.usuarios_roles ur on u.id = ur.id_usuario
	join usuarios.roles r on r.id = ur.id_rol
	join usuarios.personas p on u.id_persona = p.id
	left join operativo.departamentos dep on p.id_departamento = dep.id_departamento
	left join operativo.distritos dis on p.id_distrito = dis.id_distrito
where u.usuario ='2754932' and u._estado = 'ACTIVO' and ur._estado = 'ACTIVO' and r.id = 9
;		
--				
select * from operativo.diploma_documentos; -- docigo-rude
select * from operativo.diplomas; --id-tramite
select * from operativo.distritos order by id_distrito;
select * from sie_fdw.vw_distritos order by id_distrito;

select * from operativo.serie_secuencias;
				
				
				
				
				
				
				
				