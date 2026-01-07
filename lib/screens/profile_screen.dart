import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_circle,
                    size: 100,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'User Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 24),
                  if (authProvider.user != null) ...[
                    ListTile(
                      leading: Icon(Icons.email),
                      title: Text('Email'),
                      subtitle: Text(authProvider.user!.email ?? 'No email'),
                    ),
                    ListTile(
                      leading: Icon(Icons.calendar_today),
                      title: Text('Account Created'),
                      subtitle: Text(
                        authProvider.user!.metadata.creationTime?.toString() ?? 'Unknown',
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.access_time),
                      title: Text('Last Sign In'),
                      subtitle: Text(
                        authProvider.user!.metadata.lastSignInTime?.toString() ?? 'Unknown',
                      ),
                    ),
                  ] else ...[
                    Text('Not logged in'),
                  ],
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      await authProvider.signOut();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}