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





