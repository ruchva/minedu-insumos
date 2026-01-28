objetivo: potenciar la documentacion tecnica del proyecto
segun el siguiente contexto adiciona y organiza la informacion del proyecto
contexto: toda la informacion consolidada esta clasificada por gestión, departamento, provincia, municipio, distrito, area rural o urbana
dependencia fiscal o rural o privada, sexo, subsistema regular o alternativa entre las mas importantes
tenemos la información consolidada de:
diplomas de bachillerato emitidos gratuitamente DBG
bachillerato tecnico humanistico BTH
incentivos a bachilleres descatados IBD
beneficiarios del bono juancito pinto BJP
resultados del programa de alfabetizacion PNP, en este apartado incluimos datos de costos por participante
resultados del programa de post alfabetizacion PNP
resultados de programas como el de comunidades de lectura PNP
información de todas las unidades educativas del pais agregando información como el estado abierta o cerrada, el nivel inicial o primaria o secundaria o las conbinaciones 
disponibles vale decir inicial y primaria o primaria y secundaria etc y finalmente la ubicacion geografica en coordenadas de latitud y longitud
plan de ejecucion: revisa el documento README 
redacta en formato mark down segun la informacion de contexto 
procedimentalmente se obto por graficar en formato de tabla y tabularmente
en formato de barras o de torta 
evolucion de graduados vs la inversion realizada para los PNP
un mapa interactivo con filtros para las unidades educativas con informacion adicional en tooltip con caracteristicas de la unidad educativa
adicionalmente tenemos graficos desacoplados en una miselanea de dashboards, datos como:
resumen anual de diplomas, titulos tecnicos e incentivos por gestion, distribucion por genero en las diferentes categorias
totales por departamento y gestion, ranking de especialidades tecnicas, costos promedio de graduados por departamento y programa para los PNP
covertura del bono juancito pinto
por el momento tenemos esos graficos
procedimentalmente: usando las dependencias que figuran en el README
el origen de datos se encuentra en archivos excel para los cuales se implemento un mecanismo de ingesta de datos
se implemento un backend en supabase para la gestion de usuarios y privilegios
se implementaron vistas sobre la informacion cargada para poblar los dashboards de manera optima
se implemento el mapa con las unidades educativas de bolivia 
el esquema se seguridad que mensiona el README debe mantenerse
debes agregar diagramas de contexto, de secuencia y de componentes en formato mermaid
las instrucciones de despliegue se mantienen
resultado: un nuevo texto potenciado en formato MD listo para reemplazar el contenido del README actual o sea el que te proporcione al principio


Objetivo: sincronizar bases de datos diariamente o en tiempo real si es posible
Contexto: actualmente tengo una base de datos origen que me comparten para cargar datos a mi aplicativo
en esta base origen he implementado vistas y vistas materializadas para obtener solo la informacion que me interesa
mi backend spring boot consume esos datos mediante foreing tables que apuntan a las vistas de la base origen
tengo funciones en la base origen que me permiten refrescar las vistas
CREATE OR REPLACE FUNCTION public.refrescar_vw_distritos()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY vw_distritos;
END;
$function$
;
Plan de ejecución: necesito una forma de refrescar los datos de las vistas
1. ya sea mediante algun script o plugin para postgres
2. ya sea mediante un job programado en el backend
3. debe sicronizarse minimo una vez al dia
Entregable: dame la estrategia que se pueda implementar de manera mas directa y transparente
y que me requiera el menor esfuerzo
---
Objetivo: completar los View faltantes
Plan de ejecucion: 
Frontend: implementar los View segun las vistas recientemente creadas en 06-dashboard_views_extended
y que esten relacionadas con las views faltantes, deben seguir el mismo formato y convensiones de codificacion de los otros Views creados anteriormente 
Entregable: Genera un "Artifact" con con la implementacion antes de editar ningún archivo. 
No me preguntes por cada paso, ejecuta autónomamente y notifícame si encuentras errores bloqueantes.    
---
Objetivo: correccion de errores
Plan de ejecucion: revision y correccion de validaciones en las tablas segun el siguiente detalla
tabla bono_juancito_pinto, los campos cod_pro y secsie se insertan con NULL pero en el excel tienen datos numericoa estandar
tabla alfabetizacion, los campos cod_pro, secsie. part_m, part_f, total_part, grad_m, grad_f, total_grad, fuente_financiamiento se insertan con NULL o 0 pero en el excel tienen datos numericoa estandar, en el campo fuente_financiamiento el excel tiene un campo de texto
tabla post_alfabetizacion, los campos cod_pro, provincia, secsie. part_m, part_f, total_part, grad_m_3ro, grad_f_3ro, total_grad_3ro, grad_m_6to, grad_f_6to, total_grad_6to, fuente_financiamiento se insertan con NULL o 0 pero en el excel tienen datos numericoa estandar, en el campo fuente_financiamiento el excel tiene un campo de texto
tabla comunidades_lectura, tengo el error null value in column "cod_dep" of relation "comunidades_lectura" pero en el axcel ese campo contiene un campop numerico estandar
Entregable: Genera un "Artifact" con con la resolucion antes de editar ningún archivo. 
No me preguntes por cada paso, ejecuta autónomamente y notifícame si encuentras errores bloqueantes.
---
Objetivo: Implementar un componente de mapa interactivo dentro de la vista HistoricoUnidadesView
que visualice las ubicaciones geográficas de aproximadamente 16000 unidades educativas, 
permitiendo
Navegación por scroll/zoom del usuario.
Filtrado dinámico por departamento, provincia y municipio.
Tooltip informativo al pasar el mouse sobre cada unidad educativa.
Optimización de rendimiento para evitar lag o bloqueo de interfaz.
Plan de ejecucion: 
Frontend: React + ViteJS + TailwindCSS + Shadcn/ui
Visualización: Recharts para tooltips o leyendas, mapa principal debe ser Leaflet o MapLibre GL JS (elije el que mejor se adapte).
State & Data Fetching: TanStack Query (React Query)
Validación: Zod
Backend: Supabase vista dashboard_historico_unidades_educativas (gestion actual)
Estructura:           
	      gestion: number
          departamento: string
          cod_dep: number
          cod_pro: number | null
          provincia: string | null
          secsie: string | null
          municipio: string | null
          cod_depn: string | null
          cod_ue: number | null
          unidad_educativa: string | null
          estado_institucion: string | null
          niv_ue: string | null
          oferta_bth: number | null
          latitud: string | null **(Ej. -19,02499961853)
          longitud: string | null **(Ej. -65,258567810059)

COMPONENTE DEL MAPA (MapContainer)
Usar Leaflet.js (con react-leaflet) o MapLibre GL JS (con react-map-gl) 
Incluir control de zoom, drag, y centrado inicial en Bolivia ([-16.2902, -63.5887], zoom 5).
Estilizar con TailwindCSS, contenedor responsive, altura mínima 60vh, bordes suaves, sombra ligera.

CARGA Y OPTIMIZACIÓN DE DATOS (ESTRATEGIA)
Problema: 16000 puntos → renderizar todos a la vez causa lag severo.
Solución: Implementar clustering + viewport-based loading
Estrategia A: Clustering (Recomendado para Leaflet)
Usar react-leaflet-markercluster o leaflet.markercluster.
Agrupar marcadores cercanos en clusters hasta que el usuario haga zoom.
Al hacer zoom profundo (> zoom 14), desagrupar y mostrar marcadores individuales.
Estrategia B: Viewport Filtering (Recomendado para MapLibre)
Solo renderizar marcadores cuyas coordenadas estén dentro del viewport actual.
Usar useEffect + onMoveEnd de MapLibre para detectar cambios de vista y recalcular visibilidad.
Pre-cargar datos en caché global con TanStack Query (ver punto 3).
⚡ Optimización adicional:
Convertir los 16k registros en un GeoJSON FeatureCollection.
Usar zustand o context para almacenar datos filtrados y no recalcular constantemente.

FILTROS DINÁMICOS (Departamento > Provincia > Municipio)
Crear un panel lateral o superior con selects anidados:
Select 1: Departamento (cargado desde datos únicos)
Select 2: Provincia (filtrada por departamento seleccionado)
Select 3: Municipio (filtrada por provincia seleccionada)
Al cambiar cualquier filtro → actualizar el conjunto de marcadores mostrados en el mapa.
Mantener también el filtrado por viewport (si se implementó).
💡 Nota: Si se usa TanStack Query, crear una query key como:
	['unidades', { depto, prov, mun, viewport }]
y usar invalidateQueries cuando cambien los filtros.

TOOLTIP AL PASAR EL MOUSE
Al hacer hover sobre un marcador → mostrar tooltip con información resumida:
Nombre de la unidad educativa
Departamento / Municipio
Nivel educativo
Estado de la institución
Oferta BTH (si aplica)
Usar react-leaflet-tooltip o maplibre-gl popup nativo.
Estilizar con Tailwind: fondo blanco, borde gris, padding, sombra, texto negro, fuente sans-serif.
Mostrar solo 1 tooltip a la vez (evitar saturación visual).
Opcional: agregar ícono pequeño de “info” o “escuela” al lado del nombre.

RENDIMIENTO Y MEJORAS ADICIONALES
Debounce de eventos de zoom/movimiento para evitar recalculos innecesarios.
Virtualización de marcadores si se usa React + MapLibre (solo renderizar los visibles).
Caching con TanStack Query:
staleTime: 1000 * 60 * 5 (5 minutos)
cacheTime: 1000 * 60 * 30 (30 minutos)
refetchOnWindowFocus: false
Fallback UI: Mientras carga, mostrar skeleton o spinner centrado.
Error handling: Mostrar mensaje amigable si falla la carga de datos.
Accesibilidad: Asegurar que el mapa sea navegable con teclado (opcional pero deseable).

FLUJO DE DATOS (TanStack Query)
Al montar el componente → llamar a useQuery para obtener todos los datos (o paginados si es necesario).
Aplicar filtros locales (departamento/provincia/municipio) sobre los datos en memoria.
Enviar evento de moveend o zoomend → calcular bounding box → filtrar por coordenadas visibles.
Actualizar lista de marcadores en el mapa → re-renderizar solo los necesarios.

CASOS DE USO PRIORITARIOS
Caso | Acción | Resultado Esperado
UC1  | Usuario abre el dashboard | Mapa se carga con todos los clusters (sin lag)
UC2  | Usuario filtra por "La Paz" | Marcadores se actualizan, solo muestran unidades de La Paz
UC3  | Usuario hace zoom en El Alto | Se desagrupan clusters y aparecen marcadores individuales
UC4  | Usuario pasa mouse sobre marcador | Tooltip aparece con info completa, sin delay
UC5  | Usuario cambia a "Santa Cruz" | Mapa se actualiza instantáneamente, sin recarga completa

🛠️ ENTREGABLE FINAL
✅ Componente React funcional EducationalMap.tsx con:
	Mapa interactivo (Leaflet o MapLibre)
	Filtros anidados funcionales
	Tooltip dinámico
	Optimización de rendimiento (clustering o viewport filtering)
	Integración con TanStack Query y Zod
✅ Hook personalizado useEducationalUnits.ts para manejo de datos.
✅ Tipos TypeScript validados con Zod.
✅ Documentación breve en comentarios sobre estrategias de optimización usadas.

📌 TOMA EN CUENTA LO SIGUIENTE
Priorizar rendimiento sobre cantidad de detalles iniciales.
No usar forEach o map sobre 16k elementos directamente en el DOM.
Si hay problemas de memoria, considerar usar Web Workers para procesamiento de datos (opcional).
Asegurar compatibilidad móvil (touch events, zoom sensible).
Si se usa MapLibre, incluir token de estilo (puede ser OpenStreetMap gratuito).

No me preguntes por cada paso, ejecuta autónomamente y notifícame si encuentras errores bloqueantes.

---
Objetivo: implementar los dashboards para las nuevas vistas
Plan de ejecucion: actualizar el frontend en /dashboard/charts con los graficos 
para las nuevas vistas credas en dashboard_views_extended
Entregable: Genera un "Artifact" con el plan detallado antes de editar ningún archivo. 
No me preguntes por cada paso, ejecuta autónomamente y notifícame si encuentras errores bloqueantes.

---
Rol: Actúa como un Ingeniero Full-Stack
Objetivo: corregir error en insert campo integer
Plan de ejecucion: implementa una validacion y una cast antes del insert de campos numericos
por ejemplo en la tabla historico_unidades_educativas el campo cod_ue
en el Excel tiene el valor 80480002 pero al realizar el insert sale el mensaje parecido a
se esperaba un integer pero llego un string 
Entregable: Genera un "Artifact" con el plan detallado antes de editar ningún archivo. 
No me preguntes por cada paso, ejecuta autónomamente y notifícame si encuentras errores bloqueantes.

---
Rol: Actúa como un Ingeniero Full-Stack
Objetivo: validar la informacion en la ingesta
Plan de ejecucion: implementa las validaciones para los campos "inversion"
antes de realizar el insert el dato del Excel podria ser: "1247,39849220564"
en estos casos el dato debe ser redondeado a 2 decimales luego de la coma
Entregable: Genera un "Artifact" con el plan detallado antes de editar ningún archivo. 
No me preguntes por cada paso, ejecuta autónomamente y notifícame si encuentras errores bloqueantes.

---
Rol: Actúa como un Ingeniero Full-Stack
Objetivo: validar la informacion en la ingesta
Plan de ejecucion: implementa las validaciones para los campos numericos 
antes de realizar el insert el dato del Excel podria ser: "(en blanco)"
en estos casos el dato debe ser reemplazado por NULL o vacio para evitar errores
Entregable: Genera un "Artifact" con el plan detallado antes de editar ningún archivo. 
No me preguntes por cada paso, ejecuta autónomamente y notifícame si encuentras errores bloqueantes.

---
Rol: actua como analista de datos o cientifico de datos
Objetivo: crear y actualizar vistas para los dashboards
Plan de ejecucion: a partir de las tablas creadas en schema y schema_extended
actualiza los scripts para la creacion de vistas en dashboard_views y dashboard_view_extended
crea nuevas vistas si identificas algun nuevo escenario interesante
Entregable: scripts generados para ser aplicados en la BD
No me preguntes por cada paso, ejecuta autónomamente y notifícame si encuentras errores bloqueantes.

---
Rol: Actúa como un Ingeniero Full-Stack Senior y QA Lead.
Objetivo: extender la implementacion a nuevas tablas, crear nuevas vistas para los dashboards y
reorganizar el frontend para visualizar los nuevos Views.
Plan de Ejecución:
implementa el codigo para realizar la ingesta de datos a las tablas agregadas en 05-schema_extended
actualiza o crea nuevas vistas tomando como base las vistas de 06-dashboard_views_extended
actualiza el codigo necesario para que todo sea funcional
Frontend: debes cambiar la organizacion de las Views en Tabs por una lista de los Views a la derecha 
similar a como se muestran los internal links en una pagina .md
Entregable: Genera un "Artifact" con el plan detallado antes de editar ningún archivo. No me preguntes por cada paso, ejecuta autónomamente y notifícame si encuentras errores bloqueantes.

---
Rol: Actúa como un Ingeniero Full-Stack Senior y QA Lead.

Objetivo: 
Implementar un nuevo endpoint de "Health Check" avanzado y un panel de estado visual en el frontend.
Plan de Ejecución:
Backend: Crea un endpoint /api/health-metrics que devuelva:
Uptime del sistema.
Uso de memoria actual.
Estado de la conexión a la base de datos (haz un ping real).

Frontend: 
Crea un componente SystemStatus.tsx que consuma este endpoint.
Debe mostrar indicadores visuales (Verde/Rojo) para cada métrica.
Debe auto-refrescarse cada 30 segundos.

Verificación:
Crea un test unitario para el endpoint simulando un fallo de DB.
Inicia el servidor localmente.
Usa el Navegador Autónomo para abrir la página, tomar una captura de pantalla del componente renderizado y guardarla como "health_check_proof.png".

Entregable: 
Genera un "Artifact" con el plan detallado antes de editar ningún archivo. No me preguntes por cada paso, ejecuta autónomamente y notifícame si encuentras errores bloqueantes.
