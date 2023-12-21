import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppDrawr extends StatelessWidget {
  const AppDrawr({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height*0.6,
      child: Drawer(
        elevation: 10,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xffFFF1AA),
              ),
              child: Text('메뉴'),
            ),
            ListTile(
              leading: Icon(
                Icons.home,
              ),
              title: const Text('다시, 봄 가이드'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.settings,
              ),
              title: const Text('설정'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
