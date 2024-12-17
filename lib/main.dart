import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(GoodRichSedimentControlApp());
}

class GoodRichSedimentControlApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GoodRich Sediment Control',
      theme: ThemeData(
        primaryColor: Colors.green,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.grey[800],
        ),
        scaffoldBackgroundColor: Colors.grey[300],
        textTheme: TextTheme(
          titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.grey[800]),
        ),
      ),
      home: GoodRichHomePage(),
    );
  }
}

class GoodRichHomePage extends StatelessWidget {
  void _launchTelemetryURL(BuildContext context) async {
    final Uri telemetryUrl = Uri.parse('https://green1telemetry.nz/');
    if (!await launchUrl(
      telemetryUrl,
      mode: LaunchMode.externalApplication,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open telemetry URL')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GoodRich Sediment Control'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome!',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  _buildTile(
                    context,
                    'Pond Monitoring',
                    Icons.water_damage,
                    Colors.blue,
                  ),
                  _buildTile(
                    context,
                    'Job Cards',
                    Icons.assignment,
                    Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NewJobCardPage()),
                      );
                    },
                  ),
                  _buildTile(
                    context,
                    'Service Requests',
                    Icons.build,
                    Colors.red,
                  ),
                  _buildTile(
                    context,
                    'Telemetry',
                    Icons.insights,
                    Colors.purple,
                    onTap: () {
                      _launchTelemetryURL(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[200],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, String title, IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title clicked')));
          },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48.0, color: color),
            SizedBox(height: 8.0),
            Text(
              title,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
          ],
        ),
      ),
    );
  }
}

class NewJobCardPage extends StatefulWidget {
  @override
  _NewJobCardPageState createState() => _NewJobCardPageState();
}

class _NewJobCardPageState extends State<NewJobCardPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _siteController = TextEditingController();
  final _personnelController = TextEditingController();
  final _installedController = TextEditingController();
  final _unitTypeController = TextEditingController();
  final _flocculantTypeController = TextEditingController();
  final _amountUsedController = TextEditingController();
  final _commentsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now()); // Autofill with the current date
  }

  Future<void> _saveForm() async {
    final formData = '''
Date: ${_dateController.text}
Company Name: ${_companyNameController.text}
Site: ${_siteController.text}
Personnel: ${_personnelController.text}
Installed/Moved/Disestablished: ${_installedController.text}
Unit Type: ${_unitTypeController.text}
Flocculant Type: ${_flocculantTypeController.text}
Amount Used: ${_amountUsedController.text}
Comments: ${_commentsController.text}
''';

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/job_card_${DateTime.now().millisecondsSinceEpoch}.doc');
    await file.writeAsString(formData);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Job card saved at ${file.path}')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Job Card'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _dateController, decoration: InputDecoration(labelText: 'Date')),
              TextFormField(controller: _companyNameController, decoration: InputDecoration(labelText: 'Company Name')),
              TextFormField(controller: _siteController, decoration: InputDecoration(labelText: 'Site')),
              TextFormField(controller: _personnelController, decoration: InputDecoration(labelText: 'Personnel')),
              TextFormField(controller: _installedController, decoration: InputDecoration(labelText: 'Installed/Moved/Disestablished')),
              TextFormField(controller: _unitTypeController, decoration: InputDecoration(labelText: 'Unit Type')),
              TextFormField(controller: _flocculantTypeController, decoration: InputDecoration(labelText: 'Flocculant Type')),
              TextFormField(controller: _amountUsedController, decoration: InputDecoration(labelText: 'Amount Used')),
              TextFormField(controller: _commentsController, decoration: InputDecoration(labelText: 'Comments')),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveForm();
                  }
                },
                child: Text('Save Job Card'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
