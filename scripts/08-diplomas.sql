select
	(
	select
		serie
	from
		operativo.next_serie_secuencias(ue.departamento_abreviacion,
		cast(extract(year from now()) as smallint))) as serie ,
	ue.nombre_departamento as departamento ,
	ue.cod_distrito as distrito ,
	ue.cod_ue_id as codigoRue ,
	e.paralelo as paralelo ,
	e.codigo_rude as codigoRude ,
	case
		when t.tipo_tramite = '1' 
                then 'Humanidades'
		else 'Otro'
	end as especialidad ,
	e.nombre || ' ' || e.ap_paterno || ' ' || e.ap_materno as nombreCompleto ,
	e.localidad as lugarNacimiento ,
	to_char(e.fecha_nacimiento, 'DD Mon YYYY') as fechaNacimiento ,
	ue.nombre_departamento as ciudadEmision ,
	to_char(now(), 'DD') as diaEmision ,
	to_char(now(), 'TMMonth')|| ' ' || to_char(now(),
    'YYYY') as mesAnioEmision ,
	'' as codigoBarras2 ,
	(
	select
		p1.nombres || ' ' || p1.primer_apellido || ' ' || p1.segundo_apellido
	from
		usuarios.roles r1
	join
        usuarios.usuarios_roles ur1 
            on
		ur1.id_rol = r1.id
	join
        usuarios.usuarios u1 
            on
		ur1.id_usuario = u1.id
	join
        usuarios.personas p1 
            on
		u1.id_persona = p1.id
	where
		u1._estado = 'ACTIVO'
		and r1._estado = 'ACTIVO'
		and r1.id = 38
		and p1.id_departamento = ue.id_departamento
	order by
		p1.id desc
	limit
        1 ) as firma1 ,
	'Director Departamental' as cargo1 ,
	t.id_tramite as idTramite ,
	(
	select
		file_path
	from
		operativo.diploma_documentos ed
	where
		ed.tipo_documento = 'FOTOGRAFIA'
		and ed.codigo_rude = e.codigo_rude) as fotoPath
from
	operativo.tramites t
join
    operativo.vw_estudiantes_diploma_documento_6to e 
        on
	e.codigo_rude = t.codigo_rude
	and e.estado_matricula = 'PROMOVIDO'
	and e.archivo_declaracion_jurada_estado
	--and e.archivo_declaracion_jurada_firmada_estado         
join
    sie_fdw.vw_unidades_educativas_usuario_persona_paralelos_6to ue 
        on
	ue.cod_ue_id = e.cod_ue_id
where
	t.tipo_tramite = '1'
	and ue.cod_distrito = 4001;

select * from operativo.vw_estudiantes_diploma_documento_6to
where codigo_distrito =4001
and estado_matricula = 'PROMOVIDO'           
and archivo_declaracion_jurada_estado 
--and archivo_declaracion_jurada_firmada_estado    
;
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






