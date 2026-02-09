Basado en los flujos de procesos descritos en el documento "Flujo Emision DBD 2025"
"Plan de Pruebas", pero puedo inferir la **secuencia lógica de actividades para una Prueba Piloto (Pilot Run)** alineada con los procedimientos operativos estandarizados descritos.

Para realizar una prueba piloto efectiva, debes simular un ciclo completo de emisión (desde la inscripción hasta la entrega) con un grupo controlado de usuarios. Aquí tienes la secuencia dividida por rol:

### 1. Rol: Administrador del Sistema (Configuración Inicial)
Antes de involucrar a los usuarios finales, el equipo técnico debe preparar el entorno de pruebas ("Sandbox").
*   **Actividad 1: Definición de Plazos.** Configurar en el sistema las fechas ficticias para el "Plazo 1" (Entrega de fotos), "Plazo 2" (Carga de Declaraciones Juradas) y "Plazo 4" (Cierre de notas) para habilitar las funcionalidades escalonadamente.
*   **Actividad 2: Selección de Muestra.** Habilitar un Distrito Educativo o Unidad Educativa específica con datos reales o "dummy" (ficticios) para la prueba.

### 2. Rol: Estudiante (El Solicitante)
El objetivo es probar la interacción del ciudadano con la recolección de datos y la validación de identidad.
*   **Actividad 1: Validación de Datos Preliminares.** Entregar al estudiante piloto el formulario **DBD-IP-001** (Información Previa) impreso por el Director. El estudiante debe revisar su nombre, fecha de nacimiento y grados aprobados.
    *   *Prueba:* Verificar si el estudiante detecta errores simulados.
*   **Actividad 2: Entrega de Fotografía Digital.** El estudiante debe entregar su fotografía digital cumpliendo los requisitos (fondo blanco, 1MB, 250 dpi).
    *   *Prueba:* Verificar que la foto cumpla los estándares técnicos al ser recibida.

### 3. Rol: Director de Unidad Educativa / CEA (El Operador de Campo)
Este es el rol más crítico operativa, ya que gestiona la carga de evidencias.
*   **Actividad 1: Carga de Fotografía.** El Director sube la foto digital del estudiante al sistema.
    *   *Prueba:* Verificar si el sistema rechaza formatos incorrectos o archivos pesados.
*   **Actividad 2: Generación de Declaración Jurada.** Imprimir la **DBD-DJ-002** que ya incluye la foto cargada y los datos del SIE.
*   **Actividad 3: Digitalización y Carga.** Una vez firmada por el estudiante, el Director escanea la DBD-DJ-002 y la carga al sistema como evidencia.
*   **Actividad 4: Reporte de Revisión.** Generar y firmar el reporte **DBD-RV-003**, que consolida la lista de estudiantes revisados.

### 4. Rol: Técnico de la DDE (El Verificador/QA)
Este rol simula la auditoría de calidad de los datos antes de la emisión.
*   **Actividad 1: Revisión de Bandejas.** Acceder al sistema con usuario y contraseña para visualizar la lista de estudiantes por Distrito.
*   **Actividad 2: Control de Calidad.** Verificar visualmente en pantalla que la foto digital coincida con la foto escaneada en la Declaración Jurada (DBD-DJ-002) y que el fondo sea blanco.
*   **Actividad 3: Gestión de Observaciones.** Marcar intencionalmente un trámite como "Observado" para probar el flujo de retorno (devolución) al Director de la UE y verificar si el sistema notifica el error.

### 5. Rol: Sistema / SIE (Procesos Automáticos)
Durante la prueba piloto, se debe monitorear que los "triggers" automáticos funcionen.
*   **Actividad 1: Validación Académica.** Simular el cierre de notas de 6to de Secundaria (o niveles de Alternativa). El sistema debe cambiar automáticamente el estado del estudiante a "Aprobado".
*   **Actividad 2: Paso a Rezagados.** Verificar que, al vencerse el plazo configurado, los estudiantes que no completaron la DJ pasen automáticamente a la bandeja de "Rezagados".

### 6. Rol: Director Departamental de Educación (La Autoridad)
Prueba final de la validez legal y firma digital.
*   **Actividad 1: Firma Digital Masiva.** Conectar el Token (Firma Digital) y ejecutar la firma por lote de los diplomas aprobados.
    *   *Prueba:* Confirmar la integración con **Jacobitus** y la generación exitosa del Hash.
*   **Actividad 2: Autorización.** Generar y firmar el reporte de autorización **DBD-AU-004**.

### 7. Rol: Usuario Final / Público (Prueba de Producto Terminado)
*   **Actividad 1: Lectura de QR.** Escanear el código QR del diploma impreso (o PDF generado) para verificar que redirige a la validación en línea y muestra los datos correctos: Nombre del Director, Distrito, Firma Digital y Nacionalidad.
*   **Actividad 2: Descarga de Certificación.** Utilizar los códigos impresos para intentar descargar una "copia legalizada" digital desde el portal web.

**Nota sobre Contingencias:**
Durante la prueba piloto, es vital ejecutar el flujo de **"Corrección de Errores"** descrito en la fuente, simulando que un estudiante tiene mal su nombre o foto, para asegurar que el sistema permite subsanar (reiniciar el trámite) antes de la impresión final del cartón.


1. Objetivos del Plan
Validar la correcta transición de estados del trámite según los hitos (Plazos 1 al 4).
Asegurar la integridad de los documentos generados 
DBD-IP-001 
DBD-DJ-002 
DBD-RV-003 
DBD-AU-004
Verificar la interoperabilidad con la firma digital (Jacobitus) y el motor de validación QR.

3. Flujo de Control de Calidad
Para una verificación exitosa se debe supervisar el siguiente flujo lógico:

Consistencia Visual: El Técnico de la DDE debe realizar un "split screen" (pantalla dividida) para comparar la foto cargada vs. la foto en el documento escaneado.

Validación Académica: El sistema no debe permitir la emisión si el estado en el SIE no es "Aprobado" tras el cierre de notas de 6to de Secundaria.

Gestión de Errores (Contingencia): Se debe forzar un error en un nombre para validar que el sistema permite el "Reinicio de Trámite" sin duplicar el registro.

4. Criterios de Aceptación para TI
Seguridad: Solo los usuarios con tokens activos pueden realizar firmas masivas.

Performance: El reporte DBD-RV-003 debe generarse en menos de 5 segundos para unidades educativas con más de 100 estudiantes.

Trazabilidad: Cada cambio de estado (de "En Revisión" a "Aprobado") debe quedar registrado con fecha, hora y usuario.
