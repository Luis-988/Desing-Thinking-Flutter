import 'package:flutter/material.dart';

/// Muestra un mensaje breve, reemplazando el anterior si lo hubiera.
void showAppSnack(BuildContext context, String message, {SnackBarAction? action}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), action: action));
}
