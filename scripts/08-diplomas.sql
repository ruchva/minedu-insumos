

-- REVISION ERRORES DEMO FEBRERO 2026
select f.*, d.*, df.*
FROM sie_fdw.vw_datos_estudiantes_6to v
LEFT JOIN operativo.diploma_documentos f ON v.codigo_rude::text = f.codigo_rude::text AND f.tipo_documento::text = 'FOTOGRAFIA'::text AND f.estado::text = 'ACTIVO'::text
LEFT JOIN operativo.diploma_documentos d ON v.codigo_rude::text = d.codigo_rude::text AND d.tipo_documento::text = 'DECLARACION_JURADA'::text AND d.estado::text = 'ACTIVO'::text
LEFT JOIN operativo.diploma_documentos df ON v.codigo_rude::text = df.codigo_rude::text AND df.tipo_documento::text = 'DECLARACION_JURADA_FIRMADA'::text AND df.estado::text = 'ACTIVO'::text
LEFT JOIN operativo.tramites t ON v.codigo_rude::text = t.codigo_rude::text
LEFT JOIN sie_fdw.vw_unidades_educativas_usuario_persona_paralelos_6to ue ON v.cod_ue_id = ue.cod_ue_id
where v.estado_matricula ='PROMOVIDO'
	and v.codigo_distrito =4001
	and v.cod_ue_id =81230329
;

select f.*, d.*, df.*,v.*
FROM sie_fdw.vw_datos_estudiantes_6to v
LEFT JOIN operativo.diploma_documentos f ON v.codigo_rude::text = f.codigo_rude::text AND f.tipo_documento::text = 'FOTOGRAFIA'::text AND f.estado::text = 'ACTIVO'::text
LEFT JOIN operativo.diploma_documentos d ON v.codigo_rude::text = d.codigo_rude::text AND d.tipo_documento::text = 'DECLARACION_JURADA'::text AND d.estado::text = 'ACTIVO'::text
LEFT JOIN operativo.diploma_documentos df ON v.codigo_rude::text = df.codigo_rude::text --AND df.tipo_documento::text = 'DECLARACION_JURADA_FIRMADA'::text AND df.estado::text = 'ACTIVO'::text
where 1=1
	and v.estado_matricula ='PROMOVIDO'
	and v.codigo_distrito =4001
	and v.cod_ue_id =81230386
	and v.codigo_rude in ('100000000008338244','100000000006260397','100000000008337898','100000000006260398','100000000002726672')
;






