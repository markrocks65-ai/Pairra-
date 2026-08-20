import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

/// The verified badge — deliberately subtle. Shown only when the profile is
/// actually verified (server-set). Never large or loud.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.size = 18, this.tooltip = true});

  final double size;
  final bool tooltip;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(Icons.verified, size: size, color: AppColors.accent);
    return tooltip ? Tooltip(message: 'Verified', child: icon) : icon;
  }
}
