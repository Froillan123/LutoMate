import 'package:flutter/material.dart';
import 'register_page.dart' show foodOptions;
import 'api_service.dart';

const List<String> foodOptions = [
  'Chicken', 'Beef', 'Pork', 'Fish', 'Seafood', 'Vegetarian', 'Vegan', 'Rice', 'Noodles',
  'Soup', 'Salad', 'Egg', 'Bread', 'Snacks', 'Dessert', 'BBQ', 'Grilled', 'Fried',
  'Pasta', 'Pizza', 'Burger', 'Sandwich', 'Sushi', 'Dimsum', 'Adobo', 'Sinigang',
  'Kare-Kare', 'Lechon', 'Sisig', 'Pancit', 'Lumpia', 'Halo-Halo', 'Turon', 'Bibingka',
  'Ice Cream', 'Cake', 'Fruit', 'Coffee', 'Tea', 'Juice', 'Other',
];

class ProfilePage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final List<String> preferences;
  const ProfilePage({super.key, required this.firstName, required this.lastName, required this.preferences});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String firstName;
  late String lastName;
  late Set<String> selectedPreferences;

  @override
  void initState() {
    super.initState();
    firstName = widget.firstName;
    lastName = widget.lastName;
    selectedPreferences = Set<String>.from(widget.preferences);
  }

  String get initials {
    String f = firstName.isNotEmpty ? firstName[0] : '';
    String l = lastName.isNotEmpty ? lastName[0] : '';
    return (f + l).toUpperCase();
  }

  void _editPreferences() async {
    final result = await showDialog<Set<String>>(
      context: context,
      builder: (context) {
        Set<String> tempSelected = Set<String>.from(selectedPreferences);
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text('Edit Preferences'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: foodOptions.map((food) {
                        final selected = tempSelected.contains(food);
                        return FilterChip(
                          label: Text(food),
                          selected: selected,
                          selectedColor: const Color(0xFFD7BFA6),
                          checkmarkColor: const Color(0xFF8D6E63),
                          backgroundColor: const Color(0xFFF8F5F2),
                          labelStyle: TextStyle(
                            color: selected ? const Color(0xFF8D6E63) : const Color(0xFFBCA18C),
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          onSelected: (val) {
                            setStateDialog(() {
                              if (!val) {
                                tempSelected.remove(food);
                              } else if (tempSelected.length < 5) {
                                tempSelected.add(food);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('You can select up to 5 preferences only.'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFBCA18C),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(tempSelected),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD7BFA6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
    if (result != null) {
      setState(() {
        selectedPreferences = result;
      });
      // Save to backend
      final api = ApiService();
      final token = await _getToken();
      if (token != null) {
        final response = await api.updateProfilePreferences(token, selectedPreferences.toList());
        if (response['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Preferences updated!'), duration: Duration(seconds: 2)),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response['message'] ?? 'Failed to update preferences'), duration: Duration(seconds: 2)),
            );
          }
        }
      }
    }
  }

  void _editInfo() async {
    final firstNameController = TextEditingController(text: firstName);
    final lastNameController = TextEditingController(text: lastName);
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Edit Information'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFBCA18C),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'first_name': firstNameController.text.trim(),
                  'last_name': lastNameController.text.trim(),
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD7BFA6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (result != null) {
      setState(() {
        firstName = result['first_name'] ?? firstName;
        lastName = result['last_name'] ?? lastName;
      });
      // Save to backend
      final api = ApiService();
      final token = await _getToken();
      if (token != null) {
        final response = await api.updateProfileInfo(token, firstName, lastName);
        if (response['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated!'), duration: Duration(seconds: 2)),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response['message'] ?? 'Failed to update profile'), duration: Duration(seconds: 2)),
            );
          }
        }
      }
    }
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Preferences:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _editPreferences,
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(foregroundColor: mainColor),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline, size: 20, color: Color(0xFFBCA18C)),
                      onPressed: _editInfo,
                      tooltip: 'Edit Information',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedPreferences.map((p) => Chip(label: Text(p))).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _getToken() async {
    // TODO: Implement actual token retrieval (e.g., from secure storage)
    // For now, return null to avoid errors
    return null;
  }
} 