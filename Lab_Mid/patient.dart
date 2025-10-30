class Patient {
  int? id;
  String name;
  int age;
  String gender;
  String notes;
  String disease;
  String phone;
  String? imagePath; // single thumbnail
  String? docPathsJson; // JSON encoded list of file paths

  Patient({
    this.id,
    required this.name,
    required this.age,
    required this.gender,
    this.notes = '',
    this.disease = '',
    this.phone = '',
    this.imagePath,
    this.docPathsJson,
  });

  factory Patient.fromMap(Map<String, dynamic> map) => Patient(
        id: map['id'] as int?,
        name: map['name'] as String,
        age: map['age'] is int
            ? map['age']
            : int.tryParse(map['age'].toString()) ?? 0,
        gender: map['gender'] as String? ?? 'Male',
        notes: map['notes'] as String? ?? '',
        disease: map['disease'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        imagePath: (map['imagePath'] as String?)?.isEmpty ?? true
            ? null
            : map['imagePath'] as String?,
        docPathsJson: map['docPathsJson'] as String?,
      );

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'age': age,
      'gender': gender,
      'notes': notes,
      'disease': disease,
      'phone': phone,
      'imagePath': imagePath,
      'docPathsJson': docPathsJson,
    };
    if (id != null) map['id'] = id;
    return map;
  }
}
