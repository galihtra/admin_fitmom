import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MemberDetailScreen extends StatelessWidget {
  final String userId;
  final Map<String, dynamic> userData;
  static const String profileSvg = "assets/icon/profile.svg";

  const MemberDetailScreen({
    Key? key,
    required this.userId,
    required this.userData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileImage = userData['profileImage'];

    return Scaffold(
      appBar: AppBar(
        title: Text(userData['name'] ?? 'Detail Member'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: profileImage != null
                      ? Image.network(
                          profileImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Padding(
                              padding: const EdgeInsets.all(20),
                              child: SvgPicture.asset(profileSvg),
                            );
                          },
                        )
                      : Padding(
                          padding: const EdgeInsets.all(20),
                          child: SvgPicture.asset(profileSvg),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow("Nama", userData['name']),
                    const Divider(),
                    _buildInfoRow("Email", userData['email']),
                    const Divider(),
                    _buildInfoRow("Phone", userData['phone']),
                    const Divider(),
                    _buildInfoRow("Tanggal Lahir", userData['birthdate']),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete),
              label: const Text("Hapus Akun"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _confirmDelete(context),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            "$label:",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Akun"),
        content: const Text("Apakah kamu yakin ingin menghapus akun ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteUser(context);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteUser(BuildContext context) async {
    try {
      // Hapus dari Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();

      // Catatan: Jika admin ingin menghapus dari Firebase Auth, butuh backend function atau user login sendiri.
      // Tambahkan snackbar notifikasi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Akun berhasil dihapus")),
      );

      Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menghapus akun: $e")),
      );
    }
  }
}
