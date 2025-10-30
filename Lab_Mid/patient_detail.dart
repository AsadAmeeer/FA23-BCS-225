import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/patient.dart';
import 'package:open_file/open_file.dart';

class PatientDetailScreen extends StatelessWidget {
  final Patient patient;
  const PatientDetailScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final hasImage =
        patient.imagePath != null && File(patient.imagePath!).existsSync();
    List<String> docs = [];
    if (patient.docPathsJson != null && patient.docPathsJson!.isNotEmpty) {
      try {
        final decoded = jsonDecode(patient.docPathsJson!);
        docs = List<String>.from(decoded);
      } catch (_) {
        docs = [];
      }
    }
    return Scaffold(
      appBar: AppBar(title: Text(patient.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(patient.imagePath!),
                    height: 240, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: ${patient.name}',
                        style: const TextStyle(fontSize: 18)),
                    Text('Age: ${patient.age}'),
                    Text('Disease: ${patient.disease}'),
                    const SizedBox(height: 6),
                    Text('Phone: ${patient.phone}'),
                    if (docs.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text('Documents:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      for (final doc in docs)
                        if (File(doc).existsSync())
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.attach_file),
                              label: Text(
                                  'Open ${doc.split(Platform.pathSeparator).last}'),
                              onPressed: () => OpenFile.open(doc),
                            ),
                          ),
                    ]
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
