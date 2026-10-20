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

| Tabla | Columnas |
|---|---|
| `iniciativas` (pública) | titulo, descripcion, categorias (JSON), lider, vacantes (JSON), visitas, popular_manual, activa |
| `postulaciones` | iniciativa_id, nombre, programa, semestre, vacante, habilidades, mensaje, estado |
| `iniciativas_guardadas` | iniciativa_id |
| `sprints` | iniciativa_id, nombre, objetivo, fecha_inicio, fecha_fin, estado, orden |

## Espacio de trabajo del proyecto

El líder puede abrir la ruta desde **Mis iniciativas** o desde la ficha de su iniciativa; los integrantes aceptados pueden abrirla desde la ficha. La ruta no incluye semanas ni entregables predefinidos: el líder crea, modifica y elimina actividades con fecha límite desde el calendario. Se agrupan automáticamente por semana (lunes a domingo). El líder y los integrantes aceptados pueden marcar cada actividad como realizada.

Las actividades se sincronizan en el árbol JSON de Roble, en `iniciativas/<id>/actividades`. El árbol crea la ruta al guardar la primera tarea, por lo que no se necesita crear una tabla ni una columna. Cada actividad usa una clave generada por Roble y se puede actualizar individualmente. Las actividades nuevas pueden incluir `sprint_id`; las antiguas siguen siendo válidas sin ese campo y se agrupan temporalmente por fecha. La política de acceso del árbol debe permitir lectura y cambios únicamente a los integrantes del equipo.

Los sprints se guardan en la tabla `sprints`. El progreso no se persiste como porcentaje: se calcula con las actividades completadas dentro del rango de fechas del sprint o asociadas mediante `sprint_id`.

## Espacio de trabajo local y futura sincronización

La pantalla de trabajo del proyecto está organizada en tres vistas:

- **Detalles:** progreso calculado a partir de las actividades, objetivo actual,
  equipo y comentarios de feedback.
- **Sprints:** actividades agrupadas por periodo de fechas. No representa
  semanas numeradas ni fases predefinidas.
- **Chat:** comunicación interna del equipo.

Mientras se prepara la integración con Roble, chat y comentarios utilizan
`InMemoryWorkspaceRepository`, detrás del contrato
`WorkspaceRepository`. La UI y `WorkspaceController` no dependen de esa
implementación, por lo que podrá reemplazarse por un datasource remoto sin
cambiar las pantallas.

La estructura remota prevista es:

| Recurso | Identificador sugerido | Datos principales |
|---|---|---|
| Mensajes | `iniciativas/<id>/mensajes/<messageId>` | autor, texto, creado_en |
| Comentarios | `iniciativas/<id>/comentarios/<commentId>` | autor, texto, creado_en |
| Sprints | `iniciativas/<id>/sprints/<sprintId>` | nombre, objetivo, inicio, fin, estado |
| Miembros | `iniciativas/<id>/miembros/<userId>` | usuario, rol, permisos |

El líder de la iniciativa debe ser el administrador inicial. Los permisos
finales deben validarse en las reglas de Roble, no únicamente en la interfaz.
Los roles previstos son líder, administrador, colaborador y observador. En la
versión local, el creador aparece como líder protegido (no se puede degradar
ni eliminar desde la pantalla) y puede ajustar por miembro las capacidades de
gestionar tareas, comentar y participar en el chat. Esta misma estructura se
enviará después como `rol` y `permisos` al nodo de cada miembro en Roble.

Los guardados se persisten por usuario en `iniciativas_guardadas`. Una
iniciativa con cero plazas no se muestra como oportunidad en Inicio, pero
permanece en Explorar y Guardados con el estado **Proyecto lleno · Trabajo
iniciado** y sin permitir nuevas postulaciones.
