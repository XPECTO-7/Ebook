import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class GetMemberName extends StatelessWidget {
  final String detailId;

  const GetMemberName({Key? key, required this.detailId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('memberdetails')
          .doc(detailId)
          .get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 6, // Increase the stroke width
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Text('No data found');
        }

        var data = snapshot.data!;
        var name = data['name'];
        var lifeno = data['lifeno'];
        var birthdate;
        if (data['birthdate'] is Timestamp) {
          birthdate = (data['birthdate'] as Timestamp).toDate();
        } else if (data['birthdate'] is String) {
          birthdate = DateTime.parse(data['birthdate'] as String);
        } else {
          // Handle the case where birthdate has unexpected type
          // For example, set a default value or throw an error
        }
        var formattedBirthdate = DateFormat('yyyy-MM-dd').format(birthdate);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$name',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.habibi().fontFamily,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            Text(
              'Life No: $lifeno',
              style: TextStyle(
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            Text(
              'Birthdate: $formattedBirthdate',
              style: TextStyle(
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ],
        );
      },
    );
  }
}

class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<String> detIds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getDetIds();
  }

  Future<void> getDetIds() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('memberdetails')
        .orderBy('name')
        .get();
    setState(() {
      detIds = querySnapshot.docs.map((doc) => doc.id).toList();
      isLoading = false;
    });
  }

  Future<void> deleteDet(String detailId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('memberdetails')
                      .doc(detailId)
                      .delete();
                  getDetIds();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Deleted successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting item: $e')),
                  );
                }
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> editDet(String detailId) async {
    // Fetch the current data of the member
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('memberdetails')
        .doc(detailId)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic> memberData = snapshot.data() as Map<String, dynamic>;

      // Show dialog for editing
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Edit Member Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: memberData['name'] ?? '',
                  decoration: const InputDecoration(labelText: 'Name'),
                  onChanged: (value) {
                    memberData['name'] = value;
                  },
                ),
                TextFormField(
                  initialValue: memberData['lifeno'] ?? '',
                  decoration: const InputDecoration(labelText: 'Life No'),
                  onChanged: (value) {
                    memberData['lifeno'] = value;
                  },
                ),
                // Add more fields to edit here
                TextFormField(
                  initialValue: memberData['birthdate'].toDate().toString(),
                  decoration: const InputDecoration(labelText: 'Birth Date'),
                  onChanged: (value) {
                    memberData['birthdate'] =
                        Timestamp.fromDate(DateTime.parse(value));
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await FirebaseFirestore.instance
                        .collection('memberdetails')
                        .doc(detailId)
                        .update(memberData);
                    getDetIds();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edited successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error editing Details: $e')),
                    );
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member details not found')),
      );
    }
  }

  Future<void> _showMemberDetailsDialog(String detailId) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('memberdetails')
        .doc(detailId)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic> memberData = snapshot.data() as Map<String, dynamic>;
      DateTime birthdate = (memberData['birthdate'] as Timestamp).toDate();
      String formattedBirthdate = DateFormat('yyyy-MM-dd').format(birthdate);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Member Details'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Name: ${memberData['name'] ?? 'N/A'}',
                  style: TextStyle(
                    fontFamily: GoogleFonts.habibi().fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Life No: ${memberData['lifeno'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  'Birthdate: $formattedBirthdate',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 4),
                // Add more fields here if needed
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member details not found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        toolbarHeight: 21,
        backgroundColor: Colors.black87,
        title: Center(
          child: Text(
            ' ${detIds.length} Members',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 6, // Increase the stroke width
              )
            : detIds.isEmpty
                ? const Text('No data available')
                : ListView.builder(
                    itemCount: detIds.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(left: 8, top: 10, right: 8),
                        child: Card(
                          elevation: 4,
                          child: ListTile(
                            title: GestureDetector(
                              onTap: () {
                                _showMemberDetailsDialog(detIds[index]);
                              },
                              child: GetMemberName(detailId: detIds[index]),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    editDet(detIds[index]);
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.greenAccent,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    deleteDet(detIds[index]);
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red.shade400,
                                  ),
                                ),
                              ],
                            ),
                            tileColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
