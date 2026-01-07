import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:provider/provider.dart';
import '../models/anime.dart';
import '../providers/favorites_provider.dart';

class VideoScreen extends StatefulWidget {
  final Anime anime;

  VideoScreen({required this.anime});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _controller;
  YoutubePlayerController? _youtubeController;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isYoutube = false;

  @override
  void initState() {
    super.initState();
    print('VideoScreen init with videoUrl: ${widget.anime.videoUrl}');
    if (widget.anime.videoUrl.isNotEmpty) {
      if (_isYouTubeUrl(widget.anime.videoUrl)) {
        _isYoutube = true;
        final videoId = YoutubePlayer.convertUrlToId(widget.anime.videoUrl);
        if (videoId != null) {
          _youtubeController = YoutubePlayerController(
            initialVideoId: videoId,
            flags: YoutubePlayerFlags(
              autoPlay: false,
              mute: false,
            ),
          );
          _isInitialized = true;
        } else {
          _hasError = true;
        }
      } else {
        _controller = VideoPlayerController.network(widget.anime.videoUrl)
          ..initialize().then((_) {
            if (mounted) {
              setState(() {
                _isInitialized = true;
              });
            }
          }).catchError((error) {
            if (mounted) {
              setState(() {
                _hasError = true;
              });
            }
          });
      }
    } else {
      _hasError = true;
    }
  }

  bool _isYouTubeUrl(String url) {
    return url.contains('youtube.com') || url.contains('youtu.be');
  }

  @override
  void dispose() {
    if (!_isYoutube && widget.anime.videoUrl.isNotEmpty) {
      _controller.dispose();
    }
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFav = favoritesProvider.isFavorite(widget.anime);

    return Scaffold(
      appBar: AppBar(
        title: Text('Anime Video'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : Colors.white,
            ),
            onPressed: () {
              favoritesProvider.toggleFavorite(widget.anime);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFav ? '${widget.anime.title} removed from favorites' : '${widget.anime.title} added to favorites',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video at top
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: _hasError
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, color: Colors.white, size: 50),
                          SizedBox(height: 8),
                          Text(
                            'Video tidak tersedia',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : _isYoutube && _youtubeController != null
                      ? YoutubePlayerBuilder(
                          player: YoutubePlayer(
                            controller: _youtubeController!,
                            showVideoProgressIndicator: true,
                          ),
                          builder: (context, player) => player,
                        )
                      : _isInitialized
                          ? AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: VideoPlayer(_controller),
                            )
                          : Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
            // Play/Pause button for non-YouTube
            if (!_isYoutube && _isInitialized)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        _controller.value.isPlaying ? _controller.pause() : _controller.play();
                      });
                    },
                    child: Icon(
                      _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 30,
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            // Title and description below
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.anime.title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    widget.anime.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.grey[700],
                    ),
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