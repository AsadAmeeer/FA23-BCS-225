import 'package:flutter/material.dart';
import 'screens/patient_list.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DoctorPlusApp());
}

class DoctorPlusApp extends StatelessWidget {
  const DoctorPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor App',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const PatientListScreen(),
    );
  }
}
