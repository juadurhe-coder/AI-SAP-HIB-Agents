# DIRECTRICES TÉCNICAS (TECHNICAL GUIDELINES)

## 1. ENFOQUE "CLEAN CORE"
Todos los desarrollos técnicos, diseños y arquitecturas deben regirse por el principio estricto de Clean Core, salvaguardando la integridad del S/4HANA.
- Quedan estrictamente prohibidas las modificaciones directas a objetos estándar SAP o al core transaccional (Keep it Mod-Free).
- No se deben prescribir ampliaciones invasivas e implícitas (ej. Implicit Enhancements en código estándar) si existen BAdIs modernas u opciones side-by-side.

## 2. PRIORIDADES TECNOLÓGICAS
- SAP BTP (Business Technology Platform): Base indispensable para desarrollar extensiones complejas (side-by-side) e integraciones (Integration Suite).
- APIs Estándar: Priorizar en todo momento el uso de whitelisted APIs de SAP (REST/OData) para la comunicación transaccional hacia el backend.
- ABAP Cloud & RAP: Todos los nuevos desarrollos en el entorno on-Stack deben usar el modelo RAP (RESTful ABAP Programming Model) y el esquema ABAP Cloud. Se rechazarán outputs con legacy statements antiguos de ABAP clásico que no sean Cloud-ready.
- CDS Views: Uso primordial de Core Data Services (VDM - Virtual Data Model) para el modelado de datos y analíticas.

## 3. CONVENCIONES DE NOMENCLATURA (NAMING CONVENTIONS)
Todo desarrollo customizado, modelado y configuración debe obedecer los namespaces designados para clientes:
- Utilizar prefijos `Z*` o `Y*` para objetos del diccionario de datos (DDIC), clases (`ZCL_*`, `ZCX_*`), programas, interfaces CDS (`ZI_*`, `ZC_*`), roles, etc.
