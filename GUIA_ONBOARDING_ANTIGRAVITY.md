# 🔰 Guía Paso a Paso para Principiantes (Onboarding Completo)
## Cómo configurar Antigravity IDE y el Ecosistema Multi-Agente HIBERUS

Esta guía está redactada con todo detalle pensando en usuarios sin experiencia técnica previa. No necesitas saber de programación ni usar la consola de comandos avanzada: sigue estos 6 sencillos pasos para tener todo tu entorno listo en 10 minutos.

---

## 📋 Resumen de lo que vas a conseguir

Al finalizar esta guía tendrás en tu ordenador:
1. Las herramientas básicas instaladas (Git, Node.js y Antigravity IDE).
2. El proyecto con todas las plantillas y los 5 agentes inteligentes de HIBERUS.
3. Todo configurado automáticamente para trabajar, exportar a Word/Excel/PowerPoint y sincronizarte con el resto del equipo.

---

## 📌 PASO 1: Crear tus Cuentas Gratuitas (Si no las tienes)

Para trabajar con la Inteligencia Artificial y recibir las actualizaciones del equipo necesitas 2 cuentas gratis:

### 1.1. Cuenta de Google (Para la IA de Antigravity)
- Necesitas una cuenta de Google (sirve tu correo corporativo de la empresa si usa Google, o tu cuenta personal `@gmail.com`).
- **Para qué sirve**: Antigravity la requiere para identificarte y conectarse a los modelos de inteligencia artificial (Gemini 3.6 Flash / Pro).

### 1.2. Cuenta de GitHub (Para los proyectos y plantillas)
1. Entra en la web oficial: 👉 [https://github.com/signup](https://github.com/signup)
2. Escribe tu correo electrónico, crea una contraseña y elige un nombre de usuario.
3. Revisa tu correo y confirma el código de verificación que te enviarán.
- **Para qué sirve**: GitHub es donde guardamos las reglas de los agentes, plantillas funcionales y entregables del equipo.

---

## 📌 PASO 2: Descargar e Instalar las Herramientas Básicas

Descarga e instala estos 3 programas en tu ordenador. Solo tendrás que hacer clic en **Siguiente / Next** en todos los instaladores.

### 2.1. Instalar Git (Para gestionar los archivos del proyecto)
1. Entra en la página de descarga: 👉 [https://git-scm.com/download/win](https://git-scm.com/download/win)
2. Haz clic en **64-bit Git for Windows Setup** para descargar.
3. Abre el archivo descargado y haz clic en **Next** (Siguiente) a todo hasta que finalice la instalación.

### 2.2. Instalar Node.js (Motor para los scripts automáticos)
1. Entra en la página oficial: 👉 [https://nodejs.org/](https://nodejs.org/)
2. Haz clic en el botón verde grande que dice **LTS (Recommended For Most Users)**.
3. Abre el archivo descargado y haz clic en **Next** en todas las pantallas.

### 2.3. Instalar Antigravity IDE (Tu aplicación de Inteligencia Artificial)
1. Descarga el instalador de Antigravity IDE proporcionado por la empresa o desde la plataforma de instalación.
2. Ábrelo e instálalo normalmente.

*(Nota: Asegúrate de tener instalado Microsoft Office —Word, Excel y PowerPoint— en tu ordenador para que las exportaciones automáticas de documentos funcionen).*

---

## 📌 PASO 3: Obtener la Carpeta del Proyecto en tu Ordenador

Tienes 2 opciones para descargar el proyecto. Elige la que te resulte más cómoda:

### OPCIÓN A (Fácil con Consola):
1. Abre el buscador de Windows (la lupa al lado del botón Inicio) y escribe `cmd` o `Terminal`. Abre la aplicación **Símbolo del sistema**.
2. Escribe el siguiente comando y pulsa **Enter**:
   ```bash
   git clone https://github.com/juadurhe-coder/AI-HIBERUS-Projects.git
   ```
3. Se creará automáticamente una carpeta llamada `AI-HIBERUS-Projects` en tu equipo.

---

### OPCIÓN B (Ultra Fácil sin Consola):
1. Entra en el enlace del repositorio: 👉 [https://github.com/juadurhe-coder/AI-HIBERUS-Projects](https://github.com/juadurhe-coder/AI-HIBERUS-Projects)
2. En la parte superior derecha de la pantalla, haz clic en el botón verde que dice **`<> Code`**.
3. En el menú desplegable, haz clic en **Download ZIP**.
4. Se descargará un archivo `.zip`. Descomprímelo en tu ordenador (por ejemplo, en `Documentos\Proyectos\AI-HIBERUS-Projects`).

---

## 📌 PASO 4: Puesta a Punto en 1 Solo Clic (`setup.bat`)

Una vez tengas la carpeta `AI-HIBERUS-Projects` en tu equipo:

1. Abre el **Explorador de Archivos de Windows** y entra en la carpeta del proyecto.
2. Busca un archivo llamado **`setup.bat`** (o `setup`).
3. Haz **doble clic** sobre él.
4. Se abrirá una ventana negra que trabajará automáticamente durante 2 o 3 segundos.
5. Cuando veas un mensaje con letras verdes que dice **`🎉 ¡ENTORNO CONFIGURADO Y LISTO PARA USAR!`**, pulsa cualquier tecla de tu teclado para cerrar la ventana.

¡Ya está configurada la estructura global de los agentes en tu perfil local!

---

## 📌 PASO 5: Configurar tu Token de GitHub (Para Sincronización Automática)

Para que el sistema pueda consultar actualizaciones del equipo automáticamente o buscar código en GitHub, necesitas crear tu clave personal (Token):

### 5.1. Crear la clave en la web de GitHub:
1. Entra en GitHub e inicia sesión con tu usuario.
2. Haz clic en la **foto de tu perfil** (arriba a la derecha) y selecciona **Settings** (Configuración).
3. En el menú de la izquierda, desplázate hasta abajo del todo y haz clic en **Developer settings**.
4. Haz clic en **Personal access tokens** > **Tokens (classic)**.
5. Haz clic en el botón **Generate new token** (Generate new token classic).
6. En la casilla **Note**, escribe: `Antigravity Token`.
7. En **Expiration**, elige `No expiration` o `90 days`.
8. En las casillas de abajo, marca la primera opción: **`repo`** (Full control of private repositories).
9. Desplázate al fondo y haz clic en el botón verde **Generate token**.
10. **¡MUY IMPORTANTE!** Verás una clave que empieza por `ghp_...`. Cópiala inmediatamente (si cierras la página no volverá a mostrarse).

---

### 5.2. Pegar la clave en tu configuración local:
1. En tu teclado pulsa las teclas **`Windows + R`** a la vez.
2. En la ventanita que aparece escribe exactamente: `%USERPROFILE%\.gemini\antigravity-ide` y pulsa **Enter**.
3. Se abrirá una carpeta de Windows. Busca el archivo **`mcp_config.json`**.
4. Haz clic derecho sobre él y selecciona **Abrir con > Bloc de notas** (Notepad).
5. Verás algo como esto:

```json
{
  "mcpServers": {
    "github-mcp-server": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-github"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "AQUI_PEGA_TU_TOKEN_GHP"
      }
    }
  }
}
```

6. Reemplaza las letras `AQUI_PEGA_TU_TOKEN_GHP` por la clave que copiaste en GitHub (manteniendo las comillas `""`).
7. Pulsa `Ctrl + G` (o `Archivo > Guardar`) y cierra el Bloc de Notas.

---

## 📌 PASO 6: Abrir Antigravity IDE y Empezar a Trabajar

1. Abre la aplicación **Antigravity IDE** en tu ordenador.
2. Inicia sesión con tu cuenta de Google.
3. En el menú superior de la aplicación, haz clic en **File** (Archivo) > **Open Folder** (Abrir Carpeta).
4. Selecciona la carpeta `AI-HIBERUS-Projects` de tu ordenador y haz clic en **Seleccionar carpeta**.

¡Listo! Antigravity detectará automáticamente los 5 roles de agentes inteligentes de HIBERUS.

---

## 💬 Comandos que puedes usar en el Chat de Antigravity

Dentro del chat de Antigravity puedes escribir estos comandos especiales (empiezan por barra `/`):

| Comando | Para qué sirve y cuándo usarlo |
| :--- | :--- |
| **`/run_orchestrator`** | **Iniciar Sesión**: Activa el Orquestador Principal que decidirá qué especialista (Arquitecto, Programador, PMO, etc.) debe responderte en cada momento. |
| **`/sync_config`** | **Actualizar**: Descarga las últimas reglas, plantillas o scripts subidos por tus compañeros desde GitHub. |
| **`/push_config`** | **Publicar**: Sube todos tus cambios locales, propuestas o mejoras de agentes a GitHub para compartirlos con el equipo. |
| **`/export_to_word`** | **Generar Word**: Convierte tu propuesta o documento a formato Word `.docx` profesional con la cabecera de HIBERUS. |
| **`/export_to_excel`** | **Generar Excel**: Exporta un reporte o datos a una hoja de cálculo `.xlsx` nativa. |
| **`/export_to_pptx`** | **Generar PowerPoint**: Transforma tu documento de presentación en diapositivas PowerPoint `.pptx`. |
| **`/daily`** | **Daily Standup**: Revisa el avance diario y bloqueos con el Delivery Manager. |

---

## ❓ Preguntas Frecuentes y Ayuda

- **¿Qué hago si al saludar me sale un aviso de que hay actualizaciones?**
  Solo tienes que escribir `/sync_config` en el chat y el agente descargará las novedades automáticamente sin que tengas que hacer nada más.
- **¿Tengo que modificar rutas o archivos si cambio de PC?**
  No, todo el sistema ha sido diseñado con rutas automáticas. Al clonar la carpeta y hacer doble clic en `setup.bat` todo volverá a funcionar al instante.

---
*Manual de Onboarding para Usuarios — Equipo de IA & Gobernanza SAP HIBERUS.*
