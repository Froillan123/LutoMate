import 'package:flutter/material.dart';
import 'api_service.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'category_dishes_page.dart';
import 'message_page.dart';
import 'history_page.dart';

class OverviewPage extends StatefulWidget {
  final String token;
  const OverviewPage({super.key, required this.token});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  String? firstName;
  String? lastName;
  List<String> preferences = [];
  List<String> filteredPreferences = [];
  bool loading = true;
  String? error;
  Map<String, String> images = {};
  final ApiService apiService = ApiService();
  String searchQuery = '';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    setState(() { loading = true; });
    final result = await apiService.getProfile(widget.token);
    if (result['success']) {
      setState(() {
        firstName = result['first_name'];
        lastName = result['last_name'];
        preferences = List<String>.from(result['preferences'] ?? []);
        filteredPreferences = preferences;
      });
      await fetchImages();
    } else {
      setState(() { error = result['message']; });
    }
    setState(() { loading = false; });
  }

  Future<void> fetchImages() async {
    for (int i = 0; i < preferences.length; i++) {
      final pref = preferences[i];
      if (!images.containsKey(pref)) {
        try {
          final url = await apiService.getOpenverseImage(pref);
          if (url != null) {
            setState(() { images[pref] = url; });
          }
          // Add small delay between requests to prevent buffer overflow
          await Future.delayed(const Duration(milliseconds: 100));
        } catch (e) {
          print('Error fetching image for $pref: $e');
        }
      }
    }
  }

  String get initials {
    if ((firstName ?? '').isEmpty && (lastName ?? '').isEmpty) return '';
    String f = (firstName ?? '').isNotEmpty ? firstName![0] : '';
    String l = (lastName ?? '').isNotEmpty ? lastName![0] : '';
    return (f + l).toUpperCase();
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
      filteredPreferences = preferences
          .where((p) => p.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    });
  }

  Widget _buildHomeTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: const Text(
            "Today's popular searches",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
        ),
        // Search bar for preferences
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search your preferences...',
              prefixIcon: Icon(Icons.search, color: const Color(0xFFD7BFA6)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        // Grid of preferences with margin bottom
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: filteredPreferences.length,
              itemBuilder: (context, index) {
                final pref = filteredPreferences[index];
                final imgUrl = images[pref];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CategoryDishesPage(category: pref, token: widget.token),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        imgUrl != null
                            ? Image.network(
                                imgUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.fastfood, color: Color(0xFFD7BFA6), size: 40),
                                ),
                              )
                            : Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.fastfood, color: Color(0xFFD7BFA6), size: 40),
                              ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.2),
                                Colors.black.withOpacity(0.5),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              pref,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 4,
                                    offset: Offset(1, 1),
                                  ),
                                ],
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
        ),
      ],
    );
  }

  Widget _buildMessageTab() {
    return _MessageTab(token: widget.token);
  }

  Widget _buildHistoryTab() {
    return HistoryPage(token: widget.token);
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = const Color(0xFFD7BFA6);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
                : Column(
                    children: [
                      // Top bar with profile and settings dropdown
                      Container(
                        color: mainColor,
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.white,
                              child: Text(
                                initials,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: mainColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${firstName ?? ''} ${lastName ?? ''}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _currentIndex == 0 ? 'Home' : _currentIndex == 1 ? 'Message AI' : 'History',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.settings, color: Colors.white),
                              color: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              onSelected: (value) {
                                if (value == 'profile') {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ProfilePage(
                                        firstName: firstName ?? '',
                                        lastName: lastName ?? '',
                                        preferences: preferences,
                                      ),
                                    ),
                                  );
                                }
                                if (value == 'logout') _logout();
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'profile',
                                  child: Row(
                                    children: const [
                                      Icon(Icons.person, color: Color(0xFFD7BFA6)),
                                      SizedBox(width: 8),
                                      Text('Profile'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'logout',
                                  child: Row(
                                    children: const [
                                      Icon(Icons.logout, color: Color(0xFFD7BFA6)),
                                      SizedBox(width: 8),
                                      Text('Logout'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Content based on selected tab
                      Expanded(
                        child: IndexedStack(
                          index: _currentIndex,
                          children: [
                            _buildHomeTab(),
                            _buildMessageTab(),
                            _buildHistoryTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFD7BFA6),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Message AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}

// Simple message tab widget that shows input and navigates to message page
class _MessageTab extends StatefulWidget {
  final String token;
  const _MessageTab({required this.token});

  @override
  State<_MessageTab> createState() => _MessageTabState();
}

class _MessageTabState extends State<_MessageTab> {
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;
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
        // Navigate to message page with results
        final suggestions = List<Map<String, dynamic>>.from(result['suggestions'] ?? []);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MessagePage(
              token: widget.token,
              userInput: input,
              suggestions: suggestions,
            ),
          ),
        );
        // Clear the input after successful navigation
        _controller.clear();
      }
    } catch (e) {
      setState(() { error = 'Error: $e'; });
    } finally {
      setState(() { isLoading = false; });
    }
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
                    'Message AI',
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
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 80,
                      color: Color(0xFFD7BFA6),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Ask me anything about cooking!',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF8D6E63),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'I can suggest recipes, ingredients, and cooking tips',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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
                        hintText: 'Type your request...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
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