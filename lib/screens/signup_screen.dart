import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
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
                    Icons.person_add,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Join us today',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 24),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await Provider.of<AuthProvider>(context, listen: false)
                            .signUp(_emailController.text, _passwordController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Sign up successful'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MainScreen()),
                        );
                      } catch (e) {
                        print('Signup error: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Sign up failed: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text('Sign Up'),
                    style: ElevatedButton.styleFrom(
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