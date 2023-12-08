import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget{
  const BaseAppBar({Key? key, required this.appBar}) : super(key: key);

  final AppBar appBar;

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return AppBar(
      key: _scaffoldKey,
      elevation: 0.0,
      backgroundColor: Colors.white,
      title: Image.asset('assets/ic_barlogo.png', width: 100, height: 100),
      automaticallyImplyLeading: false,
      // appbar 뒤로가기 버튼 숨김
      actions: <Widget>[
        // actions 프로퍼티에는 어떠한 위젯도 리스트로 배치 가능
        IconButton(
          // 채팅 버튼
          onPressed: () {},
          icon: Icon(Icons.chat_outlined),
          color: Colors.black,
        ),
        IconButton(
          // 알림 버튼
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

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(appBar.preferredSize.height);
}
