import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  final String token;
  const HistoryPage({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.history, color: Color(0xFFD7BFA6), size: 64),
              SizedBox(height: 16),
              Text(
                'No history available',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

 