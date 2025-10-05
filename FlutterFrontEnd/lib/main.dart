import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_screen.dart'; // Assuming you have this file

enum PatientType { existing, newMember }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
);

  runApp(const HealthTrackerApp());
}

class HealthTrackerApp extends StatelessWidget {
  const HealthTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreen(), // Or DoctorEntryForm() for direct testing
    );
  }
}

class DoctorEntryForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final String? documentId; // This is the Patient ID (e.g., KL-690)
  final String? visitId;    // This is the visit's own unique ID

  const DoctorEntryForm({
    super.key,
    this.initialData,
    this.documentId,
    this.visitId,
  });

  @override
  State<DoctorEntryForm> createState() => _DoctorEntryFormState();
}

class _DoctorEntryFormState extends State<DoctorEntryForm> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _dateController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedVaccinationStatus;
  String? _selectedDistrict;
  final List<String> _keralaDistricts = const [
    'Alappuzha', 'Ernakulam', 'Idukki', 'Kannur', 'Kasaragod', 'Kollam',
    'Kottayam', 'Kozhikode', 'Malappuram', 'Palakkad', 'Pathanamthitta',
    'Thiruvananthapuram', 'Thrissur', 'Wayanad'
  ];
  PatientType _selectedPatientType = PatientType.newMember;

  @override
  void initState() {
    super.initState();
    // Pre-fill form if editing existing data
    if (widget.initialData != null) {
      _nameController.text = widget.initialData!['name'] ?? '';
      _idController.text = widget.documentId ?? '';
      _dateController.text = widget.initialData!['visitDate'] ?? '';
      _symptomsController.text = widget.initialData!['symptoms'] ?? '';
      _notesController.text = widget.initialData!['notes'] ?? '';
      _selectedVaccinationStatus = widget.initialData!['vaccinationStatus'];
      _selectedDistrict = widget.initialData!['location'];
      _selectedPatientType = PatientType.existing;
    }
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed.
    _nameController.dispose();
    _idController.dispose();
    _dateController.dispose();
    _symptomsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.visitId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Visit Details' : 'Add New Record'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isEditing)
              SegmentedButton<PatientType>(
                segments: const <ButtonSegment<PatientType>>[
                  ButtonSegment<PatientType>(
                    value: PatientType.newMember,
                    label: Text('Add New Member'),
                  ),
                  ButtonSegment<PatientType>(
                    value: PatientType.existing,
                    label: Text('Existing Patient'),
                  ),
                ],
                selected: {_selectedPatientType},
                onSelectionChanged: (Set<PatientType> newSelection) {
                  setState(() {
                    _selectedPatientType = newSelection.first;
                    // When switching to existing patient, use the passed documentId
                    if (_selectedPatientType == PatientType.existing && widget.documentId != null) {
                       _idController.text = widget.documentId!;
                    }
                  });
                },
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              enabled: _selectedPatientType == PatientType.newMember && !isEditing,
              decoration: const InputDecoration(
                labelText: 'Patient Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _idController,
              enabled: _selectedPatientType == PatientType.newMember && !isEditing,
              decoration: const InputDecoration(
                labelText: 'Unique Patient ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Date of Visit',
                hintText: 'e.g., dd-mm-yyyy',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _symptomsController,
              decoration: const InputDecoration(
                labelText: 'Reported Symptoms',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDistrict,
              decoration: const InputDecoration(
                labelText: 'Current Location (District)',
                border: OutlineInputBorder(),
              ),
              items:
                  _keralaDistricts.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDistrict = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedVaccinationStatus,
              decoration: const InputDecoration(
                labelText: 'Vaccination Records',
                border: OutlineInputBorder(),
              ),
              items: <String>[
                'Fully Vaccinated',
                'Partially Vaccinated',
                'Not Vaccinated'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedVaccinationStatus = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Additional Notes (Doctor Advice)',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _submitData, // Use a separate function for clarity
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 16),
                ),
                child: Text(isEditing ? 'Update Visit' : 'Submit Data'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // A dedicated function to handle the form submission logic
  Future<void> _submitData() async {
    final isEditing = widget.visitId != null;
    
    // --- 1. VALIDATION ---
    final String uniqueID = _idController.text.trim();
    final String date = _dateController.text.trim();
    final RegExp idFormat = RegExp(r'^KL-\d{3}$');
    final RegExp dateFormat =
        RegExp(r'^([0-2][0-9]|3[0-1])-(0[1-9]|1[0-2])-\d{4}$');

    if (uniqueID.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unique Patient ID cannot be empty.')));
      return;
    }
    if (_selectedPatientType == PatientType.newMember && !isEditing) {
      if (!idFormat.hasMatch(uniqueID)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Invalid ID format. Must be KL-XXX (e.g., KL-123).')));
        return;
      }
    }
    if (date.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Date cannot be empty.')));
      return;
    }
    if (!dateFormat.hasMatch(date)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid date format. Must be dd-mm-yyyy.')));
      return;
    }

    // ===================================================================
    // ===== NEW: CHECK IF PATIENT ID ALREADY EXISTS FOR NEW MEMBERS =====
    // ===================================================================
    final firestore = FirebaseFirestore.instance;
    if (_selectedPatientType == PatientType.newMember && !isEditing) {
      final patientDocRef = firestore.collection('patients').doc(uniqueID);
      final docSnapshot = await patientDocRef.get();

      if (docSnapshot.exists) {
        // If the document exists, show a warning and stop the function.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient with this ID already exists in the records.'))
        );
        return; 
      }
    }
    // ===================================================================

    try {
      final patientDocRef = firestore.collection('patients').doc(uniqueID);

      // --- 2. PREPARE VISIT DATA ---
      final Map<String, dynamic> visitData = {
        'visitDate': date,
        'symptoms': _symptomsController.text,
        'location': _selectedDistrict,
        'notes': _notesController.text,
        'vaccinationStatus': _selectedVaccinationStatus,
      };

      // --- 3. EXECUTE DATABASE OPERATIONS ---
      if (isEditing) {
        // A) UPDATE AN EXISTING VISIT
        await patientDocRef.collection('visits').doc(widget.visitId).update(visitData);
      } else {
        // B) CREATE A NEW VISIT
        visitData['recordedAt'] = FieldValue.serverTimestamp();

        // If it's a brand new patient, create their main document first
        if (_selectedPatientType == PatientType.newMember) {
          await patientDocRef.set({
            'name': _nameController.text,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        await patientDocRef.collection('visits').add(visitData);
      }
      
      // --- 4. UPDATE PATIENT'S LATEST STATUS ---
      await patientDocRef.update({
        'currentVaccinationStatus': _selectedVaccinationStatus,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data for patient $uniqueID saved successfully!')),
      );
      if (mounted) Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }
}