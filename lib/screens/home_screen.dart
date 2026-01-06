import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/anime_service.dart';
import '../models/anime.dart';
import 'video_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Anime> _animeList = [];
  bool _isLoading = true;

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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Anime App'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _animeList.length,
              itemBuilder: (context, index) {
                final anime = _animeList[index];
                return ListTile(
                  leading: Image.network(anime.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(anime.title),
                  subtitle: Text(anime.description.length > 100
                      ? '${anime.description.substring(0, 100)}...'
                      : anime.description),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoScreen(anime: anime),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}