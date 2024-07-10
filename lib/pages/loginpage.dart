import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  Future signIn() async {
    try {
      // Show loading circle
      showDialog(
        context: context,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _idController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Hide loading circle
      Navigator.of(context).pop();

      // Navigate to the home page after successful login
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      // Print out the error for debugging
      print(e);

      // Hide loading circle
      Navigator.of(context).pop();

      // Show error message
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'Failed to sign in. Please check your credentials and try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_florist_outlined,size: 70,),
                Text(
                  'God Bless You',
                  style: TextStyle(
                    fontFamily: GoogleFonts.raleway().fontFamily,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 34,
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: TextField(
                        controller: _idController,
                        style: TextStyle(
                            fontSize: 18,
                            fontFamily: GoogleFonts.habibi()
                                .fontFamily), // Increased text size
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'ID',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 25.0,
                          right:
                              8.0), // Added right padding for the suffix icon
                      child: TextField(
                        controller: _passwordController,
                        style: TextStyle(
                            fontSize: 18,
                            fontFamily: GoogleFonts.montserrat()
                                .fontFamily), // Increased text size
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: signIn,
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: GoogleFonts.raleway().fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: LoginPage(),
    routes: {
      '/home': (context) => Scaffold(body: Center(child: Text('Welcome'))),
    },
  ));
}
