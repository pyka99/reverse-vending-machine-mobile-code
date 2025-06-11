import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:recyclo/auth/auth_service.dart';
import 'package:recyclo/auth/signup_screen.dart';
import 'package:recyclo/home_screen.dart';
import 'package:recyclo/widgets/button.dart';
import 'package:recyclo/widgets/textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _login() async {
    if (_email.text.isEmpty || _password.text.isEmpty) {
      _showError("Please enter both email and password.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _auth.loginUserWithEmailAndPassword(
        _email.text.trim(),
        _password.text.trim(),
      );

      if (user != null) {
        log("User Logged In");
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        _showError("Invalid email or password. Please try again.");
      }
    } catch (e) {
      log("Login Error: $e");
      _showError("An error occurred. Please check your credentials and try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: mediaQueryHeight * 0.8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Add your logo here
                Image.asset(
                  'images/logo.png', // Make sure this asset exists
                  height: 200,
                ),
                // const SizedBox(height: 10),
                const Text(
                  "Welcome Back 👋",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Login to continue recycling with Recyclo",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  hint: "you@example.com",
                  label: "Email Address",
                  controller: _email,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  hint: "********",
                  label: "Password",
                  controller: _password,
                  obscureText: true,
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const CircularProgressIndicator()
                    : CustomButton(
                        label: "Login",
                        onPressed: _login,
                        // color: Colors.blue, // Make button blue
                        // textColor: Colors.white,
                      ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupScreen()),
                        );
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
