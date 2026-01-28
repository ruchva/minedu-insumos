-- primerio ejecutar
-- DROP SERVER IF EXISTS sie_remoto_fdw CASCADE;
-- DROP SCHEMA IF EXISTS sie_fdw CASCADE;

CREATE EXTENSION IF NOT EXISTS postgres_fdw;
CREATE SCHEMA sie_fdw AUTHORIZATION postgres;

CREATE SERVER sie_remoto_fdw
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (
    host '100.0.102.148',
    dbname 'sie_produccion',
    port '5437'
);
CREATE USER MAPPING FOR postgres
SERVER sie_remoto_fdw
OPTIONS (
    user 'bojeda',
    password 'B0G3daP40La41iAg'
);

-- 7	TECSDE	        Tecnico SIE Departamental
-- 9	DIR	            Director (Institución Educativa)
-- 10	TECSDI	        Técnico SIE Distrital
-- 21	ADMINISTRADOR	Usuario Administrador
-- 22	RESLEG	        Responsable de Legalizaón
-- 38	DDEP	        Director Departamental

SELECT codigo, lugar FROM lugar_tipo WHERE lugar_nivel_id =8;
select * from vw_estudiantes_historial_academico;
select * from vw_estudiantes_historial_academico where codigo_rude in('100000000003081167', '100000000003076628');
SELECT public.refrescar_vw_estudiantes_historial_academico();
--
select c.codigo_rude,
	f.des_dis AS distrito_educativo,
    d.institucioneducativa AS unidad_educativa,
    d.id AS codigo_sie,
    (SELECT grado FROM grado_tipo WHERE id = a.grado_tipo_id) AS escolaridad,
    (SELECT estadomatricula FROM estadomatricula_tipo WHERE id = b.estadomatricula_tipo_id) AS estadomatricula,
    a.gestion_tipo_id::int AS gestion,
    b.id as id_inscripcion
FROM institucioneducativa_curso a
	INNER JOIN estudiante_inscripcion b ON a.id = b.institucioneducativa_curso_id
	INNER JOIN estudiante c ON b.estudiante_id = c.id
	INNER JOIN institucioneducativa d ON a.institucioneducativa_id = d.id
	INNER JOIN jurisdiccion_geografica e ON d.le_juridicciongeografica_id = e.id
	INNER JOIN (
    	SELECT id, codigo AS cod_dis, lugar_tipo_id, lugar AS des_dis
    	FROM lugar_tipo
    	WHERE lugar_nivel_id = 7
	) f ON e.lugar_tipo_id_distrito = f.id
where a.nivel_tipo_id IN (13)
      AND a.grado_tipo_id IN (1, 2, 3, 4, 5, 6)
      and c.codigo_rude ='100000000003175497'
;
--
select * from estudiante e where e.codigo_rude ='100000000004846301';
-- select * from vw_datos_estudiantes_6to_2025 where codigo_rude in('100000000004846301') and estado_matricula  ='EFECTIVO';
-- select * from vw_datos_estudiantes_6to_2025 where estado_matricula  ='EFECTIVO'; --170278
-- select estado_matricula, count(estado_matricula) from vw_datos_estudiantes_6to_2025 group by estado_matricula having count(estado_matricula)>1; 
SELECT public.refrescar_vw_datos_estudiantes_6to_2025();
select * from estudiante e where e.carnet_identidad  ='7628145';
select * from persona where carnet ='7628145';
select * from estudiante where pais_tipo_id not in (0,1);
select * from pais_tipo pt order by 1;
SELECT codigo, lugar FROM lugar_tipo WHERE lugar_nivel_id =7;
--

-- VISTAS MATERIALIZADAS 

create materialized view vw_distritos as
select distinct ut.cod_distrito::int4 as id_distrito
	, ut.distrito as nombre_distrito
	, ut.id_departamento::int4 
from institucioneducativa_curso ic 
	join estudiante_inscripcion ei on ic.id = ei.institucioneducativa_curso_id 
	join ues_total ut on ic.institucioneducativa_id = ut.cod_ue_id 
where ic.nivel_tipo_id in(11,12,13)
	and ei.estadomatricula_tipo_id not in (6,9)
	and ic.gestion_tipo_id = extract(year from now())
order by 1
with data
;

CREATE UNIQUE INDEX idx_vw_distritos ON vw_distritos (id_distrito, nombre_distrito, id_departamento);

CREATE OR REPLACE FUNCTION refrescar_vw_distritos()
RETURNS void AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY vw_distritos;
END;
$$ LANGUAGE plpgsql;

-- ##########################################################################################################
CREATE MATERIALIZED VIEW vw_estudiantes_historial_academico AS
select c.codigo_rude,
      f.des_dis AS distrito_educativo,
      d.institucioneducativa AS unidad_educativa,
      d.id AS codigo_sie,
      (SELECT grado FROM grado_tipo WHERE id = a.grado_tipo_id) AS escolaridad,
      (SELECT estadomatricula FROM estadomatricula_tipo WHERE id = b.estadomatricula_tipo_id) AS estadomatricula,
      a.gestion_tipo_id::int AS gestion,
      b.id as id_inscripcion
FROM institucioneducativa_curso a
	INNER JOIN estudiante_inscripcion b ON a.id = b.institucioneducativa_curso_id
	INNER JOIN estudiante c ON b.estudiante_id = c.id
	INNER JOIN institucioneducativa d ON a.institucioneducativa_id = d.id
	INNER JOIN jurisdiccion_geografica e ON d.le_juridicciongeografica_id = e.id
	INNER JOIN (
    	SELECT id, codigo AS cod_dis, lugar_tipo_id, lugar AS des_dis
    	FROM lugar_tipo
    	WHERE lugar_nivel_id = 7
	) f ON e.lugar_tipo_id_distrito = f.id
where a.nivel_tipo_id IN (13)
      AND a.grado_tipo_id IN (1, 2, 3, 4, 5, 6)      
WITH DATA;

--drop materialized view vw_estudiantes_historial_academico;
CREATE UNIQUE INDEX idx_vw_estudiantes_historial_academico ON vw_estudiantes_historial_academico (codigo_rude, codigo_sie, escolaridad, estadomatricula, gestion, id_inscripcion);

CREATE OR REPLACE FUNCTION refrescar_vw_estudiantes_historial_academico()
RETURNS void AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY vw_estudiantes_historial_academico;
END;
$$ LANGUAGE plpgsql;

-- ##########################################################################################################
CREATE MATERIALIZED VIEW public.vw_datos_estudiantes_6to
AS SELECT d.codigo_rude,
    c.cod_ue_id,
    d.paterno,
    d.materno,
    d.nombre,
    d.fecha_nacimiento,
    gt.genero,
    d.carnet_identidad AS carnet,
    d.expedido_id,
        CASE
            WHEN d.pais_tipo_id = ANY (ARRAY[0, 1]) THEN 0
            ELSE 1
        END AS dni,
    pt.paralelo,
    ( SELECT estadomatricula_tipo.estadomatricula
           FROM estadomatricula_tipo
          WHERE estadomatricula_tipo.id = b.estadomatricula_tipo_id) AS estado_matricula,
    NULL::text AS estado_proceso,
    lt.lugar AS provincia,
    d.localidad_nac AS localidad,
    pt2.pais,
    lt3.lugar AS nombre_departamento,
    c.id_departamento::integer AS codigo_departamento,
    lt2.lugar AS nombre_distrito,
    lt2.codigo::integer AS codigo_distrito
   FROM institucioneducativa_curso a
     JOIN estudiante_inscripcion b ON a.id = b.institucioneducativa_curso_id
     JOIN ues_total c ON a.institucioneducativa_id = c.cod_ue_id
     JOIN estudiante d ON b.estudiante_id = d.id
     JOIN genero_tipo gt ON gt.id = d.genero_tipo_id
     JOIN paralelo_tipo pt ON pt.id::text = a.paralelo_tipo_id::text
     JOIN lugar_tipo lt ON lt.lugar_nivel_id = 2 AND lt.id = d.lugar_prov_nac_tipo_id
     JOIN institucioneducativa d1 ON a.institucioneducativa_id = d1.id
     JOIN jurisdiccion_geografica e ON d1.le_juridicciongeografica_id = e.id
     JOIN ( SELECT lugar_tipo.id,
            lugar_tipo.codigo,
            lugar_tipo.lugar
           FROM lugar_tipo
          WHERE lugar_tipo.lugar_nivel_id = 7) lt2 ON lt2.id = e.lugar_tipo_id_distrito
     JOIN ( SELECT lugar_tipo.codigo,
            lugar_tipo.lugar
           FROM lugar_tipo
          WHERE lugar_tipo.lugar_nivel_id = 8) lt3 ON lt3.codigo::integer::text = c.id_departamento::text
     JOIN pais_tipo pt2 ON pt2.id = d.pais_tipo_id
  WHERE a.nivel_tipo_id = 13 AND a.grado_tipo_id = 6 AND a.gestion_tipo_id::numeric = EXTRACT(year FROM now())
WITH DATA;

CREATE UNIQUE INDEX idx_vw_datos_estudiantes_6to ON vw_datos_estudiantes_6to (codigo_rude, cod_ue_id, carnet);

CREATE OR REPLACE FUNCTION refrescar_vw_datos_estudiantes_6to()
RETURNS void AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY vw_datos_estudiantes_6to;
END;
$$ LANGUAGE plpgsql;

select refrescar_vw_datos_estudiantes_6to();










