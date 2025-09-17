import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/models/LoadModel.dart';
import '../routes/app_pages.dart';
import '../services/firestore_service.dart';


class FAQ {
  final String question;
  final String answer;
  final List<String> helpfulLinks;
  final String category;

  FAQ({
    required this.question,
    required this.answer,
    this.helpfulLinks = const [],
    this.category = 'general',
  });
}

class SupportTicket {
  final String id;
  final String subject;
  final String description;
  final String status;
  final String priority;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> messages;

  SupportTicket({
    required this.id,
    required this.subject,
    required this.description,
    required this.status,
    this.priority = 'medium',
    required this.createdAt,
    this.updatedAt,
    this.messages = const [],
  });
}

class SupportController extends GetxController {
  // Observable variables
  var hasActiveShipment = false.obs;
  var currentShipment = Rxn<ShipmentModel>();
  var isSupportAvailable = true.obs;
  var isChatAvailable = true.obs;
  var isCallbackAvailable = true.obs;
  var faqs = <FAQ>[].obs;
  var recentTickets = <SupportTicket>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeSupport();
    _loadFAQs();
    _loadRecentTickets();
    _checkSupportAvailability();
  }

  void _initializeSupport() {
    try {
      final args = Get.arguments ?? {};
      final issueType = args['issueType'];
      final shipmentId = args['shipmentId'];
      final shipment = args['shipment'] as ShipmentModel?;

      if (shipment != null) {
        currentShipment.value = shipment;
        hasActiveShipment.value = true;
      } else if (shipmentId != null) {
        hasActiveShipment.value = true;
        _loadShipmentData(shipmentId);
      }

      // Handle direct issue reporting
      if (issueType != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          reportIssue(issueType);
        });
      }

      // Handle direct contact request
      if (args['direct_contact'] == true) {
        Future.delayed(const Duration(milliseconds: 500), () {
          startLiveChat();
        });
      }
    } catch (e) {
      print('Error initializing support: $e');
    }
  }

  void _loadShipmentData(String shipmentId) async {
    try {
      final shipmentData = await FirestoreService.getShipmentById(shipmentId);
      if (shipmentData != null) {
        currentShipment.value = shipmentData;
      }
    } catch (e) {
      print('Error loading shipment data: $e');
    }
  }

  void _loadFAQs() {
    // Mock FAQ data - in production, load from Firestore
    faqs.addAll([
      FAQ(
        question: 'How do I track my shipment?',
        answer: 'You can track your shipment in real-time using the tracking number provided. Go to the Track Shipment section and enter your tracking ID.',
        helpfulLinks: ['Track Shipment', 'GPS Tracking'],
        category: 'tracking',
      ),
      FAQ(
        question: 'What payment methods do you accept?',
        answer: 'We accept all major credit cards, UPI, net banking, and digital wallets. Payments are processed securely through our encrypted payment gateway.',
        helpfulLinks: ['Payment Options', 'Security'],
        category: 'payment',
      ),
      FAQ(
        question: 'How do I cancel a shipment?',
        answer: 'You can cancel a shipment up to 2 hours before pickup time without charges. After that, cancellation fees may apply. Go to your shipment details and select Cancel.',
        helpfulLinks: ['Cancellation Policy', 'Refund Process'],
        category: 'cancellation',
      ),
      FAQ(
        question: 'How do I contact my driver?',
        answer: 'Once your shipment is assigned, you can contact your driver directly through our in-app messaging system or call them using the provided phone number.',
        helpfulLinks: ['Driver Communication', 'Live Chat'],
        category: 'communication',
      ),
      FAQ(
        question: 'What if my shipment is damaged?',
        answer: 'Report any damage immediately through our app. Take photos of the damaged items and submit a claim. Our team will investigate and process compensation if applicable.',
        helpfulLinks: ['Damage Claims', 'Insurance Coverage'],
        category: 'damage',
      ),
      FAQ(
        question: 'How are delivery charges calculated?',
        answer: 'Charges are based on distance, vehicle type, load weight, and additional services. You can get an instant quote before booking.',
        helpfulLinks: ['Pricing Calculator', 'Service Charges'],
        category: 'pricing',
      ),
    ]);
  }

  void _loadRecentTickets() async {
    try {
      // Mock recent tickets - in production, load from Firestore
      await Future.delayed(const Duration(seconds: 1));

      final mockTickets = [
        SupportTicket(
          id: 'TKT-${DateTime.now().millisecondsSinceEpoch}',
          subject: 'Payment issue with shipment #AB123',
          description: 'Unable to complete payment for my recent shipment',
          status: 'in_progress',
          priority: 'high',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          messages: ['Payment issue reported', 'Support team investigating'],
        ),
        SupportTicket(
          id: 'TKT-${DateTime.now().millisecondsSinceEpoch - 100}',
          subject: 'Driver contact request',
          description: 'Need to contact driver for special instructions',
          status: 'resolved',
          priority: 'medium',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          messages: ['Request received', 'Driver contact details provided'],
        ),
      ];

      recentTickets.addAll(mockTickets);
    } catch (e) {
      print('Error loading recent tickets: $e');
    }
  }

  void _checkSupportAvailability() {
    // Check current time and set availability
    final now = DateTime.now();
    final hour = now.hour;

    // Support hours: 9 AM to 10 PM on weekdays, 10 AM to 6 PM on weekends
    final isWeekday = now.weekday <= 5;
    final isWeekdaySupport = isWeekday && hour >= 9 && hour <= 22;
    final isWeekendSupport = !isWeekday && hour >= 10 && hour <= 18;

    isSupportAvailable.value = isWeekdaySupport || isWeekendSupport;
    isChatAvailable.value = isSupportAvailable.value;
    isCallbackAvailable.value = isSupportAvailable.value;
  }

  // Emergency support
  void callEmergency() async {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.emergency, color: Colors.red[700]),
            const SizedBox(width: 8),
            const Text('Emergency Support'),
          ],
        ),
        content: const Text(
          'You are about to contact emergency support. This should only be used for urgent safety issues or emergencies during transport.\n\nDo you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _callEmergencyNumber();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            child: const Text('Call Emergency', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _callEmergencyNumber() async {
    const emergencyNumber = '+1-800-FREIGHT'; // Replace with actual emergency number
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: emergencyNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showErrorSnackbar('Unable to call emergency support');
      }
    } catch (e) {
      print('Error calling emergency: $e');
      _showErrorSnackbar('Failed to call emergency support');
    }
  }

  // Quick actions
  void trackShipment() {
    if (currentShipment.value != null) {
      Get.toNamed(Routes.TRACK_SHIPMENT, parameters: {
        'id': currentShipment.value!.id,
      });
    } else {
      Get.toNamed(Routes.SHIPMENTS);
    }
  }

  void paymentHelp() {
    _showHelpDialog(
      'Payment Help',
      'Having trouble with payments? We support all major payment methods including credit cards, UPI, and digital wallets.',
      [
        'Check Payment Methods',
        'View Transaction History',
        'Contact Payment Support',
      ],
    );
  }

  void reportGeneralIssue() {
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
              'Report an Issue',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildIssueOption('App Issue', Icons.smartphone, 'app_issue'),
            _buildIssueOption('Account Problem', Icons.account_circle, 'account_issue'),
            _buildIssueOption('Service Quality', Icons.star_border, 'service_issue'),
            _buildIssueOption('Safety Concern', Icons.security, 'safety_issue'),
            _buildIssueOption('Other', Icons.help, 'other_issue'),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueOption(String title, IconData icon, String type) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Get.back();
        reportIssue(type);
      },
    );
  }

  // Issue reporting
  void reportIssue(String issueType) {
    Get.dialog(
      AlertDialog(
        title: Text('Report ${_getIssueTypeTitle(issueType)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please describe the ${issueType.replaceAll('_', ' ')} you\'re experiencing:'),
            const SizedBox(height: 16),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe the issue in detail...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(value: false, onChanged: (value) {}),
                const Expanded(
                  child: Text(
                    'This is an urgent issue requiring immediate attention',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _submitIssueReport(issueType);
            },
            child: const Text('Submit Report'),
          ),
        ],
      ),
    );
  }

  String _getIssueTypeTitle(String type) {
    switch (type) {
      case 'delay':
        return 'Delay Issue';
      case 'damage':
        return 'Damage Report';
      case 'location':
        return 'Location Problem';
      case 'driver':
        return 'Driver Issue';
      case 'payment':
        return 'Payment Problem';
      case 'app_issue':
        return 'App Issue';
      case 'account_issue':
        return 'Account Problem';
      case 'service_issue':
        return 'Service Quality Issue';
      case 'safety_issue':
        return 'Safety Concern';
      default:
        return 'Issue';
    }
  }

  void _submitIssueReport(String issueType) async {
    try {
      // In production, submit to Firestore
      await Future.delayed(const Duration(seconds: 2));

      final ticket = SupportTicket(
        id: 'TKT-${DateTime.now().millisecondsSinceEpoch}',
        subject: _getIssueTypeTitle(issueType),
        description: 'User reported $issueType issue',
        status: 'open',
        priority: issueType == 'safety_issue' ? 'high' : 'medium',
        createdAt: DateTime.now(),
      );

      recentTickets.insert(0, ticket);

      _showSuccessSnackbar('Issue reported successfully. Ticket #${ticket.id.substring(4, 12)} created.');
    } catch (e) {
      _showErrorSnackbar('Failed to submit issue report');
    }
  }

  // Contact options
  void callSupport() async {
    if (!isSupportAvailable.value) {
      _showInfoSnackbar('Support is currently offline. Please try again during business hours.');
      return;
    }

    const supportNumber = '+1-800-SUPPORT'; // Replace with actual support number
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: supportNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showErrorSnackbar('Unable to make phone call');
      }
    } catch (e) {
      print('Error calling support: $e');
      _showErrorSnackbar('Failed to initiate call');
    }
  }

  void startLiveChat() {
    if (!isChatAvailable.value) {
      _showInfoSnackbar('Live chat is currently offline. Please try again during business hours.');
      return;
    }

    Get.toNamed(Routes.CHAT, arguments: {
      'recipientId': 'support_agent_001',
      'recipientName': 'Support Agent',
      'isSupport': true,
    });
  }

  void emailSupport() {
    Get.dialog(
      AlertDialog(
        title: const Text('Email Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Send us a detailed message and we\'ll get back to you within 24 hours.'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _showSuccessSnackbar('Email sent successfully. We\'ll respond within 24 hours.');
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void requestCallback() {
    if (!isCallbackAvailable.value) {
      _showInfoSnackbar('Callback service is currently offline. Please try again during business hours.');
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Request Callback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Our customer support team will call you within 15 minutes to assist with your query.',
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Preferred callback number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Brief description of your issue',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _requestCallback();
            },
            child: const Text('Request Call'),
          ),
        ],
      ),
    );
  }

  void _requestCallback() {
    _showSuccessSnackbar('Callback requested. We\'ll call you within 15 minutes.');
  }

  // Help sections
  void showTrackingHelp() {
    _showHelpDialog(
      'Shipment Tracking',
      'Learn how to track your shipments effectively:',
      [
        '• Use your tracking ID to get real-time updates',
        '• Enable notifications for status changes',
        '• Contact your driver directly through the app',
        '• View estimated delivery times',
        '• Access delivery proof after completion',
      ],
    );
  }

  void showPaymentHelp() {
    _showHelpDialog(
      'Payment & Billing',
      'Everything you need to know about payments:',
      [
        '• Multiple payment options available',
        '• Secure payment processing',
        '• Instant payment confirmation',
        '• Download invoices and receipts',
        '• Automatic refund processing',
      ],
    );
  }

  void showCancellationHelp() {
    _showHelpDialog(
      'Cancellation Policy',
      'Understand our cancellation terms:',
      [
        '• Free cancellation up to 2 hours before pickup',
        '• Partial charges for last-minute cancellations',
        '• Full refund for service provider cancellations',
        '• Emergency cancellations processed case-by-case',
        '• Refunds processed within 5-7 business days',
      ],
    );
  }

  void showDriverContactHelp() {
    _showHelpDialog(
      'Driver Communication',
      'How to communicate with your assigned driver:',
      [
        '• Use in-app messaging for text communication',
        '• Call driver directly when needed',
        '• Share location and special instructions',
        '• Receive real-time updates',
        '• Report any issues immediately',
      ],
    );
  }

  void showTroubleshootingHelp() {
    _showHelpDialog(
      'App Troubleshooting',
      'Common solutions for app issues:',
      [
        '• Check your internet connection',
        '• Update the app to the latest version',
        '• Clear app cache and restart',
        '• Allow location permissions for tracking',
        '• Contact support if issues persist',
      ],
    );
  }

  void _showHelpDialog(String title, String description, List<String> points) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            const SizedBox(height: 16),
            ...points.map((point) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(point, style: const TextStyle(fontSize: 14)),
            )).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Got it'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              startLiveChat();
            },
            child: const Text('Need More Help'),
          ),
        ],
      ),
    );
  }

  // FAQ functions
  void viewAllFAQs() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: faqs.length,
                itemBuilder: (context, index) {
                  final faq = faqs[index];
                  return ExpansionTile(
                    title: Text(faq.question),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(faq.answer),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void openHelpLink(String link) {
    _showInfoSnackbar('Opening $link help section...');
  }

  void searchHelp() {
    Get.dialog(
      AlertDialog(
        title: const Text('Search Help'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'What can we help you with?',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _showInfoSnackbar('Search results would appear here');
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  // Ticket management
  void viewAllTickets() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const Text(
              'Support Tickets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: recentTickets.length,
                itemBuilder: (context, index) {
                  final ticket = recentTickets[index];
                  return ListTile(
                    title: Text(ticket.subject),
                    subtitle: Text('Ticket #${ticket.id.substring(0, 8)}'),
                    trailing: Text(ticket.status.toUpperCase()),
                    onTap: () => viewTicketDetails(ticket.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void viewTicketDetails(String ticketId) {
    final ticket = recentTickets.firstWhere((t) => t.id == ticketId);

    Get.dialog(
      AlertDialog(
        title: Text('Ticket #${ticket.id.substring(0, 8)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subject: ${ticket.subject}'),
            const SizedBox(height: 8),
            Text('Status: ${ticket.status.toUpperCase()}'),
            const SizedBox(height: 8),
            Text('Created: ${DateFormat('MMM dd, yyyy').format(ticket.createdAt)}'),
            const SizedBox(height: 16),
            const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(ticket.description),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void viewShipmentDetails(String shipmentId) {
    Get.toNamed(Routes.SHIPMENT_DETAILS, arguments: {
      'shipmentId': shipmentId,
    });
  }

  // Helper methods
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