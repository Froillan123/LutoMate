import 'package:flutter/material.dart';

class OverviewPage extends StatelessWidget {
  final String token;
  const OverviewPage({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LutoMate Overview')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/cooking_icon.png', width: 80, height: 80),
              const SizedBox(height: 24),
              const Text(
                'Welcome to LutoMate!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF795548),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'You are now logged in. More features coming soon!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF6D4C41)),
              ),
              const SizedBox(height: 32),
              Text(
                'Your JWT Token:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
              ),
              const SizedBox(height: 8),
              SelectableText(token, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
} 