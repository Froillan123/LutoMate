import 'package:flutter/material.dart';
import 'api_service.dart';
import 'category_dishes_page.dart';
import 'dish_details_page.dart';

class HistoryPage extends StatefulWidget {
  final String token;
  const HistoryPage({super.key, required this.token});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> searchHistory = [];
  List<Map<String, dynamic>> viewedRecipes = [];
  bool isLoading = true;
  int selectedTab = 0;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Load search history from database
      final searchResult = await apiService.getSearchHistory(widget.token);
      if (searchResult['success']) {
        setState(() {
          searchHistory = List<Map<String, dynamic>>.from(searchResult['history'] ?? []);
        });
      }

      // For now, viewed recipes will be empty (can be implemented later)
      setState(() {
        viewedRecipes = [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading history: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear all history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // TODO: Implement clear history API call
              setState(() {
                if (selectedTab == 0) {
                  searchHistory.clear();
                } else {
                  viewedRecipes.clear();
                }
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History cleared')),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
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
                      'History',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _clearHistory,
                    icon: const Icon(Icons.clear_all, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: selectedTab == 0 
                                  ? const Color(0xFFD7BFA6) 
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Text(
                          'Searches',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: selectedTab == 0 
                                ? const Color(0xFFD7BFA6)
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: selectedTab == 1 
                                  ? const Color(0xFFD7BFA6) 
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Text(
                          'Viewed',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: selectedTab == 1 
                                ? const Color(0xFFD7BFA6)
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : selectedTab == 0
                      ? _buildSearchHistory()
                      : _buildViewedRecipes(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHistory() {
    if (searchHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, color: Colors.grey[400], size: 64),
            const SizedBox(height: 16),
            Text(
              'No search history',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your search history will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: searchHistory.length,
      itemBuilder: (context, index) {
        final item = searchHistory[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFD7BFA6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.search, color: Colors.white),
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
    );
  }

  Widget _buildViewedRecipes() {
    if (viewedRecipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.visibility_off, color: Colors.grey[400], size: 64),
            const SizedBox(height: 16),
            Text(
              'No viewed recipes',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Recipes you view will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewedRecipes.length,
      itemBuilder: (context, index) {
        final item = viewedRecipes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF3E9E1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD7BFA6)),
              ),
              child: const Icon(Icons.visibility, color: Color(0xFFD7BFA6)),
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
                  builder: (_) => DishDetailsPage(
                    dish: item['query_text'] ?? '',
                    token: widget.token,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

 