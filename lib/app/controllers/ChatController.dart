import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:io';

import '../routes/app_pages.dart';


enum MessageType { text, image, file, voice }

class ChatMessage {
  final String id;
  final String senderId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final String? fileName;
  final int? fileSize;
  final String? replyToId;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    this.type = MessageType.text,
    required this.timestamp,
    this.isRead = false,
    this.fileName,
    this.fileSize,
    this.replyToId,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      content: map['content'] ?? '',
      type: MessageType.values.firstWhere(
            (e) => e.toString() == map['type'],
        orElse: () => MessageType.text,
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      isRead: map['isRead'] ?? false,
      fileName: map['fileName'],
      fileSize: map['fileSize'],
      replyToId: map['replyToId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'content': content,
      'type': type.toString(),
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
      'fileName': fileName,
      'fileSize': fileSize,
      'replyToId': replyToId,
    };
  }
}

class ChatController extends GetxController {
  final TextEditingController messageController = TextEditingController();

  // Observable variables
  var isLoading = false.obs;
  var messages = <ChatMessage>[].obs;
  var recipientName = ''.obs;
  var recipientPhotoUrl = ''.obs;
  var shipmentId = ''.obs;
  var shipmentStatus = ''.obs;
  var isOnline = false.obs;
  var isRecipientTyping = false.obs;
  var canSendMessage = false.obs;
  var isRecording = false.obs;

  // Streams and subscriptions
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _onlineStatusSubscription;
  StreamSubscription? _typingSubscription;
  Timer? _typingTimer;

  // Properties
  String get currentUserId => 'current_user_id'; // Replace with actual user ID
  String get recipientId => Get.arguments?['recipientId'] ?? '';
  String get chatId => _generateChatId(currentUserId, recipientId);

  @override
  void onInit() {
    super.onInit();
    _initializeChat();
    _setupMessageListener();
    messageController.addListener(_onMessageTextChanged);
  }

  @override
  void onClose() {
    messageController.dispose();
    _messagesSubscription?.cancel();
    _onlineStatusSubscription?.cancel();
    _typingSubscription?.cancel();
    _typingTimer?.cancel();
    super.onClose();
  }

  void _initializeChat() {
    try {
      final args = Get.arguments ?? {};
      recipientName.value = args['recipientName'] ?? 'Driver';
      recipientPhotoUrl.value = args['recipientPhotoUrl'] ?? '';
      shipmentId.value = args['shipmentId'] ?? '';

      if (shipmentId.value.isNotEmpty) {
        _loadShipmentInfo();
      }

      _loadMessages();
      _setupOnlineStatusListener();
      _setupTypingListener();
    } catch (e) {
      print('Error initializing chat: $e');
      _showErrorSnackbar('Failed to initialize chat');
    }
  }

  void _loadShipmentInfo() async {
    try {
      // In production, load actual shipment data
      shipmentStatus.value = 'In Transit';
    } catch (e) {
      print('Error loading shipment info: $e');
    }
  }

  void _setupMessageListener() {
    // In production, listen to Firestore collection for real-time messages
    _messagesSubscription = Stream.periodic(const Duration(seconds: 2))
        .listen((_) => _checkForNewMessages());
  }

  void _setupOnlineStatusListener() {
    // In production, listen to user's online status
    _onlineStatusSubscription = Stream.periodic(const Duration(seconds: 10))
        .listen((_) => _updateOnlineStatus());
  }

  void _setupTypingListener() {
    // In production, listen to typing indicators
    _typingSubscription = Stream.periodic(const Duration(seconds: 3))
        .listen((_) => _checkTypingStatus());
  }

  void _loadMessages() async {
    try {
      isLoading.value = true;

      // Mock messages - in production, load from Firestore
      await Future.delayed(const Duration(seconds: 1));

      final mockMessages = [
        ChatMessage(
          id: '1',
          senderId: recipientId,
          content: 'Hi! I\'m on my way to pick up your shipment. ETA: 30 minutes.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          isRead: true,
        ),
        ChatMessage(
          id: '2',
          senderId: currentUserId,
          content: 'Great! Thank you for the update. Will the address on the shipment details be correct?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
          isRead: true,
        ),
        ChatMessage(
          id: '3',
          senderId: recipientId,
          content: 'Yes, I have the correct address. I\'ll call when I arrive at the pickup location.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
          isRead: true,
        ),
        ChatMessage(
          id: '4',
          senderId: currentUserId,
          content: 'Perfect. Looking forward to hearing from you.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
          isRead: true,
        ),
      ];

      messages.assignAll(mockMessages.reversed.toList());

    } catch (e) {
      print('Error loading messages: $e');
      _showErrorSnackbar('Failed to load messages');
    } finally {
      isLoading.value = false;
    }
  }

  void _checkForNewMessages() {
    // Simulate receiving new messages
    if (DateTime.now().second % 30 == 0 && messages.length < 10) {
      final newMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: recipientId,
        content: 'I\'ve arrived at the pickup location. Loading the cargo now.',
        timestamp: DateTime.now(),
        isRead: false,
      );

      messages.insert(0, newMessage);
      _markMessageAsRead(newMessage.id);
    }
  }

  void _updateOnlineStatus() {
    // Simulate online status changes
    isOnline.value = DateTime.now().second % 20 < 15;
  }

  void _checkTypingStatus() {
    // Simulate typing indicator
    isRecipientTyping.value = DateTime.now().second % 25 < 3;
  }

  void _onMessageTextChanged() {
    final hasText = messageController.text.trim().isNotEmpty;
    canSendMessage.value = hasText;

    if (hasText) {
      _sendTypingIndicator();
    }
  }

  void _sendTypingIndicator() {
    // In production, send typing indicator to recipient
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      // Stop typing indicator after 2 seconds of inactivity
    });
  }

  void sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    try {
      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: currentUserId,
        content: text,
        timestamp: DateTime.now(),
        isRead: false,
      );

      // Add message to local list immediately
      messages.insert(0, message);
      messageController.clear();
      canSendMessage.value = false;

      // In production, send to Firestore
      await _sendMessageToFirestore(message);

      // Simulate delivery confirmation
      await Future.delayed(const Duration(seconds: 1));
      _updateMessageStatus(message.id, isRead: true);

    } catch (e) {
      print('Error sending message: $e');
      _showErrorSnackbar('Failed to send message');
    }
  }

  Future<void> _sendMessageToFirestore(ChatMessage message) async {
    // In production, implement Firestore message sending
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _updateMessageStatus(String messageId, {bool? isRead}) {
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final message = messages[index];
      messages[index] = ChatMessage(
        id: message.id,
        senderId: message.senderId,
        content: message.content,
        type: message.type,
        timestamp: message.timestamp,
        isRead: isRead ?? message.isRead,
        fileName: message.fileName,
        fileSize: message.fileSize,
        replyToId: message.replyToId,
      );
    }
  }

  void _markMessageAsRead(String messageId) {
    _updateMessageStatus(messageId, isRead: true);
  }

  void makeCall() async {
    try {
      // Get recipient phone from shipment data or user profile
      const phoneNumber = '+1234567890'; // Replace with actual phone number

      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showErrorSnackbar('Unable to make phone call');
      }
    } catch (e) {
      print('Error making call: $e');
      _showErrorSnackbar('Failed to initiate call');
    }
  }

  void makeVideoCall() {
    _showInfoSnackbar('Video call feature coming soon');
  }

  void showAttachmentOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Send Attachment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  'Camera',
                  Icons.camera_alt,
                  Colors.blue,
                  sendPhoto,
                ),
                _buildAttachmentOption(
                  'Gallery',
                  Icons.photo_library,
                  Colors.green,
                  sendImageFromGallery,
                ),
                _buildAttachmentOption(
                  'Document',
                  Icons.insert_drive_file,
                  Colors.orange,
                  sendDocument,
                ),
                _buildAttachmentOption(
                  'Location',
                  Icons.location_on,
                  Colors.red,
                  sendLocation,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        Get.back();
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void sendPhoto() async {
    try {
      // In production, use image_picker to capture photo
      _showInfoSnackbar('Camera feature would open here');

      // Simulate sending photo message
      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: currentUserId,
        content: 'https://via.placeholder.com/300x200/4CAF50/FFFFFF?text=Photo',
        type: MessageType.image,
        timestamp: DateTime.now(),
        isRead: false,
      );

      messages.insert(0, message);
    } catch (e) {
      _showErrorSnackbar('Failed to send photo');
    }
  }

  void sendImageFromGallery() async {
    try {
      // In production, use image_picker to select from gallery
      _showInfoSnackbar('Gallery selection would open here');

      // Simulate sending image message
      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: currentUserId,
        content: 'https://via.placeholder.com/300x200/2196F3/FFFFFF?text=Gallery+Image',
        type: MessageType.image,
        timestamp: DateTime.now(),
        isRead: false,
      );

      messages.insert(0, message);
    } catch (e) {
      _showErrorSnackbar('Failed to send image');
    }
  }

  void sendDocument() async {
    try {
      // In production, use file_picker to select document
      _showInfoSnackbar('Document picker would open here');

      // Simulate sending document message
      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: currentUserId,
        content: 'document_url_here',
        type: MessageType.file,
        timestamp: DateTime.now(),
        isRead: false,
        fileName: 'shipment_invoice.pdf',
        fileSize: 245760, // 240 KB
      );

      messages.insert(0, message);
    } catch (e) {
      _showErrorSnackbar('Failed to send document');
    }
  }

  void sendLocation() async {
    try {
      // In production, get current location and send coordinates
      _showInfoSnackbar('Location sharing would work here');

      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: currentUserId,
        content: 'Current location shared',
        timestamp: DateTime.now(),
        isRead: false,
      );

      messages.insert(0, message);
    } catch (e) {
      _showErrorSnackbar('Failed to share location');
    }
  }

  void downloadFile(ChatMessage message) async {
    try {
      _showInfoSnackbar('Downloading ${message.fileName ?? 'file'}...');

      // In production, implement file download
      await Future.delayed(const Duration(seconds: 2));
      _showSuccessSnackbar('File downloaded successfully');
    } catch (e) {
      _showErrorSnackbar('Failed to download file');
    }
  }

  void onMessageChanged(String text) {
    // Handle message input changes
    _sendTypingIndicator();
  }

  void viewShipmentDetails() {
    if (shipmentId.value.isNotEmpty) {
      Get.toNamed(Routes.SHIPMENT_DETAILS, arguments: {
        'shipmentId': shipmentId.value,
      });
    }
  }

  void onMenuSelected(String value) {
    switch (value) {
      case 'shipment_info':
        viewShipmentDetails();
        break;
      case 'report_user':
        _reportUser();
        break;
      case 'block_user':
        _blockUser();
        break;
    }
  }

  void _reportUser() {
    Get.dialog(
      AlertDialog(
        title: const Text('Report User'),
        content: const Text('Are you sure you want to report this user?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed(Routes.SUPPORT, arguments: {
                'issueType': 'user_report',
                'reportedUserId': recipientId,
                'reportedUserName': recipientName.value,
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Report', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _blockUser() {
    Get.dialog(
      AlertDialog(
        title: const Text('Block User'),
        content: Text('Are you sure you want to block ${recipientName.value}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _performBlockUser();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Block', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _performBlockUser() async {
    try {
      // In production, implement user blocking logic
      await Future.delayed(const Duration(seconds: 1));
      _showSuccessSnackbar('User blocked successfully');
      Get.back(); // Return to previous screen
    } catch (e) {
      _showErrorSnackbar('Failed to block user');
    }
  }

  String _generateChatId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[700],
      icon: const Icon(Icons.error, color: Colors.red),
    );
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green[100],
      colorText: Colors.green[700],
      icon: const Icon(Icons.check_circle, color: Colors.green),
    );
  }

  void _showInfoSnackbar(String message) {
    Get.snackbar(
      'Info',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue[100],
      colorText: Colors.blue[700],
      icon: const Icon(Icons.info, color: Colors.blue),
    );
  }
}