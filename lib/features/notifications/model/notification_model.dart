import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String type;
  final String status;
  final bool isRead;
  final int fromId;
  final String createdAt;
  final String updatedAt;
  final String timeAgo;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.status,
    required this.isRead,
    required this.fromId,
    required this.createdAt,
    required this.updatedAt,
    required this.timeAgo,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Parse is_read - handle both bool and string
    bool parsedIsRead = false;
    if (json['is_read'] != null) {
      if (json['is_read'] is bool) {
        parsedIsRead = json['is_read'] as bool;
      } else if (json['is_read'] is String) {
        parsedIsRead = json['is_read'].toString().toLowerCase() == 'true' ||
            json['is_read'].toString() == '1';
      } else if (json['is_read'] is int) {
        parsedIsRead = json['is_read'] == 1;
      }
    } else {
      parsedIsRead = (json['status'] == 'read' || json['statut'] == 'read');
    }

    return NotificationModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? json['titre'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? json['statut'] ?? 'yes',
      isRead: parsedIsRead,
      fromId: int.tryParse(json['from_id']?.toString() ?? '0') ?? 0,
      createdAt:
          json['created_at']?.toString() ?? json['creer']?.toString() ?? '',
      updatedAt:
          json['updated_at']?.toString() ?? json['modifier']?.toString() ?? '',
      timeAgo: json['time_ago']?.toString() ??
          json['creer_modify']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'status': status,
      'is_read': isRead,
      'from_id': fromId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'time_ago': timeAgo,
    };
  }

  String get formattedDate {
    if (timeAgo.isNotEmpty) {
      return timeAgo;
    }

    try {
      final date = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            return 'Just now';
          }
          return '${difference.inMinutes}m ago';
        }
        return '${difference.inHours}h ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return createdAt;
    }
  }

  // Get notification category (ride or broadcast)
  String get category {
    // Check for broadcast types first
    if (type == 'broadcast' ||
        type == 'broadcast_driver' ||
        type == 'promotion') {
      return 'broadcast';
    }

    // Normalize type - remove underscores and convert to lowercase for comparison
    final normalizedType = type.toLowerCase().replaceAll('_', '');

    // All ride-related types - check these first before defaulting
    if (type.startsWith('ride') ||
        normalizedType.startsWith('ride') ||
        type == 'ridenewrider' ||
        normalizedType == 'ridenewrider' ||
        type == 'rideconfirmed' ||
        normalizedType == 'rideconfirmed' ||
        type == 'rideonride' ||
        normalizedType == 'rideonride' ||
        type == 'ridecompleted' ||
        normalizedType == 'ridecompleted' ||
        type == 'riderejected' ||
        normalizedType == 'riderejected' ||
        type == 'ridecancelled' ||
        normalizedType == 'ridecancelled' ||
        type == 'ridecancel' ||
        normalizedType == 'ridecancel' ||
        type == 'rideassigned' ||
        normalizedType == 'rideassigned' ||
        type == 'ridestarted' ||
        normalizedType == 'ridestarted' ||
        type == 'driveronway' ||
        normalizedType == 'driveronway' ||
        type == 'driverarrived' ||
        normalizedType == 'driverarrived' ||
        type == 'adminassigned' ||
        normalizedType == 'adminassigned' ||
        type == 'scheduledrideminder' ||
        normalizedType == 'scheduledrideminder' ||
        type == 'userconfirmed' ||
        normalizedType == 'userconfirmed' ||
        type == 'forgotitem' ||
        normalizedType == 'forgotitem' ||
        type == 'new_ride' ||
        normalizedType == 'newride' ||
        type == 'ride_cancel' ||
        normalizedType == 'ridecancel' ||
        type.contains('ride') && !type.contains('broadcast')) {
      return 'ride';
    }

    // If type is empty or unknown, default to ride (most notifications are ride-related)
    if (type.isEmpty || type == '') {
      return 'ride';
    }

    // Only return broadcast if explicitly a broadcast type
    return 'broadcast';
  }

  // Get notification type icon
  IconData get typeIcon {
    switch (category) {
      case 'ride':
        if (type.contains('new') || type.contains('assigned')) {
          return Iconsax.car;
        } else if (type.contains('confirmed')) {
          return Iconsax.tick_circle;
        } else if (type.contains('completed')) {
          return Iconsax.tick_circle;
        } else if (type.contains('rejected') || type.contains('cancelled')) {
          return Iconsax.close_circle;
        } else if (type.contains('onway') || type.contains('arrived')) {
          return Iconsax.location;
        }
        return Iconsax.car;
      case 'broadcast':
        return Iconsax.notification;
      case 'wallet':
        return Iconsax.wallet;
      case 'system':
        return Iconsax.info_circle;
      case 'subscription':
        return Iconsax.calendar;
      default:
        return Iconsax.notification;
    }
  }

  // Get notification category color
  Color get categoryColor {
    switch (category) {
      case 'ride':
        return Colors.blue;
      case 'broadcast':
        return Colors.orange;
      case 'wallet':
        return Colors.green;
      case 'system':
        return Colors.purple;
      case 'subscription':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  // Get category label
  String get categoryLabel {
    switch (category) {
      case 'ride':
        return 'Ride';
      case 'broadcast':
        return 'Broadcast';
      case 'wallet':
        return 'Wallet';
      case 'system':
        return 'System';
      case 'subscription':
        return 'Subscription';
      default:
        return 'Other';
    }
  }
}
