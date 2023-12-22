// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// class NotificationsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => NotificationModel(),
//       child: _NotificationsScreen(),
//     );
//   }
// }
//
// class _NotificationsScreen extends StatefulWidget {
//   @override
//   _NotificationsScreenState createState() => _NotificationsScreenState();
// }
//
// class _NotificationsScreenState extends State<_NotificationsScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _setupNotifications(context);
//   }
//
//   void _setupNotifications(BuildContext context) {
//     AwesomeNotifications().initialize(
//       'resource://drawable/app_icon',
//       [
//         NotificationChannel(
//           channelKey: 'basic_channel',
//           channelName: 'Basic notifications',
//           channelDescription: 'Notification channel for basic notifications',
//           defaultColor: Color(0xFF9D50DD),
//           ledColor: Colors.white,
//         ),
//       ],
//     );
//
//     AwesomeNotifications().createdStream.listen((notification) {
//       NotificationModel model = Provider.of<NotificationModel>(context, listen: false);
//       model.addNotification(notification.body ?? '');
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Notifications'),
//       ),
//       body: Consumer<NotificationModel>(
//         builder: (context, model, child) {
//           return model.notifications.isEmpty
//               ? Center(
//             child: Text('No notifications yet.'),
//           )
//               : ListView.builder(
//             itemCount: model.notifications.length,
//             itemBuilder: (context, index) {
//               String notification = model.notifications[index];
//               return ListTile(
//                 title: Text(notification),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
//
// class NotificationModel extends ChangeNotifier {
//   List<String> _notifications = [];
//
//   List<String> get notifications => _notifications;
//
//   void addNotification(String notification) {
//     _notifications.add(notification);
//     notifyListeners();
//   }
// }
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: NotificationsScreen(),
//     );
//   }
// }
