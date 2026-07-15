import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Estructura reutilizable para pantallas de autenticación: panel superior
/// navy con formas orgánicas (blobs), inspirado en el moodboard de marca,
/// + sección con el formulario. Totalmente responsiva: la altura del
/// hero se adapta al alto disponible para que el botón principal quede
/// visible sin necesidad de hacer scroll en pantallas típicas.
class AuthScaffold extends StatelessWidget {
  final IconData heroIcon;
  final String title;
  final String subtitle;
  final Widget child;

  /// Si no se especifica, la altura se calcula según el alto disponible.
  final double? heroHeight;

  const AuthScaffold({
    super.key,
    required this.heroIcon,
    required this.title,
    required this.subtitle,
    required this.child,
    this.heroHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;
            // Hero más compacto en pantallas bajas, más generoso en altas.
            final resolvedHeroHeight =
                heroHeight ??
                (availableHeight < 700
                        ? availableHeight * 0.24
                        : availableHeight * 0.30)
                    .clamp(150.0, 230.0);
            final cardPadding = availableHeight < 640 ? 20.0 : 28.0;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    // Mantiene el ancho máximo en pantallas grandes (tablet/desktop)
                    // pero sin separarse de los bordes en móvil.
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _HeroPanel(
                          icon: heroIcon,
                          title: title,
                          subtitle: subtitle,
                          height: resolvedHeroHeight,
                        ),
                        // El formulario usa el color de superficie del tema,
                        // pegado directamente al hero, sin recorte ni sombra.
                        Container(
                          width: double.infinity,
                          color: theme.colorScheme.surface,
                          padding: EdgeInsets.all(cardPadding),
                          child: child,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double height;

  const _HeroPanel({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    // El tamaño del logo y del texto se ajusta un poco si el hero
    // quedó bajo por falta de espacio vertical.
    final isCompact = height < 180;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(decoration: BoxDecoration(color: AppColors.navy)),
          Positioned.fill(child: CustomPaint(painter: _BlobPainter())),
          // Halo suave detrás del logo.
          Align(
            alignment: const Alignment(0, -0.1),
            child: Container(
              height: isCompact ? 90 : 112,
              width: isCompact ? 90 : 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.navyLight.withValues(alpha: 0.9),
                    AppColors.navyLight.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // El logo de la app vive exactamente en este círculo.
                Container(
                  height: isCompact ? 54 : 64,
                  width: isCompact ? 54 : 64,
                  decoration: const BoxDecoration(
                    color: AppColors.teal,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: isCompact ? 24 : 28,
                  ),
                ),
                SizedBox(height: isCompact ? 10 : 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isCompact ? 20 : 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Fondo de formas orgánicas (blobs), sin patrones punteados, en los tonos
/// navy + periwinkle + teal de la marca. Se dibuja proporcional al tamaño
/// del hero, así que escala bien en cualquier ancho de pantalla.
class _BlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final blobPeriwinkle = Paint()
      ..color = AppColors.blobAccent.withValues(alpha: 0.55);
    final path1 = Path()
      ..moveTo(-w * 0.15, h * 0.18)
      ..cubicTo(w * 0.05, -h * 0.15, w * 0.38, -h * 0.1, w * 0.45, h * 0.15)
      ..cubicTo(w * 0.52, h * 0.4, w * 0.32, h * 0.5, w * 0.1, h * 0.46)
      ..cubicTo(-w * 0.08, h * 0.43, -w * 0.24, h * 0.34, -w * 0.15, h * 0.18)
      ..close();
    canvas.drawPath(path1, blobPeriwinkle);

    final blobTeal = Paint()..color = AppColors.teal.withValues(alpha: 0.16);
    canvas.drawCircle(Offset(w * 0.9, h * 0.15), h * 0.4, blobTeal);

    final blobNavy = Paint()
      ..color = AppColors.navyLight.withValues(alpha: 0.55);
    final path2 = Path()
      ..moveTo(w * 0.55, h)
      ..cubicTo(w * 0.75, h * 0.68, w * 1.05, h * 0.76, w * 1.1, h)
      ..close();
    canvas.drawPath(path2, blobNavy);
  }

  @override
  bool shouldRepaint(covariant _BlobPainter oldDelegate) => false;
}
