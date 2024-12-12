
// Flutter app template to interact with the Flask API
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(LearnersApp());
}

class LearnersApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learners Performance App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LearnersList(),
    );
  }
}

class LearnersList extends StatefulWidget {
  @override
  _LearnersListState createState() => _LearnersListState();
}

class _LearnersListState extends State<LearnersList> {
  List learners = [];

  @override
  void initState() {
    super.initState();
    fetchLearners();
  }

  Future<void> fetchLearners() async {
    final response = await http.get(Uri.parse('http://<your-flask-api>/api/learners'));
    if (response.statusCode == 200) {
      setState(() {
        learners = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load learners');
    }
  }

  void navigateToAddLearner() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddLearner(onLearnerAdded: fetchLearners)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Learners List')),
      body: learners.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: learners.length,
              itemBuilder: (context, index) {
                final learner = learners[index];
                return ListTile(
                  title: Text(learner['name']),
                  subtitle: Text('Total Marks: ${learner['total']}'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToAddLearner,
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddLearner extends StatefulWidget {
  final Function onLearnerAdded;

  AddLearner({required this.onLearnerAdded});

  @override
  _AddLearnerState createState() => _AddLearnerState();
}

class _AddLearnerState extends State<AddLearner> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _marksControllers = {
    'ENG': TextEditingController(),
    'MATH': TextEditingController(),
    'KISW': TextEditingController(),
    'SCIE': TextEditingController(),
    'SST': TextEditingController(),
  };

  Future<void> addLearner() async {
    final learnerData = {
      'name': _nameController.text,
      ..._marksControllers.map((key, controller) => MapEntry(key, int.parse(controller.text)))
    };

    final response = await http.post(
      Uri.parse('http://<your-flask-api>/api/learners'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(learnerData),
    );

    if (response.statusCode == 201) {
      widget.onLearnerAdded();
      Navigator.pop(context);
    } else {
      throw Exception('Failed to add learner');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Learner')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              ..._marksControllers.keys.map((key) => TextFormField(
                    controller: _marksControllers[key],
                    decoration: InputDecoration(labelText: key),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter marks for $key';
                      }
                      return null;
                    },
                  )),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    addLearner();
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
