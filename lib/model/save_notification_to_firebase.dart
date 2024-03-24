import 'package:cloud_firestore/cloud_firestore.dart';

class SaveNotificationToFirebase {
  static Future<void> saveNotificationsToFirestore(
      String userId,
      List<Map<String, dynamic>> notifications,
      ) async {
    try {
      // Reference to the user's document in the users collection
      DocumentReference userDocRef =
      FirebaseFirestore.instance.collection('users').doc(userId);

      // Reference to the notify collection document with the userId
      DocumentReference notifyDocRef =
      FirebaseFirestore.instance.collection('notify').doc(userId);

      // Use a WriteBatch to perform the update operation for both collections
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Update the notifications in the users collection
      batch.update(userDocRef, {
        'notifications': FieldValue.arrayUnion(notifications),
      });
      batch.update(userDocRef, {
        'notifications': FieldValue.arrayRemove(notifications),
      });
      // Add the notifications to the notify collection
      batch.set(
        notifyDocRef,
        {'notifications': FieldValue.arrayUnion(notifications)},
        SetOptions(merge: true), // Merge options to prevent overwriting
      );

      // Commit the batch
      await batch.commit();
      print('Notifications saved for user $userId');
    } catch (error) {
      print("Error saving notifications: $error");
    }
  }
}
