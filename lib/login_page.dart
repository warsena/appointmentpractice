import 'package:appointmentpractice/forgotpass.dart';
import 'package:flutter/material.dart';
import 'UserHomepage/homepage.dart'; // Import the Homepage class

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
  bool isPasswordVisible = false; // Variable to track password visibility

  // Define the turquoise color
  final Color turquoiseColor = const Color(0xFF009FA0);

  @override
  Widget build(BuildContext context) {
    myColor = Theme.of(context).primaryColor;
    mediaSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,  // Set a plain white background
      body: SingleChildScrollView(
        // Allow scrolling for smaller screens
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBottom(), // Call _buildBottom here for the form content
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
          // Add padding to the card
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
              color: Colors.blueGrey, // Set text color to black
              fontSize: 30,
              fontWeight: FontWeight.w500),
        ),
        _buildGreyText("Please login with your information"),
        const SizedBox(height: 30), // Adjusted spacing
        _buildGreyText("Email address"),
        _buildInputField(emailController),
        const SizedBox(height: 20), // Adjusted spacing
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
      obscureText: isPassword ? !isPasswordVisible : false, // Toggle visibility
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
                    isPasswordVisible =
                        !isPasswordVisible; // Toggle password visibility
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
                rememberUser = value ?? false; // Handle null case
              });
            },
          ),
          _buildGreyText("Remember me"),
        ],
      ),
      TextButton(
        onPressed: () {
          // Navigate to the ForgotPassword page
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
      onPressed: () {
        // Navigate to the Homepage when the login button is pressed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Homepage()),
        );
      },
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        elevation: 10,
        shadowColor: turquoiseColor, // Set to the specified turquoise color
        minimumSize: const Size.fromHeight(60),
        backgroundColor: turquoiseColor, // Set to the specified turquoise color
      ),
      child: const Text(
        "LOGIN",
        style: TextStyle(
          color: Colors.white, // Set text color to black
          fontWeight: FontWeight.bold, // Make the text bold
        ),
      ),
    );
  }
}
