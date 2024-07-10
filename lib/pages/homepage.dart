// ignore_for_file: library_private_types_in_public_api

import 'package:adminsite/Components/copy_add.dart';
import 'package:adminsite/pages/add_member.dart';
import 'package:adminsite/pages/list.dart';
import 'package:adminsite/pages/loginpage.dart';
import 'package:adminsite/pages/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
  bool isLoading = false;
  List<DocumentSnapshot> searchResults = [];
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePageContent(),
    ListPage(),
    AddMember(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false, // Remove back button
        title: Row(
          children: [
            const Icon(
              Icons.local_florist_outlined,
              size: 40,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              'Trivandrum Zion',
              style: TextStyle(
                color: Colors.white,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontSize: 22,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        toolbarHeight: 77,
        actions:
            _selectedIndex == 2 // Show clear button only in HomePageContent
                ? [
                    IconButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/login', (route) => false);
                      },
                      icon: const Icon(Icons.logout_rounded),
                    ),
                  ] // Show logout button in other pages
                : null, // Otherwise, no action button
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.black87,
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        height: 60,
        items: const <Widget>[
          Icon(Icons.home, size: 30),
          Icon(Icons.library_books, size: 30),
          Icon(Icons.add_circle_sharp, size: 30),
        ],
        index: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({Key? key}) : super(key: key);

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = false;
  List<DocumentSnapshot> searchResults = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 8.0, right: 8, top: 17, bottom: 17),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    isLoading = true;
                  });
                  _performSearch(
                      value.toLowerCase()); // Convert query to lowercase
                },
                decoration: InputDecoration(
                  hintText: 'Search by name...',
                  hintStyle: TextStyle(
                      color: Colors.black,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                      fontWeight: FontWeight.bold),
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _clearSearch();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : searchResults.isEmpty
                        ? Center(
                            child: Text(
                              'No results found',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: GoogleFonts.poppins().fontFamily,
                                  fontSize: 18),
                            ),
                          )
                        : Center(
                            child: Wrap(
                              direction:
                                  Axis.horizontal, // Display items horizontally
                              alignment:
                                  WrapAlignment.center, // Center justify items
                              spacing: 8.0, // Horizontal spacing between items
                              runSpacing: 8.0, // Vertical spacing between items
                              children: searchResults.map((result) {
                                var member =
                                    result.data() as Map<String, dynamic>;
                                return GestureDetector(
                                  onTap: () {
                                    _showMemberDetails(member);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    child: Text(
                                      member['name'] ?? 'Name not available',
                                      style: TextStyle(
                                        fontFamily:
                                            GoogleFonts.raleway().fontFamily,
                                        fontSize: 19,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
              )
            ],
          ),
        ),
      ],
    );
  }
  String customFormat(String value) {
  // Remove "-" symbol from the value
  return value.replaceAll('-', '');
}
  void _performSearch(String query) async {
    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('memberdetails').get();

      List<DocumentSnapshot> allResults = querySnapshot.docs;

      // Filter the results based on names starting with the query
      List<DocumentSnapshot> filteredResults = allResults
          .where((doc) => (doc['name'] as String)
              .toLowerCase()
              .startsWith(query.toLowerCase()))
          .toList();

      // Sort the filtered results alphabetically
      filteredResults.sort((a, b) => (a['name'] as String)
          .toLowerCase()
          .compareTo((b['name'] as String).toLowerCase()));

      setState(() {
        searchResults = filteredResults;
        isLoading = false;
      });
    } catch (e) {
      print('Error searching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showMemberDetails(Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: 0.0,
            backgroundColor: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Member Details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: FieldWithCopy(
                                label: '',
                                value: member['name'] ?? 'N/A',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        FieldWithCopy(
                          label: 'Life No:',
                          value: customFormat(member['lifeno'] ?? 'N/A'),
                        ),
                        const SizedBox(height: 8.0),
                        FieldWithCopy(
                          label: 'Birthdate:',
                          value: DateFormat('yyyyMMdd').format(
                            (member['birthdate'] as Timestamp).toDate(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Thank you',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      searchResults.clear();
      isLoading = false;
    });
  }
}

void main() {
  runApp(MaterialApp(
    home: const LoginPage(),
    routes: {
      '/splash': (context) => const SplashScreen(),
      '/login': (context) => const LoginPage(),
      '/home': (context) => const HomePage(),
    },
  ));
}
