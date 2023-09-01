import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  final TextEditingController Urlimage = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.initialEmail;
    _fnameController.text = widget.initialFirstName;
    _lnameController.text = widget.initialLastName;
    Urlimage.text = widget.initialAvatar;
  }

  Future<void> updateData(
      int id, String email, String fname, String lname, String avatar) async {
    try {
      final uri = Uri.parse('https://reqres.in/api/users/$id');
      final request = http.MultipartRequest('PUT', uri);

      request.fields['email'] = email;
      request.fields['first_name'] = fname;
      request.fields['last_name'] = lname;
      request.fields['avatar'] = avatar;

      final response = await request.send();
      if (response.statusCode != 200) {
        throw Exception('Failed to update data');
      }
    } catch (error) {
      print('Error updating data: $error');
      throw Exception('Failed to update data');
    }
  }

  void _updateContact() async {
    if (_formKey.currentState!.validate()) {
      final contactId = widget.contactId;
      final email = _emailController.text;
      final fname = _fnameController.text;
      final lname = _lnameController.text;
      final avatar = Urlimage.text;

      try {
        await updateData(
          contactId,
          email,
          fname,
          lname,
          avatar,
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
              isFav: false,
            ));
      } catch (error) {
        if (kDebugMode) {
          print(error);
        }
        // Handle error
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to update contact.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
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
        title: const Text('Edit Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(13, 10, 13, 0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(60), // Adjust the radius as needed
                child: CachedNetworkImage(
                  imageUrl: Urlimage.text,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
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
                  hintText: 'Enter your first name',
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
                  hintText: 'Enter your last name',
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
                controller: Urlimage,
                onChanged: (value) {
                  setState(() {
                    Urlimage.text = value;
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateContact,
                child: const Text('Update Contact'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
