import 'package:flutter/material.dart';

import 'tema.dart';
import 'vms.dart';

class PantallaCantor extends StatefulWidget {
  const PantallaCantor({super.key, required this.vm});
  final CantorVm vm;

  @override
  State<PantallaCantor> createState() => _PantallaCantorState();
}

class _PantallaCantorState extends State<PantallaCantor> {
  @override
  void dispose() {
    if (!widget.vm.compartido) widget.vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (context, _) {
        final vm = widget.vm;
        return Scaffold(
          appBar: AppBar(title: const Text('Cantor')),
          body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 28), children: [
            if (vm.sala == null)
              Panel(
                child: Column(children: [
                  const Icon(Icons.campaign_outlined, size: 44, color: Cereza.principal),
                  const SizedBox(height: 10),
                  const Text('Crea una sala y comparte el código con tus jugadores.',
                      textAlign: TextAlign.center, style: TextStyle(color: Cereza.texto)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(onPressed: vm.crear, child: const Text('Crear sala')),
                  ),
                ]),
              )
            else ...[
              Panel(
                color: Cereza.principal,
                borde: null,
                padding: const EdgeInsets.all(22),
                child: Column(children: [
                  const Text('Código de la sala', style: TextStyle(color: Cereza.claro, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(vm.sala!.id,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 4),
                  const Text('Compártelo con tus jugadores', style: TextStyle(color: Cereza.claro)),
                ]),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: vm.cantar,
                  icon: const Icon(Icons.record_voice_over_outlined),
                  label: const Text('Cantar la siguiente carta'),
                ),
              ),
              const SizedBox(height: 8),
              Panel(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: SwitchListTile(
                  title: const Text('Cantar automáticamente cada 6 s'),
                  subtitle: const Text('Mantén esta pantalla abierta'),
                  value: vm.automatico,
                  onChanged: (_) => vm.alternarAutomatico(),
                ),
              ),
            ],
            if (vm.mensaje != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(vm.mensaje!, style: const TextStyle(color: Color(0xFFB3261E))),
              ),
            if (vm.cantadas.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('Cartas cantadas (${vm.cantadas.length})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Cereza.oscuro)),
              const SizedBox(height: 8),
              Panel(
                padding: EdgeInsets.zero,
                child: Column(children: [
                  for (var i = 0; i < vm.cantadas.length; i++) ...[
                    if (i > 0) const Divider(indent: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                      child: Row(children: [
                        Text(vm.cantadas[i],
                            style: TextStyle(
                                fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w400,
                                color: i == 0 ? Cereza.principal : Cereza.texto)),
                      ]),
                    ),
                  ],
                ]),
              ),
            ],
          ]),
        );
      },
    );
  }
}
