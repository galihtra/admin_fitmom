import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false; // Status loading

  Future<void> _addImageReminder() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      File file = File(image.path);

      setState(() {
        isLoading = true; // Tampilkan loading
      });

      try {
        TaskSnapshot snapshot = await _storage.ref('reminders/$fileName').putFile(file);
        String imageUrl = await snapshot.ref.getDownloadURL();

        await _firestore.collection('reminders').add({'imageUrl': imageUrl});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder berhasil ditambahkan')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan reminder: $e')),
        );
      } finally {
        setState(() {
          isLoading = false; // Sembunyikan loading
        });
      }
    }
  }

  Future<void> _deleteReminder(String docId) async {
    try {
      await _firestore.collection('reminders').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder berhasil dihapus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus reminder: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder List'),
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('reminders').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    "Belum ada reminder",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              var reminders = snapshot.data!.docs;

              return ListView.builder(
                itemCount: reminders.length,
                itemBuilder: (context, index) {
                  var reminder = reminders[index];
                  var data = reminder.data() as Map<String, dynamic>;

                  return Dismissible(
                    key: Key(reminder.id),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) => _deleteReminder(reminder.id),
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Image.network(
                              data['imageUrl'] ?? '',
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Image Reminder',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Mohon tunggu, proses sedang berlangsung...",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addImageReminder,
        child: const Icon(Icons.add),
      ),
    );
  }
}
