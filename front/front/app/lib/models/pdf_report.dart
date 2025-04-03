class PDFReport {
  final int id;
  final String name;
  final int age;
  final String gender;
  final double weight;
  final String phoneNumber;
  final String generatedAt;
  final String fileUrl; // This is the actual file path

  PDFReport({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.weight,
    required this.phoneNumber,
    required this.generatedAt,
    required this.fileUrl,
  });

  factory PDFReport.fromJson(Map<String, dynamic> json) {
    return PDFReport(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      weight: (json['weight'] as num).toDouble(),
      phoneNumber: json['phone_number'],
      generatedAt: json['generated_at'],
      fileUrl: json['file'], // Use the correct key from API response
    );
  }
}
