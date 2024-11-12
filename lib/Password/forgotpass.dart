import 'package:flutter/material.dart';
import 'verification.dart';

class Forgotpass extends StatefulWidget {
  const Forgotpass({super.key});

  @override
  _ForgotpassState createState() => _ForgotpassState();
}

class _ForgotpassState extends State<Forgotpass> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'Forgot Password',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0), //spacing send button and email 
              ElevatedButton(
                onPressed: () {
                  //Navigate to the verification page
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Verification()));
                  if (_formKey.currentState!.validate()) {
                    // Process email to send reset link
                  }
                },
                style: ElevatedButton.styleFrom(   //cantikkan button
                  backgroundColor: Colors.teal, // Set button color to turquoise
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10), //Adjust padding (size send button)
                  textStyle: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                child: const Text(
                  'Send',
                  style: TextStyle(
                    color: Colors.white, // Set text color to white
                    fontWeight: FontWeight.bold, // Make the text bold
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
