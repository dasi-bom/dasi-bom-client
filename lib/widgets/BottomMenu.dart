import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../MainPage.dart';

class BottomMenu extends StatefulWidget {
  const BottomMenu({Key? key}) : super(key: key);

  @override
  State<BottomMenu> createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> {

  // 하단 바 페이지 전환 변수 선언
  var _index = 0; // 페이지 인덱스 0,1,2,3

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      onTap: (index) {
        setState(() {
          _index = index; // 선택된 탭의 인덱스로 _index를 변경
        });
      },
      currentIndex: _index,
      // 선택된 인덱스
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          // 하단 탭 아이템리스트 선언
          label: '',
          icon: Icon(Icons.home_outlined),
        ),
        BottomNavigationBarItem(
          label: '',
          icon: Icon(Icons.border_color_outlined),
        ),
        BottomNavigationBarItem(
          label: '',
          icon: Icon(Icons.people_outline),
        ),
        BottomNavigationBarItem(
          label: '',
          icon: Icon(Icons.account_circle_outlined),
        ),
      ],
    );
  }
}
