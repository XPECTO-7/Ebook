import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GetMemberName extends StatelessWidget {
  final String detailId;
  GetMemberName({required this.detailId});

  @override
  Widget build(BuildContext context) {

    // Get the reference to the document with the provided detailId
    DocumentReference memberRef = FirebaseFirestore.instance.collection('memberdetails').doc(detailId);

    return FutureBuilder<DocumentSnapshot>(
      future: memberRef.get(), // Fetch the document using the reference
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
            // Convert birthdate from timestamp to DateTime
            DateTime birthdate = (data['birthdate'] as Timestamp).toDate();
            // Format DateTime as a readable date string
            String formattedDate = DateFormat('yyyy-MM-dd').format(birthdate);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${data['name']}'),
                Text('Life No: ${data['lifeno']}'),
                Text('Birthdate: $formattedDate'),
              ],
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
        }
        return Text('Loading..');
      },
    );
  }
}
