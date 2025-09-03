import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/message_model.dart';

class ChatController extends GetxController {
  var messages = <Message>[].obs;
  var isLoading = false.obs;
  var isTyping = false.obs; // <- simulate other user typing
  final messageTextController = TextEditingController();
  final scrollController = ScrollController();

  final String currentUserId = 'owner_id';

  @override
  void onInit() {
    super.onInit();
    fetchMessages();

    // demo: flip typing state occasionally (remove in prod)
    ever(
      messages,
      (_) => Future.delayed(const Duration(milliseconds: 50), _scrollToBottom),
    );
  }

  void fetchMessages() {
    isLoading.value = true;
    messages.value = [
      Message(
        text: 'Hello! I have a question about my booking.',
        senderId: 'user_id_1',
        timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
      ),
      Message(
        text: 'Hi there! I\'d be happy to help. What\'s your question?',
        senderId: currentUserId,
        timestamp: DateTime.now().subtract(const Duration(minutes: 34)),
      ),
      Message(
        text: 'Can I reschedule for tomorrow at 3 PM?',
        senderId: 'user_id_1',
        timestamp: DateTime.now().subtract(const Duration(minutes: 32)),
      ),
    ];
    isLoading.value = false;
    _scrollToBottom();
  }

  void sendMessage() {
    final text = messageTextController.text.trim();
    if (text.isEmpty) return;

    messages.add(
      Message(text: text, senderId: currentUserId, timestamp: DateTime.now()),
    );
    messageTextController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (!scrollController.hasClients) return;
    Future.delayed(const Duration(milliseconds: 80), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0, // list is reversed
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
