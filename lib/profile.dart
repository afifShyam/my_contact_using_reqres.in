import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'fetchUserData.dart';

class Profile extends StatefulWidget {
  final int contactId;
  final String initialEmail;
  final String initialFirstName;
  final String initialLastName;
  final String initialAvatar;

  const Profile({
    Key? key,
    required this.contactId,
    required this.initialEmail,
    required this.initialFirstName,
    required this.initialLastName,
    required this.initialAvatar,
  }) : super(key: key);

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _avatarController = TextEditingController();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.initialEmail;
    _fnameController.text = widget.initialFirstName;
    _lnameController.text = widget.initialLastName;
    _avatarController.text = widget.initialAvatar;
  }

  Future<void> updateData(int id, String email, String fname, String lname,
      String avatar, File? image) async {
    final uri = Uri.parse('https://reqres.in/api/users/$id');
    final request = http.MultipartRequest('PUT', uri);

    if (image != null) {
      final imageFile = await http.MultipartFile.fromPath('avatar', image.path);
      request.files.add(imageFile);
    }

    request.fields['email'] = email;
    request.fields['first_name'] = fname;
    request.fields['last_name'] = lname;
    request.fields['avatar'] = avatar;

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Failed to update data');
    }
  }

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  void _updateContact() async {
    if (_formKey.currentState!.validate()) {
      final contactId = widget.contactId;
      final email = _emailController.text;
      final fname = _fnameController.text;
      final lname = _lnameController.text;
      final avatar = _avatarController.text;

      try {
        await updateData(
          contactId,
          email,
          fname,
          lname,
          avatar,
          _selectedImage,
        );

        // Navigate back to the MyContact page and pass updated contact
        Navigator.pop(
            context,
            Contact(
              id: contactId,
              email: email,
              firstName: fname,
              lastName: lname,
              image: avatar,
              isFav: false, // Set isFav to an appropriate value
            ));
      } catch (error) {
        if (kDebugMode) {
          print(error);
        }
        // Handle error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(13, 10, 13, 0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      )
                    : CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(widget.initialAvatar),
                      ),
              ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email address',
                  border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  hintText: 'Enter your email address',
                  border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  hintText: 'Enter your email address',
                  border: OutlineInputBorder(),
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
              TextFormField(
                controller: _avatarController,
                decoration: const InputDecoration(
                  labelText: 'Avatar URL',
                  hintText: 'Enter your email address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an avatar URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateContact,
                child: Text('Update Contact'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
