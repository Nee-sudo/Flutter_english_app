import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import 'admin_dashboard_screen.dart';
import 'admin_login_screen.dart';

class AdminRouteWrapper extends StatefulWidget {
  const AdminRouteWrapper();

  @override
  State<AdminRouteWrapper> createState() => _AdminRouteWrapperState();
}

class _AdminRouteWrapperState extends State<AdminRouteWrapper> {
  late final Future<String?> _keyFuture;

  @override
  void initState() {
    super.initState();
    _keyFuture = _getAdminKey();
  }

  Future<String?> _getAdminKey() async {
    final storage = StorageService();
    await storage.init();
    return storage.getAdminKey();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _keyFuture,
      builder: (context, snapshot) {
        final key = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (key == null || key.isEmpty) {
          return const AdminLoginScreen();
        }

        return AdminDashboardScreen(adminKey: key);
      },
    );
  }
}

