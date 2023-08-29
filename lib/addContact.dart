import 'package:flutter/material.dart';
import 'fetchUserData.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class addPage extends StatefulWidget {
  final Function(Contact) onContactAdded;

  addPage({Key? key, required this.onContactAdded}) : super(key: key);

  @override
  _addPageState createState() => _addPageState();
}

class _addPageState extends State<addPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _avatarController = TextEditingController();

  Future<int> fetchHighestId() async {
    final response = await http.get(Uri.parse('https://reqres.in/api/users'));
    final jsonData = json.decode(response.body);
    final List<dynamic> data = jsonData['data'];

    int highestId = 0;
    for (final item in data) {
      final id = item['id'];
      if (id is int && id > highestId) {
        highestId = id;
      }
    }

    return highestId;
  }

  Future<void> createData(
      String email, String fname, String lname, String avatar) async {
    try {
      final int newId = await fetchHighestId() + 1;

      final response = await http.post(Uri.parse('https://reqres.in/api/users'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'id': newId,
            'email': email,
            'first_name': fname,
            'last_name': lname,
            'avatar': avatar,
          }));

      if (response.statusCode == 201) {
        // Create the new contact with the new ID
        final newContact = Contact(
          id: newId,
          email: email,
          firstName: fname,
          lastName: lname,
          image: avatar,
        );

        // Call the callback to notify MyContact widget about the new contact
        widget.onContactAdded(newContact);

        // Navigate back to the previous screen
        Navigator.pop(context);
      } else {
        print('Failed to create data - Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        throw Exception('Failed to create data');
      }
    } catch (error) {
      print(error);
      throw Exception('Failed to create data');
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      createData(
        _emailController.text,
        _fnameController.text,
        _lnameController.text,
        _avatarController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _fnameController,
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a first name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lnameController,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a last name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _avatarController,
                decoration: InputDecoration(labelText: 'Avatar URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an avatar URL';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Add Contact'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
