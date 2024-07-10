import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class FieldWithCopy extends StatelessWidget {
  final String label;
  final String value;

  const FieldWithCopy({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$label $value',
            style: TextStyle(
              fontFamily: GoogleFonts.ubuntu().fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 19,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () {
            _copyToClipboard(context, value);
          },
        ),
      ],
    );
  }

 void _copyToClipboard(BuildContext context, String value) {
    Clipboard.setData(ClipboardData(text: value));
    final snackBar = const SnackBar(
      behavior: SnackBarBehavior.floating, // Display SnackBar in the center
      backgroundColor: Colors.black87, // Set background color to transparent
      content: Text(
        'Text Copied',
        textAlign: TextAlign.center, // Align text to center
        style: TextStyle(color: Colors.white), // Change text color to white
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

}