import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../helpers/db_helper.dart';
import '../models/patient.dart';

class AddEditPatientScreen extends StatefulWidget {
  final Patient? patient;
  const AddEditPatientScreen({super.key, this.patient});

  @override
  State<AddEditPatientScreen> createState() => _AddEditPatientScreenState();
}

class _AddEditPatientScreenState extends State<AddEditPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _diseaseCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String? _imagePath;
  String? _docPath;
  String _gender = 'Male';

  @override
  void initState() {
    super.initState();
    if (widget.patient != null) {
      _nameCtrl.text = widget.patient!.name;
      _ageCtrl.text = widget.patient!.age.toString();
      _diseaseCtrl.text = widget.patient!.disease;
      _phoneCtrl.text = widget.patient!.phone;
      _notesCtrl.text = widget.patient!.notes;
      _gender = widget.patient!.gender;
      _imagePath = widget.patient!.imagePath;
      // pick first document path if available
      if (widget.patient!.docPathsJson != null &&
          widget.patient!.docPathsJson!.isNotEmpty) {
        try {
          final list =
              jsonDecode(widget.patient!.docPathsJson!) as List<dynamic>;
          if (list.isNotEmpty) _docPath = list.first as String?;
        } catch (_) {}
      }
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imagePath = picked.path);
    }
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _docPath = result.files.single.path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final patient = Patient(
      id: widget.patient?.id,
      name: _nameCtrl.text,
      age: int.tryParse(_ageCtrl.text) ?? 0,
      gender: _gender,
      notes: _notesCtrl.text,
      disease: _diseaseCtrl.text,
      phone: _phoneCtrl.text,
      imagePath: _imagePath,
      docPathsJson: _docPath != null
          ? jsonEncode([_docPath])
          : widget.patient?.docPathsJson,
    );
    if (widget.patient == null) {
      await DBHelper.instance.insertPatient(patient);
    } else {
      await DBHelper.instance.updatePatient(patient);
    }
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _imagePath != null && File(_imagePath!).existsSync();
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.patient == null ? 'Add Patient' : 'Edit Patient')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile circle for the patient's image. Tapping it will open the
              // image picker. Shows the chosen image in a circular avatar.
              Center(
                child: InkWell(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 64,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: hasImage
                        ? ClipOval(
                            child: Image.file(
                              File(_imagePath!),
                              width: 128,
                              height: 128,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.person,
                            size: 64, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.image),
                label: const Text('Pick Image'),
                onPressed: _pickImage,
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.attach_file),
                label: const Text('Attach Document'),
                onPressed: _pickDocument,
              ),
              if (_docPath != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('Attached: ${_docPath!.split('/').last}',
                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ageCtrl,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  prefixIcon: Icon(Icons.cake),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Enter age' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _diseaseCtrl,
                decoration: const InputDecoration(
                  labelText: 'Disease',
                  prefixIcon: Icon(Icons.healing),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter disease' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone_android),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.person),
                ),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (v) => setState(() => _gender = v ?? 'Male'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
