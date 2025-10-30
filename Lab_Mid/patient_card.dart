import 'dart:io';
import 'package:flutter/material.dart';
// models/patient.dart is intentionally not referenced here to avoid analyzer
// cross-project type conflicts; runtime still expects the object shape.

class PatientCard extends StatelessWidget {
  // Use dynamic here to avoid analyzer conflicts with multiple Patient definitions
  // in the workspace (some nested example apps define a different Patient class).
  // At runtime this still works because the object has a `phone` and `name` fields.
  final dynamic patient;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PatientCard({
    Key? key,
    required this.patient,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final avatar = patient.imagePath != null && patient.imagePath!.isNotEmpty
        ? CircleAvatar(backgroundImage: FileImage(File(patient.imagePath!)))
        : const CircleAvatar(child: Icon(Icons.person));

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: avatar,
        title: Text(patient.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(patient.phone),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'edit') onEdit?.call();
            if (v == 'delete') onDelete?.call();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}
