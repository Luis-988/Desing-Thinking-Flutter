import 'package:flutter/foundation.dart';

/// Posiciones de la barra de navegación inferior.
abstract final class HomeTabs {
  static const home = 0;
  static const explore = 1;
  static const myInitiatives = 2;
  static const saved = 3;
  static const profile = 4;
}

/// Permite cambiar de pestaña desde cualquier pantalla (por ejemplo, tras
/// enviar una postulación).
class HomeTabController extends ChangeNotifier {
  int _index = HomeTabs.home;

  int get index => _index;

  void go(int index) {
    if (index == _index) return;
    _index = index;
    notifyListeners();
  }
}
