import 'package:flutter/material.dart';

class FeedsPage extends StatelessWidget {
  const FeedsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feeds'),
        backgroundColor: const Color(0xFFD7BFA6),
      ),
      body: const Center(
        child: Text('Feeds coming soon'),
      ),
    );
  }
} 