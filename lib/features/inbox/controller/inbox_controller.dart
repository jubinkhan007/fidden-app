import 'dart:convert';
import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/inbox/data/message_model.dart';
import 'package:fidden/features/inbox/data/thread_data_model.dart';
import 'package:fidden/features/user/profile/controller/profile_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class InboxController extends GetxController {
  var threads = <Thread>[].obs;
  var isLoading = false.obs;
  final query = ''.obs;

  // To get current user info
  final ProfileController _profileController = Get.find<ProfileController>();

  List<Thread> get filtered {
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return threads;
    return threads.where((c) {
      final otherPartyName = getOtherPartyName(c).toLowerCase();
      final lastMessage = getLastMessageText(c).toLowerCase();
      return otherPartyName.contains(q) || lastMessage.contains(q);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchConversations();
  }

  int get _myUserId =>
      int.tryParse(_profileController.profileDetails.value.data?.id ?? '') ??
      -1;

  MessageModel? last(Thread t) => _getLastMessage(t);

  bool isLastFromMe(Thread t) {
    final m = last(t);
    if (m == null) return false;
    return m.sender == _myUserId;
  }

  bool isLastUnreadForMe(Thread t) {
    final m = last(t);
    if (m == null) return false;
    // unread AND not sent by me
    return m.isRead == false && m.sender != _myUserId;
  }

  String getLastMessagePreview(Thread t) {
    final m = last(t);
    if (m == null) return 'No messages yet.';
    return isLastFromMe(t) ? 'You: ${m.content}' : m.content;
  }

  void patchLastMessage(int threadId, MessageModel m) {
    final idx = threads.indexWhere((t) => t.id == threadId);
    if (idx == -1) return;
    final t = threads[idx];

    // mutate the list, then notify
    t.messages.removeWhere((x) => x.id == m.id);
    t.messages.add(m);

    // resort by latest message
    threads.sort((a, b) {
      final la =
          _getLastMessage(a)?.timestamp ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final lb =
          _getLastMessage(b)?.timestamp ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return lb.compareTo(la);
    });

    threads.refresh(); // <- force UI update
  }

  Future<void> fetchConversations() async {
    isLoading.value = true;
    try {
      final response = await NetworkCaller().getRequest(
        AppUrls.threads,
        token: AuthService.accessToken,
      );

      if (response.isSuccess && response.responseData is List) {
        threads.value = threadFromJson(jsonEncode(response.responseData));
        // Sort threads by the timestamp of the last message
        threads.sort((a, b) {
          final lastMsgA = _getLastMessage(a);
          final lastMsgB = _getLastMessage(b);
          if (lastMsgA == null) return 1;
          if (lastMsgB == null) return -1;
          return lastMsgB.timestamp.compareTo(lastMsgA.timestamp);
        });
      } else {
        AppSnackBar.showError(
          response.errorMessage ?? "Failed to load messages.",
        );
      }
    } catch (e) {
      AppSnackBar.showError('An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void onSearch(String value) => query.value = value;

  // Helper methods to derive UI data from the Thread model
  String getOtherPartyName(Thread thread) {
    final currentUserRole = AuthService.role?.toLowerCase();
    // Assuming 'user' role chats with 'owner' (shop) and vice-versa.
    if (currentUserRole == 'user') {
      return thread.shopName;
    }
    return thread.userEmail;
  }

  String getOtherPartyAvatar(Thread thread) {
    // API MISSING FIELD: returning a placeholder
    return 'https://i.pravatar.cc/150?u=${thread.id}';
  }

  MessageModel? _getLastMessage(Thread thread) {
    if (thread.messages.isEmpty) return null;
    // Messages should already be sorted by timestamp from the API,
    // but we sort here just in case to get the latest one.
    thread.messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return thread.messages.first;
  }

  String getLastMessageText(Thread thread) {
    return _getLastMessage(thread)?.content ?? 'No messages yet.';
  }

  String getLastMessageTime(Thread thread) {
    final lastMsg = _getLastMessage(thread);
    if (lastMsg == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDate = DateTime(
      lastMsg.timestamp.year,
      lastMsg.timestamp.month,
      lastMsg.timestamp.day,
    );

    if (today == msgDate) {
      return DateFormat('h:mm a').format(lastMsg.timestamp); // 5:30 PM
    } else if (today.difference(msgDate).inDays == 1) {
      return 'Yesterday';
    }
    return DateFormat('d MMM').format(lastMsg.timestamp); // 5 Sep
  }

  int getUnreadCount(Thread thread) {
    final currentUserIdStr = _profileController.profileDetails.value.data?.id;
    if (currentUserIdStr == null) return 0;

    final currentUserId = int.tryParse(currentUserIdStr);
    if (currentUserId == null) return 0;

    return thread.messages
        .where((msg) => !msg.isRead && msg.sender != currentUserId)
        .length;
  }

  void archive(String id) {
    Get.snackbar('Archive', 'Archive feature not available.');
  }

  void delete(String id) {
    Get.snackbar('Delete', 'Delete feature not available.');
  }
}
