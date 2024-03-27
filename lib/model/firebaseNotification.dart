import 'dart:convert';

import 'package:http/http.dart' as http;

class NotificationUtil {
  static Future<void> sendNotification(
      String title,
      String body,
      String token,
      DateTime notificationTime,
      ) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=AAAAaK6XL4o:APA91bHRHrQ-LdNBAovY6ju0bmVmISrukMdlvnuGRdDSI5Iovt1vzwFmSTLAu6GwUGZ8vLBVaympavSLm8XTpM7BmsmlbRlpJea6rKJyU4fAyXV3vOPKW4OpvNm8A466udxY8SfLw8zK',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
              'time': notificationTime.toIso8601String(),
              // Include the time here
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": token,
          },
        ),
      );
      print('Notification sent');
    } catch (e) {
      print("Error sending notification: $e");
    }
  }
}
