/**
 * Script: check-fiori-clean-code-quality.js
 * Propósito: Linter para verificar reglas de Clean Code en apps SAP Fiori / SAPUI5
 *            (Controladores JS/TS, Component.js, Vistas y Fragmentos XML, manifest.json, index.html, ui5.yaml, OData V4 e i18n).
 */

const fs = require('fs');
const path = require('path');
const { scanFilesRecursively, getCleanLines, readJsonSafe, initAuditResult } = require('../../utils/common-utils');

const rulesPath = path.join(__dirname, '..', '..', 'tests', 'linters', 'fiori-clean-code-rules.json');
const rules = readJsonSafe(rulesPath, {});

function checkFioriQuality(appFolderPath) {
    const results = initAuditResult();

    if (!fs.existsSync(appFolderPath)) {
        results.errors.push(`El directorio de la aplicación Fiori ${appFolderPath} no existe.`);
        results.passed = false;
        return results;
    }

    let manifestFound = false;
    const referencedI18nKeys = new Set();
    let i18nPropertiesPath = null;

    // 1. Auditoría de Controlador JS/TS y Component.js (DOM, APIs obsoletas y Sincronismo)
    function checkController(filePath, res) {
        const fileName = path.basename(filePath);
        const content = fs.readFileSync(filePath, 'utf-8');

        if (fileName.endsWith('.js') && !content.includes('"use strict"') && !content.includes("'use strict'")) {
            res.warnings.push(`[${fileName}] Se recomienda incluir '"use strict";' en la definición del módulo.`);
        }

        const cleanLines = getCleanLines(content, { commentPrefixes: ['//', '/*'], skipEmpty: true });

        cleanLines.forEach(({ trimmed, lineNum, isComment }) => {
            if (isComment) return;

            (rules.prohibitedDomPatterns || []).forEach(pattern => {
                if (trimmed.includes(pattern)) {
                    res.errors.push(`[${fileName}:L${lineNum}] Violación Clean Code: Manipulación directa del DOM detectada ("${pattern}"). Use Data Binding de SAPUI5.`);
                }
            });

            (rules.prohibitedObsoleteApis || []).forEach(api => {
                if (trimmed.includes(api)) {
                    res.errors.push(`[${fileName}:L${lineNum}] Uso de API obsoleta detectada ("${api}"). Use módulos asíncronos 'sap.ui.define'.`);
                }
            });

            (rules.prohibitedSyncPatterns || []).forEach(syncPattern => {
                const regex = new RegExp(syncPattern, 'i');
                if (regex.test(trimmed)) {
                    res.errors.push(`[${fileName}:L${lineNum}] Llamada síncrona bloqueante detectada (${syncPattern}). Las operaciones I/O y de carga de datos deben ser 100% asíncronas.`);
                }
            });
        });
    }

    // 1.1 Auditoría específica de Component.js
    function checkComponentJs(filePath, res) {
        const fileName = path.basename(filePath);
        const rawContent = fs.readFileSync(filePath, 'utf-8');
        const codeOnly = rawContent.replace(/\/\/.*/g, '').replace(/\/\*[\s\S]*?\*\//g, '');

        if (!codeOnly.includes('sap/ui/core/UIComponent')) {
            res.errors.push(`[${fileName}] Estructura Component.js: El componente raíz debe extender 'sap/ui/core/UIComponent'.`);
        }

        const hasManifestMetadata = /metadata\s*:\s*\{[^}]*manifest\s*:\s*["']json["']/i.test(codeOnly);
        if (!hasManifestMetadata) {
            res.errors.push(`[${fileName}] Metadata Component.js: Falta la declaración obligatoria 'metadata: { manifest: "json" }'.`);
        }

        if (codeOnly.includes('init:') || codeOnly.includes('init :') || codeOnly.includes('init(')) {
            if (!codeOnly.includes('UIComponent.prototype.init.apply') && !codeOnly.includes('super.init(')) {
                res.warnings.push(`[${fileName}] Lifecycle Component.js: El método init() debe invocar 'UIComponent.prototype.init.apply(this, arguments)' para inicializar el router y modelos.`);
            }
        }
    }

    // 2. Auditoría de Vistas y Fragmentos XML (Controles válidos, i18n, accesibilidad y ProgressIndicator)
    function checkXml(filePath, res) {
        const fileName = path.basename(filePath);
        const content = fs.readFileSync(filePath, 'utf-8');
        const cleanLines = getCleanLines(content, { commentPrefixes: ['<!--'], skipEmpty: true });

        let isInsideSimpleForm = false;

        cleanLines.forEach(({ trimmed, lineNum, isComment }) => {
            if (isComment) return;

            if (trimmed.includes('<SimpleForm') || trimmed.includes('<form:SimpleForm')) {
                isInsideSimpleForm = true;
            }
            if (trimmed.includes('</SimpleForm>') || trimmed.includes('</form:SimpleForm>')) {
                isInsideSimpleForm = false;
            }

            // 2.1 Controles XML inválidos (ej. <Badge> en sap.m)
            if (rules.invalidXmlControls) {
                for (const [ns, invalidTags] of Object.entries(rules.invalidXmlControls)) {
                    invalidTags.forEach(invalidTag => {
                        const tagRegex = new RegExp(`<${invalidTag}(\\s|>|/)`, 'g');
                        if (tagRegex.test(trimmed)) {
                            res.errors.push(`[${fileName}:L${lineNum}] Control XML inválido '<${invalidTag}>' en espacio de nombres predeterminado (${ns}). Use controles estándar como 'sap.m.ObjectStatus' o 'sap.m.Title'.`);
                        }
                    });
                }
            }

            // 2.2 Accesibilidad: Label sin labelFor fuera de SimpleForm
            if (!isInsideSimpleForm && /<Label\b/i.test(trimmed) && !/labelFor=/i.test(trimmed) && !/ariaLabelledBy=/i.test(trimmed)) {
                res.warnings.push(`[${fileName}:L${lineNum}] Accesibilidad (WAI-ARIA): Se recomienda incluir 'labelFor="<id_control>"' en la etiqueta <Label> fuera de SimpleForms.`);
            }

            // 2.3 ProgressIndicator percentValue
            if (/<ProgressIndicator\b/i.test(trimmed)) {
                const percentMatch = trimmed.match(/percentValue="(\d+)"/);
                if (percentMatch && parseInt(percentMatch[1], 10) > 100) {
                    res.errors.push(`[${fileName}:L${lineNum}] 'percentValue' en ProgressIndicator no puede ser mayor que 100 (${percentMatch[1]}). Use expresión acotada: percentValue="{= \${...} > 100 ? 100 : \${...} }".`);
                }
            }

            // 2.4 Recopilar claves i18n usadas para verificar completitud
            const i18nMatches = trimmed.matchAll(/\{i18n>([A-Za-z0-9_]+)\}/g);
            for (const im of i18nMatches) {
                referencedI18nKeys.add(im[1]);
            }

            // 2.5 Atributos i18n
            (rules.requiredXmlAttributesI18n || []).forEach(attr => {
                const regex = new RegExp(`\\b${attr}="([^"{}>]+)"`, 'gi');
                let match;
                while ((match = regex.exec(trimmed)) !== null) {
                    const value = match[1];
                    if (!value.startsWith('{') && !value.includes('i18n>') && isNaN(value) && !['true', 'false', 'None', 'Center', 'Left', 'Right', 'Top', 'Bottom', 'Auto', 'Information', 'Success', 'Warning', 'Error', 'Solid'].includes(value)) {
                        res.errors.push(`[${fileName}:L${lineNum}] Texto literal hardcodeado en '${attr}="${value}"'. Debe ser una clave i18n (ej. ${attr}="{i18n>key}").`);
                    }
                }
            });
        });
    }

    // 3. Auditoría de index.html (Bootstrap asíncrono, init modules y contenedor UI5)
    function checkIndexHtml(filePath, res) {
        const fileName = path.basename(filePath);
        const content = fs.readFileSync(filePath, 'utf-8');

        if (content.includes('data-sap-ui-async="true"') && /sap\.ui\.getCore\(\)\.attachInit/i.test(content) && !content.includes('data-sap-ui-oninit')) {
            res.errors.push(`[${fileName}] Riesgo de condición de carrera: 'sap.ui.getCore().attachInit' en script síncrono con 'data-sap-ui-async="true"'. Use 'data-sap-ui-oninit="module:..."' o 'sap/ui/core/ComponentSupport'.`);
        }

        if (!content.includes('data-sap-ui-xx-componentpreload="off"')) {
            res.warnings.push(`[${fileName}] Se recomienda configurar 'data-sap-ui-xx-componentpreload="off"' para evitar errores 404 de Component-preload.js en desarrollo local.`);
        }

        if (!content.includes('data-sap-ui-preload="async"')) {
            res.warnings.push(`[${fileName}] Se recomienda configurar 'data-sap-ui-preload="async"' para carga de dependencias 100% asíncrona.`);
        }

        if (!content.includes('height') || (!content.includes('100%') && !content.includes('100vh') && !content.includes('calc('))) {
            res.warnings.push(`[${fileName}] Asegúrese de que el contenedor de la aplicación ('#app-container' o 'body') tenga una altura definida (ej. height: 100% o 100vh) para evitar que vistas como FlexibleColumnLayout colapsen.`);
        }
    }

    // 3.1 Auditoría de init.js (Bootstrap Component.create asíncrono)
    function checkInitJs(filePath, res) {
        const fileName = path.basename(filePath);
        const content = fs.readFileSync(filePath, 'utf-8');

        if (!content.includes('Component.create') || (!content.includes('async: true') && !content.includes('async : true') && !content.includes('async:true'))) {
            res.warnings.push(`[${fileName}] Se recomienda utilizar 'sap/ui/core/Component.create({ manifest: true, async: true })' para inicialización 100% asíncrona sin bloqueos del hilo principal.`);
        }
    }

    // 4. Auditoría de manifest.json (Campos obligatorios, OData V4, i18n Locales y Routing)
    function checkManifestJson(filePath, res) {
        try {
            const manifest = JSON.parse(fs.readFileSync(filePath, 'utf-8'));

            if (!manifest['sap.app'] || !manifest['sap.app'].id) {
                res.errors.push(`[manifest.json] Falta 'sap.app.id'.`);
            }
            if (!manifest['sap.app'] || !manifest['sap.app'].type) {
                res.warnings.push(`[manifest.json] Falta 'sap.app.type' (ej. "application").`);
            }
            if (!manifest['sap.app'] || !manifest['sap.app'].i18n) {
                res.warnings.push(`[manifest.json] Falta 'sap.app.i18n' para la configuración del bundle de traducciones.`);
            }
            if (!manifest['sap.ui5'] || !manifest['sap.ui5'].dependencies) {
                res.warnings.push(`[manifest.json] Falta 'sap.ui5.dependencies' (librerías UI5 requeridas).`);
            }
            if (!manifest['sap.ui5'] || !manifest['sap.ui5'].models) {
                res.errors.push(`[manifest.json] Falta 'sap.ui5.models'. Debe declarar al menos el modelo principal de datos y el modelo i18n.`);
            }

            const i18nModel = manifest['sap.ui5'] && manifest['sap.ui5'].models && manifest['sap.ui5'].models.i18n;
            if (i18nModel && i18nModel.settings && !i18nModel.settings.async) {
                res.warnings.push(`[manifest.json] Se recomienda configurar 'settings.async: true' en el modelo i18n para evitar peticiones XHR síncronas.`);
            }

            if (manifest['sap.app'] && manifest['sap.app'].i18n && typeof manifest['sap.app'].i18n === 'object') {
                const supported = manifest['sap.app'].i18n.supportedLocales || [];
                if (!supported.includes('')) {
                    res.warnings.push(`[manifest.json] 'sap.app.i18n.supportedLocales' debe incluir '""' (idioma raíz por defecto).`);
                }
                if (!supported.includes('en')) {
                    res.warnings.push(`[manifest.json] 'sap.app.i18n.supportedLocales' debe incluir 'en' (fallback estándar de SAPUI5).`);
                }
            }

            if (!manifest['sap.ui5'] || !manifest['sap.ui5'].routing) {
                res.warnings.push(`[manifest.json] No se ha definido 'routing' en 'sap.ui5'.`);
            }

            const dataSources = (manifest['sap.app'] && manifest['sap.app'].dataSources) || {};
            let hasODataV4 = false;
            let hasODataV2 = false;

            for (const dsKey in dataSources) {
                const ds = dataSources[dsKey];
                if (ds.type === 'OData') {
                    const version = ds.settings && ds.settings.odataVersion;
                    if (version === '4.0' || version === '4') {
                        hasODataV4 = true;
                    } else if (version === '2.0' || version === '2' || !version) {
                        hasODataV2 = true;
                    }
                }
            }

            if (hasODataV2 && !hasODataV4) {
                res.warnings.push(`[manifest.json] Se detectó datasource OData V2. La directriz técnica exige OData V4 en nuevos desarrollos.`);
            }

        } catch (e) {
            res.errors.push(`[manifest.json] Archivo JSON inválido o corrupto (${e.message}).`);
        }
    }

    // 5. Auditoría de completitud i18n
    function checkI18nBundle(i18nPath, res) {
        if (!fs.existsSync(i18nPath)) return;
        const content = fs.readFileSync(i18nPath, 'utf-8');
        const declaredKeys = new Set();
        content.split('\n').forEach(line => {
            const trimmed = line.trim();
            if (trimmed.startsWith('#') || trimmed === '') return;
            const match = trimmed.match(/^([A-Za-z0-9_.]+)\s*=/);
            if (match) declaredKeys.add(match[1]);
        });

        // Verificar que las claves usadas en vistas existan en i18n
        referencedI18nKeys.forEach(k => {
            if (!declaredKeys.has(k)) {
                res.errors.push(`[i18n] Clave '{i18n>${k}}' referenciada en vistas pero inexistente en '${path.basename(i18nPath)}'.`);
            }
        });
    }

    // Escanear ficheros del proyecto
    const allFiles = scanFilesRecursively(appFolderPath, null, ['node_modules', 'dist', '.git']);
    allFiles.forEach(file => {
        const lowerName = path.basename(file).toLowerCase();
        if (lowerName === 'component.js') {
            checkController(file, results);
            checkComponentJs(file, results);
        } else if (lowerName.endsWith('.controller.js') || lowerName.endsWith('.controller.ts')) {
            checkController(file, results);
        } else if (lowerName.endsWith('.view.xml') || lowerName.endsWith('.fragment.xml')) {
            checkXml(file, results);
        } else if (lowerName === 'manifest.json') {
            manifestFound = true;
            checkManifestJson(file, results);
        } else if (lowerName.endsWith('.html')) {
            checkIndexHtml(file, results);
        } else if (lowerName === 'init.js') {
            checkInitJs(file, results);
        } else if (lowerName === 'i18n.properties') {
            i18nPropertiesPath = file;
        }
    });

    if (i18nPropertiesPath) {
        checkI18nBundle(i18nPropertiesPath, results);
    }

    if (!manifestFound) {
        results.warnings.push(`No se encontró 'manifest.json' en ${appFolderPath}.`);
    }

    // 6. Auditoría de MockServer (localService/)
    const localServicePath = path.join(appFolderPath, 'localService');
    const webappLocalService = path.join(appFolderPath, 'webapp', 'localService');
    if (!fs.existsSync(localServicePath) && !fs.existsSync(webappLocalService)) {
        results.warnings.push(`No se encontró directorio 'localService/' para mock data en pruebas locales offline.`);
    }

    // 7. Auditoría de Dependencias y Tooling en package.json
    function checkPackageJson(pkgPath, res) {
        const pkg = readJsonSafe(pkgPath, null);
        if (!pkg) {
            res.warnings.push(`[package.json] No se pudo parsear el archivo package.json.`);
            return;
        }
        const allDeps = Object.assign({}, pkg.dependencies || {}, pkg.devDependencies || {});
        
        if (allDeps['@ui5/cli']) {
            const ui5CliVer = allDeps['@ui5/cli'];
            const majorMatch = ui5CliVer.match(/\^?~?(\d+)/);
            if (majorMatch && parseInt(majorMatch[1], 10) < 4) {
                res.errors.push(`[package.json] Versión obsoleta de '@ui5/cli' (${ui5CliVer}). La directriz técnica exige @ui5/cli ^4.0.0 o superior.`);
            }
        }

        if (allDeps['@sap/ux-ui5-tooling']) {
            const uxToolingVer = allDeps['@sap/ux-ui5-tooling'];
            const majorMatch = uxToolingVer.match(/\^?~?(\d+)\.(\d+)/);
            if (majorMatch) {
                const major = parseInt(majorMatch[1], 10);
                const minor = parseInt(majorMatch[2], 10);
                if (major < 1 || (major === 1 && minor < 30)) {
                    res.warnings.push(`[package.json] Se recomienda actualizar '@sap/ux-ui5-tooling' (${uxToolingVer}) a la versión estable actual (^1.30.0).`);
                }
            }
        }
    }

    // 8. Auditoría de Configuración UI5 Tooling (ui5.yaml / ui5-mock.yaml)
    function checkUi5Yaml(yamlPath, res) {
        try {
            const fileName = path.basename(yamlPath);
            const content = fs.readFileSync(yamlPath, 'utf-8');
            const lines = content.split('\n');

            if (/ignoreCertError\s*:/i.test(content) && !/ignoreCertErrors\s*:/i.test(content)) {
                res.warnings.push(`[${fileName}] La propiedad 'ignoreCertError' está obsoleta. Use 'ignoreCertErrors' (en plural).`);
            }

            if (content.includes('sap-fe-mockserver') && /\bxmlPath\s*:/i.test(content)) {
                res.errors.push(`[${fileName}] En 'sap-fe-mockserver', la propiedad de anotaciones 'xmlPath' no es válida en versiones modernas. Debe usarse 'localPath'.`);
            }

            const declaredMiddlewares = new Set(['compression']);
            const referencedMiddlewares = [];

            let currentMwName = null;
            lines.forEach((line, idx) => {
                const mwMatch = line.match(/^\s*-\s*name\s*:\s*([^\s#]+)/);
                if (mwMatch) {
                    currentMwName = mwMatch[1];
                    declaredMiddlewares.add(currentMwName);
                }

                const beforeMatch = line.match(/^\s*beforeMiddleware\s*:\s*([^\s#]+)/);
                if (beforeMatch) {
                    referencedMiddlewares.push({ from: currentMwName, target: beforeMatch[1], line: idx + 1 });
                }

                const afterMatch = line.match(/^\s*afterMiddleware\s*:\s*([^\s#]+)/);
                if (afterMatch) {
                    referencedMiddlewares.push({ from: currentMwName, target: afterMatch[1], line: idx + 1 });
                }
            });

            referencedMiddlewares.forEach(ref => {
                if (!declaredMiddlewares.has(ref.target)) {
                    res.errors.push(`[${fileName}:L${ref.line}] Error en cadena de middlewares: '${ref.from}' referencia '${ref.target}', pero '${ref.target}' no está declarado en customMiddleware.`);
                }
            });

        } catch (e) {
            res.warnings.push(`[${path.basename(yamlPath)}] Error al auditar fichero YAML (${e.message}).`);
        }
    }

    const yamlFiles = scanFilesRecursively(appFolderPath, name => /^ui5.*\.ya?ml$/i.test(name), ['node_modules', 'dist', '.git']);
    yamlFiles.forEach(yf => checkUi5Yaml(yf, results));

    const pkgInApp = path.join(appFolderPath, 'package.json');
    const pkgInParent = path.join(path.dirname(appFolderPath), 'package.json');
    if (fs.existsSync(pkgInApp)) {
        checkPackageJson(pkgInApp, results);
    } else if (fs.existsSync(pkgInParent)) {
        checkPackageJson(pkgInParent, results);
    }

    if (results.errors.length > 0) {
        results.passed = false;
    }

    return results;
}

if (require.main === module) {
    const targetFolder = process.argv[2];
    if (!targetFolder) {
        console.log("Uso: node check-fiori-clean-code-quality.js <path-to-app-folder>");
        process.exit(1);
    }
    const res = checkFioriQuality(targetFolder);
    console.log(JSON.stringify(res, null, 2));
    process.exit(res.passed ? 0 : 1);
}

module.exports = { checkFioriQuality };
