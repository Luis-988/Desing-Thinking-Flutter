# Reporte de implementación

## Proyecto

**Innovación Uninorte — Desing-Thinking-Flutter**

Este documento resume los ajustes arquitectónicos, funcionalidades de iniciativas, integración con Roble, experiencia de usuario, navegación y validaciones realizadas en la aplicación.

## 1. Arquitectura actual

La aplicación utiliza una estructura **feature-first** con separación por responsabilidades:

```text
lib/
├── core/
│   ├── di/                 # Inyección de dependencias
│   ├── error/              # Excepciones y mensajes de error
│   ├── network/            # Cliente y protección de Roble
│   ├── theme/              # Tema, colores y estilos
│   ├── utils/              # Utilidades compartidas
│   └── widgets/            # Componentes reutilizables
└── features/
    ├── auth/
    ├── home/
    └── initiatives/
        ├── data/
        ├── domain/
        └── presentation/
```

Dentro de cada funcionalidad se conservan tres capas:

- **Domain:** entidades, contratos de repositorios, políticas y casos de uso.
- **Data:** modelos, datasources y repositorios concretos.
- **Presentation:** páginas, widgets y controladores Provider.

La aplicación centraliza la construcción de dependencias en `AppDependencies`, conservando `Injection` para compatibilidad con pruebas y configuraciones existentes.

## 2. Mejoras arquitectónicas realizadas

- Se agregaron casos de uso para actividades de proyecto.
- Se separó el estado del catálogo de iniciativas en `InitiativeCatalogState`.
- Se incorporaron políticas de dominio para actividades e iniciativas.
- Se centralizó la transformación de errores de Roble en `AppException`.
- Se evitó que las pantallas accedan directamente a datasources.
- Se incorporó Provider como mecanismo uniforme para controlar el estado.
- Se corrigieron problemas de inicialización, incluido un `LateInitializationError`.
- Se mantuvieron repositorios abstractos para permitir reemplazar almacenamiento remoto por implementaciones locales en pruebas.
- Se separó el almacenamiento temporal del chat y de los comentarios internos respecto al almacenamiento público de avances.

## 3. Iniciativas y postulaciones

La aplicación permite:

- Explorar iniciativas activas.
- Buscar por nombre, categoría o rol.
- Filtrar y ordenar resultados.
- Guardar iniciativas para revisarlas después.
- Publicar, editar y eliminar iniciativas.
- Postularse a roles disponibles.
- Consultar postulaciones propias.
- Revisar postulaciones recibidas como líder.
- Aceptar o rechazar integrantes.
- Mostrar proyectos llenos sin presentarlos como oportunidades disponibles.
- Mostrar el estado visual:

```text
Proyecto lleno · Trabajo iniciado
```

El creador de una iniciativa puede abrir el espacio de trabajo desde **Mis iniciativas**, incluso si todavía existen cupos disponibles. Esto permite probar actividades, sprints y publicaciones sin tener que completar previamente todo el equipo.

## 4. Espacio de trabajo del proyecto

El espacio de trabajo se organiza en cuatro pestañas:

```text
Detalles | Sprints | Chat | Avances
```

### Detalles

- Resumen de la iniciativa.
- Progreso calculado a partir de actividades completadas.
- Comentarios internos del equipo.
- Gestión de integrantes.
- Roles de equipo:
  - Líder.
  - Administrador.
  - Colaborador.
  - Observador.

El creador conserva el rol de líder y sus permisos no pueden ser retirados accidentalmente.

### Sprints

Se implementaron:

- Entidad `ProjectSprint`.
- Estados `planned`, `active` y `completed`.
- Fechas de inicio y finalización.
- Objetivo del sprint.
- Orden de sprints.
- Repositorio, datasource y controlador.
- Creación de sprints desde el workspace.
- Relación opcional entre actividades y sprints.
- Compatibilidad con actividades antiguas que no tienen `sprint_id`.
- Cálculo de progreso por actividades.

### Chat y comentarios internos

El chat y los comentarios internos se mantienen actualmente en memoria mediante `InMemoryWorkspaceRepository`. Esta decisión evita repetir el error de Roble relacionado con `_owner` mientras se define una estrategia compatible de identidad.

### Feedback de sprints

Se agregó:

- Entidad `SprintFeedback`.
- Repositorio remoto.
- Datasource remoto.
- Controlador Provider.
- UI para escribir y consultar feedback asociado a un sprint.

## 5. Publicaciones de avance y comunidad

Se diferenciaron dos tipos de interacción:

### Interacción privada del equipo

- Chat.
- Comentarios internos.
- Gestión de miembros.
- Actividades y sprints.

### Interacción pública

- Avances de proyectos.
- Comentarios de la comunidad.
- Feed público de publicaciones.

Se creó la pantalla **Comunidad**, accesible desde la navegación principal. El feed muestra:

- Proyecto relacionado.
- Autor.
- Título del avance.
- Descripción.
- Comentarios.
- Acción para comentar.

El flujo esperado es:

```text
Líder publica avance
        ↓
Se guarda en Roble
        ↓
Se muestra en el workspace
        ↓
Aparece en Comunidad
        ↓
La comunidad puede comentar
```

Se implementaron los siguientes componentes:

- `PublicFeedRemoteDataSource`.
- `PublicFeedRepository`.
- `PublicFeedRepositoryImpl`.
- `PublicFeedController`.
- `CommunityFeedPage`.

El workspace utiliza el mismo repositorio público para crear y cargar avances, evitando que existan dos copias distintas de una publicación.

El feed se actualiza:

- Al abrir la sección Comunidad.
- Después de publicar un avance.
- Al usar el gesto de actualización.

## 6. Tablas nuevas esperadas en Roble

### `publicaciones_avance`

| Campo | Tipo recomendado | Observación |
|---|---|---|
| `_id` | Automático | Lo genera Roble |
| `iniciativa_id` | Texto | Identifica el proyecto |
| `autor` | Texto | Nombre visible del autor |
| `titulo` | Texto | Título del avance |
| `texto` | Texto | Contenido del avance |
| `creado_en` | Texto o fecha | Fecha de publicación |

### `comentarios_publicacion`

| Campo | Tipo recomendado | Observación |
|---|---|---|
| `_id` | Automático | Lo genera Roble |
| `publicacion_id` | Texto | Publicación comentada |
| `iniciativa_id` | Texto | Proyecto relacionado |
| `autor` | Texto | Nombre visible del autor |
| `texto` | Texto | Contenido del comentario |
| `creado_en` | Texto o fecha | Fecha del comentario |

### Índices recomendados

Los índices no son obligatorios para una primera prueba, pero se recomiendan:

```text
publicaciones_avance:
- iniciativa_id
- creado_en

comentarios_publicacion:
- publicacion_id
- iniciativa_id
- creado_en
```

Si Roble permite índices compuestos, se pueden usar:

```text
publicaciones_avance:
- iniciativa_id + creado_en

comentarios_publicacion:
- publicacion_id + creado_en
```

`iniciativa_id` y `publicacion_id` no deben ser únicos, porque una iniciativa puede tener varios avances y una publicación puede recibir varios comentarios.

## 7. Problema de `_owner` en Roble

Durante la integración del chat y los comentarios internos se recibió el siguiente error:

```text
Roble rechazó los datos (400): Tipos inválidos: _owner (esperado: bigint)
```

Se verificó que:

- `_id` debe seguir siendo generado automáticamente por Roble.
- La aplicación no debe enviar `_owner`.
- La propiedad de filas y los permisos `own` son conceptos independientes.
- Crear otro usuario o eliminar el proyecto no resuelve la incompatibilidad.

Por seguridad, el chat y los comentarios internos permanecen temporalmente en memoria. Las publicaciones públicas se separaron en tablas propias y se configuraron sin enviar `_owner`.

La integración pública requiere que en Roble existan las tablas y permisos correspondientes:

- `read` para publicaciones al rol autenticado.
- `create` para publicaciones al rol autorizado a publicar avances.
- `read` y `create` para comentarios públicos.
- `update` y `delete` desactivados inicialmente.

Si el feed aparece vacío después de publicar, se debe comprobar primero que:

1. Exista `publicaciones_avance`.
2. Los nombres de columnas coincidan exactamente.
3. El rol tenga permiso de lectura.
4. El rol que publica tenga permiso de creación.
5. La aplicación esté conectada al contrato correcto.

## 8. Navegación y experiencia móvil

La navegación inferior tenía demasiadas opciones para una pantalla móvil. Se reorganizó para mostrar únicamente las áreas de uso frecuente:

```text
Inicio | Explorar | Comunidad | Perfil
```

Las opciones secundarias se trasladaron al menú lateral clásico:

```text
☰
├── Mis iniciativas
├── Guardados
└── Perfil
```

El botón de menú se ubica en el extremo derecho de la cabecera azul:

```text
[Logo]   Título y subtítulo                         [☰]
```

También se corrigió un posible desbordamiento horizontal del encabezado en pantallas estrechas.

## 9. Manejo de sesión y tema

La aplicación conserva:

- Restauración de sesión.
- Inicio y cierre de sesión.
- Registro de usuarios.
- Protección de pantallas que requieren autenticación.
- Tema claro y oscuro.
- Persistencia de preferencias de tema.

## 10. Pruebas y validación

Las validaciones realizadas incluyen:

- Pruebas de entidades y modelos.
- Serialización de iniciativas, actividades y sprints.
- Políticas de permisos de actividades.
- Carga y filtrado de iniciativas.
- Postulaciones y aceptación de integrantes.
- Navegación principal.
- Apertura del espacio de trabajo.
- Acceso de integrantes aceptados.
- Cambio de tema.
- Menú lateral.
- Prevención de desbordamiento visual.

Resultado más reciente:

```text
flutter test
26 pruebas exitosas
```

También se validó previamente:

```text
flutter build web --no-wasm-dry-run
Compilación exitosa
```

Los diagnósticos Dart de los archivos modificados no reportan errores.

## 11. Cómo probar el flujo de comunidad

1. Iniciar la aplicación con Flutter desde la carpeta `Desarrollo`.
2. Iniciar sesión.
3. Abrir el menú ☰.
4. Entrar en **Mis iniciativas**.
5. Publicar una iniciativa o abrir una existente.
6. Pulsar **Abrir espacio de trabajo**.
7. Entrar en **Avances**.
8. Pulsar **Publicar**.
9. Crear un avance.
10. Entrar en **Comunidad**.
11. Confirmar que aparece la publicación.
12. Pulsar **Comentar**.

Si se cambió código mientras la aplicación estaba ejecutándose:

- Usar **Hot Reload** para cambios de UI.
- Usar **Hot Restart** para cambios de inyección, estado inicial o `main()`.
- Ejecutar la app con `F5` o `flutter run -d chrome`; abrir `build/web` con un servidor estático no habilita hot reload.

## 12. Pendientes técnicos

- Confirmar en Roble la creación y permisos de las tablas públicas.
- Completar pruebas automatizadas específicas para publicaciones y comentarios públicos.
- Migrar chat y comentarios internos a una estrategia remota compatible con el tipo de identidad de `_owner`.
- Persistir localmente los datos que actualmente viven en memoria, si se requiere conservarlos al reiniciar.
- Completar edición y eliminación de sprints desde la interfaz.
- Unificar el refresco de actividades, sprints, feedback y workspace.
- Dividir `ProjectWorkspacePage`, que todavía concentra una cantidad importante de UI y lógica.
- Agregar moderación, reportes y controles de contenido para la comunidad.
- Agregar filtros de publicaciones por proyecto, categoría o fecha.

## Estado general

La aplicación cuenta ahora con una base funcional para:

- Publicar iniciativas.
- Formar equipos.
- Organizar el trabajo con actividades y sprints.
- Compartir avances públicamente.
- Recibir comentarios de la comunidad.
- Mantener una navegación móvil más limpia.

La funcionalidad de Comunidad está implementada en código, pero su funcionamiento completo depende de que las tablas `publicaciones_avance` y `comentarios_publicacion` existan en el contrato de Roble con los nombres, columnas y permisos indicados en este reporte.
