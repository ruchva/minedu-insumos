-- VISTA public.vw_estudiantes_historial_academico_alt PARA ALTERNATIVA

SELECT c.codigo_rude,
    f.des_dis AS distrito_educativo,
    d.institucioneducativa AS unidad_educativa,
    d.id AS codigo_sie,
    ( SELECT grado_tipo.grado
           FROM grado_tipo
          WHERE grado_tipo.id = a.grado_tipo_id) AS escolaridad,
    ( SELECT estadomatricula_tipo.estadomatricula
           FROM estadomatricula_tipo
          WHERE estadomatricula_tipo.id = b.estadomatricula_tipo_id) AS estadomatricula,
    a.gestion_tipo_id AS gestion,
    b.id AS id_inscripcion
   FROM institucioneducativa_curso a
     JOIN estudiante_inscripcion b ON a.id = b.institucioneducativa_curso_id
     JOIN estudiante c ON b.estudiante_id = c.id
     JOIN institucioneducativa d ON a.institucioneducativa_id = d.id
     JOIN jurisdiccion_geografica e ON d.le_juridicciongeografica_id = e.id
     JOIN ( SELECT lugar_tipo.id,
            lugar_tipo.codigo AS cod_dis,
            lugar_tipo.lugar_tipo_id,
            lugar_tipo.lugar AS des_dis
           FROM lugar_tipo
          WHERE lugar_tipo.lugar_nivel_id = 7) f ON e.lugar_tipo_id_distrito = f.id
  WHERE a.nivel_tipo_id = 15 AND a.grado_tipo_id = 99
;
-- View indexes:
-- CREATE UNIQUE INDEX idx_vw_estudiantes_historial_academico_alt ON public.vw_estudiantes_historial_academico_alt USING btree (codigo_rude, codigo_sie, escolaridad, estadomatricula, gestion, id_inscripcion);
--drop INDEX idx_vw_estudiantes_historial_academico_alt;

-- VISTA vw_datos_estudiantes PARA ALTERNATIVA
SELECT d.codigo_rude,
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
        CASE
            WHEN (( SELECT dt.activo
               FROM diplomas.diploma_test dt
              WHERE dt.id = 1)) = true AND c.cod_ue_id >= 81230000 AND c.cod_ue_id <= 81230999 AND ("right"(d.codigo_rude::text, 2)::integer % 2) = 0 THEN 'PROMOVIDO'::character varying
            WHEN (( SELECT dt.activo
               FROM diplomas.diploma_test dt
              WHERE dt.id = 1)) = true THEN 'REPROBADO'::character varying
            WHEN emt.estadomatricula IS NULL THEN 'REPROBADO'::character varying
            WHEN emt.fin_proceso_educativo = true AND emt.estadomatricula::text ~~* 'PROMOVIDO%'::text THEN 'PROMOVIDO'::character varying
            WHEN emt.fin_proceso_educativo = true AND emt.estadomatricula::text ~~* 'REPROBADO%'::text THEN 'REPROBADO'::character varying
            ELSE emt.estadomatricula
        END AS estado_matricula,
    NULL::text AS estado_proceso,
    lt.lugar AS provincia,
    d.localidad_nac AS localidad,
    pt2.pais,
    lt3.lugar AS nombre_departamento,
    c.id_departamento::integer AS codigo_departamento,
    lt2.lugar AS nombre_distrito,
    lt2.codigo::integer AS codigo_distrito, e.*    
FROM institucioneducativa_curso a
     JOIN estudiante_inscripcion b ON a.id = b.institucioneducativa_curso_id
     JOIN ues_total c ON a.institucioneducativa_id = c.cod_ue_id
     JOIN estudiante d ON b.estudiante_id = d.id
     JOIN genero_tipo gt ON gt.id = d.genero_tipo_id
     JOIN paralelo_tipo pt ON pt.id::text = a.paralelo_tipo_id::text
     JOIN lugar_tipo lt ON lt.lugar_nivel_id = 2 AND lt.id = d.lugar_prov_nac_tipo_id
     JOIN institucioneducativa d1 ON a.institucioneducativa_id = d1.id
     JOIN jurisdiccion_geografica e ON d1.le_juridicciongeografica_id = e.id
     JOIN (SELECT lugar_tipo.id,
            lugar_tipo.codigo,
            lugar_tipo.lugar
           FROM lugar_tipo
           WHERE lugar_tipo.lugar_nivel_id = 7) lt2 ON lt2.id = e.lugar_tipo_id_distrito
     JOIN (SELECT lugar_tipo.codigo,
            lugar_tipo.lugar
           FROM lugar_tipo
           WHERE lugar_tipo.lugar_nivel_id = 8) lt3 ON lt3.codigo::integer::text = c.id_departamento::text
     JOIN pais_tipo pt2 ON pt2.id = d.pais_tipo_id
     JOIN estadomatricula_tipo emt ON emt.id = b.estadomatricula_tipo_id
WHERE a.nivel_tipo_id = 15 -- Educación de Personas Jovenes y Adultas
	AND a.grado_tipo_id = 99 -- SIN GRADO - COMO SE EL GRADO CORRESPONDIENTE PARA EMITIRLE DIPLOMA? 
	AND b.fecha_inscripcion >= '2025-01-01'::date 
	--and c.cod_ue_id =51230008 -- 14 DE OCTUBRE LEQUEPALCA 136
	--and d.codigo_rude ='100000000003029170'
	AND (b.estadomatricula_tipo_id = ANY (ARRAY[1, 106, 12, 18, 19, 2, 20, 24, 26, 27, 29, 31, 34, 45, 5, 55, 56, 57, 58, 60, 64, 65, 66, 67, 68, 7, 74, 76, 78, 4, 46]))
;


-- VISTA vw_unidades_educativas_usuario_persona_paralelos PARA ALTERNATIVA 
SELECT c.cod_ue_id,
    c.desc_ue,
    c.direccion,
    c.cod_distrito::integer AS cod_distrito,
    c.id_departamento::integer AS id_departamento,
        CASE c.id_departamento::integer
            WHEN 1 THEN 'CH'::text
            WHEN 2 THEN 'LP'::text
            WHEN 3 THEN 'CO'::text
            WHEN 4 THEN 'OR'::text
            WHEN 5 THEN 'PT'::text
            WHEN 6 THEN 'TJ'::text
            WHEN 7 THEN 'SC'::text
            WHEN 8 THEN 'BE'::text
            WHEN 9 THEN 'PA'::text
            ELSE 'ND'::text
        END AS departamento_abreviacion,
        CASE c.id_departamento::integer
            WHEN 1 THEN 'Chuquisaca'::text
            WHEN 2 THEN 'La Paz'::text
            WHEN 3 THEN 'Cochabamba'::text
            WHEN 4 THEN 'Oruro'::text
            WHEN 5 THEN 'Potosí'::text
            WHEN 6 THEN 'Tarija'::text
            WHEN 7 THEN 'Santa Cruz'::text
            WHEN 8 THEN 'Beni'::text
            WHEN 9 THEN 'Pando'::text
            ELSE 'Desconocido'::text
        END AS nombre_departamento,
    u.id AS usuario_id,
    u.persona_id,
    p.correo AS director_correo,
    p.nombre AS director_nombre,
    p.paterno AS director_primer_apellido,
    p.materno AS director_segundo_apellido,
    count(DISTINCT pt.paralelo)::integer AS cantidad_paralelos,
    max(mi.gestion_tipo_id) AS gestion,
    count(*) AS total_estudiantes
 FROM institucioneducativa_curso a
     JOIN estudiante_inscripcion b ON a.id = b.institucioneducativa_curso_id
     JOIN estudiante e ON b.estudiante_id = e.id
     JOIN ues_total c ON a.institucioneducativa_id = c.cod_ue_id
     JOIN paralelo_tipo pt ON pt.id::text = a.paralelo_tipo_id::text
     JOIN maestro_inscripcion mi ON c.cod_ue_id = mi.institucioneducativa_id
     JOIN usuario u ON u.persona_id = mi.persona_id
     JOIN persona p ON u.persona_id = p.id
WHERE 1=1
    and a.gestion_tipo_id = (EXTRACT(year FROM CURRENT_DATE)::integer - 1) -- 2025 - PARA PRUEBAS
	AND mi.gestion_tipo_id = (EXTRACT(year FROM CURRENT_DATE)::integer - 1) -- 2025 = PARA PRUEBAS
	AND a.nivel_tipo_id = 15 -- Educación de Personas Jovenes y Adultas
	and c.id_departamento::integer =4 -- ORURO - PARA PRUEBAS
	AND (b.estadomatricula_tipo_id <> ALL (ARRAY[6,9])) -- 6 NO INCORPORADO - 9 RETIRADO TRASLADO
	AND a.grado_tipo_id = 99 -- SIN GRADO - COMO SE EL GRADO CORRESPONDIENTE PARA EMITIRLE DIPLOMA?
	AND (mi.cargo_tipo_id = ANY (ARRAY[12,1])) -- 1 DIRECTOR/A - 12 DIRECTOR/A ENCARGADO/A 
	AND u.esactivo 
	AND mi.es_vigente_administrativo 
	AND c.estadoinstitucion::text = 'Abierta'::text
GROUP BY c.cod_ue_id, c.desc_ue, c.direccion, c.cod_distrito, c.id_departamento, u.persona_id, u.id, p.correo, p.nombre, p.paterno, p.materno
HAVING count(*) > 0
ORDER BY c.cod_ue_id;
--
--DIRECTORES ALTERNATIVA ORURO
select * from usuario u where u.id in (13814466,92516876,92522876,13849352);
--3074543 3109189 2732688 3104294

WITH RECURSIVE listado AS (
         SELECT lugar_tipo.id,
            lugar_tipo.lugar_tipo_id,
            lugar_tipo.lugar_nivel_id,
            lugar_tipo.id::character varying(1000) AS lugares
         FROM lugar_tipo
         WHERE lugar_tipo.lugar_tipo_id IS NULL
         
         UNION ALL
         
         SELECT si.id,
            si.lugar_tipo_id,
            si.lugar_nivel_id,
            (((sp.lugares::text || ','::text) || si.id))::character varying(1000) AS lugares
         FROM lugar_tipo si 
         JOIN listado sp ON si.lugar_tipo_id = sp.id
        )
SELECT ie.id,
    ie.institucioneducativa,
    ie.le_juridicciongeografica_id,
    li.id AS lugar_tipo_id_distrito,
    li.lugar_nivel_id,
    ie.institucioneducativa_tipo_id,
    li.lugares
FROM listado li,
    jurisdiccion_geografica jg,
    institucioneducativa ie
WHERE li.id = jg.lugar_tipo_id_distrito 
AND jg.id = ie.le_juridicciongeografica_id 
--AND (li.lugar_nivel_id = ANY (ARRAY[0,1,7]))
and (ie.institucioneducativa_tipo_id = any (array[0,1,7]))--regular version ru
--and (ie.institucioneducativa_tipo_id = any (array[0,2]))--regular version ru
;


drop materialized view public.vw_distritos;
commit;
CREATE MATERIALIZED VIEW public.vw_distritos
TABLESPACE pg_default
AS SELECT DISTINCT ut.cod_distrito::integer AS id_distrito,
    	ut.distrito AS nombre_distrito,
    	ut.id_departamento::integer AS id_departamento
	FROM institucioneducativa_curso ic
	    JOIN estudiante_inscripcion ei ON ic.id = ei.institucioneducativa_curso_id
	    JOIN ues_total ut ON ic.institucioneducativa_id = ut.cod_ue_id
	WHERE (ic.nivel_tipo_id = ANY (ARRAY[11, 12, 13])) 
	  	AND (ei.estadomatricula_tipo_id <> ALL (ARRAY[6, 9])) 
	  	AND ic.gestion_tipo_id::numeric = EXTRACT(year FROM now()) -1--(2025)
	ORDER BY (ut.cod_distrito::integer)
WITH DATA;
--
CREATE UNIQUE INDEX idx_vw_distritos ON public.vw_distritos USING btree (id_distrito, nombre_distrito, id_departamento);

select * from public.ues_total ut where ut.cod_ue_id =81230329;

--## REFRESH ESTUDENTS
SELECT public.refrescar_vw_datos_estudiantes_6to();

select * from usuario u where u.username ='4057503';

-- colegios
	SELECT DISTINCT
        c.cod_ue_id,
        c.desc_ue,
        c.direccion,
        c.cod_distrito,
        'CONTACTO' AS contacto,
        'TELEFONO' AS telefono,
        c.cod_ue_id
    FROM institucioneducativa_curso a
    INNER JOIN estudiante_inscripcion b
        ON a.id = b.institucioneducativa_curso_id
    INNER JOIN ues_total c
        ON a.institucioneducativa_id = c.cod_ue_id
    WHERE a.gestion_tipo_id = 2025
      AND a.nivel_tipo_id IN (11,12,13)
      AND b.estadomatricula_tipo_id NOT IN (6,9);

-- paralelos
        SELECT 
            c.cod_ue_id AS id_unidad_educativa,
    		COUNT(DISTINCT pt.paralelo)::INT AS cantidad_paralelos
        FROM institucioneducativa_curso a
        INNER JOIN ues_total c ON a.institucioneducativa_id = c.cod_ue_id
        INNER JOIN paralelo_tipo pt ON pt.id = a.paralelo_tipo_id
        --WHERE a.nivel_tipo_id IN (13)
        GROUP BY c.cod_ue_id;

-- personas
SELECT
    usuario.id AS usuario_id,
    usuario.username,
    persona.id AS persona_id,
    persona.nombre,
    persona.paterno,
    persona.materno,
    persona.cedula_tipo_id,
    persona.carnet,
    persona.fecha_nacimiento,
    persona.celular,
    CASE persona.genero_tipo_id
        WHEN 1 THEN 'M'
        WHEN 2 THEN 'F'
        ELSE 'O'
    END AS genero,
    CASE
        WHEN lugar_tipo.lugar_nivel_id NOT IN (1,2,3,4,5,7) THEN lugar_tipo.codigo
        ELSE NULL
    END AS id_departamento,
    CASE
        WHEN lugar_tipo.lugar_nivel_id IN (7) THEN lugar_tipo.codigo
        ELSE NULL
    END AS id_distrito
FROM usuario
JOIN usuario_rol ON usuario_rol.usuario_id = usuario.id
JOIN rol_tipo ON usuario_rol.rol_tipo_id = rol_tipo.id
JOIN persona ON usuario.persona_id = persona.id
JOIN lugar_tipo ON lugar_tipo.id = usuario_rol.lugar_tipo_id
WHERE usuario.esactivo
  AND persona.activo
  AND rol_tipo.diminutivo IN ('DDEP', 'DIR', 'TECSDE', 'TECSDI');

-- personas -> unindades educativas
    SELECT
        ut.cod_ue_id as id_unidad_educativa,
        u.id AS id_usuario,
        u.persona_id AS id_persona,
        mi.gestion_tipo_id AS gestion
    FROM maestro_inscripcion mi
    INNER JOIN usuario u ON u.persona_id = mi.persona_id
    INNER JOIN ues_total ut ON ut.cod_ue_id = mi.institucioneducativa_id
    WHERE
        mi.cargo_tipo_id IN (12, 1) --DIRECTOR/A ENCARGADO/A =>12; DIRECTOR/A => 1
        AND u.esactivo
        AND mi.es_vigente_administrativo
        AND ut.estadoinstitucion = 'Abierta'
        AND mi.gestion_tipo_id  >= 2022
    ORDER BY
        mi.gestion_tipo_id DESC, mi.persona_id;

-- roles
	SELECT
        rt.id,
        rt.diminutivo   AS rol,
        rt.rol          AS nombre,
        rt.sub_sistema  AS descripcion
    FROM rol_tipo rt
    WHERE rt.diminutivo IN ('TECSDE', 'RESLEG', 'DIR', 'DDEP', 'ADMINISTRADOR', 'TECSDI');

-- usuarios
	SELECT
        u.id,
        u.username,
        p.nombre,
        p.paterno,
        p.materno,
        p.cedula_tipo_id,
        p.carnet,
        p.fecha_nacimiento,
        p.celular,
        CASE p.genero_tipo_id
            WHEN 1 THEN 'M'
            WHEN 2 THEN 'F'
            ELSE 'O'
        END AS genero,
        u.password,
        u.persona_id
    FROM usuario u
    JOIN usuario_rol ur ON ur.usuario_id = u.id
    JOIN rol_tipo rt    ON ur.rol_tipo_id = rt.id
    JOIN persona p      ON u.persona_id  = p.id
    WHERE u.esactivo
      AND p.activo
      AND TRIM(rt.diminutivo) IN ('DDEP', 'DIR', 'TECSDE', 'TECSDI')
          AND u.id > 0;  -- Existe un id con id = 0

-- usuarios -> roles
	SELECT
        ur.rol_tipo_id AS id_rol,
        u.id           AS id_usuario
    FROM usuario u
    JOIN usuario_rol ur ON ur.usuario_id = u.id
    JOIN rol_tipo rt    ON ur.rol_tipo_id = rt.id
    JOIN persona p      ON u.persona_id  = p.id
    WHERE u.esactivo
      AND p.activo
      AND TRIM(rt.diminutivo) IN ('DDEP', 'DIR', 'TECSDE', 'TECSDI');

-- historial academico
    SELECT
    c.codigo_rude,
    f.des_dis AS distrito_educativo,
    d.institucioneducativa AS unidad_educativa,
    d.id AS codigo_sie,
        (SELECT grado FROM grado_tipo WHERE id = a.grado_tipo_id) AS escolaridad,
        (SELECT estadomatricula FROM estadomatricula_tipo WHERE id = b.estadomatricula_tipo_id) AS estadomatricula,
        a.gestion_tipo_id::int AS gestion
    FROM institucioneducativa_curso a
        INNER JOIN estudiante_inscripcion b ON a.id = b.institucioneducativa_curso_id
        INNER JOIN estudiante c ON b.estudiante_id = c.id
        INNER JOIN institucioneducativa d ON a.institucioneducativa_id = d.id
        INNER JOIN jurisdiccion_geografica e ON d.le_juridicciongeografica_id = e.id
        INNER JOIN (select id, codigo as cod_dis,lugar_tipo_id,lugar as des_dis from lugar_tipo where lugar_nivel_id=7) f ON e.lugar_tipo_id_distrito = f.id
    WHERE
        a.nivel_tipo_id IN (13) --secundaria comunitaria
        AND a.grado_tipo_id IN(1, 2, 3, 4, 5, 6) --ultimos años de colegio
        AND d.id = 81981560;





