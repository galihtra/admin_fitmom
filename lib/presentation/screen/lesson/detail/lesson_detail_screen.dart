import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../data/model/lesson/lesson.dart';

class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;

  LessonDetailScreen({required this.lesson});

  @override
  _LessonDetailScreenState createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  YoutubePlayerController? _youtubeController;
  List<Map<String, dynamic>> _reviews = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _initializeYoutubePlayer();
    _fetchReviews();
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
      QuerySnapshot reviewSnapshot = await _firestore
          .collection('courses')
          .doc(widget.lesson.idCourse)
          .collection('lessons')
          .doc(widget.lesson.id)
          .collection('lesson_reviews')
          .get();

      List<Map<String, dynamic>> reviews = [];
      final currentUser = _auth.currentUser;

      for (var doc in reviewSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String userId = data['userId'] ?? "unknown_user";

        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(userId).get();

        String userName =
            userDoc.exists ? userDoc['name'] ?? "Anonymous" : "Anonymous";

        reviews.add({
          'id': doc.id, // Add document ID for deletion
          'user': userName,
          'comment': data['comment'] ?? "No comment",
          'userId': userId,
          'isCurrentUser': currentUser?.uid == userId,
        });
      }

      setState(() {
        _reviews = reviews;
      });
    } catch (e) {
      print("Error fetching reviews: $e");
    }
  }

  Future<void> _deleteReview(String reviewId) async {
    try {
      await _firestore
          .collection('courses')
          .doc(widget.lesson.idCourse)
          .collection('lessons')
          .doc(widget.lesson.id)
          .collection('lesson_reviews')
          .doc(reviewId)
          .delete();

      // Refresh the reviews list
      await _fetchReviews();
    } catch (e) {
      print("Error deleting review: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete comment: $e")),
      );
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
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
            // Video or Image Section
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

                  // Comments List with Delete Option
                  Container(
                    constraints:
                        const BoxConstraints(minHeight: 50, maxHeight: 250),
                    child: _reviews.isEmpty
                        ? const Text("Belum ada komentar.")
                        : ListView.builder(
                            itemCount: _reviews.length,
                            itemBuilder: (context, index) {
                              final review = _reviews[index];

                              return Dismissible(
                                key: Key(review['id']),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (direction) async {
                                  return await showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Hapus Komentar"),
                                      content: const Text(
                                          "Yakin ingin menghapus komentar ini?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text("Batal"),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text("Hapus",
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                onDismissed: (_) async {
                                  await _deleteReview(review['id']);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text("Komentar berhasil dihapus")),
                                  );
                                },
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.delete,
                                      color: Colors.white),
                                ),
                                child: Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          review['user'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic,
                                            color: Colors.pinkAccent,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(review['comment']),
                                        const Divider(color: Colors.pinkAccent),
                                      ],
                                    ),
                                  ),
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
