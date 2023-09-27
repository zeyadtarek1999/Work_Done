import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens_layout/layoutWorker.dart';
import 'Screens_layout/layoutclient.dart';
import 'login_screen_worker.dart';
import 'login_screen_client.dart'; // Import the login screen for clients
import 'welcome/welcome_screen.dart';

class AppLauncher extends StatefulWidget {
  @override
  _AppLauncherState createState() => _AppLauncherState();
}

class _AppLauncherState extends State<AppLauncher> {
  @override
  void initState() {
    super.initState();
    checkIdAndNavigate();
  }

  Future<void> checkIdAndNavigate() async {
    // Check if there's a worker ID or client ID
    int? savedWorkerId = await getSavedWorkerId();
    int? savedClientId = await getSavedClientId();

    if (savedWorkerId != null && savedWorkerId > 0) {
      // Worker ID exists, navigate to Worker layout
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => layoutworker()),
      );
    } else if (savedClientId != null && savedClientId > 0) {
      // Client ID exists, navigate to Client layout
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => layoutclient()),
      );
    } else {
      // No worker ID or client ID, navigate to Welcome screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    }
  }

  Future<int?> getSavedWorkerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? workerId = prefs.getInt('worker_id');
    return workerId;
  }

  Future<int?> getSavedClientId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? clientId = prefs.getInt('client_id');
    return clientId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
