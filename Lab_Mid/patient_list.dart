import 'dart:io';
import 'package:flutter/material.dart';
import '../helpers/db_helper.dart';
import '../models/patient.dart';
import 'add_edit_patient.dart';
import 'patient_detail.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  List<Patient> _patients = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    _patients = await DBHelper.instance.getPatients();
    setState(() => _loading = false);
  }

  Future<void> _delete(int id) async {
    await DBHelper.instance.deletePatient(id);
    await _refresh();
  }

  Future<void> _openAddEdit([Patient? p]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditPatientScreen(patient: p)),
    );
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('Patients',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: _patients.isEmpty
                      ? const Center(
                          child: Text('No patients yet. Tap + to add one.'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount: _patients.length,
                          itemBuilder: (context, i) {
                            final p = _patients[i];
                            final hasImage = p.imagePath != null &&
                                p.imagePath!.isNotEmpty &&
                                File(p.imagePath!).existsSync();
                            return Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 28,
                                  backgroundImage: hasImage
                                      ? FileImage(File(p.imagePath!))
                                      : null,
                                  child: hasImage
                                      ? null
                                      : const Icon(Icons.person,
                                          color: Colors.white),
                                ),
                                title: Text(p.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text('Age: ${p.age} • ${p.disease}'),
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            PatientDetailScreen(patient: p))),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blueAccent),
                                        onPressed: () => _openAddEdit(p)),
                                    IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.redAccent),
                                        onPressed: () => _delete(p.id!)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddEdit(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
