import 'package:appointmentpractice/UserHomepage/admindashboard.dart';
import 'package:appointmentpractice/UserHomepage/homepage.dart';
import 'package:appointmentpractice/UserHomepage/doctorhomepage.dart';
import 'package:appointmentpractice/Password/forgotpass.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controller for email and password input
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // State variables for login form
  bool rememberUser = false;
  bool isPasswordVisible = false;

  // ScaffoldMessenger key for showing snackbar notifications
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  // Color palette for the login page
  final Color primaryColor = const Color(0xFF009FA0);
  final Color backgroundColor = const Color(0xFFF5F5F5);

  // Firebase authentication and firestore instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkRememberMe();
  }

  // Check if "Remember Me" flag is set in Firestore and automatically fill in email
  _checkRememberMe() async {
  User? user = _auth.currentUser;
  if (user != null) {
    DocumentSnapshot userDoc =
        await _firestore.collection('User').doc(user.uid).get();
    if (userDoc.exists) {
      setState(() {
        rememberUser = userDoc['rememberUser'] ?? false;
        if (rememberUser) {
          emailController.text = userDoc['email'] ?? '';
          passwordController.text = userDoc['password'] ?? ''; // Retrieve password
        }
      });
    }
  }
}


  // Save credentials if remember me is enabled
 _saveCredentials() async {
  User? user = _auth.currentUser;
  if (user != null) {
    print('Saving credentials: ${emailController.text}, ${passwordController.text}');
    if (rememberUser) {
      await _firestore.collection('User').doc(user.uid).set({
        'rememberUser': rememberUser,
        'email': emailController.text,
        'password': passwordController.text, // Save the password
      }, SetOptions(merge: true));
    } else {
      await _firestore.collection('User').doc(user.uid).set({
        'rememberUser': false,
        'password': '', // Clear password
      }, SetOptions(merge: true));
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ScaffoldMessenger(
          key: _scaffoldKey,
          child: Scaffold(
            backgroundColor: backgroundColor,
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth > 600
                          ? 400
                          : constraints.maxWidth - 40,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 30),
                        _buildLoginCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset(
          'assets/images/umplogo.png',
          height: 80,
          width: 80,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 15),
        Text(
          'Welcome to the Clinic Campus',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 15),
        Text(
          'Login to continue',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildEmailField(),
          const SizedBox(height: 15),
          _buildPasswordField(),
          const SizedBox(height: 10),
          _buildRememberAndForgot(),
          const SizedBox(height: 15),
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: emailController,
      decoration: InputDecoration(
        labelText: 'Email Address',
        labelStyle: TextStyle(color: primaryColor),
        prefixIcon: Icon(Icons.email, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: passwordController,
      obscureText: !isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: TextStyle(color: primaryColor),
        prefixIcon: Icon(Icons.lock, color: primaryColor),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: primaryColor,
          ),
          onPressed: () {
            setState(() {
              isPasswordVisible = !isPasswordVisible;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildRememberAndForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                activeColor: primaryColor,
                value: rememberUser,
                onChanged: (value) {
                  setState(() {
                    rememberUser = value ?? false;
                  });
                },
              ),
              Flexible(
                child: Text(
                  'Remember me',
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Forgotpass()),
            );
          },
          child: Text(
            'Forgot Password?',
            style: TextStyle(color: primaryColor, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _login,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        elevation: 3,
      ),
      child: const Text(
        'LOGIN',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Login authentication method
  Future<void> _login() async {
  try {
    print("Attempting to sign in with email: ${emailController.text}");

    // Basic validation
    if (emailController.text.trim().isEmpty || 
        passwordController.text.trim().isEmpty) {
      _showError('Please enter both email and password');
      return;
    }

    // Sign in the user with Firebase Authentication
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    // Save credentials if remember me is enabled
    _saveCredentials();

    // Retrieve the user's UID from Firebase Authentication
    final String? userId = userCredential.user?.uid;
    if (userId == null) {
      print("Error: User ID not found after login.");
      _showError('User ID not found.');
      return;
    }

    print("Logged in with UID: $userId");

    // Fetch the user document from Firestore
    DocumentSnapshot userDoc = await _firestore
        .collection('User')
        .doc(userId)
        .get();

     // Check if the user document exists in Firestore
      if (!userDoc.exists) {
        print("Error: User document not found in Firestore for UID: $userId");
        _showError('User document not found.');
        return;
      }

      // Print the user document data for debugging
      print("User document data: ${userDoc.data()}");

      // Cast the document data to a Map for reliable access
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      // Verify that User_Type exists in the document data
      if (userData == null || !userData.containsKey('User_Type')) {
        print("Error: 'User_Type' field is missing in user document.");
        _showError('User type not found.');
        return;
      }

      // Retrieve the User_Type field
      String? userType = userData['User_Type'];
      print("User_Type found: $userType");

      // Redirect based on User_Type
      if (!mounted) return; // Check if widget is still mounted before navigation

      if (userType == 'Admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHomePage()),
        );
        print("Navigating to AdminHomePage");
      } else if (userType == 'Student' || userType == 'Lecturer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Homepage()),
        );
        print("Navigating to Homepage");
      } else if (userType == 'Doctor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Doctorhomepage()),
        );
        print("Navigating to Doctorhomepage");
      } else {
        print("Unknown user type: $userType");
        _showError('Unknown user type, cannot proceed.');
      }
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error: $e");
      String errorMessage;
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.message}';
      }

          _showError(errorMessage); // Show the error message in Snackbar
    } catch (e) {
      print("General Error: $e");
      _showError('An unexpected error occurred.');
    }
  }
    


  // Helper method to show error messages
  void _showError(String message) {
    _scaffoldKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
