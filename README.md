# 📘 Taller – Programación Declarativa (PostgreSQL)
## Gestión de Monedas y Cambios Diarios

Este repositorio contiene la solución completa al taller de Programación Declarativa en PostgreSQL.  
Incluye la creación de tablas, carga base, el script idempotente principal y consultas de verificación.

---

## 🎯 Objetivo del Taller

Implementar un módulo de gestión monetaria que permita:

1. Crear las tablas necesarias para monedas y cambios.
2. Alimentar los cambios diarios de los **últimos 2 meses** para **4 monedas**.
3. Validar si la moneda ya existe; si no, crearla.
4. Validar si el cambio para (moneda, fecha) ya existe; si existe, actualizarlo.
5. Lograr que el script se pueda **ejecutar varias veces sin duplicar datos**.

Este repositorio cumple todos estos puntos siguiendo el estilo y estructura de los ejemplos del profesor.

---

## 🏗️ Estructura del Proyecto

```
/
├── DDL_Monedas.sql            # Creación de tablas
├── DML_Monedas.sql            # Datos base de monedas
├── Script_Cambios.sql         # Script del taller (idempotente)
├── Consultas_Verificacion.sql # Consultas de chequeo final
└── README.md
```

---

## 🧱 1. Diseño de Base de Datos (DDL)

El modelo consta de dos tablas:

### **Tabla Moneda**
Contiene la información de cada moneda:

| Columna | Tipo | Descripción |
|---------|--------|-------------|
| Id | INT (PK) | Identificador |
| Moneda | VARCHAR | Nombre de la moneda |
| Sigla | VARCHAR (UNIQUE) | Sigla ISO (USD, EUR…) |
| Simbolo | VARCHAR | Símbolo monetario |
| Emisor | VARCHAR | País u organismo emisor |

---

### **Tabla CambioMoneda**
Registra el valor diario de cada moneda.

| Columna | Tipo | Descripción |
|---------|--------|-------------|
| IdMoneda | INT (FK) | Llave foránea a Moneda |
| Fecha | DATE | Día del cambio |
| Cambio | NUMERIC | Valor del cambio |
| (IdMoneda, Fecha) | UNIQUE | Garantiza ausencia de duplicados |

Este índice único permite usar `ON CONFLICT` para actualizar o insertar según corresponda.

---

## 🗃️ 2. Inserción Base (DML)

El archivo `DML_Monedas.sql` carga monedas iniciales requeridas por el profesor.  
Se ejecuta solo una vez antes de correr el script del taller.

---

## ⚙️ 3. Script Principal – Generación de Cambios Diarios

El archivo **Script_Cambios.sql** es el corazón del taller.

✔ Recorre diariamente los últimos 2 meses.  
✔ Genera valores de cambio usando fórmulas determinísticas.  
✔ Si la moneda no existe, la registra automáticamente.  
✔ Si el cambio ya existe, lo actualiza mediante `ON CONFLICT`.  
✔ Puede ejecutarse múltiples veces sin crear duplicados (**idempotente**).

Esto cumple exactamente las validaciones y comportamiento exigido en el taller.

---

## 🧠 4. ¿Cómo se solucionan los puntos solicitados?

| Requisito | Implementación |
|----------|----------------|
| Últimos 2 meses | `generate_series()` desde fecha actual - 2 meses |
| 4 monedas | USD, EUR, COP, MXN (creadas o verificadas en ejecución) |
| Validar si moneda existe | `SELECT Id FROM Moneda WHERE Sigla = ...` |
| Crear moneda si no existe | `INSERT ... ON CONFLICT DO NOTHING` |
| Validar cambio existente | Índice único en (IdMoneda, Fecha) |
| Actualizar si existe | `ON CONFLICT DO UPDATE SET Cambio = ...` |
| Script re-ejecutable | Todo el proceso es idempotente |

---

## ▶️ 5. Cómo Ejecutar el Proyecto (pgAdmin)

1. Instale PostgreSQL + pgAdmin.
2. Cree la base de datos: **Monedas**.
3. Ejecute en este orden:
   - `DDL_Monedas.sql`
   - `DML_Monedas.sql`
   - `Script_Cambios.sql`
4. Verifique datos con:
   ```sql
   SELECT * FROM Moneda;
   SELECT * FROM CambioMoneda ORDER BY Fecha DESC;
   ```

---

## 🔍 6. Consultas de Verificación

El archivo `Consultas_Verificacion.sql` contiene consultas como:

- Listado de monedas.
- Cambios más recientes.
- Conteo de fechas cargadas.
- Validación de no duplicados.

---

## 📌 Notas Finales

- Compatible 100% con PostgreSQL y pgAdmin.
- Puede ejecutarse tantas veces como sea necesario sin inconsistencias.
