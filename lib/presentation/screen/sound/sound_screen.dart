import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';

class SoundScreen extends StatefulWidget {
  const SoundScreen({super.key});

  @override
  State<SoundScreen> createState() => _SoundScreenState();
}

class _SoundScreenState extends State<SoundScreen> {
  final CollectionReference _soundCollection =
      FirebaseFirestore.instance.collection('sounds');

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlaying;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();

    // Listener untuk memperbarui progress audio
    _audioPlayer.positionStream.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });

    _audioPlayer.durationStream.listen((duration) {
      setState(() {
        _totalDuration = duration ?? Duration.zero;
      });
    });

    // Loop audio otomatis saat selesai
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.play();
      }
    });
  }

  Future<void> _addSound() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      String? filePath = result.files.single.path;

      if (filePath != null) {
        TextEditingController _nameController = TextEditingController();

        // Minta user masukkan nama sound
        String? customName = await showDialog<String>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Masukkan Nama Sound"),
              content: TextField(
                controller: _nameController,
                autofocus: true,
                decoration:
                    InputDecoration(hintText: "Contoh: Suara Relaksasi"),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.trim().isNotEmpty) {
                      Navigator.pop(context, _nameController.text.trim());
                    }
                  },
                  child: Text("Simpan"),
                ),
              ],
            );
          },
        );

        if (customName == null || customName.isEmpty) return;

        // Upload file ke Firebase Storage
        String storageFileName =
            "${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}";
        Reference storageRef =
            FirebaseStorage.instance.ref().child('sounds/$storageFileName');
        UploadTask uploadTask = storageRef.putFile(File(filePath));

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Mengunggah Sound...",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            );
          },
        );

        await uploadTask.whenComplete(() => null);
        String downloadUrl = await storageRef.getDownloadURL();

        // Simpan metadata ke Firestore
        await _soundCollection.add({
          'name': customName,
          'url': downloadUrl,
        });

        if (mounted) {
          Navigator.pop(context); // close loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Sound berhasil ditambahkan!"),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {});
        }
      }
    }
  }

  /// Fungsi untuk mengedit nama sound
  Future<void> _editSoundName(String docId, String currentName) async {
    TextEditingController _nameController =
        TextEditingController(text: currentName);

    String? newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Nama Sound"),
          content: TextField(
            controller: _nameController,
            autofocus: true,
            decoration: InputDecoration(hintText: "Masukkan nama baru"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.trim().isNotEmpty) {
                  Navigator.pop(context, _nameController.text.trim());
                }
              },
              child: Text("Simpan"),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty && newName != currentName) {
      try {
        await _soundCollection.doc(docId).update({'name': newName});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Nama sound berhasil diubah!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal mengubah nama: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Fungsi menghapus sound dari Firestore dan Storage
  Future<bool> _deleteSound(String docId, String soundUrl) async {
    bool confirmDelete = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus Sound'),
            content: const Text('Apakah Anda yakin ingin menghapus sound ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmDelete) {
      try {
        await FirebaseFirestore.instance
            .collection('sounds')
            .doc(docId)
            .delete();
        await FirebaseStorage.instance.refFromURL(soundUrl).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Sound berhasil dihapus!"),
              backgroundColor: Colors.green,
            ),
          );
        }
        return true;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal menghapus sound: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }
    }
    return false;
  }

  /// Fungsi memainkan atau menghentikan audio dengan loop
  Future<void> _playSound(String url) async {
    if (_currentlyPlaying == url) {
      await _audioPlayer.stop();
      setState(() {
        _currentlyPlaying = null;
        _currentPosition = Duration.zero;
      });
    } else {
      try {
        await _audioPlayer.setUrl(url);
        _totalDuration = _audioPlayer.duration ?? Duration.zero;

        setState(() {
          _currentlyPlaying = url;
        });

        await _audioPlayer.play();
      } catch (e) {
        print("Error playing audio: $e");
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sound List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addSound,
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _soundCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var sounds = snapshot.data!.docs;

          return ListView.builder(
            itemCount: sounds.length,
            itemBuilder: (context, index) {
              var sound = sounds[index];
              String soundUrl = sound['url'];

              return Dismissible(
                key: Key(sound.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await _deleteSound(sound.id, soundUrl);
                },
                child: ListTile(
                  title: Text(sound['name']),
                  subtitle: _currentlyPlaying == soundUrl
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(
                              value: _totalDuration.inMilliseconds > 0
                                  ? _currentPosition.inMilliseconds /
                                      _totalDuration.inMilliseconds
                                  : 0.0,
                              backgroundColor: Colors.grey[300],
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.pink),
                            ),
                            Text(
                              "${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}",
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        )
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _currentlyPlaying == soundUrl
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                        onPressed: () => _playSound(soundUrl),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            _editSoundName(sound.id, sound['name']),
                      ),
                    ],
                  ),
                  onTap: () => _playSound(soundUrl),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes);
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
