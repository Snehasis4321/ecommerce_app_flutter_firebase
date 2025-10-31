import 'package:intl/intl.dart';

/// Converts a millisecond timestamp into a smart, human-readable relative date.
///
/// Examples:
/// - "5 minutes ago"
/// - "3 hours ago"
/// - "Yesterday at 9:15 PM"
/// - "28 Oct 2025, 8:30 PM"
///
/// Automatically adjusts to the device's local timezone.
String formatSmartDate(int timestamp) {
  if (timestamp <= 0) return "Date unavailable";

  final localDate =
  DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true).toLocal();
  final now = DateTime.now();

  final difference = now.difference(localDate);
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final orderDay = DateTime(localDate.year, localDate.month, localDate.day);

  final timeFormat = DateFormat('hh:mm a');

  // 🔹 Relative time (for recent events)
  if (difference.inSeconds < 60) {
    return "Just now";
  } else if (difference.inMinutes < 60) {
    final mins = difference.inMinutes;
    return "$mins minute${mins == 1 ? '' : 's'} ago";
  } else if (difference.inHours < 24 && orderDay == today) {
    final hours = difference.inHours;
    return "$hours hour${hours == 1 ? '' : 's'} ago";
  } else if (orderDay == yesterday) {
    return "Yesterday at ${timeFormat.format(localDate)}";
  } else if (difference.inDays < 7) {
    return "${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago";
  }

  // 🔹 For older orders — show full date
  return DateFormat('dd MMM yyyy, hh:mm a').format(localDate);
}
