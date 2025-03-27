import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahkan
import '../../../../data/model/lesson/lesson.dart';

class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;

  LessonDetailScreen({required this.lesson});

  @override
  _LessonDetailScreenState createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  YoutubePlayerController? _youtubeController; // Nullable
  List<Map<String, dynamic>> _reviews = [];

  @override
  void initState() {
    super.initState();
    _initializeYoutubePlayer();
    _fetchReviews(); // Fetch ulasan dari Firestore
  }

  void _initializeYoutubePlayer() {
    if (widget.lesson.urlVideo.isNotEmpty) {
      final videoId = YoutubePlayer.convertUrlToId(widget.lesson.urlVideo);
      if (videoId != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            loop: false,
            forceHD: true,
          ),
        );
        setState(() {});
      }
    }
  }

  Future<void> _fetchReviews() async {
  try {
    QuerySnapshot reviewSnapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.lesson.idCourse)
        .collection('lessons')
        .doc(widget.lesson.id)
        .collection('lesson_reviews')
        .get();

    List<Map<String, dynamic>> reviews = [];

    for (var doc in reviewSnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      String userId = data['userId'] ?? "unknown_user";

      // Fetch nama user berdasarkan userId
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      String userName = userDoc.exists ? userDoc['name'] ?? "Anonymous" : "Anonymous";

      reviews.add({
        'user': userName, // Nama user, bukan userId
        'comment': data['comment'] ?? "No comment",
      });
    }

    setState(() {
      _reviews = reviews;
    });
  } catch (e) {
    print("❌ Error fetching reviews or user data: $e");
  }
}


  @override
  void dispose() {
    _youtubeController?.dispose(); // Cleanup
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.lesson.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Youtube Player atau Gambar Placeholder
            widget.lesson.urlVideo.isNotEmpty && _youtubeController != null
                ? Container(
                    width: double.infinity,
                    height: 500,
                    child: YoutubePlayerBuilder(
                      player: YoutubePlayer(controller: _youtubeController!),
                      builder: (context, player) => player,
                    ),
                  )
                : widget.lesson.image.isNotEmpty
                    ? Image.network(
                        widget.lesson.image,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: double.infinity,
                        height: 300,
                        color: Colors.grey[300],
                        child: Icon(Icons.image,
                            size: 100, color: Colors.grey[600]),
                      ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.lesson.name,
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(widget.lesson.description,
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  const Text("User Comments",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  // Ulasan ListView
                  Container(
                    height: 200, // Batas tinggi list agar tidak error
                    child: ListView.builder(
                      itemCount: _reviews.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _reviews[index]['user'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.pinkAccent,
                                ),
                              ),
                              Text(_reviews[index]['comment']),
                              const Divider(color: Colors.pinkAccent),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
