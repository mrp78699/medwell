import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';

class GeneratePDFReportScreen extends StatefulWidget {
  @override
  _GeneratePDFReportScreenState createState() => _GeneratePDFReportScreenState();
}

class _GeneratePDFReportScreenState extends State<GeneratePDFReportScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  int age = 0;
  String gender = 'Male';
  double weight = 0.0;
  String mobileNumber = '';

  final AuthService apiService = AuthService();

  void generateReport() async {
    if (_formKey.currentState!.validate()) {
      try {
        await apiService.generatePDFReport(name, age, gender, weight, mobileNumber);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF Report generated successfully')),
        );
        Navigator.pop(context, true);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate report: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate PDF Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade700,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[300]!, Colors.green[700]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enter Your Details',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 20),
                        _buildTextField('Name', (value) => name = value, TextInputType.text),
                        _buildTextField('Age', (value) => age = int.tryParse(value) ?? 0, TextInputType.number),
                        _buildDropdown(),
                        _buildTextField('Weight (kg)', (value) => weight = double.tryParse(value) ?? 0.0, TextInputType.number),
                        _buildTextField('Mobile Number', (value) => mobileNumber = value, TextInputType.phone),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: generateReport,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: Colors.green.shade700,
                    ),
                    child: Text('Generate PDF Report', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, Function(String) onChanged, TextInputType keyboardType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey.shade200,
        ),
        keyboardType: keyboardType,
        validator: (value) => value!.isEmpty ? 'Please enter your $label' : null,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Gender',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey.shade200,
        ),
        value: gender,
        items: ['Male', 'Female', 'Prefer not to say']
            .map((label) => DropdownMenuItem(
          value: label,
          child: Text(label),
        ))
            .toList(),
        onChanged: (value) {
          setState(() {
            gender = value!;
          });
        },
        validator: (value) => value == null ? 'Please select gender' : null,
      ),
    );
  }
}