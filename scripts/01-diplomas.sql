SELECT
    v.nombre_departamento AS departamento,
    v.codigo_distrito AS id_distrito,
    v.nombre_distrito AS distrito,
    COUNT(DISTINCT v.cod_ue_id) AS total_unidades_educativas,
    COUNT(*) FILTER (WHERE v.estado_tramite = 'RZ') AS total_rezagados,
    COUNT(*) FILTER (WHERE v.estado_tramite = 'JL') AS total_validos,
    COUNT(*) FILTER (WHERE v.estado_tramite IN ('OD')) AS total_observados,
    COUNT(*) AS total_estudiantes, '2025/' || REPLACE(v.nombre_departamento, '%20', ' ') || '/' || v.codigo_distrito || '/firmado_acta_autorizacion_emision_distrito_' || v.codigo_distrito || '.pdf' AS path_archivo
--  ,(select li1.estado from operativo.lotes_impresion li1 where li1.id_distrito = v.codigo_distrito) as estado_distrito
    ,li.estado
FROM operativo.vw_estudiantes_diploma_documento_6to v
	left join operativo.lotes_impresion li on li.id_distrito = v.codigo_distrito
WHERE v.codigo_departamento = 2
/*AND (
    --v.nombre_departamento ILIKE 'La Paz'
    v.nombre_distrito ILIKE ''
    OR v.cod_ue_id::text ILIKE ''
    OR v.codigo_rude ILIKE ''
    OR v.estado_tramite ILIKE ''
)*/
GROUP BY v.nombre_departamento, v.codigo_distrito, v.nombre_distrito, li.estado
;
select * from operativo.lotes_impresion;
--
select * from usuarios.casbin_rule where v3='backend' and v0='DDEP' order by id;
select * from usuarios.casbin_rule where v0='RESLEG' order by id; 
--99
INSERT INTO usuarios.casbin_rule(id, ptype, v0, v1, v2, v3, v4, v5, v6)
VALUES(99, 'p', 'DDEP', '/api/diplomas/generate/rude/:codigoRude', 'GET|POST', 'backend', NULL, NULL, NULL);
INSERT INTO usuarios.casbin_rule(id, ptype, v0, v1, v2, v3, v4, v5, v6)
VALUES(100, 'p', 'DDEP', '/api/diplomas/generate/paralelo/:codigoSieUE/:paralelo', 'GET|POST', 'backend', NULL, NULL, NULL);
INSERT INTO usuarios.casbin_rule(id, ptype, v0, v1, v2, v3, v4, v5, v6)
VALUES(101, 'p', 'DDEP', '/api/diplomas/generate/distrito/:codigoDistrito', 'GET|POST', 'backend', NULL, NULL, NULL);
INSERT INTO usuarios.casbin_rule(id, ptype, v0, v1, v2, v3, v4, v5, v6)
VALUES(102, 'p', 'DDEP', '/api/diplomas/generate/codigo-sieue/:codigoSieUE', 'GET|POST', 'backend', NULL, NULL, NULL);
commit;
select * from usuarios.roles;
--
select d.*
from operativo.diplomas d
    join operativo.tramites t on d.id_tramite = t.id_tramite
    join operativo.vw_estudiantes_diploma_documento_6to e on t.codigo_rude = e.codigo_rude
where e.cedula = '6561374'
    and e.fecha_nacimiento = now()
    and d.url_diploma_firmado IS NOT NULL
;
		
select d.url_diploma_generado as diplomaGenerado
    ,cast(li.id_lote as bigint) as idLote
from operativo.diplomas d
    join operativo.lotes_impresion li on d.lote_impresion = li.id_lote
    join sie_fdw.vw_unidades_educativas_usuario_persona_paralelos_6to ue on ue.cod_ue_id = li.cod_sie_ue
where ue.cod_distrito =0
;
select d.url_diploma_generado as diplomaGenerado 
    ,cast(li.id_lote as bigint) as idLote
from operativo.diplomas d
    join operativo.lotes_impresion li on d.lote_impresion = li.id_lote
    join operativo.tramites t on d.id_tramite = t.id_tramite
where t.codigo_rude = ''
;
select d2.id_departamento, d2.nombre_departamento 
from operativo.distritos d
    join operativo.departamentos d2 on d.id_departamento = d2.id_departamento
where d.id_distrito = 0
;
--
select * from operativo.vw_estudiantes_diploma_documento_6to e;
select * from sie_fdw.vw_unidades_educativas_usuario_persona_paralelos_6to ue where ue.desc_ue ilike '%Manupare%';
select * from operativo.distritos where id_distrito =9008; --BOLIVAR (C. SENA)
--
select * from operativo.diplomas; --delete from operativo.diplomas;
select * from operativo.lotes_impresion; --delete from operativo.lotes_impresion;
--select director departamental por depto como unico firmante
select p.nombres ||' '|| p.primer_apellido ||' '|| p.segundo_apellido as nombre_completo, r.nombre, r.rol, p.id_departamento, p.id 
	,u.usuario ,u._estado estado_usu ,ur._estado estado_rol, u.id id_usuario, r.id id_rol
from usuarios.roles r
	join usuarios.usuarios_roles ur on ur.id_rol = r.id
	join usuarios.usuarios u on ur.id_usuario = u.id
	join usuarios.personas p on u.id_persona = p.id
where 1=1
	--and r.id =38
	and p.id_departamento =9
order by p.id desc --limit 1
;
select * from operativo.distritos where id_distrito =4001;
select * from sie_fdw.vw_unidades_educativas_usuario_persona_paralelos_6to 
where cod_distrito =4001 and cod_ue_id in(81230249,81230251);
select * from usuarios.usuarios where id_persona in (93774,20249010);
-- 3116026 SARACHO
-- 2758981 ARCE
select * from usuarios.usuarios where usuario in ('5727128','3524094','3078765');
select * from usuarios.casbin_rule where v0 ='TECSDE' and v3 ='backend' and v2 ='POST';
select * from usuarios.roles;
-- DIR    Director (Institución Educativa)
-- TECSDE Tecnico SIE Departamental
-- RESLEG Responsable de Legalizaón
-- DDEP   Director Departamental
-- TECSDI Técnico SIE Distrital NO HACE NADA
select * from usuarios.roles; --22 38
select * from usuarios.personas order by id desc;
select * from usuarios.usuarios_roles where id_usuario in (13818833,13856039,92520145);
select * from usuarios.usuarios where id =92505602;--1917799
--
select * from usuarios.usuarios_roles order by id desc; 
select * from usuarios.usuarios order by id desc;
-- 96000000	4935044
select * from usuarios.personas order by id desc;
-- 2800000	RUBEN	CHIARA	VALENCIA
--
select d.url_diploma_generado as diplomaGenerado
    ,cast(li.id_lote as bigint) as idLote, li.cod_sie_ue
from operativo.diplomas d
    join operativo.lotes_impresion li on d.lote_impresion = li.id_lote
    join sie_fdw.vw_unidades_educativas_usuario_persona_paralelos_6to ue on ue.cod_distrito = li.id_distrito
where ue.cod_distrito =2082
  and li.id_lote = 94;
--
select url_diploma_generado, url_diploma_firmado, lote_impresion from operativo.diplomas order by lote_impresion;
--
select * from operativo.lotes_impresion;
select * from operativo.diplomas;
select * from sie_fdw.vw_unidades_educativas_usuario_persona_paralelos_6to;
--
select distinct d.url_diploma_generado as diplomaGenerado, cast(li.id_lote as bigint) as idLote ,ue.cod_distrito
from operativo.diplomas d
    join operativo.lotes_impresion li on d.lote_impresion = li.id_lote
    join sie_fdw.vw_unidades_educativas_usuario_persona_paralelos_6to ue on ue.cod_distrito  = li.id_distrito
--where ue.cod_distrito = 7003
order by ue.cod_distrito desc
;
--    
SELECT * 
FROM operativo.vw_estudiantes_diploma_documento_6to e 
WHERE e.cod_ue_id = 62460008 
    --AND e.estado_matricula ILIKE ANY (ARRAY[?]::text[]) 
    AND e.estado_tramite IN ('PC') 
ORDER BY paralelo ASC,
    e.ap_paterno ASC,
    e.ap_materno ASC,
    e.nombre asc; 
--
select * from operativo.vw_estudiantes_diploma_documento_6to 
where cod_ue_id = 62460008;
--
select * from operativo.departamentos;
select * from operativo.distritos where id_departamento =7;
--
select * from operativo.lotes_impresion;
select * from operativo.diplomas order by lote_impresion;
--
select * from operativo.serie_secuencias;
select * from usuarios.casbin_rule order by id;
--
select distinct d.url_diploma_generado as diplomaGenerado
    ,cast(li.id_lote as bigint) as idLote
    ,t.codigo_rude as codigoRude
from operativo.diplomas d
    join operativo.lotes_impresion li on d.lote_impresion = li.id_lote
    join sie_fdw.vw_unidades_educativas_usuario_persona_paralelos_6to ue on ue.cod_distrito = li.id_distrito
    join operativo.tramites t on t.id_tramite = d.id_tramite 
where ue.cod_distrito = 4001;
--

select ve.gestion
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
where ve.codigo_distrito = 4001
limit 100;





