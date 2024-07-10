
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AddMember extends StatefulWidget {
  const AddMember({super.key});

  @override
  State<AddMember> createState() => _AddMemberState();
}

class _AddMemberState extends State<AddMember> {
  DateTime? _selectedDate;

  //Text controllers
  final _nameController = TextEditingController();
  final _lifenoController = TextEditingController();
  final _birthdateController = TextEditingController();

  Future addMemberDetails(
      String name, String lifeno, DateTime birthdate) async {
    await FirebaseFirestore.instance.collection('memberdetails').add({
      'name': name,
      'lifeno': lifeno,
      'birthdate': birthdate,
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _birthdateController.text =
            DateFormat('yyyy-MM-dd').format(_selectedDate!);
      });
    }
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Member details added successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearFields();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _clearFields() {
    _nameController.clear();
    _lifenoController.clear();
    _birthdateController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 200.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               
                Padding(
                  padding: const EdgeInsets.only(top:70.0),
                  child: Text(
                    'Fill all the Fields',
                    style: TextStyle(
                      fontFamily: GoogleFonts.raleway().fontFamily,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 34,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Name',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 17),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: TextField(
                        controller: _lifenoController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Life No.',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 17),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 25.0),
                            child: TextField(
                              controller: _birthdateController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Birth Date',
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () {
                            _selectDate(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 17),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: () {
                      if (_nameController.text.isEmpty ||
                          _lifenoController.text.isEmpty ||
                          _birthdateController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill all fields.'),
                          ),
                        );
                      } else {
                        addMemberDetails(
                          _nameController.text,
                          _lifenoController.text,
                          DateTime.parse(_birthdateController.text),
                        ).then((_) {
                          _showDialog();
                        }).catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to add member details.'),
                            ),
                          );
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'ADD',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: GoogleFonts.raleway().fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
