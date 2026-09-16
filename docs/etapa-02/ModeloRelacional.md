# Modelo Relacional y Normalización (3FN)

Este documento detalla el esquema formal del **Modelo Relacional** correspondiente al diagrama entidad-relación (DER) del sistema de gestión de turnos médicos.

---

## 1. Notación y Convenciones

* **Clave Primaria (PK):** Atributo en **negrita y <ins>subrayado</ins>**.
* **Clave Foránea (FK):** Atributo en *cursiva*.
* **Clave Primaria Compuesta:** Combinación de atributos <ins>***en negrita, cursiva y subrayados***</ins>.
* Las restricciones de integridad referencial se especifican explícitamente debajo de cada tabla mediante la notación:  
  `atributo_fk` $\rightarrow$ `TABLA_DESTINO(atributo_pk)`.

---

## 2. Esquema Relacional

### 2.1 Tablas Maestras

* **ROL** (<ins>**id_rol**</ins>, nombre_rol)

* **ESTADO_TURNO** (<ins>**id_estado**</ins>, nombre_estado)

* **CONSULTORIO** (<ins>**id_consultorio**</ins>, numero_consultorio)

* **OBRASOCIAL** (<ins>**id_obra_social**</ins>, nombre_os)

* **ESPECIALIDAD** (<ins>**id_especialidad**</ins>, nombre_especialidad, descripcion)

---

### 2.2 Entidades de Usuarios y Subtipos

* **USUARIO** (<ins>**dni_usuario**</ins>, nombre_usuario, apellido_usuario, password_usuario, estadoUsuario, *id_rol*)  
  * *FK*: `id_rol` $\rightarrow$ `ROL(id_rol)`

* **MEDICO** (<ins>**matricula_medico**</ins>, fecha_contratacion, *dni_usuario*)  
  * *FK*: `dni_usuario` $\rightarrow$ `USUARIO(dni_usuario)` *(Restricción UNIQUE / Relación 1:1)*

* **SECRETARIO** (<ins>**credencial_secretario**</ins>, fecha_contratacion, *dni_usuario*)  
  * *FK*: `dni_usuario` $\rightarrow$ `USUARIO(dni_usuario)` *(Restricción UNIQUE / Relación 1:1)*

* **PACIENTE** (<ins>**id_paciente**</ins>, fecha_nacimiento, *dni_usuario*, *id_obra_social*)  
  * *FK*: `dni_usuario` $\rightarrow$ `USUARIO(dni_usuario)` *(Restricción UNIQUE / Relación 1:1)*  
  * *FK*: `id_obra_social` $\rightarrow$ `OBRASOCIAL(id_obra_social)`

---

### 2.3 Agendas y Asignaciones Médicas

* **ESPECIALIDAD_MEDICO** (<ins>***matricula_medico***</ins>, <ins>***id_especialidad***</ins>, activo, fecha_obtencion, institucion_emisor)  
  * *PK Compuesta*: (`matricula_medico`, `id_especialidad`)  
  * *FK*: `matricula_medico` $\rightarrow$ `MEDICO(matricula_medico)`  
  * *FK*: `id_especialidad` $\rightarrow$ `ESPECIALIDAD(id_especialidad)`

* **AGENDA_SEMANAL** (<ins>**id_agenda**</ins>, dia_semana, hora_inicio, hora_fin, duracion_minutos, *matricula_medico*)  
  * *FK*: `matricula_medico` $\rightarrow$ `MEDICO(matricula_medico)`

* **BLOQUEO_AGENDA** (<ins>**id_bloqueo**</ins>, fecha_inicio, fecha_fin, motivo, *matricula_medico*)  
  * *FK*: `matricula_medico` $\rightarrow$ `MEDICO(matricula_medico)`

---

### 2.4 Transacciones del Sistema (Turnos y Espera)

* **TURNO** (<ins>**id_turno**</ins>, codigo_turno, fecha_turno, hora_turno, *id_paciente*, *matricula_medico*, *id_consultorio*, *id_estado*)  
  * *FK*: `id_paciente` $\rightarrow$ `PACIENTE(id_paciente)`  
  * *FK*: `matricula_medico` $\rightarrow$ `MEDICO(matricula_medico)`  
  * *FK*: `id_consultorio` $\rightarrow$ `CONSULTORIO(id_consultorio)`  
  * *FK*: `id_estado` $\rightarrow$ `ESTADO_TURNO(id_estado)`

* **LISTA_ESPERA** (<ins>**id_lista**</ins>, fecha_cancelacion, *id_paciente*)  
  * *FK*: `id_paciente` $\rightarrow$ `PACIENTE(id_paciente)`

---

## 3. Justificación de Formas Normales (1FN, 2FN, 3FN)

### 3.1 Primera Forma Normal (1FN)
* Todos los atributos contienen valores atómicos e indivisibles (no existen atributos multivaluados, arreglos ni listas anidadas dentro de una tupla).
* Datos personales (como nombre y apellido) y temporales (fecha y hora del turno) se encuentran desacoplados en columnas unitarias.
* Cada relación posee una clave primaria definida inequívocamente que identifica de manera única a cada registro.

### 3.2 Segunda Forma Normal (2FN)
* El modelo cumple estrictamente con la 1FN.
* Todos los atributos no clave dependen funcionalmente de manera completa de la clave primaria (no existen dependencias parciales).
* En la tabla con clave primaria compuesta (**ESPECIALIDAD_MEDICO**): los atributos no clave (`activo`, `fecha_obtencion` e `institucion_emisor`) dependen de la combinación completa de (`matricula_medico`, `id_especialidad`) y no de una sola parte de la clave.
* En las demás relaciones, la clave primaria es simple (un único atributo), por lo que la condición de 2FN se satisface de manera directa.

### 3.3 Tercera Forma Normal (3FN)
* El modelo cumple estrictamente con la 2FN.
* No existen dependencias funcionales transitivas: ningún atributo no clave depende funcionalmente de otro atributo no clave ($X \rightarrow Y$, donde $X$ no es superclave).
* Los datos descriptivos asociados a catálogos (por ejemplo, nombres de roles, estados de turno o nombres de obras sociales) no se almacenan como texto duplicado en tablas transaccionales, sino que se aíslan en entidades maestras (`ROL`, `ESTADO_TURNO`, `OBRASOCIAL`) referenciadas únicamente mediante claves foráneas.
