import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/logout_user.dart';
import '../../features/auth/domain/usecases/register_user.dart';
import '../../features/auth/domain/usecases/restore_session.dart';
import '../../features/initiatives/data/datasources/initiative_remote_data_source.dart';
import '../../features/initiatives/data/repositories/initiative_repository_impl.dart';
import '../../features/initiatives/domain/repositories/initiative_repository.dart';
import '../../features/initiatives/domain/usecases/create_initiative.dart';
import '../../features/initiatives/domain/usecases/delete_initiative.dart';
import '../../features/initiatives/domain/usecases/get_applications.dart';
import '../../features/initiatives/domain/usecases/get_initiatives.dart';
import '../../features/initiatives/domain/usecases/save_initiative_views.dart';
import '../../features/initiatives/domain/usecases/submit_application.dart';
import '../../features/initiatives/domain/usecases/update_application_status.dart';
import '../../features/initiatives/domain/usecases/update_initiative.dart';
import '../network/roble_client.dart';

/// Inyección de dependencias manual: arma data -> domain una sola vez.
/// En pruebas se pueden pasar repositorios falsos a [init].
class Injection {
  Injection._();

  static late AuthRepository _authRepository;
  static late InitiativeRepository _initiativeRepository;

  static void init({
    AuthRepository? authRepository,
    InitiativeRepository? initiativeRepository,
  }) {
    _authRepository =
        authRepository ??
        AuthRepositoryImpl(AuthRemoteDataSource(RobleClient.db));
    _initiativeRepository =
        initiativeRepository ??
        InitiativeRepositoryImpl(InitiativeRemoteDataSource(RobleClient.db));
  }

  // Auth
  static RestoreSession get restoreSession => RestoreSession(_authRepository);
  static LoginUser get loginUser => LoginUser(_authRepository);
  static RegisterUser get registerUser => RegisterUser(_authRepository);
  static LogoutUser get logoutUser => LogoutUser(_authRepository);

  // Iniciativas
  static GetInitiatives get getInitiatives =>
      GetInitiatives(_initiativeRepository);
  static CreateInitiative get createInitiative =>
      CreateInitiative(_initiativeRepository);
  static UpdateInitiative get updateInitiative =>
      UpdateInitiative(_initiativeRepository);
  static DeleteInitiative get deleteInitiative =>
      DeleteInitiative(_initiativeRepository);
  static SaveInitiativeViews get saveInitiativeViews =>
      SaveInitiativeViews(_initiativeRepository);
  static GetApplications get getApplications =>
      GetApplications(_initiativeRepository);
  static SubmitApplication get submitApplication =>
      SubmitApplication(_initiativeRepository);
  static UpdateApplicationStatus get updateApplicationStatus =>
      UpdateApplicationStatus(_initiativeRepository);
}
