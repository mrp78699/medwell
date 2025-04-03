class Prescription {
  final int id;
  final int user;
  final String prescriptionFile;
  final String uploadedAt;

  Prescription({
    required this.id,
    required this.user,
    required this.prescriptionFile,
    required this.uploadedAt,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'],
      user: json['user'],
      prescriptionFile: json['prescription_file'] ?? '', // Handle null value
      uploadedAt: json['uploaded_at'],
    );
  }
}
