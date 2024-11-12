
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
  late Color myColor;
  late Size mediaSize;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberUser = false;
  bool isPasswordVisible = false;


  final Color turquoiseColor = const Color(0xFF009FA0);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    myColor = Theme.of(context).primaryColor;
    mediaSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBottom(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottom() {
    return SizedBox(
      width: mediaSize.width,
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(

          padding: const EdgeInsets.all(20.0),
          child: _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Welcome",
          style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 30,
              fontWeight: FontWeight.w500),
        ),
        _buildGreyText("Please login with your information"),
        const SizedBox(height: 30),
        _buildGreyText("Email address"),
        _buildInputField(emailController),
        const SizedBox(height: 20),
        _buildGreyText("Password"),
        _buildInputField(passwordController, isPassword: true),
        const SizedBox(height: 20),
        _buildRememberForgot(),
        const SizedBox(height: 20),
        _buildLoginButton(),
        const SizedBox(height: 260),
      ],
    );
  }

  Widget _buildGreyText(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.grey),
    );
  }

  Widget _buildInputField(TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? !isPasswordVisible : false,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: isPassword ? 'Enter your password' : 'Enter your email',
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _buildRememberForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: rememberUser,
              onChanged: (value) {
                setState(() {
                  rememberUser = value ?? false;
                });
              },
            ),
            _buildGreyText("Remember me"),
          ],
        ),
        TextButton(
          onPressed: () {

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Forgotpass()),
            );
          },
          child: _buildGreyText("Forgot password"),
        ),
      ],
    );
  }


  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _login,
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        elevation: 10,
        shadowColor: turquoiseColor,
        minimumSize: const Size.fromHeight(60),
        backgroundColor: turquoiseColor,
      ),
      child: const Text(
        "LOGIN",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _login() async {
    try {
        print("Attempting to sign in with email: ${emailController.text}");

        // Sign in the user with Firebase Authentication
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
        );

        // Retrieve the user's UID from Firebase Authentication
        final String? userId = userCredential.user?.uid;
        if (userId == null) {
            print("Error: User ID not found after login.");
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User ID not found.')),
            );
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
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User document not found.')),
            );
            return;
        }

        // Print the user document data for debugging
        print("User document data: ${userDoc.data()}");

        // Cast the document data to a Map for reliable access
        Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

        // Verify that User_Type exists in the document data
        if (userData == null || !userData.containsKey('User_Type')) {
            print("Error: 'User_Type' field is missing in user document.");
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User type not found.')),
            );
            return;
        }

        // Retrieve the User_Type field
        String? userType = userData['User_Type'];
        print("User_Type found: $userType");

        // Redirect based on User_Type
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
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Unknown user type, cannot proceed.')),
            );
        }
    } catch (e) {
        print("Sign-in error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
        );
    }
}

}


