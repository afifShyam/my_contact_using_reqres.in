import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'fetchUserData.dart'; // Import your Contact class here

class addPage extends StatefulWidget {
  final Function(Contact) onContactAdded;

  const addPage({Key? key, required this.onContactAdded}) : super(key: key);

  @override
  _addPageState createState() => _addPageState();
}

class _addPageState extends State<addPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  String? avatarUrl;

  Future<void> createData(
      String email, String fname, String lname, String avatarUrl) async {
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
            'avatar': avatarUrl,
          }));

      if (response.statusCode == 201) {
        // Create the new contact with the new ID
        final newContact = Contact(
          id: newId,
          email: email,
          firstName: fname,
          lastName: lname,
          image: avatarUrl,
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
      print('Error creating data: $error');
      throw Exception('Failed to create data');
    }
  }

  Future<int> fetchHighestId() async {
    try {
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
    } catch (error) {
      print('Error fetching highest ID: $error');
      throw Exception('Failed to fetch highest ID');
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (avatarUrl != null) {
        createData(
          _emailController.text,
          _fnameController.text,
          _lnameController.text,
          avatarUrl!,
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Please enter an image URL.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (avatarUrl != null)
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(60), // Adjust the radius as needed
                  child: CachedNetworkImage(
                    imageUrl: avatarUrl!,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    avatarUrl = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  hintText: 'Enter image URL here',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Email@gmail.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: _fnameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  hintText: 'Afiq',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a first name';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: _lnameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  hintText: 'Syakir',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a last name';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Contact'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
