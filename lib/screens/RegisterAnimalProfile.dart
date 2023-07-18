import 'package:flutter/material.dart';

class RegisterAnimalProfile extends StatefulWidget {
  const RegisterAnimalProfile({Key? key}) : super(key: key);

  @override
  State<RegisterAnimalProfile> createState() => _RegisterAnimalProfileState();
}

class _RegisterAnimalProfileState extends State<RegisterAnimalProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // theme: ThemeData(primaryColor: Colors.white),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        title: Text('프로필 등록하기', style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          Container(
            color: Color(0xffFFF1AA),
            width: double.infinity,
            height: 100,
            child: Row(
              children: [
                Image.asset('assets/animal_profile.png'),
                CustomPaint(
                  painter: customStyleArrow(),
                  child: Container(
                    padding: EdgeInsets.only(
                        left: 15, right: 15, bottom: 20, top: 20),
                    child:
                        Text("This is the custom painter for arrow down curve",
                            style: TextStyle(
                              color: Colors.black,
                            )),
                  ),
                ),
                // Container(
                //   margin: EdgeInsets.fromLTRB(80, 0, 0, 0),
                //   width: 250,
                //   height: 70,
                //
                //   child: DecoratedBox(
                //     decoration: BoxDecoration(
                //       color: Colors.white,
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //     child: Text('어떤 친구와 함께 하고 있나요?'),
                //   ),
                // )
              ],
            ),
          ),
          Text('함께 하는 동물 친구 프로필,'),
          Text('동물 친구 프로필 사진'),
          IconButton(onPressed: () {}, icon: Icon(Icons.add)),
        ],
      ),
    );
  }
}

class customStyleArrow extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;
    final double triangleH = 14;
    final double triangleW = 10.0;
    final double width = size.width;
    final double height = size.height;

    final Path trianglePath = Path()
      ..moveTo(width / 2 - triangleW / 2, height)
      ..lineTo(width / 2, triangleH + height)
      ..lineTo(width / 2 + triangleW / 2, height)
      ..lineTo(width / 2 - triangleW / 2, height);
    canvas.drawPath(trianglePath, paint);
    final BorderRadius borderRadius = BorderRadius.circular(15);
    final Rect rect = Rect.fromLTRB(100, 0, width, height);
    final RRect outer = borderRadius.toRRect(rect);
    canvas.drawRRect(outer, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
