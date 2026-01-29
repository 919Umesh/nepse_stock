import 'package:intl/intl.dart';

/// Utility class for formatting values
class Formatters {
  /// Format currency in NPR
  static String formatCurrency(double amount, {bool showSymbol = true}) {
    final formatter = NumberFormat('#,##,##0.00', 'en_IN');
    final formatted = formatter.format(amount);
    return showSymbol ? 'NPR $formatted' : formatted;
  }
  
  /// Format large numbers with K, L suffix
  static String formatLargeNumber(double number) {
    if (number >= 10000000) {
      // Crore
      return '${(number / 10000000).toStringAsFixed(2)}Cr';
    } else if (number >= 100000) {
      // Lakh
      return '${(number / 100000).toStringAsFixed(2)}L';
    } else if (number >= 1000) {
      // Thousand
      return '${(number / 1000).toStringAsFixed(2)}K';
    }
    return number.toStringAsFixed(2);
  }
  
  /// Format percentage
  static String formatPercentage(double percentage, {bool showPlus = false}) {
    final sign = percentage >= 0 ? (showPlus ? '+' : '') : '';
    return '$sign${percentage.toStringAsFixed(2)}%';
  }
  
  /// Format date and time
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
  }
  
  /// Format date only
  static String formatDate(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }
  
  /// Format time only
  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }
  
  /// Format relative time (e.g., "2 hours ago")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 7) {
      return formatDate(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
  
  /// Compact currency format (e.g., "1.2L" instead of "NPR 1,20,000.00")
  static String formatCompactCurrency(double amount) {
    return 'NPR ${formatLargeNumber(amount)}';
  }
}
