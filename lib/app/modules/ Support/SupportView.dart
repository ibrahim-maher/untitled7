import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/SupportController.dart';
import '../../data/models/LoadModel.dart';

class SupportView extends GetView<SupportController> {
  const SupportView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support & Help'),
        elevation: 0,

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency contact card
            _buildEmergencyCard(context),
            const SizedBox(height: 20),

            // Quick actions
            _buildQuickActionsSection(context),
            const SizedBox(height: 20),

            // Issue reporting section
            Obx(() => controller.hasActiveShipment.value
                ? _buildIssueReportingSection(context)
                : const SizedBox.shrink()),

            // Quick help topics
            _buildQuickHelpSection(context),
            const SizedBox(height: 20),

            // Contact options
            _buildContactOptionsSection(context),
            const SizedBox(height: 20),

            // FAQ section
            _buildFAQSection(context),
            const SizedBox(height: 20),

            // Recent tickets
            _buildRecentTicketsSection(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.startLiveChat,
        icon: const Icon(Icons.chat),
        label: const Text('Live Chat'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildEmergencyCard(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.red[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[700],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.emergency, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency Support',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'For urgent safety issues during transport',
                        style: TextStyle(color: Colors.red[600]),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: controller.callEmergency,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Call Now'),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    'Track Shipment',
                    Icons.gps_fixed,
                    Colors.blue,
                    controller.trackShipment,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    'Payment Help',
                    Icons.payment,
                    Colors.green,
                    controller.paymentHelp,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    'Report Issue',
                    Icons.report_problem,
                    Colors.orange,
                    controller.reportGeneralIssue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    'Live Chat',
                    Icons.chat_bubble,
                    Colors.purple,
                    controller.startLiveChat,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueReportingSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.report_problem, color: Colors.orange[600]),
                const SizedBox(width: 8),
                Text(
                  'Report Shipment Issue',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => controller.currentShipment.value != null
                ? _buildShipmentInfo(context, controller.currentShipment.value!)
                : const SizedBox.shrink()),
            const SizedBox(height: 16),
            Text(
              'What type of issue are you experiencing?',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            _buildIssueTypeGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildShipmentInfo(BuildContext context, ShipmentModel shipment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.local_shipping, color: Colors.blue[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shipment #${shipment.id.substring(0, 8)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${shipment.pickupLocation} → ${shipment.deliveryLocation}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  'Status: ${shipment.status.displayName}',
                  style: TextStyle(color: Colors.blue[600], fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => controller.viewShipmentDetails(shipment.id),
            child: const Text('View'),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueTypeGrid(BuildContext context) {
    final issueTypes = [
      IssueType('Delay', Icons.access_time, Colors.orange, 'delay'),
      IssueType('Damage', Icons.warning, Colors.red, 'damage'),
      IssueType('Wrong Location', Icons.location_off, Colors.blue, 'location'),
      IssueType('Driver Issue', Icons.person_remove, Colors.purple, 'driver'),
      IssueType('Payment', Icons.payment, Colors.green, 'payment'),
      IssueType('Other', Icons.help, Colors.grey, 'other'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: issueTypes.length,
      itemBuilder: (context, index) {
        final issueType = issueTypes[index];
        return InkWell(
          onTap: () => controller.reportIssue(issueType.type),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: issueType.color.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(issueType.icon, color: issueType.color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    issueType.title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickHelpSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Help',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildHelpTile(
              'How to track my shipment?',
              'Learn how to monitor your shipment in real-time',
              Icons.location_on,
                  () => controller.showTrackingHelp(),
            ),
            _buildHelpTile(
              'Payment and billing',
              'Understand payment process and billing cycles',
              Icons.payment,
                  () => controller.showPaymentHelp(),
            ),
            _buildHelpTile(
              'Cancellation policy',
              'Learn about cancellation rules and refunds',
              Icons.cancel,
                  () => controller.showCancellationHelp(),
            ),
            _buildHelpTile(
              'Contact my driver',
              'How to communicate with your assigned driver',
              Icons.phone,
                  () => controller.showDriverContactHelp(),
            ),
            _buildHelpTile(
              'App troubleshooting',
              'Fix common app issues and connectivity problems',
              Icons.build,
                  () => controller.showTroubleshootingHelp(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[600]),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  Widget _buildContactOptionsSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Support',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildContactCard(
                    'Call Support',
                    'Speak directly with our team',
                    Icons.phone,
                    Colors.green,
                    controller.callSupport,
                    isAvailable: controller.isSupportAvailable.value,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildContactCard(
                    'Live Chat',
                    'Chat with support agent',
                    Icons.chat,
                    Colors.blue,
                    controller.startLiveChat,
                    isAvailable: controller.isChatAvailable.value,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildContactCard(
                    'Email Support',
                    'Send us a detailed message',
                    Icons.email,
                    Colors.orange,
                    controller.emailSupport,
                    isAvailable: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildContactCard(
                    'Request Callback',
                    'We will call you back',
                    Icons.call_received,
                    Colors.purple,
                    controller.requestCallback,
                    isAvailable: controller.isCallbackAvailable.value,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Support Hours',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Mon-Fri: 9:00 AM - 10:00 PM\nSat-Sun: 10:00 AM - 6:00 PM',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
      String title,
      String subtitle,
      IconData icon,
      Color color,
      VoidCallback onTap, {
        bool isAvailable = true,
      }) {
    return InkWell(
      onTap: isAvailable ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isAvailable ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isAvailable ? color.withOpacity(0.3) : Colors.grey[300]!,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isAvailable ? color : Colors.grey[400],
                  size: 24,
                ),
                if (!isAvailable) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Offline',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isAvailable ? Colors.black87 : Colors.grey[500],
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isAvailable ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Frequently Asked Questions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: controller.viewAllFAQs,
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => Column(
              children: controller.faqs.take(3).map((faq) =>
                  _buildFAQItem(faq)).toList(),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(FAQ faq) {
    return ExpansionTile(
      title: Text(
        faq.question,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(faq.answer),
              if (faq.helpfulLinks.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: faq.helpfulLinks.map((link) =>
                      OutlinedButton(
                        onPressed: () => controller.openHelpLink(link),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        ),
                        child: Text(link, style: const TextStyle(fontSize: 12)),
                      ),
                  ).toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTicketsSection(BuildContext context) {
    return Obx(() {
      if (controller.recentTickets.isEmpty) {
        return const SizedBox.shrink();
      }

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Support Tickets',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: controller.viewAllTickets,
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...controller.recentTickets.map((ticket) =>
                  _buildTicketItem(ticket)).toList(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTicketItem(SupportTicket ticket) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getTicketStatusColor(ticket.status).withOpacity(0.1),
        child: Icon(
          _getTicketStatusIcon(ticket.status),
          color: _getTicketStatusColor(ticket.status),
          size: 20,
        ),
      ),
      title: Text(
        ticket.subject,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ticket #${ticket.id.substring(0, 8)}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          Text(
            DateFormat('MMM dd, yyyy').format(ticket.createdAt),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getTicketStatusColor(ticket.status).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          ticket.status.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: _getTicketStatusColor(ticket.status),
          ),
        ),
      ),
      onTap: () => controller.viewTicketDetails(ticket.id),
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  Color _getTicketStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getTicketStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Icons.schedule;
      case 'in_progress':
        return Icons.refresh;
      case 'resolved':
        return Icons.check_circle;
      case 'closed':
        return Icons.done_all;
      default:
        return Icons.help;
    }
  }
}

class IssueType {
  final String title;
  final IconData icon;
  final Color color;
  final String type;

  IssueType(this.title, this.icon, this.color, this.type);
}