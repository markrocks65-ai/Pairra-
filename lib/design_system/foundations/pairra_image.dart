import 'package:flutter/widgets.dart';

import '../../theme/app_motion.dart';
import '../accessibility/accessibility_scope.dart';

/// The single network-image primitive for PAIRRA photography. Route every real
/// photo through this so performance and memory behavior live in one place.
///
/// What it guarantees:
///  • **Downsampling** — decodes the image at (roughly) its on-screen pixel
///    size via `cacheWidth`, not full resolution. A 4000px portrait shown in a
///    400px card would otherwise cost ~25× the memory; this is the single most
///    important lever for memory on image-heavy screens.
///  • **Caching** — leans on Flutter's in-memory [ImageCache] (keyed by URL +
///    decode size). For cross-session disk caching, swap `Image.network` for
///    `cached_network_image`'s provider here — every call site benefits with no
///    other change.
///  • **Graceful loading/error** — a caller-supplied [placeholder] shows while
///    loading and a [fallback] (or the placeholder) shows on failure, so a
///    dead URL never leaves a broken-image glyph or blank hole.
///  • **Reduced motion** — the fade-in is skipped when the user asks for it.
class PairraImage extends StatelessWidget {
  const PairraImage({
    super.key,
    required this.url,
    required this.placeholder,
    this.fallback,
    this.fit = BoxFit.cover,
    this.semanticLabel,
    this.maxDecodeWidth = 1440,
  });

  final String url;

  /// Shown while the image loads (and as the failure fallback if [fallback] is
  /// null). Typically the gradient placeholder so the tile is never empty.
  final WidgetBuilder placeholder;

  /// Shown if the image fails to load. Defaults to [placeholder].
  final WidgetBuilder? fallback;

  final BoxFit fit;

  /// Screen-reader description. Leave null for decorative imagery so it's
  /// skipped rather than announced as an unlabeled image.
  final String? semanticLabel;

  /// Upper bound on the decoded width in physical pixels — caps memory even on
  /// very high-DPI screens or unexpectedly large source images.
  final int maxDecodeWidth;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = PairraA11y.of(context).reduceMotion;
    final dpr = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 1.0;

    Widget image = LayoutBuilder(
      builder: (context, constraints) {
        int? cacheWidth;
        if (constraints.maxWidth.isFinite && constraints.maxWidth > 0) {
          cacheWidth =
              (constraints.maxWidth * dpr).round().clamp(1, maxDecodeWidth);
        } else {
          cacheWidth = maxDecodeWidth;
        }

        return Image.network(
          url,
          fit: fit,
          cacheWidth: cacheWidth,
          gaplessPlayback: true,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded || reduceMotion) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: AppMotion.base,
              curve: AppMotion.standard,
              child: child,
            );
          },
          loadingBuilder: (context, child, progress) =>
              progress == null ? child : placeholder(context),
          errorBuilder: (context, error, stack) =>
              (fallback ?? placeholder)(context),
        );
      },
    );

    if (semanticLabel != null) {
      image = Semantics(image: true, label: semanticLabel, child: image);
    } else {
      image = ExcludeSemantics(child: image);
    }
    return image;
  }
}
