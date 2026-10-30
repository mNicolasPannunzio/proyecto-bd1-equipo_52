
## 🏛️ Universidad Nacional del Nordeste (UNNE)

### Facultad de Ciencias Exactas y Naturales y Agrimensura (FACENA)
* **Asignatura:** **BASES DE DATOS 1**
* **Año Académico:** 2026

### 👥 Integrantes del Grupo:
* **Obregón, Adrián Jesús** — *DNI: 45.456.141*
* **Pannunzio, Mario Nicolas** — *DNI: 43.825.227*
* **Perone, Tiziano** — *DNI: 46.724.743*
* **Navarro, Luciano de Jesus** — *DNI: 44.683.191*
* **Romero, Enzo** — *DNI: 41.948.148*
---

## 🧭 NAVEGACIÓN Y ESTRUCTURA DEL REPOSITORIO

Acceso rápido a las entregas, modelos y scripts SQL del proyecto:

### 📁 [`docs/`](docs/) — Documentación Académica y Entregas
* 📄 [`docs/ERS-GuaraniTurnosMedicos.pdf`](docs/ERS-GuaraniTurnosMedicos.pdf): Documento de Especificación de Requisitos de Software (ERS) base de Ingeniería de Software 1.
* 📂 [`docs/etapa-01/`](docs/etapa-01/): **Etapa I — Requerimientos y Dominio del Negocio**
  * 📝 [`Requerimientos_y_Dominio_del_Negocio.md`](docs/etapa-01/Requerimientos_y_Dominio_del_Negocio.md): Descripción del dominio clínico y especificación formal de las reglas de negocio (RN1 a RN8).
  * 📄 [`equipo52_etapa_1.pdf`](docs/etapa-01/equipo52_etapa_1.pdf): Informe formal consolidado de la primera entrega.
* 📂 [`docs/etapa-02/`](docs/etapa-02/): **Etapa II — Modelado Conceptual, Lógico y Normalización**
  * 📝 [`ModeloRelacional.md`](docs/etapa-02/ModeloRelacional.md): Esquema relacional textual con claves primarias/foráneas y proceso de normalización hasta 3FN.
  * 🖼️ [`DER TURNOS MEDICOS GUARANI - CON EDRPLUS.png`](docs/etapa-02/DER%20TURNOS%20MEDICOS%20GUARANI%20-%20CON%20EDRPLUS.png): Diagrama Entidad-Relación elaborado en ERDPlus (notación Chen).
  * 🖼️ [`MODELO RELACIONAL DE TABLAS - HECHO CON EDR PLUS.jpg`](docs/etapa-02/MODELO%20RELACIONAL%20DE%20TABLAS%20-%20HECHO%20CON%20EDR%20PLUS.jpg): Diagrama tabular del modelo relacional físico/lógico.
  * 📝 Manifiestos de contribución individual: [`equipo52_etapa02_41948148.md`](docs/etapa-02/equipo52_etapa02_41948148.md), [`equipo52_etapa02_43825227.md`](docs/etapa-02/equipo52_etapa02_43825227.md), [`equipo52_etapa02_45456141.md`](docs/etapa-02/equipo52_etapa02_45456141.md), [`equipo52_etapa02_46724743.md`](docs/etapa-02/equipo52_etapa02_46724743.md).
* 📂 [`docs/etapa-03/`](docs/etapa-03/): **Etapa III — Implementación Física (DDL/DML)**
  * 📝 Manifiestos individuales de diseño y carga DDL/DML: [`equipo52_etapa03_43825227.md`](docs/etapa-03/equipo52_etapa03_43825227.md), [`equipo52_etapa03_46724743.md`](docs/etapa-03/equipo52_etapa03_46724743.md), [`equipo52_etapa_03_41948148.md`](docs/etapa-03/equipo52_etapa_03_41948148.md), [`equipo52_etapa_03_44683191.md`](docs/etapa-03/equipo52_etapa_03_44683191.md), [`equipo52_etapa_03_45456141.md`](docs/etapa-03/equipo52_etapa_03_45456141.md).
* 📂 [`docs/etapa-04/`](docs/etapa-04/): **Etapa IV — Consultas SQL**
   * 📝 Manifiestos individuales de consultas: [`equipo52_etapa04_43825227.md`](docs/etapa-04/equipo52_etapa04_43825227.md), [`equipo52_etapa04_45456141.md`](docs/etapa-04/equipo52_etapa04_45456141.md), [`equipo52_etapa04_46724743.md`](docs/etapa-04/equipo52_etapa04_46724743.md), [`equipo52_etapa04_41948148.md`](docs/etapa-04/equipo52_etapa04_41948148.md), [`equipo52_etapa04_44683191.md`](docs/etapa-04/equipo52_etapa04_44683191.md). 
* 📂 [`docs/etapa-05/`](docs/etapa-05/): **Etapa V — Temas Técnicos**
   * 📝 Manifiesto individual de temas técnicos: [`equipo52_etapa05_43825227.md`](docs/etapa-05/equipo52_etapa05_43825227.md).

### 📁 [`SQL/`](SQL/) — Scripts SQL (SQL Server / T-SQL)
* 🛠️ [`SQL/ddl/crear_bd2.sql`](SQL/ddl/crear_bd2.sql): Script DDL completo de creación de base de datos, tablas maestras, derivadas y restricciones de integridad (`PK`, `FK`, `UQ`, `CHK`).
* 📥 [`SQL/dml/datos_prueba.sql`](SQL/dml/datos_prueba.sql): Script DML con carga de datos de prueba coherentes organizados por niveles de precedencia.
* 🔍 [`SQL/consultas/Scripts_Consultas.sql`](SQL/consultas/Scripts_Consultas.sql): Scripts de consultas de verificación y casos de uso del sistema.
* 📂 [`SQL/tecnico - etapa-v/`](SQL/tecnico%20-%20etapa-v/): **Etapa V — Temas Técnicos**
  * ⚙️ **Procedimientos y Funciones:** [`scripts.sql`](SQL/tecnico%20-%20etapa-v/procedimientos-funciones/scripts.sql) | 📝 [`investigacion.md`](SQL/tecnico%20-%20etapa-v/procedimientos-funciones/investigacion.md) | 📝 [`evidencias/`](SQL/tecnico%20-%20etapa-v/procedimientos-funciones/evidencias/)
  * 🔄 **Transacciones y Concurrencia:** [`scripts.sql`](SQL/tecnico%20-%20etapa-v/transacciones/scripts.sql) | 📝 [`investigacion.md`](SQL/tecnico%20-%20etapa-v/transacciones/investigacion.md)
  * 🛡️ **Triggers y Auditoría:** [`scripts.sql`](SQL/tecnico%20-%20etapa-v/triggers-auditoria/scripts.sql) | 📝 [`investigacion.md`](SQL/tecnico%20-%20etapa-v/triggers-auditoria/investigacion.md)

---

## 📌 DESCRIPCIÓN DEL PROYECTO

### 📐 Proyecto Base de Origen
Este trabajo toma como base conceptual y de especificación el **Proyecto Integrador realizado para la asignatura Ingeniería de Software 1** (Año 2026). 

Para consultar el documento original de Especificación de Requisitos de Software (ERS), la educción de requerimientos, entrevistas, historias de usuario y prototipos de pantalla, se puede acceder al siguiente enlace:

📄 **Documento Base ERS:** [ERS-GuaraniTurnosMedicos.pdf](docs/ERS-GuaraniTurnosMedicos.pdf)

---

## 🎯 ALCANCE EN BASES DE DATOS 1

El objetivo principal de este repositorio es llevar a cabo la **fase de modelado, diseño conceptual, lógico, físico y desarrollo SQL de la Base de Datos Relacional** para el sistema *"Guaraní Turnos Médicos"*, tomando como referencia los requisitos educativos previamente formalizados.

### 🗄️ Aspectos Técnicos y Funcionalidades del Sistema a Persistir:

1. **Gestión de Usuarios y Roles (RBAC):**
   * Manejo de perfiles diferenciados: *Pacientes*, *Médicos*, *Secretarios* y *Administradores*.
   * Cifrado e integridad de credenciales de acceso conforme a la **Ley 25.326** (Protección de Datos Personales).

2. **Estructura y Catálogos Clínicos:**
   * Catálogo de **Especialidades Médicas** y asignación a profesionales.
   * Gestión de **Consultorios / Espacios Físicos** para evitar superposiciones.
   * Configuración de **Obras Sociales** y planes de salud aceptados (ej. *IOSCOR*, *Jerárquicos Salud*).

3. **Gestión de Agenda Médica y Disponibilidad:**
   * Configuración de días y rangos horarios de atención semanal por especialidad/médico.
   * Parametrización de la duración de consultas (15, 20, 30 min).
   * **Bloqueo temporal de agendas** por licencias, congresos o feriados (HU#15).

4. **Ciclo de Vida y Transacciones de Turnos Médicos:**
   * **Estados del Turno:** `Disponible` ➡️ `En proceso de reserva` ➡️ `Reservado` ➡️ `Paciente en Espera` ➡️ `En consulta` ➡️ `Finalizado` / `Ausente` / `Cancelado`.
   * **Control de Concurrencia (Bloqueo en tiempo real):** Prevención de condiciones de carrera cuando dos usuarios intentan seleccionar el mismo turno simultáneamente.
   * **Manejo de Tiempos de Expiración:** Liberación automática de turnos tras 5 minutos de inactividad durante la reserva.
   * **Reglas de Cancelación:** Permitida únicamente con más de 2 horas de anticipación.
   * **Lista de Espera Prioritaria:** Generación automática de cola de reasignación para turnos cancelados.

---

## 🛠️ TECNOLOGÍAS Y MOTOR DE BASE DE DATOS

* **Motor Relacional:** SQLServer / DBeaver (SGBD Relacional con soporte ACID)
* **Lenguaje:** SQL (DDL, DML, DCL, Triggers, Stored Procedures y Vistas)
* **Modelado:** Diagrama Entidad-Relación (DER) / Diagrama Relacional Tabular

---
---
---

## 📜 Pautas para la elaboración
### 1) Presentación y Contexto
El objetivo central del proyecto es diseñar, normalizar e implementar una base de datos relacional que soporte el ciclo completo de operaciones de venta, garantizando la integridad referencial, la consistencia y la no redundancia de la información.

---

#### 2) Alcance y Restricciones
**Dominio del problema:** Todos los equipos deberán desarrollar un sistema de gestión de ventas de productos o servicios(ej. indumentaria, electrónica, repuestos automotores, librería, etc.) , pudiendo seleccionar libremente el dominio específico, siempre que el caso permita satisfacer los requerimientos mínimos establecidos.
#### ***(Nosotros concretamente realizamos un sistema diferente porque se basa en otra materia ya cursada)***
**Límite de tablas:** El modelo deberá presentar una complejidad suficiente para representar adecuadamente el dominio seleccionado. Como referencia, se espera un esquema de entre 6 y 10 relaciones, pudiendo justificarse una cantidad diferente cuando las características del dominio lo requieran.
**Nivel de normalización:** El esquema debe alcanzar obligatoriamente la Tercera Forma Normal (3FN).

---

## 3) Etapas y Entregables
### Etapa I: Requerimientos y Dominio del Negocio
1. Descripción del caso: Breve introducción al rubro elegido y alcance del sistema.
2. Reglas de Negocio (mínimo 6): Redacción explícita de las reglas que rigen las operaciones.
Debe incluir al menos: gestión de stock, registro de clientes, historial de precios unitarios en el detalle de compra (para evitar cambios retroactivos) y métodos de pago.

### Etapa II: Modelado Conceptual y Lógico
1. Diagrama Entidad-Relación (DER): Diagrama con entidades, atributos, relaciones y cardinalidades (1:1, 1:N, N:M). Usando notación P. Chen en la herramienta ERDPlus.
2. Transformación al Modelo Relacional: Notación de tablas con claves primarias (PK) y foráneas (FK).
3. Proceso de Normalización: Documentación paso a paso de la evolución del modelo:
   * 1FN: Eliminación de grupos repetitivos y garantía de atomicidad.
   * 2FN: Eliminación de dependencias funcionales parciales en claves compuestas.
   * 3FN: Eliminación de dependencias transitivas en atributos no clave.

### Etapa III: Implementación Física (Scripts SQL)
1. Script DDL (Data Definition Language):
 * Creación de tablas e integridad referencial (PRIMARY KEY, FOREIGN KEY con reglas de borrado/modificación).
 * Definición correcta de tipos de datos (VARCHAR, DECIMAL, DATETIME, etc.) y restricciones (NOT NULL, UNIQUE, CHECK).
2. Script DML (Data Manipulation Language):
 * Poblado inicial de la base de datos con al menos 8 a 10 registros coherentes por tabla para pruebas.

### Etapa IV: Consultas y Casos de Uso
Desarrollar y probar los scripts SQL para responder a las siguientes necesidades de información:

* Factura/Comprobante: Consulta que consolide el encabezado y detalle de una venta, calculando sub-totales por renglón y el total acumulado.
* Reporte Agregado: Total de ventas realizadas por cada vendedor o por cada categoría de producto en un rango de fechas (GROUP BY, SUM, COUNT).
* Consulta de Negocio Avanzada: Una consulta que combine al menos 3 tablas mediante JOIN y aplique filtros condicionales (HAVING o subconsultas).

### Etapa V: Implementación temas tècnicos
Investigar e implementar en el motor de bases de datos diferentes  componentes, mecanismos y estructuras que aportan valor crítico para que la implementación de la base de datos sea robusta, rápida, segura y fácil de mantener a largo plazo.

1. Descripción breve de cada uno de los temas tècnicos y fundamentos de aplicación en el caso de estudio desarrollado
2. Script SQL de implementación en el motor de bases de datos
3. Script SQL o resumen explicativo (en caso de corresponder) de demostración de utilización de cada tema técnico implementado.
4. Temas técnicos: Procedimientos y funciones almacenadas; Manejo de transacciones; Triggers de auditorías; Seguridad; Índices (optimización)

---

### 5) Etapas y fechas

| Etapa | Pregunta que responde | Producto | Fecha Entrega |
|-------|-----------------------|----------|---------------|
| I. Requerimientos | ¿Qué necesita el negocio? | Requerimientos + reglas | viernes 04/09 |
| II. Modelado | ¿Cómo representamos la información? | DER + modelo relacional + 3FN | viernes 11/09 |
| III. Implementación | ¿Cómo construimos la BD? | DDL + DML | miércoles 30/09 |
| IV. Consultas | ¿Cómo obtenemos información? | SQL + casos de uso | |
| V. Temas técnicos | ¿Cómo hacemos la solución más robusta? | Procedimientos, funciones, transacciones, triggers, seguridad e índices | |

---

### 6) Estructura del GIT
Cada equipo debería tener un repositorio propio, siguiendo la siguiente estructura:


proyecto-bd1-equipo_XX/

│

├── docs/

│   ├── etapa-01/

│   ├── etapa-02/

│   ├── etapa-03/

│   ├── etapa-04/

│   └── etapa-05/

│

├── sql/

│   ├── ddl/

│   ├── dml/

│   ├── consultas/

│   └── tecnico/

│

├── modelos/

│   └── der/

│

└── README.md

---
---
---
# fin
