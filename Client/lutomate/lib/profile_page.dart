import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String firstName;
  final String lastName;
  final List<String> preferences;
  const ProfilePage({super.key, required this.firstName, required this.lastName, required this.preferences});

  String get initials {
    String f = firstName.isNotEmpty ? firstName[0] : '';
    String l = lastName.isNotEmpty ? lastName[0] : '';
    return (f + l).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = const Color(0xFFD7BFA6);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: mainColor,
                  child: Text(
                    initials,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$firstName $lastName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Preferences:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: preferences.map((p) => Chip(label: Text(p))).toList(),
            ),
          ],
        ),
      ),
    );
  }
} 