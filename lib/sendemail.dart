import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'fetchUserData.dart';

import 'profile.dart';

class SendEmail extends StatefulWidget {
  final int contactId;
  final String initialEmail;
  final String initialFirstName;
  final String initialLastName;
  final String initialAvatar;

  const SendEmail({
    Key? key,
    required this.contactId,
    required this.initialEmail,
    required this.initialFirstName,
    required this.initialLastName,
    required this.initialAvatar,
  }) : super(key: key);

  @override
  _SendEmailState createState() => _SendEmailState();
}

class _SendEmailState extends State<SendEmail> {
  void _sendEmail() async {
    String? encodeQueryParameters(Map<String, String> params) {
      return params.entries
          .map((MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
    }

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: widget.initialEmail,
      query: encodeQueryParameters(<String, String>{
        'subject': 'Hi hope you hired me!',
      }),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      // Handle the case where the device can't open an email app.
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Email App Not Found'),
          content: const Text('No email app is available on this device.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Email'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                // Navigate to the edit page.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Profile(
                      contactId: widget.contactId,
                      initialEmail: widget.initialEmail,
                      initialFirstName: widget.initialFirstName,
                      initialLastName: widget.initialLastName,
                      initialAvatar: widget.initialAvatar,
                    ),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(widget.initialAvatar),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${widget.initialFirstName} ${widget.initialLastName}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.initialEmail,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendEmail,
              child: const Text('Send Email'),
            ),
          ],
        ),
      ),
    );
  }
}
