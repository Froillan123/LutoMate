import 'package:flutter/material.dart';
import 'api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class VoicePage extends StatefulWidget {
  final String token;
  const VoicePage({super.key, required this.token});

  @override
  State<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> {
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;
  List<Map<String, dynamic>> aiSuggestions = [];
  String? error;

  void _sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;
    setState(() { isLoading = true; error = null; });
    try {
      final result = await ApiService().aiConversation(input, widget.token);
      if (result['success'] == false) {
        setState(() { error = result['message'] ?? 'Failed to get suggestions'; });
      } else {
        setState(() {
          aiSuggestions = List<Map<String, dynamic>>.from(result['suggestions'] ?? []);
        });
      }
    } catch (e) {
      setState(() { error = 'Error: $e'; });
    } finally {
      setState(() { isLoading = false; });
    }
  }

  Widget _buildResultCard(Map<String, dynamic> suggestion) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: const Color(0xFFF7E9D6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              suggestion['name'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF8D6E63)),
            ),
            if (suggestion['description'] != null && suggestion['description'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Text(suggestion['description'], style: const TextStyle(fontSize: 15)),
              ),
            if (suggestion['ingredients'] != null && suggestion['ingredients'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black87, fontSize: 15),
                    children: [
                      const TextSpan(text: 'Ingredients: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: suggestion['ingredients']),
                    ],
                  ),
                ),
              ),
            if (suggestion['time'] != null && suggestion['time'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black87, fontSize: 15),
                    children: [
                      const TextSpan(text: 'Time: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: suggestion['time']),
                    ],
                  ),
                ),
              ),
            if (suggestion['difficulty'] != null && suggestion['difficulty'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black87, fontSize: 15),
                    children: [
                      const TextSpan(text: 'Difficulty: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: suggestion['difficulty']),
                    ],
                  ),
                ),
              ),
            if (suggestion['reference'] != null && suggestion['reference'].toString().isNotEmpty)
              GestureDetector(
                onTap: () async {
                  final url = Uri.parse(suggestion['reference']);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    suggestion['reference'],
                    style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                children: const [
                  Text(
                    'AI Chat',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Color(0xFF8D6E63),
                    ),
                  ),
                ],
              ),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            Expanded(
              child: aiSuggestions.isEmpty
                  ? const Center(child: Text('Type your request and get recipe suggestions!'))
                  : ListView.builder(
                      itemCount: aiSuggestions.length,
                      itemBuilder: (context, index) => _buildResultCard(aiSuggestions[index]),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type your request...'
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF8D6E63)),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 