import 'package:flutter/material.dart';

import '../dominio/cartas.dart';
import '../dominio/lineas.dart';
import '../dominio/partida.dart';
import 'pantalla_cantor.dart';
import 'tema.dart';
import 'vms.dart';

class PantallaJuego extends StatelessWidget {
  const PantallaJuego({super.key, required this.vm, this.crearCantor});
  final JuegoVm vm;

  /// Solo en el modo demo: abre al cantor desde el juego (los dos viven en el mismo teléfono).
  final CantorVm Function()? crearCantor;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        final p = vm.partida;
        if (p == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        return Scaffold(
          appBar: AppBar(
            title: Text('Sala ${p.sala}'),
            actions: [
              if (crearCantor != null)
                IconButton(
                  tooltip: 'Abrir al cantor',
                  icon: const Icon(Icons.campaign_outlined),
                  onPressed: () => Navigator.of(context)
                      .push(MaterialPageRoute<void>(builder: (_) => PantallaCantor(vm: crearCantor!()))),
                ),
              IconButton(tooltip: 'Salir', icon: const Icon(Icons.logout_rounded), onPressed: vm.salir),
            ],
          ),
          // El botón vive fijo abajo: siempre a la mano, aunque la tabla sea larga.
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: p.puedeCantarLoteria ? vm.cantarLoteria : null,
                  child: const Text('¡LOTERÍA!'),
                ),
              ),
            ),
          ),
          body: ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), children: [
            Text('Jugando como ${p.nombre}', style: const TextStyle(color: Cereza.suave)),
            const SizedBox(height: 10),
            if (!vm.avisosActivos) ...[
              const Panel(
                color: Cereza.clarito,
                borde: null,
                padding: EdgeInsets.all(12),
                child: Row(children: [
                  Icon(Icons.notifications_off_outlined, size: 18, color: Cereza.oscuro),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text('Sin avisos: la app revisa al cantor cada 5 s mientras esté abierta.',
                        style: TextStyle(color: Cereza.oscuro, fontSize: 13)),
                  ),
                ]),
              ),
              const SizedBox(height: 10),
            ],
            _CartaActual(partida: p),
            const SizedBox(height: 10),
            if (p.ganador != null) ...[
              Panel(
                color: const Color(0xFFFBF1DD),
                borde: null,
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  const Icon(Icons.emoji_events_outlined, color: Cereza.dorado),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${p.ganador} ganó con ${describirPatron(p.patronGanador ?? '')}',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Cereza.texto),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 10),
            ] else if (p.casi) ...[
              const Panel(
                color: Cereza.claro,
                borde: null,
                padding: EdgeInsets.all(14),
                child: Row(children: [
                  Icon(Icons.bolt_rounded, color: Cereza.principal),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text('¡Estás a UNA carta de ganar!',
                        style: TextStyle(fontWeight: FontWeight.w700, color: Cereza.oscuro)),
                  ),
                ]),
              ),
              const SizedBox(height: 10),
            ],
            if (vm.mensaje != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(vm.mensaje!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Cereza.oscuro)),
              ),
            if (vm.controlador.ultimoError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(vm.controlador.ultimoError!,
                    textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFB3261E))),
              ),
            const Text('Tu tabla', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Cereza.oscuro)),
            const SizedBox(height: 8),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.74,
                  children: [for (final id in p.tabla) _Casilla(id: id, marcada: p.estaMarcada(id))],
                ),
              ),
            ),
          ]),
        );
      },
    );
  }
}

class _CartaActual extends StatelessWidget {
  const _CartaActual({required this.partida});
  final Partida partida;

  @override
  Widget build(BuildContext context) {
    final c = partida.ultimaCarta;
    return Panel(
      color: Cereza.principal,
      borde: null,
      padding: const EdgeInsets.all(18),
      child: c == null
          ? const Text('Esperando la primera carta...',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16))
          : Column(children: [
              const Text('Salió', style: TextStyle(color: Cereza.claro, fontSize: 13)),
              const SizedBox(height: 2),
              Text('#${c.n} · ${c.nombre}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(c.pista,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Cereza.claro, fontStyle: FontStyle.italic)),
            ]),
    );
  }
}

/// Una casilla como carta de lotería: número arriba, nombre abajo. Marcada = ficha cereza.
class _Casilla extends StatelessWidget {
  const _Casilla({required this.id, required this.marcada});
  final int id;
  final bool marcada;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: marcada ? Cereza.claro : Colors.white,
        border: Border.all(color: marcada ? Cereza.principal : Cereza.borde, width: marcada ? 2 : 1),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.fromLTRB(6, 5, 6, 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$id',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: marcada ? Cereza.principal : Cereza.suave)),
        Expanded(
          child: Center(
            child: marcada
                ? Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(color: Cereza.principal, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded, size: 15, color: Colors.white),
                  )
                : const SizedBox.shrink(),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Text(
            nombreDeCarta(id),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 11, height: 1.15, fontWeight: FontWeight.w600, color: marcada ? Cereza.oscuro : Cereza.texto),
          ),
        ),
      ]),
    );
  }
}
