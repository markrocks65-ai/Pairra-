import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../../onboarding/domain/onboarding_profile.dart';
import '../../application/profile_labels.dart';
import 'profile_photo_view.dart';

/// How the profile is being viewed. [owner] shows everything (with private
/// markers); [publicPreview] shows only what a non-matched viewer would see,
/// so previews and other-user views honor the privacy settings.
enum ProfileViewMode { owner, publicPreview }

/// The shared, editorial profile renderer: a large photography-first header
/// over calm, spaced sections. Composed of [ProfileHeaderView] + the scrolling
/// [ProfileSections], both reusable independently (e.g. the match-detail screen
/// prepends a compatibility summary between them).
class ProfileView extends StatelessWidget {
  const ProfileView({super.key, required this.profile, required this.mode});

  final OnboardingProfile profile;
  final ProfileViewMode mode;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ProfileHeaderView(profile: profile, mode: mode),
        ProfileSections(profile: profile, mode: mode),
      ],
    );
  }
}

/// Whether a field is shown for the given [mode]: the owner sees everything;
/// a public viewer sees only fields explicitly set to [FieldVisibility.public].
bool profileFieldVisible(
    OnboardingProfile profile, ProfileViewMode mode, String field) {
  if (mode == ProfileViewMode.owner) return true;
  return profile.visibilityOf(field) == FieldVisibility.public;
}

/// The stacked profile sections (About, Identity, Looking for, Interests,
/// Lifestyle, Compatibility, Preferences, Ideal dates) — sensitive fields
/// appear only when their visibility allows. Renders as a non-scrolling column
/// so it can be embedded in any scroll view.
class ProfileSections extends StatelessWidget {
  const ProfileSections({super.key, required this.profile, required this.mode});

  final OnboardingProfile profile;
  final ProfileViewMode mode;

  bool get _owner => mode == ProfileViewMode.owner;
  bool _visible(String field) => profileFieldVisible(profile, mode, field);

  @override
  Widget build(BuildContext context) {
    final p = profile;
    final roles = ProfileLabels.roleLabels(p, p.sexualRoles);
    final showRoles = roles.isNotEmpty && _visible('roles');
    final gender = ProfileLabels.gender(p);
    final orientation = ProfileLabels.orientation(p);
    final showPrefs = _owner || p.privacy.preferencesVisible;

    final lifestyle = <String?>[
      ProfileLabels.smoking(p.lifestyle.smoking),
      ProfileLabels.drinking(p.lifestyle.drinking),
      ProfileLabels.pets(p.lifestyle.pets),
      ProfileLabels.children(p.lifestyle.children),
    ].whereType<String>().toList();

    return Padding(
      // Trailing space clears the floating nav bar: this is the last thing in
      // every profile scroll view (owner, preview, candidate & match detail).
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl,
          AppSpacing.xl, AppSpacing.navBarClearance),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if ((p.bio ?? '').trim().isNotEmpty) ...[
            _Section(
              title: 'About',
              child: Text(p.bio!.trim(),
                  style: AppTypography.bodyLarge
                      .copyWith(color: AppColors.textSecondary)),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
          if ((_visible('gender') && gender != null) ||
              (_visible('orientation') && orientation != null)) ...[
            _Section(
              title: 'Identity',
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  if (_visible('gender') && gender != null) _Pill(gender),
                  if (_visible('orientation') && orientation != null)
                    _Pill(orientation),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
          if (ProfileLabels.intentions(p.datingIntentions).isNotEmpty) ...[
            _Section(
              title: 'Looking for',
              child: _Pills(ProfileLabels.intentions(p.datingIntentions)),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
          if (p.interests.isNotEmpty) ...[
            _Section(
              title: 'Interests',
              child: _Pills(ProfileLabels.interests(p.interests)),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
          if (lifestyle.isNotEmpty) ...[
            _Section(title: 'Lifestyle', child: _Pills(lifestyle)),
            const SizedBox(height: AppSpacing.xxl),
          ],
          if (showRoles) ...[
            _Section(
              title: 'Compatibility',
              visibilityTag: _owner ? p.visibilityOf('roles').label : null,
              child: _Pills(roles),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
          if (showPrefs) ...[
            _Section(
              title: 'Preferences',
              visibilityTag: _owner
                  ? (p.privacy.preferencesVisible
                      ? FieldVisibility.public.label
                      : FieldVisibility.private.label)
                  : null,
              child: _PreferencesBody(profile: p),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
          if (ProfileLabels.firstDates(p.datePreferences.firstDates)
                  .isNotEmpty ||
              p.datePreferences.budgetId != null) ...[
            _Section(
              title: 'Ideal dates',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (ProfileLabels.firstDates(p.datePreferences.firstDates)
                      .isNotEmpty)
                    _Pills(
                        ProfileLabels.firstDates(p.datePreferences.firstDates)),
                  if (p.datePreferences.budgetId != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Budget: ${ProfileLabels.budget(p.datePreferences.budgetId)}',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The large photography-first header (photo, name, age, distance, verified
/// badge). Reusable on its own (profile, preview, match detail).
class ProfileHeaderView extends StatelessWidget {
  const ProfileHeaderView({
    super.key,
    required this.profile,
    required this.mode,
    this.height = 480,
    this.distanceLabel,
  });

  final OnboardingProfile profile;
  final ProfileViewMode mode;
  final double height;

  /// The real approximate distance to show a viewer (e.g. "~4 km away"),
  /// computed by the caller from coarse coordinates. When null, the header
  /// falls back to the coarse area label — it never fabricates a distance.
  final String? distanceLabel;

  String get _monogram {
    final n = (profile.displayName ?? '').trim();
    return n.isEmpty ? '' : n.characters.first.toUpperCase();
  }

  String? get _distanceLine {
    if (mode == ProfileViewMode.owner) return profile.location.areaLabel;
    if (!profile.privacy.showDistance || !profile.location.hasLocation) {
      return null;
    }
    // Prefer a real computed distance; otherwise show the coarse area label
    // (never an invented number).
    return distanceLabel ?? profile.location.areaLabel;
  }

  @override
  Widget build(BuildContext context) {
    final seed =
        profile.photos.isNotEmpty ? profile.photos.first.placeholderSeed : 'p1';
    final name = (profile.displayName ?? '').trim();
    final age = profile.age;
    final title = age != null && name.isNotEmpty
        ? '$name, $age'
        : (name.isNotEmpty ? name : 'Your name');

    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ProfilePhotoView(seed: seed, monogram: _monogram),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [Color(0x00000000), Color(0xCC05070D)],
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            bottom: AppSpacing.xl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (profile.photos.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _PhotoDots(count: profile.photos.length),
                  ),
                Row(
                  children: [
                    Flexible(
                      child: Text(title,
                          style: AppTypography.displayLarge
                              .copyWith(fontSize: 34)),
                    ),
                    if (profile.verification.hasBadge) ...[
                      const SizedBox(width: AppSpacing.sm),
                      const Icon(Icons.verified,
                          color: AppColors.accent, size: 24),
                    ],
                  ],
                ),
                if (_distanceLine != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(_distanceLine!,
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoDots extends StatelessWidget {
  const _PhotoDots({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < count; i++)
          Container(
            width: 22,
            height: 3,
            margin: const EdgeInsets.only(right: AppSpacing.xs),
            decoration: BoxDecoration(
              color: i == 0 ? AppColors.textPrimary : AppColors.borderStrong,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.visibilityTag});

  final String title;
  final Widget child;
  final String? visibilityTag;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: AppTypography.headingSmall),
            if (visibilityTag != null) ...[
              const SizedBox(width: AppSpacing.sm),
              _VisibilityTag(visibilityTag!),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        child,
      ],
    );
  }
}

class _VisibilityTag extends StatelessWidget {
  const _VisibilityTag(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 11, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _Pills extends StatelessWidget {
  const _Pills(this.labels);
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [for (final l in labels) _Pill(l)],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassSurface(
      level: GlassLevel.subtle,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      showShadow: false,
      showBorder: false,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm + 2),
      child: Text(label, style: AppTypography.buttonSmall),
    );
  }
}

class _PreferencesBody extends StatelessWidget {
  const _PreferencesBody({required this.profile});
  final OnboardingProfile profile;

  @override
  Widget build(BuildContext context) {
    final p = profile;
    final preferredRoles =
        ProfileLabels.roleLabels(p, p.lookingFor.preferredRoles);
    final rel = ProfileLabels.relationshipTypes(p.lookingFor.relationshipTypes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ages ${p.lookingFor.ageMin}–${p.lookingFor.ageMax} · '
          'within ${p.lookingFor.maxDistanceKm.round()} km',
          style:
              AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        if (preferredRoles.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _Pills(preferredRoles),
        ],
        if (rel.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _Pills(rel),
        ],
      ],
    );
  }
}
