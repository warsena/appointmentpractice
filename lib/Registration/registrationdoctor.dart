import 'package:appointmentpractice/UserHomepage/admindashboard.dart';
import 'package:appointmentpractice/UserHomepage/doctorhomepage.dart';
import 'package:appointmentpractice/UserHomepage/homepage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrationDoctor extends StatefulWidget {
  const RegistrationDoctor({Key? key}) : super(key: key);

  @override
  State<RegistrationDoctor> createState() => _RegistrationDoctorState();
}

class _RegistrationDoctorState extends State<RegistrationDoctor> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _gender;
  String? _userType; // User type field
  String? _campus;
  bool _isLoading = false;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create user with email and password
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // Get the newly created user's ID
        String userId = userCredential.user!.uid;

        // Save user data in Firestore, including User_Type
        await _firestore.collection('User').doc(userId).set({
          'User _ID': userId,
          'User _Name': _nameController.text.trim(),
          'User _Email': _emailController.text.trim(),
          'User _Contact': _contactController.text.trim(),
          'User _Gender': _gender,
          'User _Password': _passwordController.text,
          'User _Confirm_Password': _passwordController.text,
          'User _Type': _userType, // Added user type
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

        // Redirect user based on User_Type
      //   if (_userType == 'Admin') {
      //     Navigator.pushReplacement(
      //       context,
      //       MaterialPageRoute(builder: (context) => const AdminHomePage()),
      //     );
      //   } else if (_userType == 'Student' || _userType == 'Lecturer') {
      //     Navigator.pushReplacement(
      //       context,
      //       MaterialPageRoute(builder: (context) => const Homepage()),
      //     );
      //   } else if (_userType == 'Doctor') {
      //     Navigator.pushReplacement(
      //       context,
      //       MaterialPageRoute(builder: (context) => const Doctorhomepage()),
      //     );
      //   } else {
      //     // If User_Type is unexpected, show a warning
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(content: Text('Unknown user type, please contact support.')),
      //     );
      //   }
      // } on FirebaseAuthException catch (e) {
      //   String errorMessage = 'An error occurred';

      //   if (e.code == 'weak-password') {
      //     errorMessage = 'The password provided is too weak';
      //   } else if (e.code == 'email-already-in-use') {
      //     errorMessage = 'An account already exists for this email';
      //   } else if (e.code == 'invalid-email') {
      //     errorMessage = 'Please enter a valid email address';
      //   }

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
        title: const Text('Registration Doctor Form'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _nameController,
                labelText: 'Name',
                validatorMessage: 'Please enter your name',
              ),
              const SizedBox(height: 10),

              // Email Address
              _buildTextField(
                controller: _emailController,
                labelText: 'Email Address',
                keyboardType: TextInputType.emailAddress,
                validatorMessage: 'Please enter your email',
                additionalValidator: (value) {
                  if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value!)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Gender
              _buildDropdownField(
                value: _gender,
                labelText: 'Gender',
                hintText: 'Select gender',
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
                validatorMessage: 'Please select your gender',
              ),
              const SizedBox(height: 10),

              // Contact Number
              _buildTextField(
                controller: _contactController,
                labelText: 'Contact Number',
                keyboardType: TextInputType.phone,
                validatorMessage: 'Please enter your contact number',
              ),
              const SizedBox(height: 10),

              // User Type
              _buildDropdownField(
                value: _userType,
                labelText: 'User  Type',
                hintText: 'Select user type',
                items: const [
                  DropdownMenuItem(value: 'Doctor', child: Text('Doctor')),
                  DropdownMenuItem(value: 'Student', child: Text('Student')),
                  DropdownMenuItem(value: 'Lecturer', child: Text('Lecturer')),
                ],
                onChanged: (value) {
                  setState(() {
                    _userType = value;
                  });
                },
                validatorMessage: 'Please select your user type',
              ),
              const SizedBox(height: 10),

              // Type of Service
              _buildDropdownField(
                value: _campus,
                labelText: 'Type of Service',
                hintText: 'Select a service',
                items: const [
                  DropdownMenuItem(value: 'Dental', child: Text('Dental')),
                  DropdownMenuItem(value: 'Physiotherapy', child: Text('Physiotherapy')),
                  DropdownMenuItem(value: 'Hypertension', child: Text('Hypertension')),
                  DropdownMenuItem(value: 'Obesity', child: Text('Obesity')),
                  DropdownMenuItem(value: 'Stress Consultation', child: Text('Stress Consultation')),
                  DropdownMenuItem(value: 'Checkup', child: Text('Checkup')),
                ],
                onChanged: (value) {
                  setState(() {
                    _campus = value;
                  });
                },
                validatorMessage: 'Please select a service',
              ),
              const SizedBox(height: 10),

              // Password
              _buildPasswordField(
                controller: _passwordController,
                labelText: 'Password',
                isPasswordVisible: _isPasswordVisible,
                onVisibilityToggle: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                validatorMessage: 'Please enter your password',
              ),
              const SizedBox(height: 10),

              // Confirm Password
              _buildPasswordField(
                controller: _confirmPasswordController,
                labelText: 'Confirm Password',
                isPasswordVisible: _isConfirmPasswordVisible,
                onVisibilityToggle: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
                validatorMessage: 'Please confirm your password',
                additionalValidator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Register ',
                        style: TextStyle(fontSize: 16.0, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? validatorMessage,
    TextInputType? keyboardType,
    String? Function(String?)? additionalValidator,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: labelText, border: InputBorder.none),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validatorMessage;
          }
          return additionalValidator?.call(value);
        },
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String labelText,
    required String hintText,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    required String validatorMessage,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: labelText, border: InputBorder.none),
        hint: Text(hintText),
        items: items,
        onChanged: onChanged,
        validator: (value) {
          if (value == null) return validatorMessage;
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required bool isPasswordVisible,
    required VoidCallback onVisibilityToggle,
    String? validatorMessage = 'Please enter a value',
    String? Function(String?)? additionalValidator,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: !isPasswordVisible,
        decoration: InputDecoration(
          labelText: labelText,
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: onVisibilityToggle,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validatorMessage; // Use provided message or default
          }
          return additionalValidator?.call(value); // Call additionalValidator if provided
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

