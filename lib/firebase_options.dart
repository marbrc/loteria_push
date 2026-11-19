// ARCHIVO PROVISIONAL.
// El de verdad lo genera `flutterfire configure` (manual, Ronda 1) y REEMPLAZA a este.
// Existe solo para que el proyecto compile y VS Code no marque error mientras practicas
// en modo demo (lib/main_demo.dart), que no usa Firebase.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => throw UnsupportedError(
        'Falta configurar Firebase: corre `flutterfire configure` (manual, Ronda 1). '
        'Mientras tanto usa el modo demo: flutter run -t lib/main_demo.dart',
      );
}
