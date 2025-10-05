import 'dart:convert'; // Needed for utf8 encoding
import 'package:crypto/crypto.dart'; // The crypto package for hashing
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'choice_screen.dart'; // This is your main app screen after login

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // This is the new password hashing function
  String _hashPassword(String password) {
    final bytes = utf8.encode(password); // Encode the password to bytes
    final digest = sha256.convert(bytes); // Hash the bytes using SHA-256
    return digest.toString(); // Return the hash as a string
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username and password cannot be empty.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // 1. Look for a document with the given username in the 'doctors' collection
      final docRef =
          FirebaseFirestore.instance.collection('doctors').doc(username);
      final docSnapshot = await docRef.get();

      // 2. Check if the doctor exists and the password matches
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        
        // Hash the password the user typed in the form
        final String hashedPassword = _hashPassword(password);

        // Compare the generated hash with the hash stored in the database
        if (data['password'] == hashedPassword) {
          // If login is successful, navigate to the main screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ChoiceScreen()),
          );
        } else {
          // If password is wrong
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incorrect password.')),
          );
        }
      } else {
        // If username is not found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username not found.')),
        );
      }
    } catch (e) {
      // Handle potential errors like network issues
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Login'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true, // Hides the password
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}