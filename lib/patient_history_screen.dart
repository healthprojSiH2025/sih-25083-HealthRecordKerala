import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'main.dart'; // Import main.dart to access DoctorEntryForm

class PatientHistoryScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const PatientHistoryScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<PatientHistoryScreen> createState() => _PatientHistoryScreenState();
}

class _PatientHistoryScreenState extends State<PatientHistoryScreen> {
  late Future<List<QueryDocumentSnapshot>> _visitsFuture;

  @override
  void initState() {
    super.initState();
    _visitsFuture = _fetchPatientVisits();
  }

  Future<List<QueryDocumentSnapshot>> _fetchPatientVisits() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('patients')
        .doc(widget.patientId)
        .collection('visits')
        .orderBy('recordedAt', descending: true)
        .get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History for ${widget.patientName}"),
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _visitsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No visit history found.'));
          }

          final visits = snapshot.data!;
          return ListView.builder(
            itemCount: visits.length,
            itemBuilder: (context, index) {
              final visitDocument = visits[index];
              final visit = visitDocument.data() as Map<String, dynamic>;
              // Add patient's name and ID to the visit data for the form
              final visitDataForForm = {
                ...visit,
                'name': widget.patientName,
                'id': widget.patientId
              };

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Visit Date: ${visit['visitDate'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // ===================================
                          // ===== NEW EDIT BUTTON =============
                          // ===================================
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: 'Edit Visit',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DoctorEntryForm(
                                    // Pass all necessary data for editing
                                    initialData: visitDataForForm,
                                    documentId: widget.patientId, // Patient ID
                                    visitId: visitDocument.id, // Visit's own unique ID
                                  ),
                                ),
                              ).then((_) {
                                // Refresh the list after returning from the edit screen
                                setState(() {
                                  _visitsFuture = _fetchPatientVisits();
                                });
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Symptoms: ${visit['symptoms'] ?? 'N/A'}'),
                      const SizedBox(height: 4),
                      Text('Location: ${visit['location'] ?? 'N/A'}'),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'Doctor Notes:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 4),
                      Text(visit['notes'] ?? 'No notes provided.'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}