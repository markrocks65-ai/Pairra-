import 'package:flutter/widgets.dart';

import '../../../../core/models/profile_photo.dart';
import '../../../../design_system/design_system.dart';

/// Premium gradient palette used for placeholder photos until real image
/// upload is wired in. Keyed by a stable seed so a photo keeps its look.
abstract final class ProfileGradients {
  static const seeds = ['p1', 'p2', 'p3', 'p4', 'p5', 'p6'];

  static List<Color> of(String seed) {
    switch (seed) {
      case 'p1':
        return const [Color(0xFF2B3A6B), Color(0xFF6E8BFF)];
      case 'p2':
        return const [Color(0xFF1E5C7A), Color(0xFF3FB98A)];
      case 'p3':
        return const [Color(0xFF3A2F6B), Color(0xFF7E5BFF)];
      case 'p4':
        return const [Color(0xFF5A2A3A), Color(0xFFE0A745)];
      case 'p5':
        return const [Color(0xFF20343F), Color(0xFF4A5568)];
      case 'p6':
        return const [Color(0xFF244B3A), Color(0xFF3FB98A)];
      default:
        return const [Color(0xFF20283A), Color(0xFF3A4558)];
    }
  }
}

/// Renders a [ProfilePhoto] as a tile. When the photo has a real [ProfilePhoto.url]
/// it loads through [PairraImage] (downsampled, cached, fade-in, with the
/// gradient as its loading/error state); otherwise it shows the premium gradient
/// placeholder with an optional large monogram. Call sites don't change when
/// real photos are wired in — only the data gains a `url`.
class ProfilePhotoView extends StatelessWidget {
  const ProfilePhotoView({
    super.key,
    this.photo,
    this.seed,
    this.monogram,
    this.showMonogram = true,
    this.fit = BoxFit.cover,
    this.semanticLabel,
  });

  final ProfilePhoto? photo;

  /// Explicit seed when there's no [photo] (e.g. the onboarding avatar seed).
  final String? seed;

  final String? monogram;
  final bool showMonogram;
  final BoxFit fit;

  /// Screen-reader description for real photos (e.g. "Photo of Alex").
  /// Decorative gradients stay unlabeled.
  final String? semanticLabel;

  Widget _gradient(BuildContext context) {
    final resolvedSeed = photo?.placeholderSeed ?? seed ?? 'p1';
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: ProfileGradients.of(resolvedSeed),
        ),
      ),
      child: (showMonogram && (monogram ?? '').isNotEmpty)
          ? Center(
              child: Text(
                monogram!,
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 96,
                  color: const Color(0x33FFFFFF),
                ),
              ),
            )
          : const SizedBox.expand(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = photo?.url;
    if (url == null || url.isEmpty) return _gradient(context);
    return PairraImage(
      url: url,
      fit: fit,
      semanticLabel: semanticLabel,
      placeholder: _gradient,
    );
  }
}
