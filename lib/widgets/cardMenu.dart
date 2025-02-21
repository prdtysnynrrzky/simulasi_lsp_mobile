// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget cardMenu({
  required IconData icon,
  required String label,
  VoidCallback? onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 40,
            color: Colors.white,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 10,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}
