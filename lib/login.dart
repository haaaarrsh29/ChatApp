
import 'package:chat_app/chatscreen.dart';
import 'package:chat_app/uihelper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';




TextEditingController emailcont = TextEditingController();
TextEditingController passcont = TextEditingController();

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Login Function
  Future<void> login(String email, String pass) async {
    if (email.isEmpty || pass.isEmpty) {
      UiHelper.customalertbox(context, 'Please enter required details.');
      return;
    }

    try {
      print("Attempting login with email: $email"); // Debugging
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pass);

      print("User logged in: ${userCredential.user?.email}"); // Debugging
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  ChatScreen()),
      );
    } on FirebaseAuthException catch (ex) {
      print("Login failed: ${ex.message}"); // Debugging
      UiHelper.customalertbox(context, ex.code.toString());
    }
  }

  // Sign Up Function
  Future<void> add(String email, String pass) async {
    if (email.isEmpty || pass.isEmpty) {
      UiHelper.customalertbox(context, 'Please enter required details.');
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);

      print("User account created: ${userCredential.user?.email}"); // Debugging
      UiHelper.customalertbox(context, 'Account created successfully!');
    } on FirebaseAuthException catch (ex) {
      print("Sign up failed: ${ex.message}"); // Debugging
      UiHelper.customalertbox(context, ex.code.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Login Page"),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3), // Transparent background
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    UiHelper.customtextfeild(emailcont, 'Email', Icons.email, false),
                    UiHelper.customtextfeild(passcont, 'Password', Icons.lock, true),
                    const SizedBox(height: 20),
                    UiHelper.custombutton(
                      () {
                        print("Login button pressed"); // Debugging
                        login(emailcont.text.trim(), passcont.text.trim());
                      },
                      'Login',
                    ),
                    const SizedBox(height: 10),
                    
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}