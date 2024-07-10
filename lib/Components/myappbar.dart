import 'package:flutter/material.dart';

class CurvedAppBar extends StatelessWidget {
  final Widget appBar;
  final Widget body;
  final double curveHeight;

  CurvedAppBar({
    required this.appBar,
    required this.body,
    required this.curveHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: MyClipper(curveHeight: curveHeight),
              child: Container(
                height: 120, // Adjust as needed
                decoration: BoxDecoration(
                  color: Colors.blueGrey[900],
                ),
              ),
            ),
          ),
          Positioned(
            top: curveHeight - 30, // Adjust as needed
            left: 0,
            right: 0,
            child: appBar,
          ),
          Positioned.fill(
            top: curveHeight + 10, // Adjust as needed
            child: body,
          ),
        ],
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  final double curveHeight;

  MyClipper({required this.curveHeight});

  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
        size.width / 2, size.height - curveHeight, size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}