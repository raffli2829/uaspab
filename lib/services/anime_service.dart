import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/anime.dart';

class AnimeService {
  static const String baseUrl = 'https://api.jikan.moe/v4';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Anime>> fetchTopAnime() async {
    final response = await http.get(Uri.parse('$baseUrl/top/anime'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> animeList = data['data'];
      List<Anime> animes = animeList.map((json) => Anime.fromJson(json)).toList();

      // For each anime, check if there's override in Firebase
      for (int i = 0; i < animes.length; i++) {
        Anime anime = animes[i];
        print('Checking Firebase for anime: ${anime.title}');
        try {
          DocumentSnapshot doc = await _firestore.collection('anime').doc(anime.title).get();
          if (doc.exists) {
            print('Found in Firebase: ${anime.title}');
            Map<String, dynamic> firebaseData = doc.data() as Map<String, dynamic>;
            animes[i] = Anime(
              title: firebaseData['title'] ?? anime.title,
              imageUrl: firebaseData['imageUrl'] ?? anime.imageUrl,
              videoUrl: firebaseData['videoUrl'] ?? anime.videoUrl,
              description: firebaseData['description'] ?? anime.description,
            );
            print('Overridden ${anime.title} with Firebase data: videoUrl=${animes[i].videoUrl}');
          } else {
            print('Not found in Firebase: ${anime.title}');
          }
        } catch (e) {
          print('Error checking Firebase for ${anime.title}: $e');
          // If error, keep Jikan data
        }
      }

      return animes;
    } else {
      throw Exception('Failed to load anime');
    }
  }

  Future<List<Anime>> searchAnime(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/anime?q=$query&limit=20'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> animeList = data['data'];
      return animeList.map((json) => Anime.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search anime');
    }
  }
}