/// @title Time labels
/// @notice Turns cached UTC millis into the short labels used by the inbox,
/// chat, and history rows.
/// @dev Kept dependency-free so the data layer carries no intl package.
/// @author Kosply-mobile
library;

/// @dev Weekday names indexed by `DateTime.weekday - 1`.
const List<String> _weekdays = <String>[
  'Sen',
  'Sel',
  'Rab',
  'Kam',
  'Jum',
  'Sab',
  'Min',
];

/// @dev Month names indexed by `DateTime.month - 1`.
const List<String> _months = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

/// @notice Formats a cache timestamp for inbox-style time columns.
/// @dev Today shows the clock, yesterday shows "Kemarin", the rest of the week
/// shows the weekday, and older dates show "d Mmm".
/// @param utcMillis UTC millis from a cached row.
/// @param now Override for the current time; defaults to {DateTime.now}.
/// @return The short label.
String timeLabelFor(int utcMillis, {DateTime? now}) {
  final DateTime local = DateTime.fromMillisecondsSinceEpoch(utcMillis);
  final DateTime current = now ?? DateTime.now();
  final DateTime today = DateTime(
    current.year,
    current.month,
    current.day,
  );
  final DateTime day = DateTime(local.year, local.month, local.day);
  final int days = today.difference(day).inDays;
  if (days <= 0) {
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
  if (days == 1) {
    return 'Kemarin';
  }
  if (days < 7) {
    return _weekdays[local.weekday - 1];
  }
  return '${local.day} ${_months[local.month - 1]}';
}

/// @notice Formats a cache timestamp as a seller activity line.
/// @param utcMillis UTC millis of the seller's last activity.
/// @param now Override for the current time; defaults to {DateTime.now}.
/// @return The label, e.g. "aktif 5 menit lalu".
String activityLabelFor(int utcMillis, {DateTime? now}) {
  final DateTime local = DateTime.fromMillisecondsSinceEpoch(utcMillis);
  final DateTime current = now ?? DateTime.now();
  final Duration diff = current.difference(local);
  if (diff.inMinutes < 1) {
    return 'aktif barusan';
  }
  if (diff.inMinutes < 60) {
    return 'aktif ${diff.inMinutes} menit lalu';
  }
  if (diff.inHours < 24) {
    return 'aktif ${diff.inHours} jam lalu';
  }
  if (diff.inDays == 1) {
    return 'aktif kemarin';
  }
  return 'aktif ${diff.inDays} hari lalu';
}
