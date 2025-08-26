import 'package:flutter/material.dart';

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

  // State variables to store registered user data
  String _registeredName = "";
  String _registeredPhoneNumber = "";
  String _registeredEmail = "";
  String _registeredPassword = "";
  String _registeredAddress = "";
  String _registeredBloodType = "";
  String _registeredAllergies = "";
  String _registeredMedicalConditions = "";
  String _registeredMedications = "";

  bool _didExtractArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didExtractArgs) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      print('LoginScreen didChangeDependencies: Received args: $args');
      if (args != null) {
        _registeredName = args['name'] as String? ?? '';
        _registeredPhoneNumber = args['phoneNumber'] as String? ?? '';
        _registeredEmail = args['email'] as String? ?? '';
        _registeredPassword = args['password'] as String? ?? ''; // Store password
        _registeredAddress = args['address'] as String? ?? '';
        _registeredBloodType = args['bloodType'] as String? ?? '';
        _registeredAllergies = args['allergies'] as String? ?? '';
        _registeredMedicalConditions =
            args['medicalConditions'] as String? ?? '';
        _registeredMedications = args['medications'] as String? ?? '';
        
        // For debugging: Print stored registered data
        print('LoginScreen: Stored Registered Data - Email: $_registeredEmail, Password: $_registeredPassword, Name: $_registeredName, Phone: $_registeredPhoneNumber, Address: $_registeredAddress, BloodType: $_registeredBloodType, Allergies: $_registeredAllergies, Conditions: $_registeredMedicalConditions, Medications: $_registeredMedications');
      }
      _didExtractArgs = true;
    }
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await Future.delayed(const Duration(seconds: 1)); 

    // For debugging: print values being compared
    print('LoginScreen _signIn: Comparing input Email: ${_emailController.text} with Stored: $_registeredEmail');
    print('LoginScreen _signIn: Comparing input Password: ${_passwordController.text} with Stored: $_registeredPassword');

    // Compare with registered credentials
    if (_emailController.text == _registeredEmail &&
        _passwordController.text == _registeredPassword &&
        _registeredEmail.isNotEmpty) { // Ensure an email was actually registered
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        // For debugging: Print data being passed to /main
        print('LoginScreen: Navigating to /main with Name: $_registeredName, Phone: $_registeredPhoneNumber, Email: $_registeredEmail, Address: $_registeredAddress, BloodType: $_registeredBloodType, Allergies: $_registeredAllergies, Conditions: $_registeredMedicalConditions, Medications: $_registeredMedications');
        
        Navigator.pushReplacementNamed(
          context,
          '/main',
          arguments: {
            'name': _registeredName,
            'phoneNumber': _registeredPhoneNumber,
            'email': _registeredEmail,
            'address': _registeredAddress,
            'bloodType': _registeredBloodType,
            'allergies': _registeredAllergies,
            'medicalConditions': _registeredMedicalConditions,
            'medications': _registeredMedications,
            // DO NOT pass the password to MainScreen/HomeScreen
          },
        );
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid email or password';
      });
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
                                    validator: (value) => value == null || value.isEmpty
                                        ? 'Enter email'
                                        : null,
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
                                      child: Text(
                                        _errorMessage!,
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: fontSize,
                                        ),
                                      ),
                                    ),
                                  SizedBox(
                                    width: double.infinity,
                                    height: buttonHeight,
                                    child: ElevatedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : () {
                                              if (_formKey.currentState!.validate()) {
                                                _signIn();
                                              }
                                            },
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
                                  Wrap(
                                    alignment: WrapAlignment.center,
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
                                            fontSize: fontSize,
                                          ),
                                        ),
                                      ),
                                    ],
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
