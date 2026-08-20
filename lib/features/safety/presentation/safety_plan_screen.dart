import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../application/safety_plan_controller.dart';
import '../domain/safety_plan.dart';

/// Create a date safety plan: who you're meeting, where, when, an optional
/// trusted contact, and an optional check-in reminder.
class SafetyPlanScreen extends ConsumerStatefulWidget {
  const SafetyPlanScreen({super.key, this.initialName, this.initialPlace});

  final String? initialName;
  final String? initialPlace;

  @override
  ConsumerState<SafetyPlanScreen> createState() => _SafetyPlanScreenState();
}

class _SafetyPlanScreenState extends ConsumerState<SafetyPlanScreen> {
  late final TextEditingController _name =
      TextEditingController(text: widget.initialName ?? '');
  late final TextEditingController _place =
      TextEditingController(text: widget.initialPlace ?? '');
  final _contact = TextEditingController();
  late DateTime _time;
  bool _checkIn = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _time = DateTime(now.year, now.month, now.day, 19);
  }

  @override
  void dispose() {
    _name.dispose();
    _place.dispose();
    _contact.dispose();
    super.dispose();
  }

  static Widget _darkPicker(BuildContext context, Widget? child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            surface: AppColors.surfaceElevated,
            onSurface: AppColors.textPrimary,
          ),
          dialogTheme: const DialogThemeData(backgroundColor: AppColors.surface),
        ),
        child: child!,
      );

  Future<void> _pickTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _time,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: _darkPicker,
    );
    if (date == null || !mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _time.hour, minute: _time.minute),
      builder: _darkPicker,
    );
    if (!mounted) return;
    setState(() => _time = DateTime(
        date.year, date.month, date.day, t?.hour ?? 19, t?.minute ?? 0));
  }

  void _save() {
    ref.read(safetyPlansProvider.notifier).add(SafetyPlan(
          id: 'plan_${DateTime.now().microsecondsSinceEpoch}',
          meetingName: _name.text.trim(),
          place: _place.text.trim(),
          time: _time,
          trustedContact:
              _contact.text.trim().isEmpty ? null : _contact.text.trim(),
          checkInEnabled: _checkIn,
          checkInAt: _checkIn ? _time.add(const Duration(hours: 2)) : null,
          createdAt: DateTime.now(),
        ));
    LiquidGlassOverlay.show(
      context,
      title: 'Safety plan saved',
      message: _checkIn
          ? 'We\'ll check in with you after your date.'
          : 'Have a great time.',
      icon: Icons.shield_outlined,
      tone: OverlayTone.success,
    );
    Navigator.of(context).maybePop();
  }

  String _timeLabel(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.month}/${d.day} · $h:$m ${d.hour < 12 ? 'AM' : 'PM'}';
  }

  @override
  Widget build(BuildContext context) {
    final canSave =
        _name.text.trim().isNotEmpty && _place.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text('Safety plan', style: AppTypography.headingSmall),
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
            Text('Just for you — a plan makes a date feel easy. It\'s private '
                'and never shared with your match.',
                style: AppTypography.bodySecondary),
            const SizedBox(height: AppSpacing.xl),
            LiquidGlassTextField(
              controller: _name,
              label: 'I\'m meeting',
              hint: 'Their name',
              prefixIcon: Icons.person_outline,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.lg),
            LiquidGlassTextField(
              controller: _place,
              label: 'At',
              hint: 'Place or venue',
              prefixIcon: Icons.place_outlined,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Time', style: AppTypography.label),
            const SizedBox(height: AppSpacing.sm),
            PressableScale(
              onTap: _pickTime,
              child: LiquidGlassSurface(
                level: GlassLevel.subtle,
                borderRadius: BorderRadius.circular(AppRadius.md),
                showShadow: false,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    const Icon(Icons.schedule,
                        size: 20, color: AppColors.textMuted),
                    const SizedBox(width: AppSpacing.md),
                    Text(_timeLabel(_time), style: AppTypography.bodyLarge),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            LiquidGlassTextField(
              controller: _contact,
              label: 'Trusted contact (optional)',
              hint: 'Name or number to keep in the loop',
              prefixIcon: Icons.contact_phone_outlined,
            ),
            const SizedBox(height: AppSpacing.lg),
            LiquidGlassCard(
              level: GlassLevel.subtle,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Check in with me', style: AppTypography.bodyLarge),
                        Text('We\'ll send a gentle reminder ~2 hours after.',
                            style: AppTypography.caption),
                      ],
                    ),
                  ),
                  Switch(
                    value: _checkIn,
                    onChanged: (v) => setState(() => _checkIn = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            LiquidGlassButton(
              label: 'Save safety plan',
              expand: true,
              onPressed: canSave ? _save : null,
            ),
          ],
        ),
      ),
    );
  }
}
