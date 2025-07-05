import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'api_service.dart';
import 'dish_details_page.dart';

class SmartConversationPage extends StatefulWidget {
  final String token;
  const SmartConversationPage({super.key, required this.token});

  @override
  State<SmartConversationPage> createState() => _SmartConversationPageState();
}

class _SmartConversationPageState extends State<SmartConversationPage> {
  bool isListening = false;
  String userInput = '';
  List<Map<String, dynamic>> aiSuggestions = [];
  bool isLoading = false;
  bool hasPermission = false;
  final stt.SpeechToText _speech = stt.SpeechToText();
  final ApiService apiService = ApiService();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    final status = await Permission.microphone.request();
    setState(() {
      hasPermission = status.isGranted;
    });

    if (hasPermission) {
      final available = await _speech.initialize(
        onError: (error) {
          print('Speech recognition error: $error');
          setState(() {
            isListening = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Speech recognition error: ${error.errorMsg}')),
          );
        },
        onStatus: (status) {
          print('Speech recognition status: $status');
          if (status == 'done' || status == 'notListening') {
            setState(() {
              isListening = false;
            });
          }
        },
      );
      if (!available) {
        setState(() {
          hasPermission = false;
        });
      }
    }
  }

  void _startListening() async {
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please grant microphone permission')),
      );
      return;
    }

    setState(() {
      isListening = true;
      userInput = '';
    });

    try {
      await _speech.listen(
        onResult: (result) {
          setState(() {
            userInput = result.recognizedWords;
          });
        },
        listenFor: const Duration(seconds: 15),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: 'en_US',
      );
    } catch (e) {
      setState(() {
        isListening = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting speech recognition: $e')),
      );
    }
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() {
      isListening = false;
    });
  }

  void _sendMessage() async {
    if (userInput.trim().isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Save to search history
      await apiService.saveSearchHistory(userInput, widget.token);
      
      // Get AI conversation response
      final result = await apiService.aiConversation(userInput, widget.token);
      
      if (result['success']) {
        setState(() {
          aiSuggestions = List<Map<String, dynamic>>.from(result['suggestions'] ?? []);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to get suggestions')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _clearInput() {
    setState(() {
      userInput = '';
      aiSuggestions = [];
    });
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: const Color(0xFFD7BFA6),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      'Smart AI Assistant',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Input Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Text Input
                  TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Tell me what you want to cook...',
                      prefixIcon: const Icon(Icons.chat, color: Color(0xFF8D6E63)),
                      suffixIcon: IconButton(
                        onPressed: _clearInput,
                        icon: const Icon(Icons.clear, color: Color(0xFF8D6E63)),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8F5F2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        userInput = value;
                      });
                    },
                    onSubmitted: (_) => _sendMessage(),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Voice Input Button
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTapDown: (_) => _startListening(),
                          onTapUp: (_) {
                            _stopListening();
                            if (userInput.trim().isNotEmpty) {
                              _sendMessage();
                            }
                          },
                          onTapCancel: () {
                            _stopListening();
                            if (userInput.trim().isNotEmpty) {
                              _sendMessage();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isListening 
                                  ? const Color(0xFF8D6E63)
                                  : const Color(0xFFD7BFA6),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isListening ? Icons.mic : Icons.mic_none,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isListening ? 'Listening...' : 'Voice Input',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: isLoading ? null : _sendMessage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD7BFA6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Ask AI'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // AI Suggestions
            if (aiSuggestions.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'AI Suggestions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8D6E63),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: aiSuggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = aiSuggestions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD7BFA6),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: const Icon(Icons.restaurant, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        suggestion['name'] ?? 'Unknown Dish',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF8D6E63),
                                        ),
                                      ),
                                      Text(
                                        suggestion['description'] ?? '',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildInfoChip('⏱️ ${suggestion['time'] ?? 'N/A'}'),
                                const SizedBox(width: 8),
                                _buildInfoChip('📊 ${suggestion['difficulty'] ?? 'N/A'}'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Ingredients: ${suggestion['ingredients'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF8D6E63),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => DishDetailsPage(
                                        dish: suggestion['name'] ?? '',
                                        token: widget.token,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.restaurant_menu, color: Colors.white),
                                label: const Text('Get Full Recipe'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD7BFA6),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else if (userInput.isNotEmpty && !isLoading) ...[
              // Show user input when no suggestions yet
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.grey[400], size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'Processing your request...',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userInput,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Welcome message
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E9E1),
                          borderRadius: BorderRadius.circular(60),
                          border: Border.all(color: const Color(0xFFD7BFA6), width: 3),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFFD7BFA6),
                          size: 60,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Smart AI Assistant',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8D6E63),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Tell me what you want to cook\nand I\'ll suggest perfect recipes!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F5F2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              'Try saying:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8D6E63),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text('• "I want to cook something with noodles"'),
                            Text('• "Show me easy chicken recipes"'),
                            Text('• "I have eggs and vegetables"'),
                            Text('• "Quick dinner ideas"'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E9E1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD7BFA6)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF8D6E63),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
} 