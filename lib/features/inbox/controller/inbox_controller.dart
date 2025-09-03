// lib/features/inbox/controller/inbox_controller.dart
import 'package:get/get.dart';
import '../data/conversation_model.dart';

class InboxController extends GetxController {
  var conversations = <Conversation>[].obs;
  var isLoading = false.obs;

  // NEW: local search query
  final query = ''.obs;

  // Derived list based on query
  List<Conversation> get filtered {
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return conversations;
    return conversations.where((c) {
      final hay = '${c.name} ${c.lastMessage}'.toLowerCase();
      return hay.contains(q);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchConversations();
  }

  Future<void> fetchConversations() async {
    isLoading.value = true;
    await Future.delayed(
      const Duration(milliseconds: 450),
    ); // UX: brief shimmer
    conversations.value = [
      Conversation(
        id: '1',
        name: 'John Smith',
        avatarUrl: 'https://i.pravatar.cc/150?img=1',
        lastMessage: 'Sure, I will be there at 5 PM.',
        time: '5:30 PM',
        unreadCount: 2,
      ),
      Conversation(
        id: '2',
        name: 'Jane Doe',
        avatarUrl: 'https://i.pravatar.cc/150?img=2',
        lastMessage: 'Thank you for the wonderful haircut!',
        time: 'Yesterday',
      ),
      Conversation(
        id: '3',
        name: 'Emily White',
        avatarUrl: 'https://i.pravatar.cc/150?img=3',
        lastMessage: 'Can I reschedule my appointment?',
        time: '3d ago',
      ),
    ];
    isLoading.value = false;
  }

  void onSearch(String value) => query.value = value;

  // Optional: fake archive/delete to demo swipe
  void archive(String id) => conversations.refresh();
  void delete(String id) {
    conversations.removeWhere((e) => e.id == id);
    conversations.refresh();
  }
}
