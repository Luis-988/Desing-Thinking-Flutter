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

## Espacio de trabajo del proyecto

Cuando todas las plazas de una iniciativa tienen integrantes aceptados, aparece la acción **Iniciar trabajo del proyecto** en **Mis iniciativas**. El espacio organiza los 12 entregables de las semanas 1 a 5 en formularios editables, muestra el equipo aceptado y guarda automáticamente el avance en el dispositivo mediante `shared_preferences`.

Los borradores no se sincronizan entre dispositivos ni se guardan en las tablas públicas de Roble; así, las notas de entrevistas y validación no quedan expuestas como parte de la ficha pública del proyecto.
