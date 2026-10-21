import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/logout_user.dart';
import '../../features/auth/domain/usecases/register_user.dart';
import '../../features/auth/domain/usecases/restore_session.dart';
import '../../features/initiatives/data/datasources/initiative_remote_data_source.dart';
import '../../features/initiatives/data/datasources/project_activity_remote_data_source.dart';
import '../../features/initiatives/data/repositories/initiative_repository_impl.dart';
import '../../features/initiatives/data/repositories/project_activity_repository_impl.dart';
import '../../features/initiatives/data/repositories/project_sprint_repository_impl.dart';
import '../../features/initiatives/data/datasources/project_sprint_remote_data_source.dart';
import '../../features/initiatives/data/repositories/in_memory_workspace_repository.dart';
import '../../features/initiatives/data/repositories/workspace_repository_impl.dart';
import '../../features/initiatives/data/datasources/workspace_remote_data_source.dart';
import '../../features/initiatives/data/repositories/saved_initiative_repository_impl.dart';
import '../../features/initiatives/data/repositories/in_memory_saved_initiative_repository.dart';
import '../../features/initiatives/domain/repositories/initiative_repository.dart';
import '../../features/initiatives/domain/repositories/project_activity_repository.dart';
import '../../features/initiatives/domain/repositories/project_sprint_repository.dart';
import '../../features/initiatives/domain/repositories/workspace_repository.dart';
import '../../features/initiatives/domain/repositories/saved_initiative_repository.dart';
import '../../features/initiatives/data/datasources/saved_initiative_remote_data_source.dart';
import '../../features/initiatives/domain/usecases/create_initiative.dart';
import '../../features/initiatives/domain/usecases/delete_initiative.dart';
import '../../features/initiatives/domain/usecases/get_applications.dart';
import '../../features/initiatives/domain/usecases/get_initiatives.dart';
import '../../features/initiatives/domain/usecases/get_project_activities.dart';
import '../../features/initiatives/domain/usecases/create_project_activity.dart';
import '../../features/initiatives/domain/usecases/delete_project_activity.dart';
import '../../features/initiatives/domain/usecases/save_initiative_views.dart';
import '../../features/initiatives/domain/usecases/submit_application.dart';
import '../../features/initiatives/domain/usecases/update_application_status.dart';
import '../../features/initiatives/domain/usecases/update_initiative.dart';
import '../../features/initiatives/domain/usecases/update_project_activity.dart';
import '../../features/auth/presentation/providers/session_controller.dart';
import '../../features/initiatives/presentation/providers/initiatives_controller.dart';
import '../../features/initiatives/presentation/providers/project_activities_controller.dart';
import '../../features/initiatives/presentation/providers/project_sprints_controller.dart';
import '../../features/initiatives/presentation/providers/workspace_controller.dart';
import '../network/roble_client.dart';
import '../../features/initiatives/data/datasources/sprint_feedback_remote_data_source.dart';
import '../../features/initiatives/data/repositories/sprint_feedback_repository_impl.dart';
import '../../features/initiatives/domain/repositories/sprint_feedback_repository.dart';
import '../../features/initiatives/data/datasources/public_feed_remote_data_source.dart';
import '../../features/initiatives/data/repositories/public_feed_repository_impl.dart';
import '../../features/initiatives/domain/repositories/public_feed_repository.dart';
import '../../features/initiatives/presentation/providers/public_feed_controller.dart';
import '../../features/initiatives/presentation/providers/sprint_feedback_controller.dart';

class AppDependencies {
  final AuthRepository authRepository;
  final InitiativeRepository initiativeRepository;
  final ProjectActivityRepository projectActivityRepository;
  final ProjectSprintRepository projectSprintRepository;
  final WorkspaceRepository workspaceRepository;
  final SprintFeedbackRepository sprintFeedbackRepository;
  final SavedInitiativeRepository savedInitiativeRepository;
  final PublicFeedRepository publicFeedRepository;

  AppDependencies({
    required this.authRepository,
    required this.initiativeRepository,
    required this.projectActivityRepository,
    required this.projectSprintRepository,
    required this.workspaceRepository,
    required this.sprintFeedbackRepository,
    SavedInitiativeRepository? savedInitiativeRepository,
    PublicFeedRepository? publicFeedRepository,
  }) : savedInitiativeRepository =
           savedInitiativeRepository ?? InMemorySavedInitiativeRepository(),
       publicFeedRepository =
           publicFeedRepository ??
           PublicFeedRepositoryImpl(
             PublicFeedRemoteDataSource(RobleClient.db),
           );

  factory AppDependencies.production() => AppDependencies(
    authRepository: AuthRepositoryImpl(AuthRemoteDataSource(RobleClient.db)),
    initiativeRepository: InitiativeRepositoryImpl(
      InitiativeRemoteDataSource(RobleClient.db),
    ),
    projectActivityRepository: ProjectActivityRepositoryImpl(
      ProjectActivityRemoteDataSource(RobleClient.db),
    ),
    projectSprintRepository: ProjectSprintRepositoryImpl(
      ProjectSprintRemoteDataSource(RobleClient.db),
    ),
    workspaceRepository: WorkspaceRepositoryImpl(
      WorkspaceRemoteDataSource(RobleClient.db),
    ),
    sprintFeedbackRepository: SprintFeedbackRepositoryImpl(
      SprintFeedbackRemoteDataSource(RobleClient.db),
    ),
    savedInitiativeRepository: SavedInitiativeRepositoryImpl(
      SavedInitiativeRemoteDataSource(RobleClient.db),
    ),
    publicFeedRepository: PublicFeedRepositoryImpl(
      PublicFeedRemoteDataSource(RobleClient.db),
    ),
  );

  RestoreSession get restoreSession => RestoreSession(authRepository);
  LoginUser get loginUser => LoginUser(authRepository);
  RegisterUser get registerUser => RegisterUser(authRepository);
  LogoutUser get logoutUser => LogoutUser(authRepository);

  GetInitiatives get getInitiatives => GetInitiatives(initiativeRepository);
  CreateInitiative get createInitiative =>
      CreateInitiative(initiativeRepository);
  UpdateInitiative get updateInitiative =>
      UpdateInitiative(initiativeRepository);
  DeleteInitiative get deleteInitiative =>
      DeleteInitiative(initiativeRepository);
  SaveInitiativeViews get saveInitiativeViews =>
      SaveInitiativeViews(initiativeRepository);
  GetApplications get getApplications => GetApplications(initiativeRepository);
  SubmitApplication get submitApplication =>
      SubmitApplication(initiativeRepository);
  UpdateApplicationStatus get updateApplicationStatus =>
      UpdateApplicationStatus(initiativeRepository);

  GetProjectActivities get getProjectActivities =>
      GetProjectActivities(projectActivityRepository);
  CreateProjectActivity get createProjectActivity =>
      CreateProjectActivity(projectActivityRepository);
  UpdateProjectActivity get updateProjectActivity =>
      UpdateProjectActivity(projectActivityRepository);
  DeleteProjectActivity get deleteProjectActivity =>
      DeleteProjectActivity(projectActivityRepository);

  ProjectSprintsController createProjectSprintsController() =>
      ProjectSprintsController(projectSprintRepository);

  SavedInitiativeRepository get savedInitiatives => savedInitiativeRepository;

  SessionController createSessionController() => SessionController(
    restoreSession: restoreSession,
    loginUser: loginUser,
    registerUser: registerUser,
    logoutUser: logoutUser,
  );

  InitiativesController createInitiativesController() => InitiativesController(
    getInitiatives: getInitiatives,
    createInitiative: createInitiative,
    updateInitiative: updateInitiative,
    deleteInitiative: deleteInitiative,
    saveViews: saveInitiativeViews,
    getApplications: getApplications,
    submitApplication: submitApplication,
    updateApplicationStatus: updateApplicationStatus,
    savedInitiativeRepository: savedInitiativeRepository,
  );

  ProjectActivitiesController createProjectActivitiesController() =>
      ProjectActivitiesController.fromUseCases(
        getActivities: getProjectActivities,
        createActivity: createProjectActivity,
        updateActivity: updateProjectActivity,
        deleteActivity: deleteProjectActivity,
      );

  WorkspaceController createWorkspaceController() =>
      WorkspaceController(
        workspaceRepository,
        publicFeedRepository: publicFeedRepository,
      );

  PublicFeedController createPublicFeedController() =>
      PublicFeedController(publicFeedRepository);

  SprintFeedbackController createSprintFeedbackController() =>
      SprintFeedbackController(sprintFeedbackRepository);
}

/// Inyección de dependencias manual: arma data -> domain una sola vez.
/// En pruebas se pueden pasar repositorios falsos a [init].
/// Los controladores se crean desde aquí para no acoplar la UI a `data`.
class Injection {
  Injection._();

  static AppDependencies? _dependencies;

  static void init({
    AuthRepository? authRepository,
    InitiativeRepository? initiativeRepository,
    ProjectActivityRepository? projectActivityRepository,
    ProjectSprintRepository? projectSprintRepository,
    WorkspaceRepository? workspaceRepository,
    SprintFeedbackRepository? sprintFeedbackRepository,
    SavedInitiativeRepository? savedInitiativeRepository,
  }) {
    _dependencies = AppDependencies(
      authRepository:
          authRepository ??
          AuthRepositoryImpl(AuthRemoteDataSource(RobleClient.db)),
      initiativeRepository:
          initiativeRepository ??
          InitiativeRepositoryImpl(InitiativeRemoteDataSource(RobleClient.db)),
      projectActivityRepository:
          projectActivityRepository ??
          ProjectActivityRepositoryImpl(
            ProjectActivityRemoteDataSource(RobleClient.db),
          ),
      projectSprintRepository:
          projectSprintRepository ??
          ProjectSprintRepositoryImpl(
            ProjectSprintRemoteDataSource(RobleClient.db),
          ),
      workspaceRepository: workspaceRepository ?? InMemoryWorkspaceRepository(),
      sprintFeedbackRepository:
          sprintFeedbackRepository ??
          SprintFeedbackRepositoryImpl(
            SprintFeedbackRemoteDataSource(RobleClient.db),
          ),
      savedInitiativeRepository:
          savedInitiativeRepository ?? InMemorySavedInitiativeRepository(),
    );
  }

  static AppDependencies get dependencies =>
      _dependencies ??= AppDependencies.production();

  static SessionController createSessionController() =>
      dependencies.createSessionController();

  static InitiativesController createInitiativesController() =>
      dependencies.createInitiativesController();

  static ProjectActivitiesController createProjectActivitiesController() =>
      dependencies.createProjectActivitiesController();
}
