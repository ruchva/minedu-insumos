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
