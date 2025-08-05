import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _bloodTypeController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _medicalConditionsController =
      TextEditingController();
  final TextEditingController _medicationsController = TextEditingController();

  bool _isLoading = false;

  Future<void> _createAccount() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Mock account creation
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.02),
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: screenWidth * 0.3,
                        height: screenWidth * 0.3,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F3F3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Color(0xFF666666),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: screenWidth * 0.09,
                          height: screenWidth * 0.09,
                          decoration: const BoxDecoration(
                            color: Color(0xFF333333),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),

                // Basic Information Section
                const Text(
                  'Basic Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: _fullNameController,
                  hintText: 'Full name as per IC',
                  validator: (value) => value?.isEmpty == true
                      ? 'Please enter your full name'
                      : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _phoneController,
                  hintText: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  validator: (value) => value?.isEmpty == true
                      ? 'Please enter your phone number'
                      : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _emailController,
                  hintText: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Please enter your email' : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Please enter a password' : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Re-enter Password',
                  obscureText: true,
                  validator: (value) {
                    if (value?.isEmpty == true) {
                      return 'Please re-enter your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                // Emergency Information Section
                const Text(
                  'Emergency Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: _addressController,
                  hintText: 'Address',
                  validator: (value) => value?.isEmpty == true
                      ? 'Please enter your address'
                      : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _bloodTypeController,
                  hintText: 'Blood Type',
                  validator: (value) => value?.isEmpty == true
                      ? 'Please enter your blood type'
                      : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _allergiesController,
                  hintText: 'Allergies',
                  validator: (value) => value?.isEmpty == true
                      ? 'Please enter any allergies'
                      : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _medicalConditionsController,
                  hintText: 'Medical Conditions',
                  validator: (value) => value?.isEmpty == true
                      ? 'Please enter any medical conditions'
                      : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _medicationsController,
                  hintText: 'Medications',
                  validator: (value) => value?.isEmpty == true
                      ? 'Please enter any medications'
                      : null,
                ),

                const SizedBox(height: 40),

                // Create Account Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFED213A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            'Create account',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF666666),
          fontSize: 16,
        ),
        filled: true,
        fillColor: const Color(0xFFF3F3F3),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
