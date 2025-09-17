import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/ChatController.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: controller.recipientPhotoUrl.value.isNotEmpty
                  ? NetworkImage(controller.recipientPhotoUrl.value)
                  : null,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: controller.recipientPhotoUrl.value.isEmpty
                  ? Icon(Icons.person, color: Theme.of(context).primaryColor)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.recipientName.value,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    controller.isOnline.value ? 'Online' : 'Last seen recently',
                    style: TextStyle(
                      fontSize: 12,
                      color: controller.isOnline.value ? Colors.green : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        )),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: controller.makeCall,
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: controller.makeVideoCall,
          ),
          PopupMenuButton<String>(
            onSelected: controller.onMenuSelected,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'shipment_info',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text('Shipment Info'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'report_user',
                child: Row(
                  children: [
                    Icon(Icons.report, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Report User'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'block_user',
                child: Row(
                  children: [
                    Icon(Icons.block, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Block User'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Shipment info banner
          Obx(() => controller.shipmentId.value.isNotEmpty
              ? _buildShipmentBanner(context)
              : const SizedBox.shrink()),

          // Messages list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.messages.isEmpty) {
                return _buildEmptyState(context);
              }

              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  final isNextMessageFromSameUser = index > 0 &&
                      controller.messages[index - 1].senderId == message.senderId;

                  return _buildMessageBubble(
                    context,
                    message,
                    isNextMessageFromSameUser,
                  );
                },
              );
            }),
          ),

          // Typing indicator
          Obx(() => controller.isRecipientTyping.value
              ? _buildTypingIndicator(context)
              : const SizedBox.shrink()),

          // Message input
          _buildMessageInput(context),
        ],
      ),
    );
  }

  Widget _buildShipmentBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(Icons.local_shipping, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shipment #${controller.shipmentId.value.substring(0, 8)}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Obx(() => Text(
                  controller.shipmentStatus.value,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).primaryColor.withOpacity(0.7),
                  ),
                )),
              ],
            ),
          ),
          TextButton(
            onPressed: controller.viewShipmentDetails,
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Start Conversation',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send a message to start chatting',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message, bool isNextFromSame) {
    final isMe = message.senderId == controller.currentUserId;

    return Padding(
      padding: EdgeInsets.only(
        bottom: isNextFromSame ? 2 : 12,
        top: 2,
      ),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && !isNextFromSame) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: controller.recipientPhotoUrl.value.isNotEmpty
                  ? NetworkImage(controller.recipientPhotoUrl.value)
                  : null,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: controller.recipientPhotoUrl.value.isEmpty
                  ? Icon(Icons.person, size: 16, color: Theme.of(context).primaryColor)
                  : null,
            ),
            const SizedBox(width: 8),
          ] else if (!isMe) ...[
            const SizedBox(width: 40),
          ],

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _getMessageBackgroundColor(message, isMe, context),
                borderRadius: _getMessageBorderRadius(isMe, isNextFromSame),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.type == MessageType.image)
                    _buildImageMessage(message)
                  else if (message.type == MessageType.file)
                    _buildFileMessage(message)
                  else
                    _buildTextMessage(message, isMe),

                  const SizedBox(height: 4),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(message.timestamp),
                        style: TextStyle(
                          color: isMe ? Colors.white70 : Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color: message.isRead ? Colors.blue[300] : Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (isMe) ...[
            const SizedBox(width: 8),
            if (!isNextFromSame)
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.person, size: 16, color: Colors.white),
              )
            else
              const SizedBox(width: 32),
          ],
        ],
      ),
    );
  }

  Widget _buildTextMessage(ChatMessage message, bool isMe) {
    return Text(
      message.content,
      style: TextStyle(
        color: isMe ? Colors.white : Colors.black87,
        fontSize: 16,
      ),
    );
  }

  Widget _buildImageMessage(ChatMessage message) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        message.content,
        width: 200,
        height: 150,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 200,
            height: 150,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 200,
            height: 150,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image),
          );
        },
      ),
    );
  }

  Widget _buildFileMessage(ChatMessage message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.fileName ?? 'Document',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (message.fileSize != null)
                  Text(
                    _formatFileSize(message.fileSize!),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => controller.downloadFile(message),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundImage: controller.recipientPhotoUrl.value.isNotEmpty
                ? NetworkImage(controller.recipientPhotoUrl.value)
                : null,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: controller.recipientPhotoUrl.value.isEmpty
                ? Icon(Icons.person, size: 12, color: Theme.of(context).primaryColor)
                : null,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 2),
                _buildTypingDot(1),
                const SizedBox(width: 2),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.5 + (value * 0.5),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment button
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: controller.showAttachmentOptions,
            ),

            // Message input field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: controller.messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: controller.onMessageChanged,
                  onSubmitted: (_) => controller.sendMessage(),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            Obx(() => CircleAvatar(
              backgroundColor: controller.canSendMessage.value
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300],
              child: IconButton(
                icon: Icon(
                  controller.isRecording.value ? Icons.stop : Icons.send,
                  color: controller.canSendMessage.value
                      ? Colors.white
                      : Colors.grey[600],
                ),
                onPressed: controller.canSendMessage.value
                    ? controller.sendMessage
                    : null,
              ),
            )),
          ],
        ),
      ),
    );
  }

  Color _getMessageBackgroundColor(ChatMessage message, bool isMe, BuildContext context) {
    if (isMe) {
      return Theme.of(context).primaryColor;
    } else {
      return Colors.grey[200]!;
    }
  }

  BorderRadius _getMessageBorderRadius(bool isMe, bool isNextFromSame) {
    if (isMe) {
      return BorderRadius.only(
        topLeft: const Radius.circular(20),
        topRight: const Radius.circular(20),
        bottomLeft: const Radius.circular(20),
        bottomRight: isNextFromSame ? const Radius.circular(20) : const Radius.circular(4),
      );
    } else {
      return BorderRadius.only(
        topLeft: const Radius.circular(20),
        topRight: const Radius.circular(20),
        bottomRight: const Radius.circular(20),
        bottomLeft: isNextFromSame ? const Radius.circular(20) : const Radius.circular(4),
      );
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}