
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
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
        );

        print("User signed in: ${userCredential.user?.uid}");

        // Fetch the user document from the 'User' collection
        DocumentSnapshot userDoc = await _firestore
            .collection('User')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
            // Log the entire document data for debugging
            print("User document data: ${userDoc.data()}");

            // Cast data to Map<String, dynamic> for reliable access
            Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

            // Retrieve the user's role from the user data map
            String? role = userData?['Role'];
            if (role == null) {
                print("Error: 'Role' field is missing in user document.");
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User role not found.')),
                );
                return;
            }

            print("Role found: $role");

            // Redirect based on role
            if (role == 'Admin') {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminHomePage()),
                );
                print("Navigating to AdminDashboard");
            } else if (role == 'Student' || role == 'Lecturer') {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Homepage()),
                );
                print("Navigating to Homepage");
            } else if (role == 'Doctor') {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Doctorhomepage()),
                );
                print("Navigating to Doctorhomepage");
            } else {
                print("Unknown role: $role");
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Unknown role, cannot proceed.')),
                );
            }
        } else {
            print("User document not found in Firestore");
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User role not found.')),
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
