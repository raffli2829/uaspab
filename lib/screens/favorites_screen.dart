import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../models/anime.dart';
import 'video_screen.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    return favoritesProvider.favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add some anime to your favorites!',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: favoritesProvider.favorites.length,
                itemBuilder: (context, index) {
                  final anime = favoritesProvider.favorites[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 16.0),
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          anime.description.length > 100
                              ? '${anime.description.substring(0, 100)}...'
                              : anime.description,
                          style: TextStyle(color: Colors.grey[700]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.favorite, color: Colors.red),
                        onPressed: () {
                          favoritesProvider.removeFromFavorites(anime);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${anime.title} removed from favorites')),
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
            );
  }
}