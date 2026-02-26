SELECT public.refrescar_vw_datos_estudiantes_6to();


--***********************
--* EDUCACION ALTERNATIVA FUNSION SIE_PRODUCCION
--***********************
select j.id as estudiante_id_RAEP
	, i.id as estudiante_inscripcion_id_RAEP
	, null::smallint as estadomatricula_tipo_id_fin_R
	, null::character varying(80) as estadomatricula_fin_R
	, null::character varying(80) as estadomatricula_inicio_R
	, f.gestion_tipo_id as gestion_tipo_id_RAEP
	, f.periodo_tipo_id as periodo_tipo_id_RAEP
	, (select periodo from periodo_tipo where id=f.periodo_tipo_id) as periodo_RAEP
	, e.institucioneducativa_id as institucioneducativa_id_RAEP
	, z.institucioneducativa as institucioneducativa_RAEP
	, z.institucioneducativa_tipo_id as institucioneducativa_tipo_id_RAEP
	, q.descripcion as institucioneducativa_tipo_descrip_RAEP
	, null::smallint as nivel_tipo_id_R
	, null::character varying(45) as nivel_R
	, null::smallint as ciclo_tipo_id_R
	, null::character varying(50) as ciclo_R
	, null::smallint as grado_tipo_id_R
	, null::character varying(45) as grado_R
	, h.turno_tipo_id as turno_tipo_id_RAEP
	, (select turno from turno_tipo where id=h.turno_tipo_id) as turno_RAEP
	, h.paralelo_tipo_id as paralelo_tipo_id_RAEP
	, (select paralelo from paralelo_tipo where id=h.paralelo_tipo_id) as paralelo_RAEP
	, j.codigo_rude as codigo_rude_RAEP
	, j.paterno as paterno_RAEP
	, j.materno as materno_RAEP
	, j.nombre as nombre_RAEP
	, (select genero from genero_tipo where id=j.genero_tipo_id)as genero_RAEP
	, j.fecha_nacimiento as fecha_nacimiento_RAEP
	, j.carnet_identidad as carnet_identidad_RAEP
	, j.complemento as complemento_RAEP
	, f.sucursal_tipo_id as sucursal_tipo_id_A
	, a.codigo as superior_facultad_area_tipo_A
	, a.facultad_area as facultad_area_A
	, b.codigo as superior_especialidad_tipo_id_A
	, b.especialidad as especialidad_A
	, d.codigo as superior_acreditacion_tipo_id_A
	, d.acreditacion as acreditacion_A
	, cast(null as smallint) as area_especial_id_E
	, null::character varying(70) as area_especial_E
	, cast(null as smallint) as nivel_id_E
	, null::character varying(45) as nivel_E
	, cast(null as smallint) as grado_id_E
	, null::character varying(45) as grado_E
	, null::text as tecnica_E
	, cast(null as smallint) AS bloque_P
	, cast(null as smallint) AS parte_P
	, cast(null as date) AS fech_ini_P
	, cast(null as date) AS fech_fin_P
	, null::character varying(80) as estadomatricula_P
	, h.id as institucioneducativa_curso_id_RAEP
from superior_facultad_area_tipo a
    inner join superior_especialidad_tipo b on a.id=b.superior_facultad_area_tipo_id
    inner join superior_acreditacion_especialidad c on b.id=c.superior_especialidad_tipo_id
    inner join superior_acreditacion_tipo d on c.superior_acreditacion_tipo_id=d.id
    inner join superior_institucioneducativa_acreditacion e on e.acreditacion_especialidad_id=c.id
    inner join institucioneducativa_sucursal f on e.institucioneducativa_sucursal_id=f.id
    inner join institucioneducativa z on z.id = f.institucioneducativa_id 
	inner join superior_institucioneducativa_periodo g on g.superior_institucioneducativa_acreditacion_id=e.id
	inner join institucioneducativa_curso h on h.superior_institucioneducativa_periodo_id=g.id
	inner join estudiante_inscripcion i on h.id=i.institucioneducativa_curso_id
	inner join estudiante j on i.estudiante_id=j.id
	inner join institucioneducativa_tipo q on z.institucioneducativa_tipo_id=q.id
where 1=1 --limit 1000
-- and codigo_rude = '''|| codigo_rude_in ||'''  
-- and exists (select 1 from superior_modulo_periodo k where g.id=k.institucioneducativa_periodo_id)
and f.gestion_tipo_id =2025 
;

/**
 * mecanismo para migracion de datos el cual fue pasado a la logica de las vistas materializadas
 * 
 */
DROP TABLE IF EXISTS estudiantes_completo;

CREATE TABLE IF NOT EXISTS estudiantes_completo AS
    SELECT DISTINCT ON (d.codigo_rude)
            d.codigo_rude,
            c.cod_ue_id,
            d.paterno,
            d.materno,
            d.nombre,
            d.fecha_nacimiento,
            gt.genero as genero,
            p.carnet,
            p.expedido_id,
            p.es_extranjero as dni,
            pt.paralelo as paralelo,
            (select estadomatricula from estadomatricula_tipo where id=b.estadomatricula_tipo_id) as estado_matricula,
            NULL::text AS estado_proceso,
            lt.lugar as provincia, -- provincia
            d.localidad_nac as localidad, -- localidad
            pt2.pais AS pais
    FROM institucioneducativa_curso a
    INNER JOIN estudiante_inscripcion b ON a.id = b.institucioneducativa_curso_id
    INNER JOIN ues_total c ON a.institucioneducativa_id = c.cod_ue_id
    INNER JOIN estudiante d ON b.estudiante_id = d.id
    INNER JOIN persona p ON p.carnet = d.carnet_identidad
    INNER JOIN genero_tipo gt ON gt.id = d.genero_tipo_id
    INNER JOIN paralelo_tipo pt ON pt.id=a.paralelo_tipo_id
    INNER JOIN lugar_tipo lt ON lt.lugar_nivel_id = 2 and lt.id = d.lugar_prov_nac_tipo_id
    INNER JOIN pais_tipo pt2 ON pt2.id = d.pais_tipo_id
    WHERE a.nivel_tipo_id IN (13);
    --AND b.estadomatricula_tipo_id NOT IN (6,9);
            
-- drop table if exists ues_total;
create table ues_total as
select  a.id as cod_ue_id,a.institucioneducativa as desc_ue,a.orgcurricular_tipo_id,a.estadoinstitucion_tipo_id, h.estadoinstitucion, a.le_juridicciongeografica_id as cod_le_id,a.orgcurricular_tipo_id as cod_org_curr_id,f.orgcurricula
	,a.dependencia_tipo_id as cod_dependencia_id, e.dependencia,a.convenio_tipo_id ,d.cod_dep as id_departamento,d.des_dep as desc_departamento
	,d.cod_pro as id_provincia, d.des_pro as desc_provincia, d.cod_sec as id_seccion, d.des_sec as desc_seccion, d.cod_can as id_canton, d.des_can as desc_canton
	,d.cod_loc as id_localidad,d.des_loc as desc_localidad,d.area2001 as tipo_area,d.cod_dis as cod_distrito,d.des_dis as distrito,d.direccion,d.zona
	,d.cod_nuc,d.des_nuc,0 as usuario_id,current_date as fecha_last_update, a.fecha_creacion,d.cordx,d.cordy, a.nro_resolucion, a.fecha_resolucion
	,a.fecha_cierre,a.fecha_fundacion,a.obs_rue,a.institucioneducativa_tipo_id
from institucioneducativa a 
	join (select a.id as cod_le,cod_dep,des_dep,cod_pro,des_pro,cod_sec,des_sec,cod_can,des_can,cod_loc,des_loc,area2001,cod_dis,des_dis,a.cod_nuc,a.des_nuc,a.direccion,a.zona,a.cordx,cordy 
			from jurisdiccion_geografica a 
			join (select e.id,cod_dep,a.lugar as des_dep,cod_pro,b.lugar as des_pro,cod_sec,c.lugar as des_sec,cod_can,d.lugar as des_can,cod_loc,e.lugar as des_loc,area2001 
					from (select id,codigo as cod_dep,lugar_tipo_id,lugar from lugar_tipo where lugar_nivel_id=1) a 
					join (select id,codigo as cod_pro,lugar_tipo_id,lugar from lugar_tipo where lugar_nivel_id=2) b on a.id=b.lugar_tipo_id 
					join (select id,codigo as cod_sec,lugar_tipo_id,lugar from lugar_tipo where lugar_nivel_id=3) c on b.id=c.lugar_tipo_id 
					join (select id,codigo as cod_can,lugar_tipo_id,lugar from lugar_tipo where lugar_nivel_id=4) d on c.id=d.lugar_tipo_id 
					join (select id,codigo as cod_loc,lugar_tipo_id,lugar,area2001 from lugar_tipo where lugar_nivel_id=5) e on d.id=e.lugar_tipo_id) b on a.lugar_tipo_id_localidad=b.id
		    join (select id,codigo as cod_dis,lugar_tipo_id,lugar as des_dis from lugar_tipo where lugar_nivel_id=7) c on a.lugar_tipo_id_distrito=c.id) d on a.le_juridicciongeografica_id=d.cod_le  and institucioneducativa_acreditacion_tipo_id=1 and estadoinstitucion_tipo_id=10
	join dependencia_tipo e ON a.dependencia_tipo_id = e.id
	join orgcurricular_tipo f ON a.orgcurricular_tipo_id = f.id
	join estadoinstitucion_tipo h ON a.estadoinstitucion_tipo_id = h.id
where a.institucioneducativa_acreditacion_tipo_id = 1;

-- public.vw_datos_estudiantes_6to source
CREATE MATERIALIZED VIEW public.vw_datos_estudiantes_6to
TABLESPACE pg_default
AS SELECT d.codigo_rude,
    c.cod_ue_id,
    EXTRACT(year FROM b.fecha_inscripcion) AS gestion,
    d.paterno,
    d.materno,
    d.nombre,
    d.fecha_nacimiento,
    gt.genero,
    d.carnet_identidad AS carnet,
    d.empareja_sereci,
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
  WHERE a.nivel_tipo_id = 13
  AND a.grado_tipo_id = 6
  AND b.fecha_inscripcion >= '2025-01-01'::date 
  AND b.estadomatricula_tipo_id IN (
    1,   -- INSCRITO NUEVO
    106, -- PROMOCIONADO (CERTIFICACIÓN)
    12,  -- INSCRITO AÑO DE EXTENSIÓN
    18,  -- INSCRITO
    19,  -- EXTEMPORÁNEO EXTRANJERO NUEVO
    2,   -- INSCRITO REPITENTE
    20,  -- EXTEMPORÁNEO EXTRANJERO REPITENTE
    24,  -- APROBADO HOMOLOGACIÓN
    26,  -- PROMOVIDO POST-BACHILLERATO
    27,  -- INSCRITO TALENTO EXTRAORDINARIO
    29,  -- INSCRITO POST-BACHILLERATO
    31,  -- INSCRITO
    34,  -- TRASLADO NUEVO
    45,  -- APROBADO HOMOLOGACIÓN
    5,   -- PROMOVIDO
    55,  -- PROMOVIDO BACHILLER DE EXCELENCIA
    56,  -- PROMOVIDO POR NIVELACIÓN
    57,  -- PROMOVIDO POR REZAGO ESCOLAR
    58,  -- PROMOVIDO TALENTO EXTRAORDINARIO
    60,  -- INSCRITO UES NO ACREDITADAS
    64,  -- INSCRITO POR DOBLE PROMOCIÓN
    65,  -- REINCORPORADO PNP
    66,  -- INSCRITO PNP
    67,  -- INSCRITO NUEVO MODULAR
    68,  -- INSCRITO EXCEPCIONAL
    7,   -- EXTEMPORÁNEO NUEVO
    74,  -- INSCRITO ESPECIAL
    76,  -- APROBADO PERMANENTE
    78,  -- CONCLUIDO
    4,   -- EFECTIVO
    46   -- EFECTIVO
  ) WITH DATA;

-- View indexes:
CREATE UNIQUE INDEX idx_vw_datos_estudiantes_6to ON public.vw_datos_estudiantes_6to USING btree (codigo_rude, cod_ue_id, carnet);
---- 
-- operativo.vw_estudiantes_diploma_documento_6to source
CREATE OR REPLACE VIEW operativo.vw_estudiantes_diploma_documento_6to
AS SELECT v.codigo_rude,
    v.cod_ue_id,
    ue.gestion AS gestion,
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
    t.estado AS estado_tramite
   FROM sie_fdw.vw_datos_estudiantes_6to v
     LEFT JOIN operativo.diploma_documentos f ON v.codigo_rude::text = f.codigo_rude::text AND f.tipo_documento::text = 'FOTOGRAFIA'::text AND f.estado::text = 'ACTIVO'::text
     LEFT JOIN operativo.diploma_documentos d ON v.codigo_rude::text = d.codigo_rude::text AND d.tipo_documento::text = 'DECLARACION_JURADA'::text AND d.estado::text = 'ACTIVO'::text
     LEFT JOIN operativo.diploma_documentos df ON v.codigo_rude::text = df.codigo_rude::text AND df.tipo_documento::text = 'DECLARACION_JURADA_FIRMADA'::text AND df.estado::text = 'ACTIVO'::text
     LEFT JOIN operativo.tramites t ON v.codigo_rude::text = t.codigo_rude::text
     LEFT JOIN sie_fdw.vw_unidades_educativas_usuario_persona_paralelos_6to ue ON v.cod_ue_id = ue.cod_ue_id;


-- Obtienen todos los calegios que tengan alunos en 6to de secundaria
-- con sus respectivos directores encargados
-- mientras la UE este abierta
-- en la gestion actual (2025)
-- Mientras sus estudiantes sean mayores a 0


CREATE OR REPLACE VIEW vw_unidades_educativas_usuario_persona_paralelos_6to AS
SELECT
    c.cod_ue_id,
    c.desc_ue,
    c.direccion,
    c.cod_distrito,
    c.id_departamento::INT,
    CASE c.id_departamento::INT
        WHEN 1 THEN 'CH'
        WHEN 2 THEN 'LP'
        WHEN 3 THEN 'CO'
        WHEN 4 THEN 'OR'
        WHEN 5 THEN 'PT'
        WHEN 6 THEN 'TJ'
        WHEN 7 THEN 'SC'
        WHEN 8 THEN 'BE'
        WHEN 9 THEN 'PA'
        ELSE 'ND'
    END AS departamento_abreviacion,
    CASE c.id_departamento::INT
        WHEN 1 THEN 'Chuquisaca'
        WHEN 2 THEN 'La Paz'
        WHEN 3 THEN 'Cochabamba'
        WHEN 4 THEN 'Oruro'
        WHEN 5 THEN 'Potosí'
        WHEN 6 THEN 'Tarija'
        WHEN 7 THEN 'Santa Cruz'
        WHEN 8 THEN 'Beni'
        WHEN 9 THEN 'Pando'
        ELSE 'Desconocido'
    END AS nombre_departamento,
    u.id AS usuario_id,
    u.persona_id,
    p.correo AS director_correo,
    p.nombre AS director_nombre,
    p.paterno AS director_primer_apellido,
    p.materno AS director_segundo_apellido,
    COUNT(DISTINCT pt.paralelo)::INT AS cantidad_paralelos,
    MAX(mi.gestion_tipo_id) AS gestion,
    COUNT(*) AS total_estudiantes_6to
FROM institucioneducativa_curso a
INNER JOIN estudiante_inscripcion b ON a.id = b.institucioneducativa_curso_id
INNER JOIN estudiante e ON b.estudiante_id  = e.id 
INNER JOIN ues_total c ON a.institucioneducativa_id = c.cod_ue_id
INNER JOIN paralelo_tipo pt ON pt.id = a.paralelo_tipo_id
INNER JOIN maestro_inscripcion mi ON c.cod_ue_id = mi.institucioneducativa_id
INNER JOIN usuario u ON u.persona_id = mi.persona_id
INNER JOIN persona p ON u.persona_id = p.id
WHERE a.gestion_tipo_id = EXTRACT(YEAR FROM CURRENT_DATE)::INT --Solo el año en curso 2025
  AND mi.gestion_tipo_id = EXTRACT(YEAR FROM CURRENT_DATE)::INT --Solo el año en curso 2025
  AND a.nivel_tipo_id IN (13) --SECUNDARIA
  AND b.estadomatricula_tipo_id NOT IN (6,9)
  AND a.grado_tipo_id = 6 --6to
  AND mi.cargo_tipo_id IN (12, 1)  --DIRECTOR/A ENCARGADO/A =>12; DIRECTOR/A => 1
  AND u.esactivo
  AND mi.es_vigente_administrativo
  AND c.estadoinstitucion = 'Abierta'
  --AND cod_ue_id = 80730438
GROUP BY
    c.cod_ue_id,
    c.desc_ue,
    c.direccion,
    c.cod_distrito,
    c.id_departamento,
    u.persona_id,
    u.id,
    p.correo,
    p.nombre,
    p.paterno,
    p.materno
HAVING COUNT(*) > 0
ORDER BY
    c.cod_ue_id;


-- luego importar 
IMPORT FOREIGN SCHEMA public
  LIMIT TO (vw_unidades_educativas_usuario_persona_paralelos_6to)
  FROM SERVER sie_remoto_fdw
  INTO sie_fdw;


IMPORT FOREIGN SCHEMA public
  LIMIT TO (vw_datos_estudiantes_6to)
  FROM SERVER sie_remoto_fdw
  INTO sie_fdw;


-- en nuestra base de datos ejecutar

CREATE FOREIGN TABLE sie_fdw.vw_unidades_educativas_paralelos (
	cod_ue_id int4 NULL,
	desc_ue varchar NULL,
	direccion varchar NULL,
	cod_distrito int4 NULL,
	id_departamento int4 NULL,
	cantidad_paralelos int4 NULL
)
SERVER sie_remoto_fdw
OPTIONS (schema_name 'public', table_name 'vw_unidades_educativas_usuario_persona_paralelos_6to');


-- primerio ejecutar

DROP SERVER IF EXISTS sie_remoto_fdw CASCADE;
DROP SCHEMA IF EXISTS sie_fdw CASCADE;
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


