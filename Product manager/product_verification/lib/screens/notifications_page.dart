import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      NotificationItem(
        icon: Icons.warning,
        title: 'Product Alert',
        message: 'Multiple counterfeit reports for Premium Headphones (PRD001)',
        time: '2 hours ago',
        isRead: false,
        severity: NotificationSeverity.high,
      ),
      NotificationItem(
        icon: Icons.info,
        title: 'System Update',
        message: 'MBS Verify app has been updated with new security features',
        time: '1 day ago',
        isRead: true,
        severity: NotificationSeverity.info,
      ),
      NotificationItem(
        icon: Icons.security,
        title: 'Security Notice',
        message: 'New counterfeit products detected in Electronics category',
        time: '3 days ago',
        isRead: true,
        severity: NotificationSeverity.medium,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {
              // Mark all as read
            },
            child: const Text(
              'Mark all read',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getSeverityColor(notification.severity).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        notification.icon,
                        color: _getSeverityColor(notification.severity),
                      ),
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(notification.message),
                        const SizedBox(height: 4),
                        Text(
                          notification.time,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    trailing: notification.isRead
                        ? null
                        : Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D32),
                              shape: BoxShape.circle,
                            ),
                          ),
                    onTap: () {
                      // Mark as read and show details
                    },
                  ),
                );
              },
            ),
    );
  }

  Color _getSeverityColor(NotificationSeverity severity) {
    switch (severity) {
      case NotificationSeverity.high:
        return Colors.red;
      case NotificationSeverity.medium:
        return Colors.orange;
      case NotificationSeverity.info:
        return Colors.blue;
    }
  }
}

class NotificationItem {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final bool isRead;
  final NotificationSeverity severity;

  NotificationItem({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.severity,
  });
}

enum NotificationSeverity { high, medium, info }