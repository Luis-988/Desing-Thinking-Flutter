# Sistema de Innovación Uninorte (Flutter)

App móvil del proyecto de Design Thinking. El backend es **Roble** (proyecto `flut_innovation_hub_77a7800a82`).

## Cómo correrla

1. En Windows, activa el **Modo de desarrollador** (`Windows + R` → `ms-settings:developers`).
2. `flutter pub get`
3. `flutter run -d chrome` (o F5 en VS Code eligiendo Chrome).

## Arquitectura limpia

El código está organizado **por funcionalidad** (`features/`) y, dentro de cada una, **por capas**:

```
lib/
├── main.dart                     # Arranque: Injection.init() y sesión guardada
├── core/                         # Lo compartido por todas las features
│   ├── di/injection.dart         # Inyección de dependencias (arma data → domain)
│   ├── network/roble_client.dart # Conexión única a Roble (URL y contrato)
│   └── theme/app_theme.dart      # Colores y tema
└── features/
    ├── auth/                     # Registro, login, sesión y perfil
    │   ├── domain/               # Reglas del negocio, sin Flutter ni Roble
    │   │   ├── entities/         # ProfileUser, AuthResult
    │   │   ├── repositories/     # AuthRepository (contrato abstracto)
    │   │   └── usecases/         # LoginUser, RegisterUser, LogoutUser, RestoreSession
    │   ├── data/                 # Cómo se obtienen los datos
    │   │   ├── datasources/      # AuthRemoteDataSource (habla con Roble)
    │   │   ├── models/           # ProfileUserModel (Roble → entidad)
    │   │   └── repositories/     # AuthRepositoryImpl (implementa el contrato)
    │   └── presentation/pages/   # ProfilePage, AuthPage
    └── initiatives/              # Iniciativas y postulaciones
        ├── domain/
        │   ├── entities/         # Initiative, InitiativeRole, InitiativeApplication
        │   ├── repositories/     # InitiativeRepository (contrato abstracto)
        │   └── usecases/         # GetInitiatives, CreateInitiative, SubmitApplication…
        ├── data/
        │   ├── datasources/      # InitiativeRemoteDataSource (tablas de Roble)
        │   ├── models/           # InitiativeModel, InitiativeApplicationModel
        │   └── repositories/     # InitiativeRepositoryImpl
        └── presentation/pages/   # FeedPage, InitiativeDetailPage, ApplyInitiativePage, PublishInitiativePage
```

**Regla de dependencias:** `presentation → domain ← data`.

- `domain` no importa nada de `data` ni de `presentation`.
- Las pantallas solo llaman casos de uso a través de `Injection`.
- Solo los `datasources` conocen el paquete `roble`.

Para cambiar de backend basta con una nueva implementación del repositorio. Las pruebas (`test/widget_test.dart`) usan repositorios falsos en memoria con `Injection.init(...)`.

## Tablas en Roble

Proyecto `flut_innovation_hub_77a7800a82`. Todas las columnas son `text` salvo que se indique otro tipo. Roble agrega `_id` (uuid) y `_owner` (usuario que creó la fila) a cada tabla.

| Tabla | Columnas | Uso en la app |
|---|---|---|
| `iniciativas` (pública) | titulo, descripcion, categorias (JSON), lider, vacantes (JSON), visitas (int), popular_manual (bool), activa (bool) | Explorar, publicar y editar iniciativas |
| `postulaciones` | iniciativa_id, nombre, programa, semestre, vacante, habilidades, mensaje, estado | Postularse; el líder acepta o rechaza |
| `iniciativas_guardadas` | iniciativa_id | Guardados de cada usuario (la app filtra con `isMine`) |
| `sprints` | iniciativa_id, nombre, objetivo, fecha_inicio, fecha_fin, estado, orden (int) | Sprints del espacio de trabajo |
| `feedback_sprints` | iniciativa_id, sprint_id, autor, texto, creado_en | Feedback por sprint |
| `mensajes_workspace` | iniciativa_id, autor, texto, creado_en | Chat del equipo |
| `comentarios_workspace` | iniciativa_id, autor, texto, creado_en | Comentarios del equipo |
| `miembros_workspace` | iniciativa_id, miembro_id, nombre, rol_nombre, rol, puede_gestionar_tareas (bool), puede_comentar (bool), puede_chatear (bool) | Integrantes del proyecto y sus permisos |
| `publicaciones_avance` | iniciativa_id, autor, titulo, texto, creado_en | Comunidad: avances publicados |
| `comentarios_publicacion` | publicacion_id, iniciativa_id, autor, texto, creado_en | Comunidad: comentarios a los avances |

Las fechas (`creado_en`, `fecha_inicio`, `fecha_fin`) se guardan como texto ISO 8601.

### Permisos del rol `user`

Quien se registra desde la app recibe el rol `user`. Además de `all:create`, `all:read` y `all:execute`, la app necesita:

- `iniciativas`: update, delete
- `postulaciones`: update (el líder cambia el estado de postulaciones de otros)
- `iniciativas_guardadas`: update, delete
- `sprints`: update, delete
- `miembros_workspace`: update (el líder ajusta los permisos de cada integrante)

Se configuran en la consola de Roble: Configuración → Roles → `user` → Seleccionar permiso → Asignar.

## Espacio de trabajo del proyecto

El líder puede abrir la ruta desde **Mis iniciativas** o desde la ficha de su iniciativa; los integrantes aceptados pueden abrirla desde la ficha. La ruta no incluye semanas ni entregables predefinidos: el líder crea, modifica y elimina actividades con fecha límite desde el calendario. Se agrupan automáticamente por semana (lunes a domingo). El líder y los integrantes aceptados pueden marcar cada actividad como realizada.

Las actividades se sincronizan en el árbol JSON de Roble, en `iniciativas/<id>/actividades`. El árbol crea la ruta al guardar la primera tarea, por lo que no se necesita crear una tabla ni una columna. Cada actividad usa una clave generada por Roble y se puede actualizar individualmente. Las actividades nuevas pueden incluir `sprint_id`; las antiguas siguen siendo válidas sin ese campo y se agrupan temporalmente por fecha. La política de acceso del árbol debe permitir lectura y cambios únicamente a los integrantes del equipo.

Los sprints se guardan en la tabla `sprints`. El progreso no se persiste como porcentaje: se calcula con las actividades completadas dentro del rango de fechas del sprint o asociadas mediante `sprint_id`.

## Espacio de trabajo y sincronización con Roble

La pantalla de trabajo del proyecto está organizada en tres vistas:

- **Detalles:** progreso calculado a partir de las actividades, objetivo actual,
  equipo y comentarios de feedback.
- **Sprints:** actividades agrupadas por periodo de fechas. No representa
  semanas numeradas ni fases predefinidas.
- **Chat:** comunicación interna del equipo.

Todo se guarda en Roble a través de `WorkspaceRepositoryImpl`:

| Recurso | Dónde se guarda |
|---|---|
| Actividades | árbol JSON `iniciativas/<id>/actividades` |
| Sprints | tabla `sprints` |
| Feedback de sprints | tabla `feedback_sprints` |
| Mensajes del chat | tabla `mensajes_workspace` |
| Comentarios del equipo | tabla `comentarios_workspace` |
| Miembros y permisos | tabla `miembros_workspace` |
| Publicaciones y sus comentarios | tablas `publicaciones_avance` y `comentarios_publicacion` |

`InMemoryWorkspaceRepository` queda solo para las pruebas.

El líder de la iniciativa es el administrador inicial. Al abrir el espacio de
trabajo, el líder y los integrantes aceptados que aún no estén en
`miembros_workspace` se agregan automáticamente. Los roles son líder,
administrador, colaborador y observador; el líder aparece protegido (no se
puede degradar ni eliminar desde la pantalla) y puede ajustar por miembro las
capacidades de gestionar tareas, comentar y participar en el chat.

Los guardados se persisten por usuario en `iniciativas_guardadas`. Una
iniciativa con cero plazas no se muestra como oportunidad en Inicio, pero
permanece en Explorar y Guardados con el estado **Proyecto lleno · Trabajo
iniciado** y sin permitir nuevas postulaciones.

## Plan de pruebas

| Nivel | Qué se prueba | Archivo | Cómo se corre |
|---|---|---|---|
| Unitarias | Reglas de postulación y plazas (`InitiativePolicy`) | `test/unit/initiative_policy_test.dart` | `flutter test test/unit` |
| Unitarias | Lectura de datos de Roble (`decodeJsonList`, `toBool`) | `test/unit/json_utils_test.dart` | `flutter test test/unit` |
| Widget | Etiqueta de estado de una postulación (`StatusPill`) | `test/widget/status_pill_test.dart` | `flutter test test/widget` |
| Widget y unitarias | Modelos, controlador de iniciativas, navegación, modo oscuro, actividades | `test/widget_test.dart`, `test/project_activities_test.dart` | `flutter test` |
| Integración | La app abre en Inicio y Explorar lista las iniciativas | `integration_test/app_test.dart` | `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d chrome` |

Las pruebas usan repositorios falsos en memoria, así que no dependen de Roble ni de internet.
GitHub Actions (`.github/workflows/main.yml`) corre todas las pruebas en cada push a `main` y en cada Pull Request.
