// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget textField({
  required TextEditingController controller,
  required String hint,
  TextInputType keyboardType = TextInputType.text,
  String? Function(String?)? validator,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: Colors.grey.shade100,
    ),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.all(15),
      ),
      validator: validator,
      onFieldSubmitted: (value) {},
    ),
  );
}
