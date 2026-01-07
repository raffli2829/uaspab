import 'package:flutter/material.dart';
import '../models/anime.dart';

class FavoritesProvider with ChangeNotifier {
  List<Anime> _favorites = [];

  List<Anime> get favorites => _favorites;

  bool isFavorite(Anime anime) {
    return _favorites.any((fav) => fav.title == anime.title);
  }

  void addToFavorites(Anime anime) {
    if (!isFavorite(anime)) {
      _favorites.add(anime);
      notifyListeners();
    }
  }

  void removeFromFavorites(Anime anime) {
    _favorites.removeWhere((fav) => fav.title == anime.title);
    notifyListeners();
  }

  void toggleFavorite(Anime anime) {
    if (isFavorite(anime)) {
      removeFromFavorites(anime);
    } else {
      addToFavorites(anime);
    }
  }
}