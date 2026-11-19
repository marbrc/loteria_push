import 'package:flutter/material.dart';

/// Paleta "cereza": rojo intenso con rosa cereza clarito y fondo crema.
class Cereza {
  static const principal = Color(0xFFB3203A); // cereza
  static const oscuro = Color(0xFF7A1428); // títulos
  static const claro = Color(0xFFF8DCE1); // rosa cereza para fondos
  static const clarito = Color(0xFFFCEEF0);
  static const fondo = Color(0xFFFFF7F6);
  static const texto = Color(0xFF2E1A1D);
  static const suave = Color(0xFF8E6A70);
  static const borde = Color(0xFFF0D9DC);
  static const tallo = Color(0xFF3F7D4E); // el verde del tallito de la cereza
  static const dorado = Color(0xFFC9963B);
}

class TemaCereza {
  static ThemeData get claro {
    const esquema = ColorScheme(
      brightness: Brightness.light,
      primary: Cereza.principal,
      onPrimary: Colors.white,
      primaryContainer: Cereza.claro,
      onPrimaryContainer: Cereza.oscuro,
      secondary: Cereza.oscuro,
      onSecondary: Colors.white,
      secondaryContainer: Cereza.clarito,
      onSecondaryContainer: Cereza.oscuro,
      error: Color(0xFFB3261E),
      onError: Colors.white,
      errorContainer: Color(0xFFF9DEDC),
      onErrorContainer: Color(0xFF410E0B),
      surface: Colors.white,
      onSurface: Cereza.texto,
      onSurfaceVariant: Cereza.suave,
      outline: Cereza.borde,
    );

    final redondo = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: Cereza.fondo,
      appBarTheme: const AppBarTheme(
        backgroundColor: Cereza.fondo,
        foregroundColor: Cereza.oscuro,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Cereza.oscuro,
          fontSize: 21,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Cereza.principal,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Cereza.claro,
          disabledForegroundColor: Cereza.suave,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: redondo,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Cereza.principal,
          backgroundColor: Colors.white,
          side: const BorderSide(color: Cereza.borde),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          shape: redondo,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: Cereza.principal),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: Cereza.suave),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Cereza.borde),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Cereza.borde),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Cereza.principal, width: 1.6),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? Colors.white : Cereza.suave),
        trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? Cereza.principal : Cereza.clarito),
        trackOutlineColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? Cereza.principal : Cereza.borde),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        titleTextStyle: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Cereza.texto),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Cereza.oscuro,
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(color: Cereza.borde, space: 1),
    );
  }
}

/// Tarjeta base. Es un Material (no un Container con color) para que los interruptores
/// y botones de adentro puedan pintar su efecto al tocarlos.
class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(18),
    this.borde = Cereza.borde,
  });
  final Widget child;
  final Color color;
  final EdgeInsets padding;
  final Color? borde;

  @override
  Widget build(BuildContext context) => Material(
        color: color,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: borde == null ? BorderSide.none : BorderSide(color: borde!),
        ),
        child: Padding(padding: padding, child: SizedBox(width: double.infinity, child: child)),
      );
}
