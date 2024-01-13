import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WritingAppBar extends StatefulWidget implements PreferredSizeWidget {
  const WritingAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  State<WritingAppBar> createState() => _WritingAppBarState();
}

class _WritingAppBarState extends State<WritingAppBar> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return AppBar(
      key: _scaffoldKey,
      elevation: 0.0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      leadingWidth: 250,
      leading: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 20),
          TextButton(
            onPressed: () {
              // 둘러보기 동작
            },
            child: Text(
              '둘러보기',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(width: 8),
          TextButton(
            onPressed: () {
              // 구독
            },
            child: Text(
              '구독',
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.chat_outlined),
          color: Colors.black,
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.add_alert_outlined),
          color: Colors.black,
        ),
        IconButton(
          // 햄버거 메뉴 버튼
          onPressed: () {
            _scaffoldKey.currentState?.openEndDrawer();
          },
          icon: Icon(Icons.menu),
          color: Colors.black,
        ),
      ],
    );
  }
}
