# 🇪🇸 Servidor FiveM - Spain Rol v2.0 Oficial (QBCore)

Servidor de Roleplay Español basado en QBCore con sistemas exclusivos de Spain Rol y Origin RP, optimizado para trabajo en equipo y desarrollo colaborativo.

---

## 🚀 Guía de Inicio Rápido para Colaboradores

Si eres un amigo/colaborador y acabas de clonar este repositorio:

### 1. Iniciar la Base de Datos
1. Ve a la carpeta `database/`.
2. Asegúrate de que el motor MariaDB esté iniciado y ejecuta `importar_base_de_datos.bat` para cargar todas las tablas, ítems, vehículos y usuarios.

### 2. Iniciar el Servidor
1. Haz doble clic en `iniciar_servidor.bat` en la raíz del proyecto.
2. Abre FiveM, pulsa **`F8`** y escribe:
   ```text
   connect localhost
   ```

---

## 🌿 Flujo de Trabajo en Equipo con Git e IA (Antigravity)

Para que podamos trabajar en paralelo de forma individual sin pisarnos los archivos:

### 1. Crear una Rama para tu tarea
Antes de empezar a programar con la IA un nuevo sistema o modificar algo, crea una rama propia:
```bash
git checkout -b feature/nombre-de-tu-sistema
```
*Ejemplo:* `git checkout -b feature/mafias-drogas` o `git checkout -b feature/nuevo-taller`

### 2. Programar con la IA y Probar
- Pídele a la IA en tu ordenador que implemente o modifique lo que necesitas.
- Prueba los cambios en tu servidor local (`localhost`).

### 3. Guardar y Subir tus Cambios
```bash
git add .
git commit -m "feat: añadido sistema de mafias y puntos de spawn"
git push origin feature/nombre-de-tu-sistema
```

### 4. Unir los Cambios (*Merge*) a `main`
- En GitHub, abre un **Pull Request** para revisar los cambios y fusionarlos a la rama principal `main`.
- Luego, en la rama `main`:
  ```bash
  git checkout main
  git pull origin main
  ```

---

## 📁 Estructura del Repositorio

- `server-data/resources/`
  - `[spain-rol]/`: Sistemas exclusivos de Spain Rol (`spain_systems`, `spain_mdt`, `spain_loadingscreen`, `spain_vehicles`).
  - `[qb]/`: Framework QBCore base en español (`qb-phone` estilo iPhone Pro, `qb-adminmenu` en F10, robos, trabajos, etc.).
  - `[standalone]/`: Dependencias (`oxmysql`, `pma-voice`, `dpemotes`, `PolyZone`, etc.).
- `server-data/server.cfg`: Archivo de configuración central del servidor.
- `database/qbcoreframework_dump.sql`: Volcado completo de la base de datos para sincronizar esquemas.
