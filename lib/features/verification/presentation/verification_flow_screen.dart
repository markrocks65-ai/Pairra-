import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../application/verification_providers.dart';
import '../domain/verification_check.dart';

/// The photo / identity verification flow. When a provider is connected this
/// launches it; when not, it clearly presents the flow as coming soon /
/// development-only and never fabricates a result.
class VerificationFlowScreen extends ConsumerWidget {
  const VerificationFlowScreen({super.key, required this.type});

  final VerificationCheckType type;

  List<String> get _steps => switch (type) {
        VerificationCheckType.photo => const [
            'Position your face in the frame',
            'Follow the quick on-screen prompts',
            'We privately match it to your profile photos',
          ],
        VerificationCheckType.identity => const [
            'Photograph a government-issued ID',
            'Take a quick selfie',
            'We privately confirm they match',
          ],
      };

  String get _privacyLine => type == VerificationCheckType.photo
      ? 'Your selfie is processed by our verification partner and is never '
          'shown to anyone. Only your verification status appears on your profile.'
      : 'Your ID and selfie are processed by our verification partner and are '
          'never shown to anyone. Only your verification status appears on your '
          'profile.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connected = ref.watch(verificationProviderProvider).isConnected;
    final state = ref.watch(verificationStateProvider);
    final status = type == VerificationCheckType.photo
        ? state.photo
        : state.identity;
    final verified = status.isVerified;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(type.label, style: AppTypography.headingSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Center(
              child: Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                    color: AppColors.accentWash, shape: BoxShape.circle),
                child: Icon(
                  type == VerificationCheckType.photo
                      ? Icons.face_retouching_natural
                      : Icons.badge_outlined,
                  color: AppColors.accent,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(type.description,
                textAlign: TextAlign.center,
                style: AppTypography.bodyLarge
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xxl),
            if (!connected && !verified) const _ComingSoonBanner(),
            if (!connected && !verified) const SizedBox(height: AppSpacing.xl),
            Text('HOW IT WORKS', style: AppTypography.label),
            const SizedBox(height: AppSpacing.md),
            for (var i = 0; i < _steps.length; i++) ...[
              _Step(number: i + 1, text: _steps[i]),
              const SizedBox(height: AppSpacing.md),
            ],
            const SizedBox(height: AppSpacing.md),
            _PrivacyNote(text: _privacyLine),
            const SizedBox(height: AppSpacing.xxl),
            if (verified)
              const _VerifiedState()
            else
              LiquidGlassButton(
                label: connected ? 'Start ${type.label.toLowerCase()}' : 'Coming soon',
                icon: connected ? Icons.arrow_forward : null,
                expand: true,
                // Disabled until a real provider is connected — never fakes it.
                onPressed: connected
                    ? () => ref.read(verificationProviderProvider).start(type)
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}

class _ComingSoonBanner extends StatelessWidget {
  const _ComingSoonBanner();

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      level: GlassLevel.subtle,
      child: Row(
        children: [
          const Icon(Icons.construction_outlined,
              size: 18, color: AppColors.warning),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Coming soon. This is a preview of the flow — verification isn\'t '
              'active yet, so no one is marked verified.',
              style: AppTypography.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});
  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Text('$number',
              style: AppTypography.caption.copyWith(color: AppColors.accent)),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(text, style: AppTypography.bodyLarge),
          ),
        ),
      ],
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      level: GlassLevel.subtle,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_outline, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTypography.caption)),
        ],
      ),
    );
  }
}

class _VerifiedState extends StatelessWidget {
  const _VerifiedState();

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      child: Row(
        children: [
          const Icon(Icons.verified, color: AppColors.accent, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text('You\'re verified. Nice.',
                style: AppTypography.bodyLarge),
          ),
        ],
      ),
    );
  }
}
