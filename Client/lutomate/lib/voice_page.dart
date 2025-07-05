import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'api_service.dart';
import 'category_dishes_page.dart';
import 'smart_conversation_page.dart';

class VoicePage extends StatefulWidget {
  final String token;
  const VoicePage({super.key, required this.token});

  @override
  State<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> {
  bool isListening = false;
  String recognizedText = '';
  List<Map<String, dynamic>> searchHistory = [];
  bool isLoading = false;
  bool hasPermission = false;
  final stt.SpeechToText _speech = stt.SpeechToText();
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _loadVoiceHistory();
  }

  Future<void> _initializeSpeech() async {
    // Request microphone permission
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition not available')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission denied')),
      );
    }
  }

  Future<void> _loadVoiceHistory() async {
    final result = await apiService.getVoiceHistory(widget.token);
    if (result['success']) {
      setState(() {
        searchHistory = List<Map<String, dynamic>>.from(result['queries'] ?? []);
      });
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
      recognizedText = '';
    });

    try {
      await _speech.listen(
        onResult: (result) {
          setState(() {
            recognizedText = result.recognizedWords;
          });
        },
        listenFor: const Duration(seconds: 10),
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

  void _searchRecipe() async {
    if (recognizedText.isEmpty) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      // Save voice query to database
      await apiService.saveVoiceQuery(recognizedText, widget.token);
      
      // Save search history
      await apiService.saveSearchHistory(recognizedText, widget.token);
      
      // Reload voice history
      await _loadVoiceHistory();

      // Navigate to smart conversation page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SmartConversationPage(token: widget.token),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing voice input: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _clearText() {
    setState(() {
      recognizedText = '';
    });
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';
    
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minutes ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hours ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF8D6E63)),
                  ),
                  const Expanded(
                    child: Text(
                      'Voice Search',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8D6E63),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              
              // Main Voice Interface
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Microphone Button
                    GestureDetector(
                      onTapDown: (_) => _startListening(),
                      onTapUp: (_) => _stopListening(),
                      onTapCancel: () => _stopListening(),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isListening ? 140 : 120,
                        height: isListening ? 140 : 120,
                        decoration: BoxDecoration(
                          color: isListening 
                              ? const Color(0xFF8D6E63)
                              : const Color(0xFFD7BFA6),
                          borderRadius: BorderRadius.circular(isListening ? 70 : 60),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.brown.withOpacity(isListening ? 0.4 : 0.3),
                              blurRadius: isListening ? 30 : 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.white,
                          size: isListening ? 70 : 60,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Status Text
                    Text(
                      isListening ? 'Listening...' : 'Tap to speak',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: isListening 
                            ? const Color(0xFF8D6E63)
                            : Colors.grey[600],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Recognized Text Display
                    if (recognizedText.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F5F2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFD7BFA6)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.record_voice_over, color: Color(0xFF8D6E63)),
                                const SizedBox(width: 8),
                                const Text(
                                  'Recognized:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF8D6E63),
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: _clearText,
                                  icon: const Icon(Icons.clear, color: Color(0xFF8D6E63)),
                                  iconSize: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              recognizedText,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF8D6E63),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Search Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : _searchRecipe,
                          icon: isLoading 
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.search, color: Colors.white),
                          label: Text(isLoading ? 'Searching...' : 'Search Recipe'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD7BFA6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Search History
              if (searchHistory.isNotEmpty) ...[
                const Divider(height: 40),
                const Text(
                  'Recent Voice Searches',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8D6E63),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: searchHistory.length,
                    itemBuilder: (context, index) {
                      final item = searchHistory[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD7BFA6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.mic, color: Colors.white, size: 20),
                          ),
                          title: Text(
                            item['query_text'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(_formatTimestamp(item['created_at'])),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFD7BFA6), size: 16),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CategoryDishesPage(
                                  category: item['query_text'] ?? '',
                                  token: widget.token,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 