import 'package:appointmentpractice/UserHomepage/admindashboard.dart';
import 'package:appointmentpractice/UserHomepage/doctorhomepage.dart';
import 'package:appointmentpractice/UserHomepage/homepage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class RegistrationUser extends StatefulWidget {
  const RegistrationUser({super.key});

  @override
  State<RegistrationUser> createState() => _RegistrationUserState();
}

class _RegistrationUserState extends State<RegistrationUser> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _gender;
  String? _userType;
  String? _campus;
  bool _isLoading = false;

  // Visibility toggles for password fields
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create user with email and password
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // Get the newly created user's ID
        String userId = userCredential.user!.uid;

        // Create user document in Firestore
        await _firestore.collection('User').doc(userId).set({
          'User_ID': userId,
          'User_Name': _nameController.text.trim(),
          'User_Email': _emailController.text.trim(),
          'User_Contact': _contactController.text.trim(),
          'User_Gender': _gender,
          'User_Password':_passwordController.text, // Not recommended for real-world apps
          'User_Confirm_Password': _passwordController.text,
          'User_Type': _userType,
          'Campus': _campus,
          'Created_At': FieldValue.serverTimestamp(),
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful')),
        );

        // After registration, navigate back to AdminHomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHomePage()),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'An error occurred';

        // Handle Firebase errors
        if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'An account already exists for this email';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Please enter a valid email address';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registration User Form',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make the text bold
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 100, 200, 185),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Email Address
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(
                            r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                        .hasMatch(value)) {
                      return 'Invalid email address';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Gender
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: DropdownButtonFormField<String>(
                  value: _gender,
                  onChanged: (value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: InputBorder.none,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                  ],
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your gender';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Contact
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextFormField(
                  controller: _contactController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Number',
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(11), // Allow up to 11 digits
                    FilteringTextInputFormatter.digitsOnly, // Only allow digits
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your contact number';
                    }

                    // Remove hyphen for validation
                    final cleanedValue = value.replaceAll('-', '');

                    // Check if the number starts with 01x
                    if (!RegExp(r'^01[0-9]').hasMatch(cleanedValue)) {
                      return 'Contact number must start with 01x';
                    }

                    // Check total number of digits (10 or 11 digits allowed)
                    if (cleanedValue.length < 10 || cleanedValue.length > 11) {
                      return 'Contact number must be 10 or 11 digits long';
                    }

                    return null;
                  },
                ),
              ),
              const SizedBox(height: 10),

              // User Type
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: DropdownButtonFormField<String>(
                  value: _userType,
                  onChanged: (value) {
                    setState(() {
                      _userType = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'User Type',
                    border: InputBorder.none,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Student', child: Text('Student')),
                    DropdownMenuItem(
                        value: 'Lecturer', child: Text('Lecturer')),
                    DropdownMenuItem(value: 'Doctor', child: Text('Doctor')),
                  ],
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your user type';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Campus
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: DropdownButtonFormField<String>(
                  value: _campus,
                  onChanged: (value) {
                    setState(() {
                      _campus = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Campus',
                    border: InputBorder.none,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Gambang', child: Text('Gambang')),
                    DropdownMenuItem(value: 'Pekan', child: Text('Pekan')),
                  ],
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your campus';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Password
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Confirm Password
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Register Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 100, 200, 185),
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Register',
                        style: TextStyle(fontSize: 16.0, color: Colors.black),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Formatter for Contact Number
class _ContactNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove all non-digit characters
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Format with hyphens
    if (newText.length >= 4 && newText.length <= 6) {
      newText = '${newText.substring(0, 3)}-${newText.substring(3)}';
    } else if (newText.length > 6) {
      newText =
          '${newText.substring(0, 3)}-${newText.substring(3, 6)}-${newText.substring(6, 10)}';
    }

    // Return the new formatted value
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
