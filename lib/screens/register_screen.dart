import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) =>  LoginScreen()),
        );
      } on FirebaseAuthException catch (e) {
        String message = "An error occurred" ;
        if (e.code == 'email-already-in-use') {
          message = 'This email is already in use.';
        } else if (e.code == 'invalid-email') {
          message = 'Invalid email address.';
        } else if (e.code == 'weak-password') {
          message = 'Password should be at least 6 characters.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top orange header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Create an account",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(color: Colors.black87),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) =>  LoginScreen()),
                          ),
                          child: const Text(
                            "Log in",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Registration form
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Full Name
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            hintText: "Full Name",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your full name";
                            }
                            return null;
                          },
                        ),
                      ),

                      // Email
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            hintText: "Email Address",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your email address";
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return "Please enter a valid email";
                            }
                            return null;
                          },
                        ),
                      ),

                      // Password
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            hintText: "Password",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter a password";
                            }
                            if (value.length < 6) {
                              return "Password should be at least 6 characters";
                            }
                            return null;
                          },
                        ),
                      ),

                      // Sign up button
                      ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.orange, width: 2),
                          ),
                        ),
                        child: const Text(
                          "Sign up",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}