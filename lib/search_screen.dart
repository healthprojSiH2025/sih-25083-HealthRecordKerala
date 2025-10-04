import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'patient_history_screen.dart'; // 1. ADD THIS IMPORT for the new screen

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _idController = TextEditingController();

  // This function is now updated to navigate to the patient history screen
  Future<void> _searchMigrant() async {
    // Hide the keyboard
    FocusScope.of(context).unfocus();
    
    final String uniqueID = _idController.text.trim();
    final RegExp idFormat = RegExp(r'^KL-\d{3}$');

    if (uniqueID.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Search ID.')),
      );
      return;
    }

    if (!idFormat.hasMatch(uniqueID)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Invalid ID format. Must be KL-XXX (e.g., KL-123).')),
      );
      return;
    }

    final patientDocRef =
        FirebaseFirestore.instance.collection('patients').doc(uniqueID);
    final patientSnapshot = await patientDocRef.get();

    if (patientSnapshot.exists) {
      // ========================================================
      // ===== THIS IS THE MODIFIED LOGIC =======================
      // ========================================================
      final patientData = patientSnapshot.data() as Map<String, dynamic>;
      final patientName = patientData['name'] ?? 'Unknown Patient';

      // Navigate to the new history screen, passing the patient's ID and name
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PatientHistoryScreen(
            patientId: uniqueID,
            patientName: patientName,
          ),
        ),
      );
      // ========================================================
      // ===== END OF MODIFIED LOGIC ============================
      // ========================================================
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Migrant with this ID not found.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Existing Migrant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'Enter Unique Migrant ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _searchMigrant, // Call the search function when pressed
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}