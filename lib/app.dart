import 'package:flutter/material.dart';

import 'presentacion/pantalla_inicio.dart';
import 'presentacion/pantalla_juego.dart';
import 'presentacion/tema.dart';
import 'presentacion/vms.dart';

/// Llave global para mostrar avisos dentro de la app (la usa el modo demo para
/// pintar los "push" que llegan con la app abierta).
final GlobalKey<ScaffoldMessengerState> mensajero = GlobalKey<ScaffoldMessengerState>();

void mostrarAvisoDentroDeLaApp(String titulo, String cuerpo) {
  mensajero.currentState
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      duration: const Duration(seconds: 4),
      content: Row(children: [
        const Icon(Icons.notifications_active_outlined, color: Colors.white, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titulo, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
            if (cuerpo.isNotEmpty) Text(cuerpo, style: const TextStyle(color: Cereza.claro)),
          ]),
        ),
      ]),
    ));
}

class AppLoteria extends StatefulWidget {
  const AppLoteria({super.key, required this.vm, required this.crearCantor, this.demo = false});
  final JuegoVm vm;
  final CantorVm Function() crearCantor;

  /// Modo demo: cantor y jugador en el mismo dispositivo (ver lib/main_demo.dart).
  final bool demo;

  @override
  State<AppLoteria> createState() => _AppLoteriaState();
}

class _AppLoteriaState extends State<AppLoteria> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.vm.iniciar();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Al volver a la app: pregunta al servidor (pudieron perderse avisos mientras dormía).
    if (state == AppLifecycleState.resumed) widget.vm.alVolverALaApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Lotería Push',
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: mensajero,
        theme: TemaCereza.claro,
        // En la compu no se estira de lado a lado: se centra con ancho de teléfono.
        builder: (context, child) => ColoredBox(
          color: Cereza.fondo,
          child: Center(
            child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520), child: child),
          ),
        ),
        home: ListenableBuilder(
          listenable: widget.vm,
          builder: (context, _) => widget.vm.partida == null
              ? PantallaInicio(vm: widget.vm, crearCantor: widget.crearCantor, demo: widget.demo)
              : PantallaJuego(vm: widget.vm, crearCantor: widget.demo ? widget.crearCantor : null),
        ),
      );
}
