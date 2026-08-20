/// PAIRRA Design System — single import surface for the entire foundational
/// visual system. Feature code should import this (and `theme/theme.dart` for
/// raw tokens) rather than reaching into individual files.
library;

// Theme tokens (colors, spacing, typography, motion, glass).
export '../theme/theme.dart';

// Accessibility.
export 'accessibility/accessibility_controller.dart';
export 'accessibility/accessibility_scope.dart';
export 'accessibility/accessibility_settings.dart';

// Foundations.
export 'foundations/liquid_glass_surface.dart';
export 'foundations/pairra_image.dart';

// Motion utilities.
export 'motion/animated_compatibility_score.dart';
export 'motion/appear.dart';
export 'motion/pressable_scale.dart';

// Components.
export 'components/liquid_glass_bottom_sheet.dart';
export 'components/liquid_glass_button.dart';
export 'components/liquid_glass_card.dart';
export 'components/liquid_glass_chip.dart';
export 'components/glass_icon_button.dart';
export 'components/liquid_glass_fab.dart';
export 'components/liquid_glass_modal.dart';
export 'components/liquid_glass_navigation.dart';
export 'components/liquid_glass_overlay.dart';
export 'components/liquid_glass_section.dart';
export 'components/liquid_glass_tab_bar.dart';
export 'components/liquid_glass_text_field.dart';
