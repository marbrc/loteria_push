import 'dart:async';
import 'dart:math';

import '../dominio/api_juego.dart';
import '../dominio/cartas.dart';
import '../dominio/evento.dart';
import '../dominio/lineas.dart';
import '../dominio/puerto_push.dart';

/// MODO DEMO (para la versión web y para practicar sin servidor ni Firebase).
///
/// El manual pone al cantor en un servidor Node y los avisos viajan por Firebase.
/// GitHub Pages solo sirve páginas, no corre servidores, así que para jugar desde el
/// navegador del celular este archivo trae una copia sencilla del cantor DENTRO de la app.
/// Implementa las MISMAS interfaces (ApiJuego y PuertoPush): el controlador, la partida
/// y las pantallas no cambian ni una línea. Es justo la ventaja de aislar todo con puertos.

/// Pistas de las cartas (las mismas del servidor, server/baraja.js).
const List<String> pistasCartas = [
  'Madruga más que tu mamá un domingo.',
  'Pórtate bien... o no.',
  'Llega tarde porque se arregla con calma.',
  'Trae más sombrero que presupuesto.',
  'Nunca está cuando llueve.',
  'Canta bonito, pero no la sigas al mar.',
  'Sube de a poquito y baja de a brinco.',
  'Tiene mucho que contar y poco contenido.',
  'Redondo, pesado y siempre rodando.',
  'Da sombra gratis a quien se la merece.',
  'Se elige a golpecitos y aun así sale malo.',
  'Dice que no tiene miedo, pero camina de lado.',
  'Para el frío, para la moda o para el chistorete.',
  'Pálida y flaca, pero nadie le gana en puntualidad.',
  'Madura solo cuando tú no la vigilas.',
  'Ondea más fuerte que tu wifi.',
  'Suena a fiesta aunque nadie lo invitó.',
  'Hace llorar a todos sin decir una palabra.',
  'Una pata y mucha elegancia.',
  'Madruga, canta y no paga renta.',
  'Pedir con ella es fácil; devolver, ya no.',
  'Camina por ti y huele por sí sola.',
  'Cambia de cara y nadie se lo reprocha.',
  'Habla sin parar y repite lo que oye.',
  'Juró que era el último... hace tres rondas.',
  'Doblado, doradito y con salsita: nadie lo rechaza.',
  'No tiene llave pero igual se lo roban.',
  'Por fuera tranquila, por dentro pura fiesta.',
  'Todo el mundo lo golpea y aun así llama la atención.',
  'Se duerme y la corriente se lo lleva.',
  'Flechas que no preguntan a quién le dan.',
  'Si no hay propina, hay indirectas.',
  'Teje su casa y nunca paga hipoteca.',
  'Marcha derecho aunque le pique la nariz.',
  'Brilla de noche y se hace la importante de día.',
  'Hierve rápido, igual que tu paciencia.',
  'Gira sin descanso y no te avisa.',
  'Con mayonesa, chile y limón es de la familia.',
  'Pica, pero en ensalada se porta bien.',
  'Trae la cola lista y mal humor.',
  'Bonita hasta que te pica.',
  'Es de azúcar y se come con sonrisa.',
  'Todos la oyen, pocos saben a quién llama.',
  'Agua fresca, cuando no se rompe.',
  'Salta y desaparece cuando lo buscas.',
  'Llega primero y se va sin despedirse.',
  'Pesa más de lo que se ve.',
  'Flota y no se hunde, como los chismes.',
  'Verde todo el año, hasta en diciembre.',
  'Nada, nada, y nada más.',
  'Se mece sin que nadie la empuje.',
  'Con cariño florece; sin él, se vuelve reproche.',
  'Cuerdas largas, historias largas.',
  'Croa más que tu tío en las fiestas.',
];

class _Jugador {
  _Jugador(this.nombre, this.tabla, this.clave, this.destino);
  final String nombre;
  final List<int> tabla;
  final String clave;
  DestinoPush? destino;
  bool avisadoCasi = false;
}

class _SalaLocal {
  _SalaLocal(this.id, this.claveCantor, this.mazo);
  final String id;
  final String claveCantor;
  final List<int> mazo;
  final List<CartaCantada> cantadas = [];
  final Map<String, _Jugador> jugadores = {};
  String? ganador;
  String? patron;
}

/// "Pregonero" local: entrega los avisos dentro de la app, como si llegaran por push.
class PuertoPushLocal implements PuertoPush {
  PermisoPush _permiso = PermisoPush.sinPreguntar;
  final Set<String> _temas = {};
  final _frente = StreamController<MensajePush>.broadcast();
  final _abrir = StreamController<MensajePush>.broadcast();
  final _destino = StreamController<DestinoPush>.broadcast();

  /// Cómo pintar el aviso en pantalla (la app conecta aquí un banner).
  void Function(String titulo, String cuerpo)? alMostrar;

  static const destinoLocal = DestinoPush('token', 'demo-este-dispositivo');

  /// Entrega a quien esté suscrito al tema (difusión a toda la sala).
  void entregarATema(String tema, MensajePush m) {
    if (_permiso != PermisoPush.concedido || !_temas.contains(tema)) return;
    _entregar(m);
  }

  /// Entrega personal (a un token).
  void entregarPersonal(MensajePush m) {
    if (_permiso != PermisoPush.concedido) return;
    _entregar(m);
  }

  void _entregar(MensajePush m) {
    alMostrar?.call(m.titulo ?? '', m.cuerpo ?? '');
    _frente.add(m);
  }

  @override
  Future<PermisoPush> estadoPermiso() async => _permiso;

  /// En la demo el "diálogo del sistema" siempre acepta.
  @override
  Future<PermisoPush> pedirPermiso() async => _permiso = PermisoPush.concedido;

  @override
  Future<DestinoPush?> obtenerDestino() async => _permiso == PermisoPush.concedido ? destinoLocal : null;

  @override
  Stream<DestinoPush> get destinoCambiado => _destino.stream;
  @override
  Stream<MensajePush> get enPrimerPlano => _frente.stream;
  @override
  Stream<MensajePush> get alAbrirDesdeNotificacion => _abrir.stream;
  @override
  Future<MensajePush?> mensajeInicial() async => null;
  @override
  Future<void> suscribirTema(String tema) async => _temas.add(tema);
  @override
  Future<void> desuscribirTema(String tema) async => _temas.remove(tema);
}

/// Copia sencilla de las reglas del servidor (sala.js), en memoria.
class CantorLocal implements ApiJuego {
  CantorLocal(this.push, {Random? azar}) : _azar = azar ?? Random();
  final PuertoPushLocal push;
  final Random _azar;
  final Map<String, _SalaLocal> _salas = {};

  static const _letras = 'ABCDEFGHJKLMNPQRSTUVWXYZ';

  String _codigo() => List.generate(5, (_) => _letras[_azar.nextInt(_letras.length)]).join();
  String _clave() => List.generate(16, (_) => _azar.nextInt(16).toRadixString(16)).join();

  List<int> _barajar() => List.generate(54, (i) => i + 1)..shuffle(_azar);

  _SalaLocal _sala(String id) {
    final s = _salas[id.trim().toUpperCase()];
    if (s == null) throw const ErrorApi('SALA_NO_EXISTE', 'No existe una sala con ese código.');
    return s;
  }

  _Jugador _jugador(_SalaLocal s, String nombre, String clave) {
    final j = s.jugadores[nombre];
    if (j == null || j.clave != clave) throw const ErrorApi('CREDENCIALES', 'Credenciales inválidas.');
    return j;
  }

  @override
  Future<SalaCreada> crearSala() async {
    var id = _codigo();
    while (_salas.containsKey(id)) {
      id = _codigo();
    }
    final s = _SalaLocal(id, _clave(), _barajar());
    _salas[id] = s;
    return SalaCreada(id, s.claveCantor);
  }

  @override
  Future<Union> unirse(String sala, String nombre, DestinoPush? destino) async {
    final s = _sala(sala);
    final n = nombre.trim();
    if (n.isEmpty || n.length > 20) throw const ErrorApi('NOMBRE_INVALIDO', 'Escribe un nombre de 1 a 20 letras.');
    if (s.jugadores.containsKey(n)) throw const ErrorApi('NOMBRE_OCUPADO', 'Ese nombre ya está en la sala.');
    if (s.ganador != null) throw const ErrorApi('SALA_TERMINADA', 'Esa partida ya terminó.');
    final tabla = _barajar().take(16).toList();
    final j = _Jugador(n, tabla, _clave(), destino);
    s.jugadores[n] = j;
    return Union(nombre: n, tabla: tabla, claveJugador: j.clave, cartas: s.cantadas.toList());
  }

  @override
  Future<EstadoSala> estado(String sala, int desde) async {
    final s = _sala(sala);
    return EstadoSala(
      ultima: s.cantadas.length,
      cartas: s.cantadas.where((c) => c.n > desde).toList(),
      ganador: s.ganador,
      patron: s.patron,
    );
  }

  @override
  Future<CartaCantada> cantar(String sala, String claveCantor) async {
    final s = _sala(sala);
    if (s.claveCantor != claveCantor) throw const ErrorApi('NO_AUTORIZADO', 'Solo el cantor puede cantar.');
    if (s.ganador != null) throw const ErrorApi('SALA_TERMINADA', 'La partida ya terminó.');
    if (s.cantadas.length >= s.mazo.length) throw const ErrorApi('SIN_CARTAS', 'Ya se cantaron todas las cartas.');

    final id = s.mazo[s.cantadas.length];
    final c = CartaCantada(n: s.cantadas.length + 1, cartaId: id, nombre: nombreDeCarta(id), pista: pistasCartas[id - 1]);
    s.cantadas.add(c);

    // Difusión a la sala (como el tema "sala_XXXXX" de FCM). Todo "data" va como TEXTO.
    push.entregarATema(
      'sala_${s.id}',
      MensajePush(
        titulo: c.nombre,
        cuerpo: c.pista,
        datos: {'tipo': 'carta', 'sala': s.id, 'n': '${c.n}', 'cartaId': '$id', 'nombre': c.nombre, 'pista': c.pista},
      ),
    );
    _avisarCasi(s);
    return c;
  }

  /// Aviso personal "¡Casi!": una sola vez por jugador y solo a quien tiene destino.
  void _avisarCasi(_SalaLocal s) {
    final ids = {for (final c in s.cantadas) c.cartaId};
    for (final j in s.jugadores.values) {
      if (j.avisadoCasi || j.destino == null) continue;
      int? falta;
      for (final e in patrones.entries) {
        if (e.key == 'llena') continue;
        final faltantes = [for (final pos in e.value) if (!ids.contains(j.tabla[pos])) j.tabla[pos]];
        if (faltantes.length == 1) {
          falta = faltantes.first;
          break;
        }
      }
      if (falta == null) continue;
      j.avisadoCasi = true;
      push.entregarPersonal(MensajePush(
        titulo: '¡Casi!',
        cuerpo: 'Estás a UNA carta de cantar Lotería. ¡Atento!',
        datos: {'tipo': 'casi', 'sala': s.id, 'n': '${s.cantadas.length}', 'cartaId': '$falta'},
      ));
    }
  }

  @override
  Future<ResultadoReclamo> reclamar(String sala, String nombre, String claveJugador) async {
    final s = _sala(sala);
    final j = _jugador(s, nombre, claveJugador);
    if (s.ganador != null) throw const ErrorApi('YA_HAY_GANADOR', 'Alguien ya cantó Lotería.');
    final completos = patronesCompletos(j.tabla, {for (final c in s.cantadas) c.cartaId});
    if (completos.isEmpty) return const ResultadoReclamo(gano: false);
    // Se prefiere un patrón "corto" (fila, columna...) antes que la tabla llena.
    final patron = completos.firstWhere((p) => p != 'llena', orElse: () => completos.first);
    s.ganador = j.nombre;
    s.patron = patron;
    push.entregarATema(
      'sala_${s.id}',
      MensajePush(
        titulo: '¡LOTERÍA!',
        cuerpo: '${j.nombre} ganó con ${describirPatron(patron)}. ¡Felicidades!',
        datos: {'tipo': 'loteria', 'sala': s.id, 'n': '${s.cantadas.length.clamp(1, 54)}', 'ganador': j.nombre, 'patron': patron},
      ),
    );
    return ResultadoReclamo(gano: true, patron: patron);
  }

  @override
  Future<void> actualizarDestino(String sala, String nombre, String claveJugador, DestinoPush destino) async {
    final s = _sala(sala);
    _jugador(s, nombre, claveJugador).destino = destino;
  }
}
