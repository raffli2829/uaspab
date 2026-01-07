import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  File? _imageFile;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _nameController.text = authProvider.user?.displayName ?? '';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.updateDisplayName(_nameController.text);
      // For photo, you might need to upload to Firebase Storage and update photoURL
      // For now, just show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
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
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : (authProvider.user?.photoURL != null
                                ? NetworkImage(authProvider.user!.photoURL!)
                                : null) as ImageProvider?,
                        child: _imageFile == null && authProvider.user?.photoURL == null
                            ? Icon(Icons.account_circle, size: 120, color: Theme.of(context).primaryColor)
                            : null,
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: IconButton(
                              icon: Icon(Icons.camera_alt, color: Colors.white),
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isEditing)
                        ElevatedButton.icon(
                          onPressed: _updateProfile,
                          icon: Icon(Icons.save),
                          label: Text('Save'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isEditing = true;
                            });
                          },
                          icon: Icon(Icons.edit),
                          label: Text('Edit Profile'),
                        ),
                      SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await authProvider.signOut();
                          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                        },
                        icon: Icon(Icons.logout),
                        label: Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (_isEditing)
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Display Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  else
                    Text(
                      authProvider.user?.displayName ?? 'No name',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}