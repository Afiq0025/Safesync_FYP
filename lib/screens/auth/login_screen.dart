import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safesync/services/bluetooth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BluetoothService _bluetoothService = BluetoothService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Disconnect any existing Bluetooth connection before signing in a new user
      await _bluetoothService.disconnectDevice();

      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        debugPrint("Firebase Login successful: Auth UID: ${user.uid}, Email: ${user.email}");

        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          debugPrint("Firebase Login: User details fetched from Firestore: $userData");

          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              '/main',
              arguments: {
                'name': userData['fullName'] ?? (user.displayName ?? 'User'),
                'phoneNumber': userData['phoneNumber'] ?? 'N/A',
                'email': user.email,
                'address': userData['address'] ?? 'N/A',
                'bloodType': userData['bloodType'] ?? 'N/A',
                'allergies': userData['allergies'] ?? 'N/A',
                'medicalConditions': userData['medicalConditions'] ?? 'N/A',
                'medications': userData['medications'] ?? 'N/A',
              },
            );
          }
        } else {
          debugPrint("Firebase Login: Error - User document not found in Firestore for UID: ${user.uid}");
          if (mounted) {
            setState(() {
              _errorMessage = "User details not found. Please sign up or contact support.";
            });
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential' || e.code == 'INVALID_LOGIN_CREDENTIALS') {
        message = 'Invalid email or password.';
      } else {
        message = 'Login failed: ${e.message}';
      }
      debugPrint("Firebase Login error (Auth): $message (${e.code})");
      if (mounted) {
        setState(() {
          _errorMessage = message;
        });
      }
    } catch (e) {
      debugPrint("Login error (Auth or Firestore): $e");
      if (mounted) {
        setState(() {
          _errorMessage = "An unexpected error occurred during login.";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 350;
          final isLargeScreen = constraints.maxWidth > 600;

          final welcomeFontSize = isSmallScreen ? 28.0 : 40.0;
          final cardWidth = isLargeScreen
              ? constraints.maxWidth * 0.5
              : constraints.maxWidth * 0.88;
          final cardPadding = EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16.0 : 24.0,
            vertical: isSmallScreen ? 20.0 : 32.0,
          );
          final buttonHeight = isSmallScreen ? 44.0 : 48.0;
          final fontSize = isSmallScreen ? 14.0 : 16.0;

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFFE60000),
                  Color(0xFFFF6A6A),
                  Color(0xFFFAFAFA),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: isSmallScreen ? 20.0 : 10.0),
                        Text(
                          'Welcome',
                          style: TextStyle(
                            fontSize: welcomeFontSize,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontFamily: 'Serif',
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 40.0 : 60.0),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: cardWidth,
                          ),
                          child: Container(
                            padding: cardPadding,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Sign in',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 24.0 : 28.0,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Serif',
                                    ),
                                  ),
                                  SizedBox(height: isSmallScreen ? 16.0 : 24.0),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      hintText: 'Email address',
                                      filled: true,
                                      fillColor: const Color(0xFFF3F3F3),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: isSmallScreen ? 12 : 16,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(24),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Enter email';
                                      }
                                      if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
                                        return 'Please enter a valid email address';
                                      }
                                      return null;
                                    }
                                  ),
                                  SizedBox(height: isSmallScreen ? 12.0 : 16.0),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: 'Password',
                                      filled: true,
                                      fillColor: const Color(0xFFF3F3F3),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: isSmallScreen ? 12 : 16,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(24),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    validator: (value) => value == null || value.isEmpty
                                        ? 'Enter password'
                                        : null,
                                  ),
                                  SizedBox(height: isSmallScreen ? 20.0 : 24.0),
                                  if (_errorMessage != null)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Center(
                                        child: Text(
                                          _errorMessage!,
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: fontSize,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  SizedBox(
                                    width: double.infinity,
                                    height: buttonHeight,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _signIn,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFED213A),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: _isLoading
                                          ? const CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                            )
                                          : Text(
                                              'Sign In',
                                              style: TextStyle(
                                                fontSize: isSmallScreen ? 16.0 : 18.0,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                  SizedBox(height: isSmallScreen ? 12.0 : 16.0),
                                  Center(
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          "Don't have an account? ",
                                          style: TextStyle(fontSize: fontSize),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pushNamed(context, '/signup');
                                          },
                                          child: Text(
                                            'Sign up',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.underline,
                                              color: const Color(0xFFED213A),
                                              fontSize: fontSize,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
