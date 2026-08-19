import 'dart:convert';
import 'dart:developer';
import 'package:cabme_driver/features/notifications/model/notification_model.dart';
import 'package:cabme_driver/service/api.dart';
import 'package:cabme_driver/core/utils/Preferences.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NotificationController extends GetxController {
  var isLoading = true.obs;
  var notifications = <NotificationModel>[].obs;
  var errorMessage = ''.obs;
  var unreadCount = 0.obs;
  var hasMore = false.obs;
  var total = 0.obs;
  var selectedCategory = 'ride'.obs; // 'ride' or 'broadcast'

  int _currentOffset = 0;
  final int _limit = 20;

  // Get filtered notifications based on selected category
  List<NotificationModel> get filteredNotifications {
    return notifications
        .where((n) => n.category == selectedCategory.value)
        .toList();
  }

  // Get available categories - always show Ride and Broadcast
  List<String> get availableCategories {
    return ['ride', 'broadcast'];
  }

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    fetchUnreadCount();
  }

  Future<void> fetchNotifications({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentOffset = 0;
        notifications.clear();
      }

      isLoading.value = true;
      errorMessage.value = '';

      final driverId = Preferences.getInt(Preferences.userId);
      if (driverId == 0) {
        errorMessage.value = 'Driver not logged in';
        isLoading.value = false;
        return;
      }

      final url = API.getNotifications(
            limit: _limit,
            offset: _currentOffset,
          ) +
          '&driver_id=$driverId';

      log('📡 Fetching notifications from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: API.header,
      );

      log('📥 Response status: ${response.statusCode}');
      log('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        log('📥 Response parsed: success=${responseBody['success']}, data=${responseBody['data']}');

        if (responseBody['success'] == 'success' ||
            responseBody['success'] == true) {
          if (responseBody['data'] != null) {
            final List<dynamic> data = responseBody['data'];
            final List<NotificationModel> newNotifications =
                data.map((item) => NotificationModel.fromJson(item)).toList();

            if (refresh) {
              notifications.value = newNotifications;
            } else {
              notifications.addAll(newNotifications);
            }

            // Update meta information
            if (responseBody['meta'] != null) {
              total.value = responseBody['meta']['total'] ?? 0;
              unreadCount.value = responseBody['meta']['unread_count'] ?? 0;
              hasMore.value = responseBody['meta']['has_more'] ?? false;
            }

            _currentOffset += newNotifications.length;

            log('✅ Loaded ${notifications.length} notifications (${unreadCount.value} unread)');
          } else {
            log('⚠️ No data in response');
            if (refresh) {
              notifications.value = [];
            }
          }
        } else {
          // Handle error response
          final errorMsg = responseBody['error'] ??
              responseBody['message'] ??
              'Failed to load notifications';
          errorMessage.value = errorMsg.toString();
          log('❌ API Error: $errorMsg');
          if (refresh) {
            notifications.value = [];
          }
        }
      } else {
        // Handle non-200 status codes
        final Map<String, dynamic>? errorBody =
            response.statusCode >= 400 && response.statusCode < 500
                ? json.decode(response.body)
                : null;
        final errorMsg = errorBody?['error'] ??
            errorBody?['message'] ??
            'Failed to load notifications (${response.statusCode})';
        errorMessage.value = errorMsg.toString();
        log('❌ HTTP Error ${response.statusCode}: $errorMsg');
        if (refresh) {
          notifications.value = [];
        }
      }
    } catch (e) {
      log('❌ Error fetching notifications: $e');
      errorMessage.value = 'Error: ${e.toString()}';
      if (refresh) {
        notifications.value = [];
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final driverId = Preferences.getInt(Preferences.userId);
      if (driverId == 0) return;

      final url = API.getUnreadCount() + '&driver_id=$driverId';
      final response = await http.get(Uri.parse(url), headers: API.header);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['success'] == 'success' ||
            responseBody['success'] == true) {
          unreadCount.value = responseBody['unread_count'] ?? 0;
        }
      } else {
        log('❌ Error fetching unread count: HTTP ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Error fetching unread count: $e');
    }
  }

  Future<bool> markAsRead(int notificationId) async {
    try {
      final driverId = Preferences.getInt(Preferences.userId);
      if (driverId == 0) return false;

      final url = API.markAsRead(notificationId) + '&driver_id=$driverId';
      final response = await http.post(Uri.parse(url), headers: API.header);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['success'] == 'success') {
          // Update local notification
          final index = notifications.indexWhere((n) => n.id == notificationId);
          if (index != -1) {
            final notification = notifications[index];
            notifications[index] = NotificationModel(
              id: notification.id,
              title: notification.title,
              message: notification.message,
              type: notification.type,
              status: 'read',
              isRead: true,
              fromId: notification.fromId,
              createdAt: notification.createdAt,
              updatedAt: notification.updatedAt,
              timeAgo: notification.timeAgo,
            );
            unreadCount.value =
                (unreadCount.value - 1).clamp(0, double.infinity).toInt();
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      log('❌ Error marking notification as read: $e');
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final driverId = Preferences.getInt(Preferences.userId);
      if (driverId == 0) return false;

      final url = API.markAllAsRead() + '&driver_id=$driverId';
      final response = await http.post(Uri.parse(url), headers: API.header);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['success'] == 'success') {
          // Update all local notifications
          notifications.value = notifications.map((n) {
            return NotificationModel(
              id: n.id,
              title: n.title,
              message: n.message,
              type: n.type,
              status: 'read',
              isRead: true,
              fromId: n.fromId,
              createdAt: n.createdAt,
              updatedAt: n.updatedAt,
              timeAgo: n.timeAgo,
            );
          }).toList();
          unreadCount.value = 0;
          return true;
        }
      }
      return false;
    } catch (e) {
      log('❌ Error marking all as read: $e');
      return false;
    }
  }

  Future<bool> deleteNotification(int notificationId) async {
    try {
      final driverId = Preferences.getInt(Preferences.userId);
      if (driverId == 0) return false;

      final url =
          API.deleteNotification(notificationId) + '&driver_id=$driverId';
      final response = await http.delete(Uri.parse(url), headers: API.header);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['success'] == 'success') {
          notifications.removeWhere((n) => n.id == notificationId);
          // Update unread count if it was unread
          final notification =
              notifications.firstWhereOrNull((n) => n.id == notificationId);
          if (notification != null && notification.isRead == false) {
            unreadCount.value =
                (unreadCount.value - 1).clamp(0, double.infinity).toInt();
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      log('❌ Error deleting notification: $e');
      return false;
    }
  }

  Future<void> refreshNotifications() async {
    await fetchNotifications(refresh: true);
    await fetchUnreadCount();
  }

  void loadMore() {
    if (hasMore.value && !isLoading.value) {
      fetchNotifications();
    }
  }
}
