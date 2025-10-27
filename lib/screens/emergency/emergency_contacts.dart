import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

// Model for a contact
class Contact {
  String id;
  String name;
  String phone;
  String relationship;

  Contact({required this.id, required this.name, required this.phone, required this.relationship});

 factory Contact.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Contact(
        id: doc.id,
        name: data['name'] ?? '',
        phone: data['phone'] ?? '',
        relationship: data['relationship'] ?? '');
  }
}

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late CollectionReference _contactsCollection;

  // Controllers for the Add/Edit dialog
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();

 @override
  void initState() {
    super.initState();
    // Ensure user is logged in before accessing collection
    User? user = _auth.currentUser;
    if (user != null) {
      _contactsCollection = _firestore.collection('users').doc(user.uid).collection('emergency_contacts');
    } else {
      // Handle user not logged in case. Maybe navigate away or show an error.
      debugPrint("User not logged in!");
    }
  }


  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  void _clearControllers() {
    _nameController.clear();
    _phoneController.clear();
    _relationshipController.clear();
  }

  void _showAddOrEditContactDialog({Contact? contact}) {
    if (contact != null) {
      _nameController.text = contact.name;
      _phoneController.text = contact.phone;
      _relationshipController.text = contact.relationship;
    } else {
      _clearControllers();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: Text(contact == null ? 'Add Emergency Contact' : 'Edit Emergency Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Full name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Phone number (e.g., +60...)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _relationshipController,
                decoration: const InputDecoration(
                  hintText: 'Relationship (e.g., Parent)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5A5A),
              ),
              onPressed: () {
                if (_nameController.text.isNotEmpty &&
                    _phoneController.text.isNotEmpty &&
                    _relationshipController.text.isNotEmpty) {
                  if (contact == null) {
                    // Add new contact to Firestore
                    _contactsCollection.add({
                      'name': _nameController.text,
                      'phone': _phoneController.text,
                      'relationship': _relationshipController.text,
                    });
                  } else {
                    // Update existing contact in Firestore
                    _contactsCollection.doc(contact.id).update({
                      'name': _nameController.text,
                      'phone': _phoneController.text,
                      'relationship': _relationshipController.text,
                    });
                  }
                  _clearControllers();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Contact ${contact == null ? 'added' : 'updated'} successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              child: Text(contact == null ? 'Add Contact' : 'Save Changes', style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Contact contact) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Contact'),
          content: Text('Are you sure you want to delete ${contact.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                _contactsCollection.doc(contact.id).delete();
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contact deleted successfully')),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

 Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.platformDefault);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch dialer for $phoneNumber')),
      );
    }
  }

  Widget _buildContactItem(BuildContext context, Contact contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(contact.phone, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                const SizedBox(height: 2),
                Text(contact.relationship, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              _showAddOrEditContactDialog(contact: contact);
            },
            child: const Text('Edit', style: TextStyle(color: Color(0xFFFF5A5A))), 
          ),
          TextButton(
            onPressed: () {
               _makePhoneCall(contact.phone);
            },
            child: const Text('Call', style: TextStyle(color: Color(0xFFFF5A5A))), 
          ),
          TextButton(
            onPressed: () {
              _showDeleteConfirmationDialog(context, contact);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],), 
    );
  }

  @override
  Widget build(BuildContext context) {
    // Re-check user in build method in case of auth state changes
    User? user = _auth.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to see contacts.")),
      );
    }
    // Re-initialize collection reference if it's not set (e.g., after hot reload)
    _contactsCollection = _firestore.collection('users').doc(user.uid).collection('emergency_contacts');


    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFF5A5A), Color(0xFFFF8A8A)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Make scaffold transparent
        appBar: AppBar(
          title: const Text('Emergency Contacts', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent, // Make appbar transparent
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _contactsCollection.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            'No contacts yet. Tap "Add Contact" to begin.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.8)),
                          ),
                        );
                      }
                      final contacts = snapshot.data!.docs.map((doc) => Contact.fromFirestore(doc)).toList();
                      return ListView.builder(
                        itemCount: contacts.length,
                        itemBuilder: (context, index) {
                          return _buildContactItem(context, contacts[index]);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // Button color
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      _showAddOrEditContactDialog();
                    },
                    child: const Text(
                      'Add Contact',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF5A5A), // Text color
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
