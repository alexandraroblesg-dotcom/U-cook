# U-Cook — Aplicación Móvil (iOS & Android)
**Proyecto Académico · Universidad del Norte, Barranquilla**

U-Cook acompaña a estudiantes foráneos en la gestión cotidiana de su alimentación, reduciendo la carga mental de decidir qué comer, qué comprar y cuánto gastar.

---

## 📱 Estructura de la Aplicación

La aplicación implementa con fidelidad la navegación fija de **4 pestañas** requeridas por el Prompt Maestro y la Guía de Construcción:

1. **Inicio (`/home`)**:
   - Saludo con nombre del usuario.
   - Tarjeta visible y prioritaria **"¿Qué vas a comer hoy?"** con acceso a planificar.
   - Atajos directos a **Historial de gastos** y **Escáner nutricional**.
   - Resumen del presupuesto disponible en COP con barra de consumo.
2. **Comida (`/food`)**:
   - Selector semanal horizontal.
   - Bloque visible **Menú de hoy**.
   - Filtros de tiempo de preparación (*Menos de 15m*, *20 a 30m*, *Más de 40m*).
   - Catálogo curado de recetas colombianas en JSON local (`assets/data/recipes.json`).
   - Detalle de receta con selección de ingredientes y acción **"Enviar faltantes a Compras"**.
3. **Compras (`/shopping`)**:
   - 3 pestañas: *Todos*, *Pendientes* y *Comprados*.
   - Checkbox con un solo toque y contadores sincronizados.
   - Deslizamiento para borrar con opción *Deshacer*.
   - Agrupación de ingredientes que provienen de las recetas.
4. **Gastos (`/expenses`)**:
   - Presupuesto editable por periodo (*Semanal*, *Quincenal*, *Mensual*).
   - Cálculo exacto en pesos colombianos en enteros (`NumberFormat.currency`).
   - Separación entre *Alimentación* y *Otros gastos*.
   - Tono calmado y neutro si se agota el presupuesto (sin alertas rojas culpabilizadoras).
5. **Escáner Nutricional (`/scanner`)**:
   - Cámara con `mobile_scanner` y permiso contextual con descripción en español.
   - Conexión a la base de datos abierta de **Open Food Facts**.
   - 4 estados claros: *leyendo*, *consultando*, *producto encontrado*, *producto no encontrado*.
   - Manejo ético de datos: **no se inventa información nutricional**.
   - Botón directo para agregar el producto a la lista de compras.
6. **Onboarding (`/onboarding`)**:
   - 3 pasos breves (Nombre y comensales, Objetivos, Presupuesto y frecuencia).
   - Opción de omitir y persistencia de `onboarding_done` para no repetirse.

---

## 🎨 Identidad Visual

| Color | Hex | Uso |
|---|---|---|
| **Verde oliva** | `#667A5A` | Identidad, encabezados y botones principales |
| **Crema** | `#F7F3E8` | Fondo base de todas las pantallas |
| **Amarillo** | `#E8C85A` | Acentos, botones secundarios y destacados |
| **Coral** | `#D9826B` | Avisos suaves e ilustraciones sin culpabilizar |
| **Azul noche** | `#263238` | Texto principal legible y contraste accesible |

---

## 🚀 Cómo Ejecutar en Local

```bash
# 1. Instalar dependencias
flutter pub get

# 2. Ejecutar análisis estático y pruebas unitarias
flutter analyze
flutter test

# 3. Ejecutar en dispositivo o navegador
flutter run
```

---

## 🍎 Compilación y Despliegue en iPhone (iOS)

Dado que el desarrollo se realiza en Windows, se proporcionan dos caminos certificados por la guía:

### Ruta 1: Compilación Automática en la Nube con Codemagic (Sin Mac físico)
El archivo `codemagic.yaml` ya se encuentra configurado en la raíz del proyecto.
1. Sube el repositorio a GitHub o GitLab.
2. Inicia sesión en [codemagic.io](https://codemagic.io) con tu cuenta de Git.
3. Vincula el proyecto `ucook`. Codemagic detectará automáticamente `codemagic.yaml`.
4. En **Environment Variables**, vincula tu clave de API de **App Store Connect** (`App Store Connect API key`).
5. Ejecuta el workflow `ios-testflight`. Codemagic compilará en un Mac M2 en la nube, firmará el IPA y lo enviará a **TestFlight**.

### Ruta 2: Compilación en un Mac con Xcode
1. Clona el proyecto en una Mac.
2. Abre la carpeta `ios` en Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
3. En **Signing & Capabilities**, selecciona tu **Team** de Apple y activa *Automatically manage signing*.
4. Conecta el iPhone y corre:
   ```bash
   flutter run -d <id-del-iphone>
   ```
5. Para generar el instalable IPA:
   ```bash
   flutter build ipa --release
   ```

---

## 📋 Verificación Técnica iOS Incluida
- **Permisos de Cámara**: Configurados en `ios/Runner/Info.plist` con texto descriptivo en español.
- **Export Compliance**: `<key>ITSAppUsesNonExemptEncryption</key><false/>` declarado para subidas limpias sin advertencias en TestFlight.
- **Manifiesto de Privacidad de Apple**: `ios/Runner/PrivacyInfo.xcprivacy` configurado con razón `CA92.1` para almacenamiento de preferencias.
- **Versión mínima de iOS**: Fijada en iOS 13.0 en `Podfile`.
