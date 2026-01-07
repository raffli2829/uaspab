import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../services/anime_service.dart';
import '../models/anime.dart';
import 'video_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Anime> _animeList = [];
  List<Anime> _filteredAnimeList = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchAnime();
  }

  Future<void> _fetchAnime() async {
    try {
      final animeService = AnimeService();
      final anime = await animeService.fetchTopAnime();
      if (mounted) {
        setState(() {
          _animeList = anime;
          _filteredAnimeList = anime;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load anime: $e')),
        );
      }
    }
  }

  void _filterAnime(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredAnimeList = _animeList;
      } else {
        _filteredAnimeList = _animeList
            .where((anime) =>
                anime.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _searchAnime(String query) async {
    if (query.isEmpty) {
      _filterAnime('');
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final animeService = AnimeService();
      final anime = await animeService.searchAnime(query);
      if (mounted) {
        setState(() {
          _animeList = anime;
          _filteredAnimeList = anime;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to search anime: $e')),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FavoritesScreen()),
      ).then((_) => setState(() => _selectedIndex = 0));
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      ).then((_) => setState(() => _selectedIndex = 0));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    Widget body;
    if (_selectedIndex == 0) {
      body = Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search anime...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _filterAnime,
              onSubmitted: _searchAnime,
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading anime...', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  )
                : _filteredAnimeList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.movie, size: 80, color: Colors.grey[400]),
                            SizedBox(height: 16),
                            Text(
                              'No anime found',
                              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredAnimeList.length,
                        itemBuilder: (context, index) {
                          final anime = _filteredAnimeList[index];
                          final isFav = favoritesProvider.isFavorite(anime);
                          return Card(
                            margin: EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16.0),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  anime.imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Icon(
                                    Icons.broken_image,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              title: Text(
                                anime.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text(
                                  anime.description.length > 100
                                      ? '${anime.description.substring(0, 100)}...'
                                      : anime.description,
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  color: isFav ? Colors.red : Colors.grey,
                                ),
                                onPressed: () {
                                  favoritesProvider.toggleFavorite(anime);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isFav ? '${anime.title} removed from favorites' : '${anime.title} added to favorites',
                                      ),
                                    ),
                                  );
                                },
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VideoScreen(anime: anime),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      );
    } else {
      body = Container(); // Placeholder for other tabs
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Anime Collection'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}