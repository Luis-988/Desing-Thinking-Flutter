# Reporte temporal de cambios del proyecto

> Documento de continuidad para el equipo y para futuras sesiones con IA.  
> Este archivo es temporal y puede eliminarse cuando todos los integrantes hayan incorporado el contexto.

## 1. Información general

- Proyecto: `Desing-Thinking-Flutter`
- Aplicación Flutter: `Desarrollo`
- Tecnología: Flutter / Dart
- Flutter validado: `3.47.1`
- Dart validado: `3.13.1`
- Sistema operativo usado durante la validación: Windows
- Archivo de entrada: `Desarrollo/lib/main.dart`
- Backend utilizado: Roble
- Arquitectura: separación por capas `core`, `data`, `domain` y `presentation`
- Inyección de dependencias: manual, centralizada en `lib/core/di/injection.dart`

## 2. Advertencia importante sobre el estado del repositorio

El repositorio ya tenía muchos cambios locales antes de las últimas modificaciones. No se deben ejecutar comandos destructivos ni revertir archivos sin revisar primero el trabajo de los demás integrantes.

Antes de modificar algo:

```powershell
cd "C:\Users\luis9\OneDrive\Documentos\1.Universidad\Programación\Desing-Thinking-Flutter"
git status --short
```

No utilizar sin autorización:

```text
git reset --hard
git checkout -- .
git clean -fd
```

El archivo `pubspec.lock` también tiene cambios locales. Debe conservarse salvo que el equipo acuerde actualizar dependencias.

## 3. Dependencias actuales

Archivo: `Desarrollo/pubspec.yaml`

Dependencias directas:

```yaml
cupertino_icons: ^1.0.8
roble: ^1.12.0
provider: ^6.1.5
google_fonts: ^6.3.0
```

Dependencia de desarrollo:

```yaml
flutter_lints: ^6.0.0
```

Versiones importantes resueltas:

| Paquete | Versión |
|---|---:|
| `roble` | `1.12.0` |
| `provider` | `6.1.5+1` |
| `google_fonts` | `6.3.3` |
| `cupertino_icons` | `1.0.9` |
| `socket_io_client` | `3.1.6` |
| `socket_io_common` | `3.1.1` |
| `flutter_secure_storage` | `10.3.4` |

`roble` utiliza dependencias transitivas relacionadas con Socket.IO, almacenamiento seguro, autenticación y Web.

### Estado de las dependencias

`flutter pub get` termina correctamente:

```text
Got dependencies!
```

No faltan paquetes y no existe actualmente un conflicto de versiones que impida ejecutar o compilar la aplicación.

No actualizar paquetes mayores automáticamente. Las versiones actuales ya fueron validadas con Flutter `3.47.1` y Dart `3.13.1`.

## 4. Configuración de Roble

Archivo: `Desarrollo/lib/core/network/roble_client.dart`

Configuración vigente:

```dart
static const String baseUrl =
    'https://roble-api.test-openlab.uninorte.edu.co';
static const String contractId =
    'flut_innovation_hub_77a7800a82';
```

No modificar `baseUrl` ni `contractId` sin confirmar el contrato real del equipo.

El manejo centralizado de errores se encuentra en:

```text
Desarrollo/lib/core/network/roble_guard.dart
```

Traduce errores de red, HTTP `401`, HTTP `403` y errores generales de Roble a `AppException`.

## 5. Arquitectura actual

### Core

Ubicación: `Desarrollo/lib/core/`

Incluye:

- `di/injection.dart`: inyección manual de repositorios, casos de uso y controladores.
- `network/roble_client.dart`: cliente único de Roble.
- `network/roble_guard.dart`: traducción de errores.
- `error/app_exception.dart`: error de aplicación.
- `theme/app_colors.dart`: paleta visual.
- `theme/app_theme.dart`: tema global.
- `theme/app_text_styles.dart`: estilos tipográficos.
- `widgets/app_tag.dart`: etiquetas de categorías, estados y roles.
- `widgets/screen_header.dart`: cabecera reutilizable.
- `widgets/initials_avatar.dart`: avatar con iniciales.
- `widgets/state_views.dart`: estados de carga, error y vacío.
- `utils/`: utilidades de presentación.

### Auth

Ubicación: `Desarrollo/lib/features/auth/`

Incluye:

- Login.
- Registro.
- Restauración de sesión.
- Cierre de sesión.
- Perfil de usuario.
- `SessionController` como `ChangeNotifier`.

### Initiatives

Ubicación: `Desarrollo/lib/features/initiatives/`

Incluye:

- Modelos y entidades de iniciativas.
- Repositorio remoto.
- Casos de uso.
- Controlador de estado.
- Publicación, edición y eliminación.
- Detalle de iniciativa.
- Postulaciones.
- Guardados.
- Mis iniciativas.
- Explorar.
- Componentes visuales de tarjetas y estados.

### Home

Ubicación: `Desarrollo/lib/features/home/`

Incluye:

- `HomeShell`: navegación inferior.
- `HomeTab`: pantalla Inicio.
- `HomeTabController`: cambio de pestañas.

## 6. Cambios funcionales implementados

### 6.1 Inicio de sesión y carga inicial

En `main.dart`:

- Se inicializa `Injection`.
- Se crea `SessionController`.
- Se restaura la sesión al iniciar.
- Se crea `InitiativesController` mediante `ChangeNotifierProxyProvider`.
- La carga de iniciativas se sincroniza con el estado de sesión.

### 6.2 Navegación principal

`HomeShell` contiene cinco pestañas:

1. Inicio.
2. Explorar.
3. Mis iniciativas.
4. Guardados.
5. Perfil.

### 6.3 Explorar sin botón de publicar

Archivo:

```text
Desarrollo/lib/features/initiatives/presentation/pages/explore_page.dart
```

La pestaña Explorar no debe utilizarse para publicar proyectos. Se eliminó el botón `+` de publicar.

La publicación sigue disponible desde las áreas destinadas al propietario, como:

- Mis iniciativas.
- Acciones de propietario.
- Flujo específico de publicación.

Explorar está enfocada en:

- Buscar iniciativas.
- Filtrar iniciativas.
- Ordenar resultados.
- Revisar tarjetas.
- Abrir el detalle.

### 6.4 Filtros de Explorar

Los filtros se muestran mediante un `BottomSheet`.

Categorías:

- Se utilizan como piloto para intereses y tipos de proyecto.
- Se obtienen de `initiative.categories`.

Roles:

- Se obtienen dinámicamente de `initiative.roles`.

El controlador expone:

```dart
categoryOptions
roleOptions
filterOptions
```

La búsqueda revisa:

- Título.
- Descripción.
- Líder.
- Categorías.
- Roles.

### 6.5 Ordenamiento de Explorar

Archivo:

```text
Desarrollo/lib/features/initiatives/presentation/providers/initiatives_controller.dart
```

Enum actual:

```dart
enum InitiativeSort {
  recent,
  popular,
  availableSlots,
}
```

Opciones visibles:

- Más recientes.
- Más populares.
- Más plazas disponibles.

El ordenamiento ocurre en memoria y no modifica Roble.

### 6.6 Iniciativas activas

Explorar utiliza `activeInitiatives`, por lo que no muestra iniciativas inactivas.

### 6.7 Guardados

Existe `BookmarkButton` para guardar o quitar una iniciativa.

El estado actual de guardados vive en memoria:

```text
Desarrollo/lib/features/initiatives/presentation/widgets/bookmark_button.dart
```

No hay persistencia de guardados en Roble todavía.

### 6.8 Recomendaciones

El controlador expone:

```dart
recommendedInitiatives
```

La recomendación actual es una heurística sencilla basada en:

- Iniciativa popular.
- Existencia de plazas abiertas.
- Estado activo.

No es todavía un sistema personalizado por intereses guardados del usuario. No se debe presentar como inteligencia artificial o recomendación avanzada.

### 6.9 Inicio con recomendaciones colapsables

Archivo:

```text
Desarrollo/lib/features/home/presentation/pages/home_tab.dart
```

Para evitar sobrecargar la pantalla Inicio, las recomendaciones se muestran dentro de un `ExpansionTile` cerrado inicialmente:

```text
Descubre proyectos para ti
Recomendaciones con oportunidades abiertas
```

Al abrirlo:

- Se muestran tarjetas compactas en scroll horizontal.
- El usuario decide si quiere explorar las recomendaciones.
- El contenido normal del Inicio continúa después.

El orden general del Inicio incluye:

1. Encabezado.
2. Hero principal.
3. Métricas.
4. Recomendaciones colapsables.
5. Más populares.
6. Roles más buscados.
7. Recién publicadas.

### 6.10 Tarjetas de iniciativas

Archivo:

```text
Desarrollo/lib/features/initiatives/presentation/widgets/initiative_card.dart
```

Las tarjetas muestran:

- Popularidad.
- Si es propia.
- Estado activa.
- Líder con avatar de iniciales.
- Categorías.
- Descripción.
- Visitas.
- Plazas abiertas.
- Roles disponibles.
- Guardado.
- Botón para ver la iniciativa.

También se añadió:

- `ÚLTIMA PLAZA` cuando queda una plaza disponible.
- `Buscando equipo` cuando existen plazas.
- `Equipo completo` cuando no existen plazas.

### 6.11 Detalle de iniciativa

Archivo:

```text
Desarrollo/lib/features/initiatives/presentation/pages/initiative_detail_page.dart
```

Incluye:

- Título.
- Categorías.
- Estado.
- Popularidad.
- Líder.
- Estadísticas.
- Descripción.
- Roles y vacantes.
- Guardado.
- Registro de visitas.
- Acceso al perfil del líder.

### 6.12 Logo de Innovation Hub

El logo completo original se tomó como referencia, pero actualmente se utiliza solo el símbolo azul.

Asset vigente:

```text
Desarrollo/assets/images/innovation_hub_mark.png
```

El asset muestra únicamente el símbolo azul, sin las letras `Innovation Hub`.

Se registró en:

```text
Desarrollo/pubspec.yaml
```

En `HomeTab`, `ScreenHeader` recibe:

```dart
logoAsset: 'assets/images/innovation_hub_mark.png'
```

El logo aparece solamente en la cabecera de Inicio.

Las demás pestañas conservan sus íconos:

- Explorar.
- Mis iniciativas.
- Guardados.
- Perfil.

`ScreenHeader` mantiene el parámetro opcional `logoAsset`; si no se envía, muestra el ícono tradicional.

## 7. Componentes visuales relevantes

### Paleta

Archivo:

```text
Desarrollo/lib/core/theme/app_colors.dart
```

Colores principales:

- Navy institucional.
- Navy oscuro.
- Naranja de acento.
- Fondo gris claro.
- Blanco de superficies.
- Verde para éxito.
- Amarillo para advertencias.
- Rojo para errores.
- Azul informativo.
- Violeta para roles.

### AppTag

Archivo:

```text
Desarrollo/lib/core/widgets/app_tag.dart
```

Variantes disponibles:

```dart
AppTag(...)
AppTag.success(...)
AppTag.warning(...)
AppTag.danger(...)
AppTag.info(...)
AppTag.violet(...)
AppTag.accent(...)
```

Usar este componente antes de crear nuevas etiquetas visuales.

### ScreenHeader

Archivo:

```text
Desarrollo/lib/core/widgets/screen_header.dart
```

Parámetros:

```dart
icon
title
subtitle
trailing
logoAsset
```

No duplicar cabeceras manualmente si la pantalla puede reutilizar este componente.

## 8. Alcance excluido intencionalmente

No implementar por ahora:

- Notificaciones push.
- Notificaciones internas.
- Subida de archivos.
- Descarga de archivos.
- Control documental.
- Portafolios adjuntos.
- Gestión de evidencias.
- Compartir archivos.
- Mensajería entre estudiantes.
- Nuevas dependencias para archivos o notificaciones.

Estas funcionalidades pueden quedar para una fase futura, pero no deben introducirse como parte de cambios visuales actuales.

## 9. Campos que todavía no existen

La entidad `Initiative` actualmente contiene:

- `id`
- `title`
- `categories`
- `description`
- `leader`
- `isPopularManually`
- `isActive`
- `roles`
- `views`
- `isMine`

No existe un campo independiente `projectType`.

Por eso, el piloto utiliza `categories` para representar:

- Intereses.
- Tipos de proyecto.

Si en el futuro se necesita distinguirlos, habrá que actualizar coherentemente:

1. Entidad de dominio.
2. Modelo JSON.
3. Data source.
4. Repositorio.
5. Formulario de publicación.
6. Filtros.
7. Pruebas.
8. Estructura de Roble.

No agregar un campo aislado solo en la UI.

## 10. Pruebas existentes

Archivo:

```text
Desarrollo/test/widget_test.dart
```

Las pruebas utilizan repositorios falsos:

- `FakeAuthRepository`
- `FakeInitiativeRepository`

Esto permite probar sin depender de internet ni de Roble.

La prueba de UI verifica:

- Navegación inferior.
- Inicio.
- Explorar.
- Carga de iniciativas.
- Filtros.
- Guardados.
- Postulaciones.
- Vistas.
- Errores.

## 11. Validaciones realizadas

### Dependencias

```powershell
cd "C:\Users\luis9\OneDrive\Documentos\1.Universidad\Programación\Desing-Thinking-Flutter\Desarrollo"
flutter pub get
```

Resultado esperado:

```text
Got dependencies!
```

### Análisis

```powershell
dart analyze --format=machine
```

Resultado actual:

- Sin errores de compilación.
- Existen lints de estilo preexistentes:
  - `USE_NULL_AWARE_ELEMENTS`
  - `PREFER_INITIALIZING_FORMALS`

No confundir estos lints con errores de paquetes.

### Pruebas

```powershell
flutter test test/widget_test.dart
```

Último resultado validado:

```text
13 pruebas aprobadas
0 pruebas fallidas
```

### Compilación Web

```powershell
flutter build web
```

Último resultado validado:

```text
√ Built build\web
```

## 12. Advertencia WASM conocida

Durante `flutter build web` aparece un aviso relacionado con:

```text
socket_io_common-3.1.1
invalid_runtime_check_with_js_interop_types
```

Interpretación:

- Es una incompatibilidad detectada durante la comprobación experimental de WebAssembly.
- Proviene de una dependencia transitiva de `roble`.
- No impide la compilación Web normal.
- No modificar archivos dentro de la caché global de Pub.
- No reemplazar Roble ni Socket.IO sin una decisión del equipo.

La salida final de compilación JavaScript continúa siendo correcta.

## 13. Problema de entorno Android conocido

`flutter doctor -v` indicó:

```text
Android license status unknown
```

Acción local:

```powershell
flutter doctor --android-licenses
```

Esto no está relacionado con los errores de Dart, Roble, las pruebas de UI ni el logo.

## 14. Procedimiento recomendado antes de continuar

1. Revisar el estado del repositorio:

```powershell
git status --short
```

2. Leer los archivos relacionados antes de editar:

```text
lib/main.dart
lib/core/di/injection.dart
lib/core/network/roble_client.dart
lib/core/widgets/screen_header.dart
lib/features/home/presentation/pages/home_tab.dart
lib/features/home/presentation/pages/home_shell.dart
lib/features/initiatives/presentation/pages/explore_page.dart
lib/features/initiatives/presentation/providers/initiatives_controller.dart
lib/features/initiatives/presentation/widgets/initiative_card.dart
lib/features/initiatives/domain/entities/initiative.dart
test/widget_test.dart
```

3. Mantener la inyección falsa de los tests.
4. No conectar la UI directamente con Roble.
5. Reutilizar los componentes existentes.
6. Ejecutar formato Dart en cada archivo Dart modificado.
7. Ejecutar análisis y pruebas después de cada cambio coherente.
8. Ejecutar compilación Web si se modifican assets, dependencias o estructura global.

## 15. Comandos de validación completos

```powershell
cd "C:\Users\luis9\OneDrive\Documentos\1.Universidad\Programación\Desing-Thinking-Flutter\Desarrollo"
flutter pub get
dart analyze --format=machine
flutter test test/widget_test.dart
flutter build web
```

Resultado esperado:

- Dependencias resueltas.
- Sin errores de compilación.
- 13 pruebas aprobadas.
- Build Web generado.

## 16. Recomendaciones para futuras mejoras

Orden recomendado:

1. Corregir lints de estilo sin alterar comportamiento.
2. Añadir pruebas específicas para ordenamiento.
3. Añadir pruebas para filtros por categoría y rol.
4. Añadir pruebas para el panel colapsable de recomendaciones.
5. Añadir intereses persistentes del usuario, si el equipo lo decide.
6. Reemplazar la heurística de recomendaciones por una estrategia basada en intereses.
7. Persistir guardados si se necesita mantenerlos entre sesiones.
8. Revisar accesibilidad, tamaños de texto y contraste.
9. Revisar comportamiento en pantallas pequeñas.

## 17. Regla de continuidad

El siguiente integrante o IA debe:

- Preservar los cambios locales existentes.
- No asumir que un aviso de una dependencia es un error de la aplicación.
- No introducir notificaciones ni archivos en esta fase.
- No actualizar dependencias mayores como solución automática.
- No duplicar componentes ya existentes.
- Añadir o actualizar pruebas cuando cambie el comportamiento.
- Reportar claramente qué archivos modificó y qué validaciones ejecutó.

