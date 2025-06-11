import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recyclo/auth/auth_service.dart';
import 'package:recyclo/auth/login_screen.dart';
import 'package:recyclo/home_screen.dart';
import 'package:recyclo/widgets/button.dart';
import 'package:recyclo/widgets/textfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = AuthService();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  bool _isPasswordStrong(String password) {
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');
    return regex.hasMatch(password);
  }

  _signup() async {
    if (_name.text.isEmpty || _email.text.isEmpty || _password.text.isEmpty) {
      _showError("Please fill in all fields.");
      return;
    }

    if (!_isPasswordStrong(_password.text)) {
      _showError("Password must be at least 8 characters and include uppercase, lowercase, and number.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final users = await _auth.createUserWithEmailAndPassword(
        _email.text.trim(),
        _password.text.trim(),
      );

      if (users != null) {
        String uid = users.uid;
        await FirebaseFirestore.instance.collection("user").doc(uid).set({
          "uid": uid,
          "name": _name.text.trim(),
          "email": _email.text.trim(),
          "points": 0,
        });

        log("User Created & Stored in Firestore Successfully");
        goToHome(context);
      }
    } catch (e) {
      log("Signup Error: $e");
      _showError("Signup failed: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  goToLogin(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );

  goToHome(BuildContext context) => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo at the top
              Image.asset(
                'images/logo.png',
                height: 200,
              ),
              
              const Text(
                "Create Account ✨",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "Start your journey with Recyclo",
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              CustomTextField(
                hint: "Your full name",
                label: "Name",
                controller: _name,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hint: "you@example.com",
                label: "Email Address",
                controller: _email,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hint: "********",
                label: "Password",
                isPassword: true,
                controller: _password,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : CustomButton(
                      label: "Sign Up",
                      onPressed: _signup,
                    ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () => goToLogin(context),
                    child: const Text(
                      "Login",
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
    );
  }
}
