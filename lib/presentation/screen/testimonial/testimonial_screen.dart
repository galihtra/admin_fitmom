import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'add/add_testimonial_screen.dart';
import 'widget/like_button_widget.dart';

class TestimonialScreen extends StatefulWidget {
  const TestimonialScreen({super.key});

  @override
  State<TestimonialScreen> createState() => _TestimonialScreenState();
}

class _TestimonialScreenState extends State<TestimonialScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _deleteTestimonial(String docId) async {
    try {
      await _firestore.collection('testimonials').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Testimonial deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete testimonial: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('testimonials').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada testimoni",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          var testimonials = snapshot.data!.docs;

          return Column(
            children: [
              Expanded(
                child: CarouselSlider.builder(
                  options: CarouselOptions(
                    height: screenHeight * 0.65,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 4),
                    viewportFraction: 0.85,
                  ),
                  itemCount: testimonials.length,
                  itemBuilder: (context, index, realIndex) {
                    var testimonial = testimonials[index];
                    var data = testimonial.data() as Map<String, dynamic>;

                    // Use single 'image' field
                    final imageUrl = data['image'] ?? '';

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Like and Delete buttons
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          LikeButton(docId: testimonial.id),
                                          Text(
                                            '${data['totalLikes'] ?? 0} orang menyukai',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.pinkAccent,
                                            ),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () =>
                                            _deleteTestimonial(testimonial.id),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),

                                  // Image display
                                  if (imageUrl.isNotEmpty)
                                    Container(
                                      width: screenWidth * 0.7,
                                      height: screenHeight * 0.3,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                  Icons.broken_image,
                                                  size: 50),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 20),

                                  // User Name
                                  Text(
                                    data['name'] ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pinkAccent,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Description
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    constraints: BoxConstraints(
                                      maxHeight: screenHeight * 0.15,
                                      maxWidth: screenWidth * 0.8,
                                    ),
                                    child: SingleChildScrollView(
                                      child: Text(
                                        data['description'] ??
                                            'Tidak ada deskripsi.',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddTestimonialScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
