import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Contact {
  int id;
  String email;
  String firstName;
  String lastName;
  String image;
  bool isFav;

  Contact({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.image,
    this.isFav = false,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
        id: json['id'],
        email: json['email'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        image: json['avatar']);
  }
}

// Data source that fetches data from the API and stores it in persistent storage
class ContactDataSource {
  Future<void> saveContacts(List<Contact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('contacts', jsonEncode(contacts));
  }
}
