import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Form to CSV',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FormPage(),
    );
  }
}

class FormPage extends StatefulWidget {
  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  bool _isSaving = false;

  Future<void> _saveToFile(String fileName, String content) async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Get the appropriate storage directory based on platform
      final Directory? directory = await getExternalStorageDirectory();

      if (directory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('External storage not available')),
        );
        return;
      }

      // Construct custom directory path
      final String customPath = '${directory.path}/GOODRICHAPP/Runsheets';
      final Directory customDirectory = Directory(customPath);

      // Create the directory if it doesn't exist
      if (!await customDirectory.exists()) {
        await customDirectory.create(recursive: true);
      }

      final File file = File('$customPath/$fileName');

      // Write or append CSV content
      final bool fileExists = await file.exists();
      if (fileExists) {
        // Append new data without rewriting header
        await file.writeAsString('$content\n', mode: FileMode.append);
      } else {
        // Write with header for a new file
        await file.writeAsString('Name,Age\n$content\n');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File saved successfully to ${file.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving file: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text;
      final String age = _ageController.text;

      // Create CSV content
      final String csvContent = '$name,$age';

      // Save to file
      _saveToFile('user_data.csv', csvContent);

      // Clear the form
      _nameController.clear();
      _ageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Save Form to CSV'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _isSaving
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _handleSubmit,
                      child: Text('Save to CSV'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
