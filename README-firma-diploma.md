# Implementacion de la firma digital

## 1. Introducción

Este servicio ofrece:

- Firma digital **síncrona** de documentos PDF alojados en bucket S3
- Firma de archivos remotos descargados desde el Storage
- Firma **masiva en lote**
- Descarga automática del softoken desde el bucket tokens por usuario
---

## 2. Requisitos Técnicos

### Software

| Componente | Mínimo | Recomendado |
|------------|--------|-------------|
| Java | 17 | 21 |
| Maven | 3.9.x | 3.9.10+ |
| Spring Boot | 3.5.x | 3.5.3 |
| Redis | 7.0+ | 7.2+ (opcional) |
| MinIO/S3 | Compatible S3 | MinIO latest |
| Docker | 24.0+ | 24.0+ |
| OS | Ubuntu 24.04+, Debian 13 | Ubuntu 24.04+, Debian 13 |

### Frameworks y dependencias principales

- **Spring Boot 3.5.3** (Web, Validation, Security, Data Redis, Actuator)
- **AWS SDK v2** (S3 AsyncClient, S3 Transfer Manager) 2.38.3
- **Jacobitus Libreria** 1.2.1 (Firma digital PKCS#11/PKCS#12)
- **SpringDoc OpenAPI** 2.8.14 (Documentación Swagger)
- **Lombok**
- **OpenTelemetry Java Agent**

---

## 3. Vista Lógica

### Estructura de paquetes

```
src/main/java/com/minedu/planificacion/firma/
├── FirmaJavaApplication.java       # Punto de entrada Spring Boot
├── application/                    # Casos de uso y DTOs
│   ├── dto/                        # Request/Response DTOs
│   │   ├── SolicitudFirmaRequest.java
│   │   ├── SolicitudFirmaUrlRequest.java
│   │   ├── FirmaLoteRequest.java
│   │   ├── DiplomaLoteRequest.java
│   │   └── ResultadoFirmaDto.java
│   └── services/                   # Interfaces de servicios
│       ├── FirmaService.java
│       └── impl/
│           └── FirmaServiceImpl.java
├── domain/                         # Modelos de dominio y puertos
│   ├── models/
│   │   ├── CertificadoActivo.java
│   │   ├── FirmaPayload.java
│   │   └── ResponseModel.java
│   └── ports/                      # Interfaces de adaptadores
│       ├── SignerPort.java
│       ├── StoragePort.java
│       └── JobQueuePort.java
├── infrastructure/                 # Adaptadores externos
│   ├── config/                     # Configuración Spring
│   │   ├── AppConfig.java
│   │   ├── AsyncConfig.java
│   │   ├── FirmaExecutorConfig.java
│   │   ├── OpenApiConfig.java
│   │   └── WebConfig.java
│   ├── jacobitus/
│   │   └── JacobitusSignerAdapter.java  # Integración con librería Jacobitus
│   ├── storage/
│   │   └── S3StorageService.java        # Cliente S3 async
│   ├── queue/
│   │   └── ImmediateJobQueue.java       # Queue stub (puede integrarse con Redis)
│   └── security/
│       └── filter/                      # Filtros de autenticación
└── presentation/                   # Controladores REST
    ├── controllers/
    │   ├── FirmaController.java         # Endpoints /firmar, /firmar-url
    │   ├── FirmaLoteController.java     # Endpoint /firmar-lote
    │   └── HealthController.java
    └── advice/
        └── GlobalExceptionHandler.java
```

### Diagrama de componentes

```mermaid
classDiagram
    class FirmaController {
        +firmar(SolicitudFirmaRequest) ResponseEntity
        +firmarUrl(SolicitudFirmaUrlRequest) ResponseEntity
    }
    class FirmaLoteController {
        +firmarLote(FirmaLoteRequest) ResponseEntity
    }
    class FirmaService {
        +firmarSync(request) ResultadoFirmaDto
        +firmarDesdeUrl(request) ResultadoFirmaDto
        +firmarLoteAsync(request) void
        +downloadSoftkey(username) boolean
    }
    class SoftokenService {
        +resolverCertificado(username, pin) CertificadoActivo
        +descargarSoftoken(username) File
    }
    class JacobitusSignerAdapter {
        +firmar(payload, cert) byte[]
    }
    class S3StorageService {
        +download(bucket, key) File
        +upload(bucket, key, data) void
        +presign(bucket, key, hours) String
    }
    class ImmediateJobQueue {
        +enqueue(type, payload) String
    }
    class ThreadPoolTaskExecutor {
        +submit(task)
    }

    FirmaController --> FirmaService
    FirmaLoteController --> FirmaService
    FirmaService --> SoftokenService
    FirmaService --> JacobitusSignerAdapter
    FirmaService --> S3StorageService
    FirmaService --> ImmediateJobQueue
    FirmaService --> ThreadPoolTaskExecutor
    JacobitusSignerAdapter --> S3StorageService
```

### Modelo de arquitectura

```mermaid
graph TB
    subgraph Presentación
        A1[REST Controllers]
        A2[Swagger UI /swagger-ui/]
        A3[Spring Security Filters]
    end
    subgraph Aplicación
        S1[FirmaService]
        S2[SoftokenService]
    end
    subgraph Dominio
        D1[Puertos: SignerPort]
        D2[Puertos: StoragePort]
        D3[Puertos: JobQueuePort]
    end
    subgraph Infraestructura
        I1[JacobitusSignerAdapter]
        I2[S3StorageService]
        I3[ImmediateJobQueue]
        I4[ThreadPool Executor]
    end
    subgraph Externos
        E1[MinIO/S3]
        E2[Jacobitus Libreria]
        E3[Redis opcional]
        E4[Backend Core API]
        E5[OpenTelemetry Collector]
    end

    A1 --> S1
    A1 --> S2
    S1 --> D1
    S1 --> D2
    S1 --> D3
    D1 --> I1
    D2 --> I2
    D3 --> I3
    S1 --> I4
    I1 --> E2
    I2 --> E1
    I3 --> E3
    I4 -->|Firma asíncrona| S1
    S1 -->|Callback opcional| E4
    A1 -->|Trazas| E5
```

---

## 4. Diagramas de Secuencia y Algoritmos

### Proceso de firma en lote asíncrono

```mermaid
sequenceDiagram
    participant Cliente
    participant API as REST /api/v1/firmar-lote
    participant Service as FirmaService
    participant Executor as ThreadPoolExecutor
    participant Worker as Async Task
    participant Storage as S3StorageService
    participant Backend as Core API

    Cliente->>API: POST /firmar-lote + FirmaLoteRequest
    API->>Service: firmarLoteAsync(request)
    Service->>Service: downloadSoftkey(username)
    Service-->>API: 200 {jobId, status:accepted, total}
    API-->>Cliente: Respuesta inmediata
    
    Service->>Executor: submit N tareas paralelas
    loop Para cada diploma
        Executor->>Worker: procesarDiploma()
        Worker->>Storage: download(pdf)
        Worker->>Worker: firmar con Jacobitus
        Worker->>Storage: upload(firmado)
        Worker->>Backend: POST callback con resultado
        Backend-->>Worker: 200 OK
    end
```

### Proceso de firma con Jacobitus

```mermaid
sequenceDiagram
    participant Service
    participant Signer as JacobitusSignerAdapter
    participant Jacobitus as Jacobitus Libreria
    participant Token as Softoken/Hardware

    Service->>Signer: firmar(payload, cert)
    alt PKCS#12
        Signer->>Signer: cargar archivo.p12
        Signer->>Jacobitus: configurar TokenPKCS12
    else PKCS#11
        Signer->>Jacobitus: configurar Slot con provider
    end
    
    Signer->>Jacobitus: FirmadorPdf.firmar(pdf, opciones)
    Jacobitus->>Token: solicitar firma con PIN
    Token-->>Jacobitus: firma criptográfica
    Jacobitus-->>Signer: PDF firmado
    Signer->>Signer: limpiar archivo temporal
    Signer-->>Service: byte[] firmado
```

---

## 5. Vista de Despliegue

### 5.1 Diagrama de Infraestructura Física

```mermaid
flowchart TB
    subgraph .
        subgraph APP_SERVER["Servicio de Aplicacion"]
            subgraph CONTS["Contenedores en ejecución"]
                WRAPPER[firma-digital-wrapper-java<br/>Puerto: 7171<br/>Java 21 + OpenTelemetry]
                MINIO[S3<br/>Puerto: 9000<br/>Buckets: diplomas, tokens]
                REDIS[Redis<br/>Puerto: 6379<br/>Colas internas]
            end
        end

        subgraph BACK_SERVER["Servicio Backend :3000"]
            BACKEND[Backend Core API<br/>Recepción de callbacks de firma]
        end

        subgraph SIG_NOZ["SigNoz"]
            OTEL[OpenTelemetry Collector<br/>Puerto: 4317<br/>Protocolo gRPC OTLP]
        end

    end

    WRAPPER -->|Download / Upload PDFs| MINIO
    WRAPPER -->|Publicación de jobs<br/>en cola interna| REDIS
    WRAPPER -->|POST callbacks<br/>resultado de firma| BACKEND
    WRAPPER -->|Traces / Métricas / Logs| OTEL

```

### 5.2 Pipeline CI/CD GitLab

```mermaid
flowchart TD
    Dev[Commit] -->|push| GitLabCI[GitLab CI/CD]

    subgraph Pipeline
        GitLabCI --> Build[Stage: Build<br/>Maven compila JAR<br/>Java 21]
        Build --> DockerBuild[Stage: Docker-Build<br/>Docker build + push<br/>Instala jacobitus-libreria]
        DockerBuild --> Deploy[Stage: Deploy<br/>SSH al servidor remoto<br/>Docker compose up]
    end

    Deploy --> Server[Servidor destino]
    Server --> Container[Contenedor app<br/>Puerto 7171<br/>+ OpenTelemetry agent]
    Container --> MinIO[MinIO S3]
    Container --> Redis[Redis opcional]
    Container --> OTEL[OpenTelemetry Collector]
```

### Diagrama de contenedores

```mermaid
graph TB
    subgraph Docker Host
        APP[firma-digital-wrapper-java<br/>Puerto 7171<br/>Java 21 Runtime]
        OTEL_AGENT[OpenTelemetry Agent<br/>Instrumentación automática]
    end
    
    subgraph Servicios Externos
        MINIO[MinIO S3<br/>Puerto 9000<br/>Bucket: diplomas, tokens]
        REDIS[Redis<br/>Puerto 6379<br/>Queue opcional]
        BACKEND[Backend Core API<br/>Callbacks]
        OTEL_COL[OpenTelemetry Collector<br/>Puerto 4317]
    end
    
    APP --> MINIO
    APP --> REDIS
    APP --> BACKEND
    APP --> OTEL_AGENT
    OTEL_AGENT --> OTEL_COL
```

---

## 6. Configuración y Variables de Entorno

### Archivo `application.yml`

```yaml
server:
  port: 7171

spring:
  application:
    name: firma-java
  data:
    redis:
      host: 100.0.102.147
      port: 6379
      password: dgp123

app:
  token: TEST_TOKEN
  s3:
    endpoint: http://100.0.102.147:9000
    access-key: admintest
    secret-key: admintest
    bucket-name: diplomas
    region: us-east-1
  tokens:
    bucket: tokens
  jacobitus:
    provider-path: /usr/lib/x86_64-linux-gnu/pkcs11/opensc-pkcs11.so
    timeout-ms: 60000
    validation-enabled: true
    default-pin: 123456
  firma:
    lote:
      max-threads: 5        # Threads paralelos para firma en lote
      queue-capacity: 500   # Capacidad de cola
  backend:
    core-api: http://100.0.102.147:3000/api
    api-token: TEST_TOKEN
    timeout-ms: 30000
```

### Variables de entorno Docker

```bash
OTEL_SERVICE_NAME=firma-digital-wrapper-java
OTEL_EXPORTER_OTLP_ENDPOINT=http://10.8.0.4:4317
OTEL_LOGS_EXPORTER=otlp
OTEL_METRICS_EXPORTER=otlp
OTEL_TRACES_EXPORTER=otlp
```

---

## 7. Instalación y Ejecución

### 7.1 Requisitos previos

1. **Instalar librería Jacobitus en repositorio local Maven:**

```bash
./mvnw install:install-file \
  -Dfile=libs/jacobitus-libreria-1.2.1.jar \
  -DgroupId=bo.firmadigital.jacobitus \
  -DartifactId=jacobitus-libreria \
  -Dversion=1.2.1 \
  -Dpackaging=jar
```

2. **Configurar S3:**
   - Crear bucket `diplomas` para PDFs
   - Crear bucket `tokens` para softokens (.p12)

### 7.2 Compilación

```bash
# Compilar el proyecto
./mvnw clean package -DskipTests

# El JAR generado estará en:
# target/firma-java-0.0.1-SNAPSHOT.jar
```

### 7.3 Ejecución local

```bash
# Ejecutar la aplicación
java -jar target/firma-java-0.0.1-SNAPSHOT.jar

# O con Maven wrapper
./mvnw spring-boot:run
```

La aplicación estará disponible en `http://localhost:7171`

### 7.4 Despliegue con Docker

```bash
# Construir imagen
docker build -t firma-digital-wrapper-java .

# Ejecutar con docker-compose
cd docker
docker-compose up -d
```

---

## 8. API Endpoints

### 8.1 Documentación interactiva

- **Swagger UI:** `http://localhost:7171/swagger-ui/index.html`
- **OpenAPI JSON:** `http://localhost:7171/v3/api-docs`

### 8.2 Endpoints principales

#### POST `/api/v1/firmar` - Firma síncrona

**Request:**
#### POST `/api/v1/firmar-lote` - Firma masiva asíncrona

**Request:**
```json
{
  "jobId": "lote-123",
  "username": "usuario",
  "pin": "123456",
  "diplomas": [
    {
      "diplomaId": "DIP-001",
      "pdfPath": "lote/diploma1.pdf",
      "nombreArchivo": "diploma1.pdf"
    },
    {
      "diplomaId": "DIP-002",
      "pdfPath": "lote/diploma2.pdf",
      "nombreArchivo": "diploma2.pdf"
    }
  ]
}
```

**Response:**
```json
{
  "status": "accepted",
  "message": "Se recibieron 2 documentos para firma digital",
  "total": 2,
  "jobId": "lote-123"
}
```
---

## 9. Desarrollo

### 9.1 Estructura del código

- **Arquitectura hexagonal (Ports & Adapters)**
- **Inyección de dependencias con Spring**
- **Programación reactiva con S3 AsyncClient**
- **DTOs validados con Jakarta Validation**
- **Manejo global de excepciones**

### 9.2 Hot reload en desarrollo

```bash
./mvnw spring-boot:run

```

---

## 10. Observabilidad

### 10.1 Métricas y trazas

- **OpenTelemetry Java Agent** integrado en el contenedor
- Exporta trazas, logs y métricas vía OTLP/gRPC
- Endpoint configurado: `http://10.8.0.4:4317`

### 10.2 Logs

- **SLF4J 2.x + Logback** (por defecto en Spring Boot)
- Logs estructurados con contexto de operaciones
- Niveles configurables vía `application.yml`

### 10.3 Actuator endpoints

```bash
# Health
curl http://localhost:7171/actuator/health

# Info
curl http://localhost:7171/actuator/info
```

---

## 11. Troubleshooting

### Error: "No se pudo descargar el softtoken"

**Solución:** 
1. Verificar que el archivo `.p12` exista en el bucket `tokens`
2. Comprobar que el nombre de usuario coincida con el archivo (ej: `usuario.p12`)

### Error de conexión con S3

**Solución:**
1. Verificar credenciales en `application.yml`
2. Comprobar conectividad de red: `curl http://100.0.102.147:9000`
3. Validar que los buckets existan

### Firma lenta en lote

**Solución:** Aumentar el número de threads:

```yaml
app:
  firma:
    lote:
      max-threads: 10  # Aumentar según CPU disponible
```

---
