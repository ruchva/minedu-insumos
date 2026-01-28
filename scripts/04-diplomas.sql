-- ## VISTAS DASHBOARDS PARA EL PORTAL DE LOGROS

select * from public.mv_mapa_municipios_resumen;
CREATE MATERIALIZED VIEW public.mv_mapa_municipios_resumen AS
SELECT departamento,
    provincia,
	municipio,    
    cod_dep,
    cod_pro, 
    secsie,
    COUNT(*) as total_ue,
    -- Calculamos el centro aproximado del municipio promediando las coordenadas de sus escuelas
    AVG(latitud::numeric) as centro_lat, 
    AVG(longitud::numeric) as centro_lng
FROM public.dashboard_historico_unidades_educativas -- Usamos la vista de la gestión actual que creamos antes
WHERE latitud IS NOT NULL AND longitud IS NOT NULL
GROUP BY departamento, provincia, municipio, cod_dep, cod_pro, secsie
ORDER BY total_ue DESC;
-- Indice para que el filtro "Top 500" sea instantáneo
CREATE INDEX idx_mv_resumen_total ON public.mv_mapa_municipios_resumen (total_ue DESC);

--drop view public.dashboard_historico_unidades_educativas;
CREATE OR REPLACE VIEW public.dashboard_historico_unidades_educativas AS
SELECT gestion,
	cod_dep,
    departamento,    
    cod_pro,
    provincia,
    secsie,
    municipio,
    cod_depn,
    cod_ue,
    unidad_educativa,
    estado_institucion,
    niv_ue,
    case oferta_bth when 1 then 'SI Ofrece BTH' else 'No Ofrece BTH' end oferta_bth,
    latitud,
    longitud
FROM public.historico_unidades_educativas hue
WHERE hue.gestion = (    
    SELECT MAX(gestion) --ultima gestion cargada
    FROM public.historico_unidades_educativas
)
order by 1 desc, 2
;
-- Vista: Eficiencia de Inversión en Alfabetización
-- Descripción: Calcula el costo promedio por graduado en programas de alfabetización.
-- KPI Crítico para evaluar el retorno de la inversión social.
CREATE OR REPLACE VIEW public.view_eficiencia_alfabetizacion AS
select gestion
    ,cod_dep
	,departamento
    ,'alfabetizacion' as programa
    ,sum(total_part) as total_participantes
    ,SUM(total_grad) as total_graduados
    ,CASE 
        WHEN SUM(total_grad) > 0 THEN ROUND(SUM(inversion) / SUM(total_grad), 2)
        ELSE 0 
    END as costo_por_graduado
    ,SUM(inversion) as total_inversion
from public.alfabetizacion
group by gestion, cod_dep, departamento
union all 
select gestion
    ,cod_dep
	,departamento
    ,'post_alfabetizacion' as programa    
    -- graduados de 3ro y 6to para el total de post-alfa
    ,sum(total_part) as total_participantes
    ,SUM(COALESCE(total_grad_3ro, 0) + COALESCE(total_grad_6to, 0)) as total_graduados
    ,CASE 
        WHEN SUM(COALESCE(total_grad_3ro, 0) + COALESCE(total_grad_6to, 0)) > 0 
        THEN ROUND(SUM(inversion) / SUM(COALESCE(total_grad_3ro, 0) + COALESCE(total_grad_6to, 0)), 2)
        ELSE 0 
    END as costo_por_graduado
    ,SUM(inversion) as total_inversion
from public.post_alfabetizacion
group by gestion, cod_dep, departamento
order by gestion desc, 2, 4, costo_por_graduado desc
;
-- Vista: Cobertura Bono Juancito Pinto
-- Descripción: Muestra la cantidad de estudiantes beneficiados por Nivel y Subsistema.
CREATE OR REPLACE VIEW public.view_bono_juancito_pinto AS
select gestion
	,cod_dep 
    ,departamento
    ,subsistema
    ,nivel
    ,case genero when 'Masculino' then 'Hombres'
				 when 'Femenino' then 'Mujeres' end genero
    ,SUM(estudiantes) as total_beneficiarios
from public.bono_juancito_pinto
group by gestion, cod_dep ,departamento, subsistema, nivel, genero
order by gestion desc, cod_dep, total_beneficiarios desc
;
-- Incentivos al Bachiller Destacado - IBD
CREATE OR REPLACE VIEW public.view_incentivos_bachiller_destacado AS
select ibd.gestion 
	,ibd.cod_dep 
	,ibd.departamento 
	,case ibd.area when 'R' then 'Rural' 
				   when 'U' then 'Urbana' end area
	,ibd.subsistema 
	,case ibd.sexo when '1' then 'Hombres'
				   when '2' then 'Mujeres' end sexo
	,sum(ibd.suma_beneficiados) suma_beneficiados
from public.incentivos_bachiller_destacado ibd
	join public.municipios_estandarizada me on ibd.cod_dep = me.cod_dep and ibd.provincia = me.provincia and ibd.secsie::int = me.secsie
group by ibd.gestion ,ibd.cod_dep ,ibd.departamento ,ibd.area ,ibd.subsistema ,ibd.sexo 
order by 1,2
;
select * from public.view_incentivos_bachiller_destacado;
-- Bachiller Técnico Humanístico - BTH
CREATE OR REPLACE VIEW public.view_bachilleres_tecnico_humanistico AS
select bth.gestion 
	,bth.cod_dep 
	,bth.departamento
	,case bth.area when 'R' then 'Rural' 
				   when 'U' then 'Urbana' end area
	,bth.especialidad 
	,case bth.sexo when '1-Hombre' then 'Hombres'
				   when '2-Mujer' then 'Mujeres' end sexo
	,sum(bth.suma_titulados) suma_titulados 
from public.bachilleres_tecnico_humanistico bth 
	join public.municipios_estandarizada me on bth.cod_dep = me.cod_dep and bth.provincia = me.provincia and bth.secsie::int = me.secsie 
group by bth.gestion ,bth.cod_dep ,bth.departamento ,bth.area ,bth.especialidad ,bth.sexo 
order by 1,2
;
select * from public.view_bachilleres_tecnico_humanistico;
-- Diplomas de Bachiller Gratuitos - DBG
CREATE OR REPLACE VIEW public.view_diplomas_bachiller AS
select db.gestion 
	,db.cod_dep 
	,db.departamento 
	,case db.area when 'R' then 'Rural' 
				  when 'U' then 'Urbana' end area
	,case db.dependencia when 1 then 'Fiscal' 
						 when 2 then 'Convenio' 
						 when 3 then 'Privada' end dependencia
	,db.subsistema 
	,case db.sexo when '1-Hombre' then 'Hombres'
				  when '2-Mujer' then 'Mujeres' end sexo
	,sum(db.suma_diplomas) suma_diplomas
from public.diplomas_bachiller db 
	join public.municipios_estandarizada me on db.cod_dep = me.cod_dep and db.provincia = me.provincia and db.secsie::int = me.secsie
group by db.gestion ,db.cod_dep ,db.departamento ,db.area ,db.dependencia ,db.subsistema ,db.sexo
order by 1,2,4
;
select * from public.view_diplomas_bachiller;
--
select * from public.diplomas_bachiller db
order by 2,3
;
select db.municipio , db.provincia ,db.cod_pro , me.cod_pro ,me.provincia ,me.municipio 
from public.diplomas_bachiller db 
	join public.municipios_estandarizada me on db.cod_dep = me.cod_dep and db.provincia = me.provincia and db.secsie::int = me.secsie 
where 1=1
order by 6
;
-- 
create table public.municipios_estandarizada (
  cod_dep integer not null,
  departamento text not null,
  cod_pro integer,
  provincia text,
  secsie integer,
  municipio text,
  created_at timestamp with time zone default timezone('utc'::text, now()),
  updated_at timestamp with time zone default timezone('utc'::text, now()),
  constraint pk_municipios_estandarizada primary key (cod_dep, cod_pro, secsie)
)
;
CREATE OR REPLACE VIEW public.filter_departamentos AS
select distinct me.cod_dep, me.departamento
from municipios_estandarizada me
order by 1
;
select * from public.filter_departamentos
;
CREATE OR REPLACE FUNCTION public.filter_provincias(depto int)
 RETURNS table (
 	cod_pro int,
 	provincia text
 )
 LANGUAGE plpgsql
AS $$
BEGIN
  	return query
	select distinct me.cod_pro, me.provincia
	from municipios_estandarizada me
	where me.cod_dep = depto
	order by 1;
END;
$$
;
--DROP FUNCTION filter_provincias(integer);
select * from public.filter_provincias(9)
;
CREATE OR REPLACE FUNCTION public.filter_municipios(prov int)
 RETURNS table (
 	secsie int,
 	municipio text
 )
 LANGUAGE plpgsql
AS $$
BEGIN
  	return query
	select distinct me.secsie, me.municipio 
	from municipios_estandarizada me
	where me.cod_pro = prov
	order by 1;
END;
$$
;
select * from public.filter_municipios(901)
;



