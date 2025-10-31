import 'package:intl/intl.dart';

String formatSmartDate(int timestamp) {
  if (timestamp <= 0) return "Date unavailable";

  final orderDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final now = DateTime.now();

  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final orderDay = DateTime(orderDate.year, orderDate.month, orderDate.day);

  final timeFormat = DateFormat('hh:mm a');

  if (orderDay == today) {
    return "Today at ${timeFormat.format(orderDate)}";
  } else if (orderDay == yesterday) {
    return "Yesterday at ${timeFormat.format(orderDate)}";
  } else {
    return DateFormat('dd MMM yyyy, hh:mm a').format(orderDate);
  }
}

/// Returns human-readable relative time like “2 hours ago”, “3 days ago”.
String formatRelativeTime(int timestamp) {
  if (timestamp <= 0) return "Unknown time";

  final orderDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final now = DateTime.now();
  final difference = now.difference(orderDate);

  if (difference.inSeconds < 60) {
    return "Just now";
  } else if (difference.inMinutes < 60) {
    return "${difference.inMinutes} min${difference.inMinutes == 1 ? '' : 's'} ago";
  } else if (difference.inHours < 24) {
    return "${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago";
  } else if (difference.inDays < 7) {
    return "${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago";
  } else {
    return DateFormat('dd MMM yyyy').format(orderDate);
  }
}
