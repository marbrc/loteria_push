import 'package:flutter/material.dart';

import '../dominio/puerto_push.dart';
import 'pantalla_cantor.dart';
import 'tema.dart';
import 'vms.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key, required this.vm, required this.crearCantor, this.demo = false});
  final JuegoVm vm;
  final CantorVm Function() crearCantor;
  final bool demo;

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  final _nombre = TextEditingController();
  final _sala = TextEditingController();

  @override
  void dispose() {
    _nombre.dispose();
    _sala.dispose();
    super.dispose();
  }

  /// Pre-permiso: explicamos el valor ANTES de que salga el diálogo del sistema.
  Future<bool> _preguntarPorAvisos() async {
    if (widget.vm.permiso != PermisoPush.sinPreguntar) return false; // ya decidió: no insistimos
    final r = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        icon: const Icon(Icons.notifications_active_outlined, color: Cereza.principal, size: 32),
        title: const Text('¿Quieres que el cantor te avise?'),
        content: const Text(
            'Te avisaremos cuando se cante una carta y cuando estés a UNA de ganar, aunque tengas la app cerrada. '
            'Si prefieres no recibir avisos, igual puedes jugar: la app revisará cada pocos segundos mientras esté abierta.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Mejor no')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Sí, avísame')),
        ],
      ),
    );
    return r ?? false;
  }

  Future<void> _unirse() async {
    final nombre = _nombre.text.trim();
    final sala = _sala.text.trim();
    if (nombre.isEmpty || sala.isEmpty) return;
    final pedir = await _preguntarPorAvisos();
    if (!mounted) return;
    await widget.vm.unirse(sala: sala, nombre: nombre, pedirAvisos: pedir);
  }

  Future<void> _abrirCantor() async {
    final cantor = widget.crearCantor();
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PantallaCantor(vm: cantor)));
    // En la demo, al regresar ya trae escrito el código de la sala que se creó.
    if (widget.demo && cantor.sala != null && mounted) _sala.text = cantor.sala!.id;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (context, _) => Scaffold(
        body: SafeArea(
          child: ListView(padding: const EdgeInsets.fromLTRB(20, 24, 20, 28), children: [
            // ---------- Portada ----------
            Panel(
              color: Cereza.principal,
              borde: null,
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Lotería',
                    style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                const Text('PUSH',
                    style: TextStyle(color: Cereza.claro, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 4)),
                const SizedBox(height: 14),
                const Text('El cantor canta las cartas por notificación push. Llena una línea y grita Lotería.',
                    style: TextStyle(color: Colors.white, height: 1.4)),
                if (widget.demo) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: Cereza.oscuro, borderRadius: BorderRadius.circular(20)),
                    child: const Text('Modo demo · cantor dentro de la app',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ]),
            ),
            const SizedBox(height: 22),
            const Text('Entrar a una sala',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Cereza.oscuro)),
            const SizedBox(height: 12),
            TextField(controller: _nombre, maxLength: 20, decoration: const InputDecoration(labelText: 'Tu nombre')),
            const SizedBox(height: 4),
            TextField(
              controller: _sala,
              textCapitalization: TextCapitalization.characters,
              maxLength: 8,
              style: const TextStyle(letterSpacing: 3, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(labelText: 'Código de sala'),
            ),
            if (widget.vm.mensaje != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(widget.vm.mensaje!, style: const TextStyle(color: Color(0xFFB3261E))),
              ),
            SizedBox(
              height: 52,
              child: FilledButton(onPressed: widget.vm.ocupado ? null : _unirse, child: const Text('Unirme a la sala')),
            ),
            const SizedBox(height: 28),
            const Row(children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('o', style: TextStyle(color: Cereza.suave)),
              ),
              Expanded(child: Divider()),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.campaign_outlined),
                onPressed: _abrirCantor,
                label: const Text('Soy el cantor: crear una sala'),
              ),
            ),
            if (widget.demo)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'En la demo tú eres cantor y jugador: crea la sala, regresa (el código ya queda escrito), '
                  'únete y abre al cantor con el megáfono de arriba.',
                  style: TextStyle(color: Cereza.suave, fontSize: 13, height: 1.4),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
