import 'package:flutter/material.dart';

import 'app.dart';
import 'demo/cantor_local.dart';
import 'dominio/almacen.dart';
import 'dominio/controlador.dart';
import 'presentacion/vms.dart';

/// Arranque en MODO DEMO: sin servidor y sin Firebase.
///   flutter run -t lib/main_demo.dart -d chrome
///   flutter build web -t lib/main_demo.dart ...
/// El cantor vive dentro de la app (lib/demo/cantor_local.dart) y los avisos se
/// muestran como banner. El controlador, la partida y las pantallas son los mismos.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final push = PuertoPushLocal();
  final api = CantorLocal(push);
  push.alMostrar = mostrarAvisoDentroDeLaApp;

  // En la demo la sesión vive en memoria: al recargar la página se empieza de cero
  // (el cantor local también se reinicia).
  final controlador = ControladorPartida(api: api, push: push, almacen: AlmacenMemoria());
  final cantor = CantorVm(api, compartido: true); // el mismo cantor para toda la demo

  runApp(AppLoteria(vm: JuegoVm(controlador), crearCantor: () => cantor, demo: true));
}
