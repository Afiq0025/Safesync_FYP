import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  final String name;
  final String phoneNumber;
  final String email;
  final String address;
  final String bloodType;
  final String allergies;
  final String medicalConditions;
  final String medications;

  const ProfileScreen({
    Key? key,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.bloodType,
    required this.allergies,
    required this.medicalConditions,
    required this.medications,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _bloodTypeController;
  late TextEditingController _allergiesController;
  late TextEditingController _medicalConditionsController;
  late TextEditingController _medicationsController;

  bool _isEditingName = false;
  bool _isEditingPhone = false;
  bool _isEditingAddress = false;
  bool _isEditingBloodType = false;
  bool _isEditingAllergies = false;
  bool _isEditingMedicalConditions = false;
  bool _isEditingMedications = false;

  bool _isLoading = false;

  Map<String, bool> expandedSections = {
    'address': false,
    'bloodType': false,
    'allergies': false,
    'medicalConditions': false,
    'medications': false,
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _phoneController = TextEditingController(text: widget.phoneNumber);
    _addressController = TextEditingController(text: widget.address);
    _bloodTypeController = TextEditingController(text: widget.bloodType);
    _allergiesController = TextEditingController(text: widget.allergies);
    _medicalConditionsController =
        TextEditingController(text: widget.medicalConditions);
    _medicationsController = TextEditingController(text: widget.medications);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    _medicalConditionsController.dispose();
    _medicationsController.dispose();
    super.dispose();
  }

  void _resetAllEditingStates() {
    setState(() {
      _isEditingName = false;
      _isEditingPhone = false;
      _isEditingAddress = false;
      _isEditingBloodType = false;
      _isEditingAllergies = false;
      _isEditingMedicalConditions = false;
      _isEditingMedications = false;
    });
  }

  Future<void> _saveDisplayName() async {
    if (_nameController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name cannot be empty.')),
        );
      }
      return;
    }
    setState(() {
      _isLoading = true;
    });
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in. Cannot save name.')),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      String newName = _nameController.text.trim();

      // 1. Update Firebase Authentication displayName (this field name is fixed by Firebase Auth)
      await currentUser.updateProfile(displayName: newName);
      await currentUser.reload();

      // 2. Update 'fullName' field in Firestore document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set({'fullName': newName}, SetOptions(merge: true)); // Key changed to fullName

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name updated successfully!')),
        );
        setState(() {
          _isEditingName = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating name: $e')),
        );
      }
      debugPrint('Error in _saveDisplayName (Auth or Firestore): $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _savePhoneNumber() async {
    if (_phoneController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phone number cannot be empty.')),
        );
      }
      return;
    }
    setState(() {
      _isLoading = true;
    });

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in. Cannot save phone number.')),
        );
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set({'phoneNumber': _phoneController.text.trim()}, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phone number updated successfully in Firestore!')),
        );
        setState(() {
          _isEditingPhone = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating phone number in Firestore: $e')),
        );
      }
      debugPrint('Firestore Error in _savePhoneNumber: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveField(
      String fieldName, TextEditingController controller, Function(bool) setEditingState) async {
    if (controller.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$fieldName cannot be empty.')),
        );
      }
      return;
    }
    setState(() {
      _isLoading = true;
    });

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in. Cannot save data.')),
        );
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set({fieldName: controller.text.trim()}, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$fieldName updated successfully in Firestore!')),
        );
        setState(() {
          setEditingState(false);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating $fieldName in Firestore: $e')),
        );
      }
      debugPrint('Firestore Error in _saveField ($fieldName): $e');
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D1D1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 20),
                _isEditingName
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              icon: Icon(Icons.save, color: Colors.transparent),
                              onPressed: null),
                          Flexible(
                            child: TextField(
                              controller: _nameController,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black),
                              decoration: const InputDecoration(
                                  hintText: 'Enter your name',
                                  border: InputBorder.none),
                              autofocus: true,
                            ),
                          ),
                          _isLoading && _isEditingName
                              ? SizedBox(
                                  height: 48,
                                  width: 48,
                                  child: Center(
                                      child: SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2))))
                              : IconButton(
                                  icon: const Icon(Icons.save,
                                      color: Colors.green),
                                  onPressed: _saveDisplayName)
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              icon: Icon(Icons.edit, color: Colors.transparent),
                              onPressed: null),
                          Flexible(
                            child: Text(
                              FirebaseAuth.instance.currentUser?.displayName ??
                                  _nameController.text,
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _resetAllEditingStates();
                              setState(() {
                                _nameController.text = FirebaseAuth
                                        .instance.currentUser?.displayName ??
                                    widget.name;
                                _isEditingName = true;
                              });
                            },
                          ),
                        ],
                      ),
                const SizedBox(height: 0),
                _isEditingPhone
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              icon: Icon(Icons.save,
                                  color: Colors.transparent, size: 20),
                              onPressed: null),
                          Flexible(
                            child: TextField(
                              controller: _phoneController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(
                                  fontSize: 16, color: Color(0xFF666666)),
                              decoration: const InputDecoration(
                                  hintText: 'Enter phone number',
                                  border: InputBorder.none),
                              autofocus: true,
                            ),
                          ),
                          _isLoading && _isEditingPhone
                              ? SizedBox(
                                  height: 48,
                                  width: 48,
                                  child: Center(
                                      child: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2))))
                              : IconButton(
                                  icon: const Icon(Icons.save,
                                      color: Colors.green, size: 20),
                                  onPressed: _savePhoneNumber)
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              icon: Icon(Icons.edit,
                                  color: Colors.transparent, size: 20),
                              onPressed: null),
                          Flexible(
                            child: Text(
                              _phoneController.text.isNotEmpty
                                  ? _phoneController.text
                                  : '(No phone number)',
                              style: const TextStyle(
                                  fontSize: 16, color: Color(0xFF666666)),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.blue, size: 20),
                            onPressed: () {
                              _resetAllEditingStates();
                              setState(() {
                                _isEditingPhone = true;
                              });
                            },
                          ),
                        ],
                      ),
                const SizedBox(height: 4),
                Text(
                  widget.email,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 40),
            _buildExpandableEditableSection(
              'Address',
              'address',
              _addressController,
              _isEditingAddress,
              (bool isEditing) => setState(() => _isEditingAddress = isEditing),
              () => _saveField('address', _addressController, (val) => _isEditingAddress = val),
            ),
            const SizedBox(height: 12),
            _buildExpandableEditableSection(
              'Blood Type',
              'bloodType',
              _bloodTypeController,
              _isEditingBloodType,
              (bool isEditing) => setState(() => _isEditingBloodType = isEditing),
              () => _saveField('bloodType', _bloodTypeController, (val) => _isEditingBloodType = val),
            ),
            const SizedBox(height: 12),
            _buildExpandableEditableSection(
              'Allergies',
              'allergies',
              _allergiesController,
              _isEditingAllergies,
              (bool isEditing) => setState(() => _isEditingAllergies = isEditing),
              () => _saveField('allergies', _allergiesController, (val) => _isEditingAllergies = val),
            ),
            const SizedBox(height: 12),
            _buildExpandableEditableSection(
              'Medical Conditions',
              'medicalConditions',
              _medicalConditionsController,
              _isEditingMedicalConditions,
              (bool isEditing) => setState(() => _isEditingMedicalConditions = isEditing),
              () => _saveField('medicalConditions', _medicalConditionsController, (val) => _isEditingMedicalConditions = val),
            ),
            const SizedBox(height: 12),
             _buildExpandableEditableSection(
              'Medications',
              'medications',
              _medicationsController,
              _isEditingMedications,
              (bool isEditing) => setState(() => _isEditingMedications = isEditing),
              () => _saveField('medications', _medicationsController, (val) => _isEditingMedications = val),
            ),
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  _showLogoutDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE60000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Log out',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableEditableSection(
      String title,
      String key,
      TextEditingController controller,
      bool isEditing,
      Function(bool) setEditingState,
      VoidCallback onSave) {
    bool isExpanded = expandedSections[key] ?? false;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(15),
                topRight: const Radius.circular(15),
                bottomLeft: Radius.circular(isExpanded ? 0 : 15),
                bottomRight: Radius.circular(isExpanded ? 0 : 15),
              ),
              onTap: () {
                setState(() {
                  expandedSections[key] = !isExpanded;
                });
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: const Color(0xFF666666),
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 18, top: 10),
              child: isEditing
                  ? Row(
                      children: [
                        Flexible(
                          child: TextField(
                            controller: controller,
                            style: const TextStyle(
                              color: Color(0xFF555555),
                              fontSize: 15,
                              height: 1.4,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter $title',
                              border: const UnderlineInputBorder(),
                            ),
                            maxLines: null,
                            autofocus: true,
                          ),
                        ),
                        _isLoading && isEditing
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: Center(
                                    child: SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2))))
                            : IconButton(
                                icon: const Icon(Icons.save,
                                    color: Colors.green, size: 20),
                                onPressed: onSave,
                              ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Text(
                            controller.text.isNotEmpty ? controller.text : 'Not set',
                            style: const TextStyle(
                              color: Color(0xFF555555),
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: Colors.blue, size: 20),
                          onPressed: () {
                            _resetAllEditingStates();
                            setEditingState(true);
                          },
                        ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            'Log Out',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.of(context).pop();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (Route<dynamic> route) => false);
                }
              },
              child: const Text(
                'Log Out',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
