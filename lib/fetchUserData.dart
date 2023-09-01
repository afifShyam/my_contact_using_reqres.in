import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Contact {
  int id;
  String email;
  String firstName;
  String lastName;
  bool isFav;
  String image;

  Contact({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.isFav = false,
    required this.image,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      image: json["avatar"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'avatar': image,
      'isFav': isFav,
    };
  }
}

// Data source that fetches data from the API and stores it in persistent storage
class ContactDataSource {
  Future<void> saveContacts(List<Contact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('contacts', jsonEncode(contacts));
  }

  Future<List<Contact>> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contactsJson = prefs.getString('contacts');
    if (contactsJson != null) {
      final List<dynamic> contactsData = jsonDecode(contactsJson);
      return contactsData.map((data) => Contact.fromJson(data)).toList();
    }
    return [];
  }
}
