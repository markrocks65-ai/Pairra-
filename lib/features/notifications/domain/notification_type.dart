/// Notification categories. Preferences and delivery are governed per category.
/// [safety] is treated entirely separately from [marketing]: it's always
/// delivered in-app and ignores quiet hours, and can't be switched off.
enum NotificationCategory {
  safety('Safety'),
  activity('Activity'),
  account('Account'),
  marketing('Recommendations');

  const NotificationCategory(this.label);
  final String label;

  bool get isSafety => this == NotificationCategory.safety;
}

/// Every kind of notification PAIRRA can send, mapped to the category that
/// governs it.
enum NotificationType {
  newMatch('New match', NotificationCategory.activity),
  newMessage('New message', NotificationCategory.activity),
  like('New like', NotificationCategory.activity),
  dateReminder('Date reminder', NotificationCategory.activity),
  subscription('Subscription', NotificationCategory.account),
  verification('Verification', NotificationCategory.account),
  safetyCheckIn('Safety check-in', NotificationCategory.safety),
  dateSuggestion('Date suggestion', NotificationCategory.marketing),
  profileActivity('Profile activity', NotificationCategory.marketing);

  const NotificationType(this.label, this.category);
  final String label;
  final NotificationCategory category;
}

/// A delivery channel the user can control.
enum NotificationChannel { push, email, inApp }
