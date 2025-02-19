import 'package:flutter/material.dart';

class NewsSaveButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const NewsSaveButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Simpan", style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
