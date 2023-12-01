import 'package:dasi_bom_client/community/Com_WritingPage.dart';
import 'package:dasi_bom_client/mypage/dasibom_content.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dasi_bom_client/widgets/Kakao_Login.dart';
import 'package:dasi_bom_client/widgets/main_view_model.dart';
import 'package:dasi_bom_client/writing/WritingPage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

// Page1의 _buildMiddle() 메서드에 들어갈 사진 url
final dummyItems = [
  'https://cdn.pixabay.com/photo/2016/02/18/18/37/puppy-1207816_960_720.jpg',
  'https://cdn.pixabay.com/photo/2018/10/01/09/21/pets-3715733_960_720.jpg',
  'https://cdn.pixabay.com/photo/2017/09/25/13/14/dog-2785077_960_720.jpg',
];

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final storage = FlutterSecureStorage();
  final baseUrl = dotenv.env['BASE_URL'].toString();
  final getDiaryListUrl = dotenv.env['GET_DIARY_LIST_API'].toString();

  var cursor = 20;
  var diaryList = [];

  Future<void> getDiaryList() async {
    try {
      final accessToken = await storage.read(key: 'accessToken');
      final url = Uri.parse('$baseUrl$getDiaryListUrl?cursor=$cursor');
      final headers = {
        'Content-Type': 'application/json ',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };

      final res = await http.get(url, headers: headers);
      final status = res.statusCode;
      print('${res.request} ==> $status');

      if (status == 200) {
        var result = jsonDecode(res.body);
        print(result);
      }
    } catch (err) {
      print('err ===> $err');
    }
  }

  // 로그인 생성자
  final viewModel = MainViewModel(KakaoLogin());

  // 하단 바 페이지 전환 변수 선언
  var _index = 0; // 페이지 인덱스 0,1,2,3
  var _pages = [
    // Page1,2,3,4 클래스와 연동하여 변수 선언(페이지를 _pages 리스트 변수의 값으로 정의)
    Page1(),
    Page2(),
    Page3(),
    Page4(),
  ];

  @override
  void initState() {
    getDiaryList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: _scaffoldKey,
      // 상단 앱 바
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        title: Image.asset('assets/ic_barlogo.png', width: 100, height: 100),
        automaticallyImplyLeading: false,
        // appbar 뒤로가기 버튼 숨김
        actions: <Widget>[
          // actions 프로퍼티에는 어떠한 위젯도 리스트로 배치 가능
          IconButton(
            // 카카오 로그아웃 버튼
            onPressed: () async {
              await storage.deleteAll(); // Delete all
              // await viewModel.logout();

              // 로그아웃 되면 로그인 화면으로 화면 이동
              final result = await Navigator.pushNamed(context, '/login');
            },
            icon: Icon((Icons.outbond)),
            color: Colors.black,
          ),
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
      ),
      // 햄버거 메뉴 버튼 구성
      endDrawer: Drawer(
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
      // index에 따라 페이지 바뀜
      body: _pages[_index],

      // 하단 내비게이션 바
      bottomNavigationBar: BottomNavigationBar(
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
      ),
    );
  }
}

// 홈 클래스-> Scaffold의 body 프로퍼티에 코드 연동
class Page1 extends StatelessWidget {
  const Page1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      // Column을 ListView로 변경하면 상하 스크롤이 생김
      children: <Widget>[
        _buildTop(),
        _buildMiddle(context),
        _buildBottom(),
      ],
    );
  }

  // 홈 클래스 _ 상단
  Widget _buildTop() {
    return Container(
      // color: Color(0xffFFF1AA),
      height: 200,
      decoration: const BoxDecoration(
          image: DecorationImage(
        fit: BoxFit.cover,
        image: AssetImage('assets/img_back.png'),
      )),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 30, top: 20),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                '봄님의 다시 봄 챌린지 현황',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 30, top: 10),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                '일기 하나만 더 쓰면, 챌린지 완료!',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.normal),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Image.asset('assets/user1.png'),
                Image.asset('assets/user2.png'),
                Image.asset('assets/user1.png'),
                Image.asset('assets/user2.png'),
                Image.asset('assets/user1.png'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                child: Text(
                  '다시 봄 챌린지 알아보기 ▶',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 11,
                      color: Colors.black),
                ),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 홈 클래스 _ 중단
  Widget _buildMiddle(context) {
    var viewModel;
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 10),
              child: Align(
                alignment: Alignment.topLeft,
                child: TextButton(
                  child: Text(
                    '날도 좋은데, 기분 좋은 산책일기 >',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black),
                  ),
                  onPressed: () {},
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 10),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  child: Text(
                    '+ 작성하기',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.orange),
                  ),
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
        CarouselSlider(
          options: CarouselOptions(
            height: 150,
            autoPlay: true,
          ),
          items: dummyItems.map((url) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: ClipRRect(
                    // ClipRRect는 child를 둥근 사각형으로 자르는 위젯
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 10),
              child: Align(
                alignment: Alignment.topLeft,
                child: TextButton(
                  child: Text(
                    '웃긴 표정을 찰칵! 유쾌일기 >',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black),
                  ),
                  onPressed: () {},
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 60, top: 10),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  child: Text(
                    '+ 작성하기',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.orange),
                  ),
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
        CarouselSlider(
          options: CarouselOptions(
            height: 120,
            autoPlay: true,
          ),
          items: dummyItems.map((url) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: ClipRRect(
                    // ClipRRect는 child를 둥근 사각형으로 자르는 위젯
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 10),
              child: Align(
                alignment: Alignment.topLeft,
                child: TextButton(
                  child: Text(
                    '무슨 꿈을 꾸나? 쿨쿨일기 >',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black),
                  ),
                  onPressed: () {},
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 70, top: 10),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  child: Text(
                    '+ 작성하기',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.orange),
                  ),
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
        CarouselSlider(
          options: CarouselOptions(
            height: 120,
            autoPlay: true,
          ),
          items: dummyItems.map((url) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: ClipRRect(
                    // ClipRRect는 child를 둥근 사각형으로 자르는 위젯
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        SizedBox(
          height: 50,
        ),
        Container(
          height: 250,
          width: 500,
          color: Color(0xffFFF0DA),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 30, top: 10),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: TextButton(
                    child: Text(
                      '오늘의 챌린지 랭킹 >',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black),
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      height: 170,
                      width: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Center(
                            child: Container(
                              height: 30,
                              width: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.green,
                              ),
                              child: Text(
                                '산책왕',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: AssetImage('assets/dog.jpg'),
                          ),
                          Text(
                            '곰곰이',
                          ),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      height: 170,
                      width: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Center(
                            child: Container(
                              height: 30,
                              width: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.orange,
                              ),
                              child: Text(
                                '유쾌왕',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: AssetImage('assets/dog.jpg'),
                          ),
                          Text(
                            '뭉치',
                          ),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      height: 170,
                      width: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Center(
                            child: Container(
                              height: 30,
                              width: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.purple,
                              ),
                              child: Text(
                                '드림왕',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: AssetImage('assets/dog.jpg'),
                          ),
                          Text(
                            '카야',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30, top: 10),
          child: Align(
            alignment: Alignment.topLeft,
            child: TextButton(
              child: Text(
                '요즘 뜨는 이야기 >',
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black),
              ),
              onPressed: () { },
            ),
          ),
        ),
        Container(
          height: 500,
          width: 500,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 180,
                        width: 180,
                        child: InkWell(
                          onTap: () {}, // Handle your callback.
                          splashColor: Colors.brown.withOpacity(0.5),
                          child: Ink(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: AssetImage('assets/dog.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '뭉치의 낮잠',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '''고양이는 하루에 10시간을 넘게
잔다고 하는데...''',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 180,
                        width: 180,
                        child: InkWell(
                          onTap: () {}, // Handle your callback.
                          splashColor: Colors.brown.withOpacity(0.5),
                          child: Ink(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: AssetImage('assets/dog.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '샐리와 처음 만난 날',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '''운명처럼 만난 너무나 귀엽고
사람을 좋아하는 아이!''',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 180,
                        width: 180,
                        child: InkWell(
                          onTap: () {}, // Handle your callback.
                          splashColor: Colors.brown.withOpacity(0.5),
                          child: Ink(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: AssetImage('assets/dog.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '비누 이야기',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '''비누는 정말 똑똑합니다.
제가 일어나는 시간을 딱 맞춰서...''',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 180,
                        width: 180,
                        child: InkWell(
                          onTap: () {}, // Handle your callback.
                          splashColor: Colors.brown.withOpacity(0.5),
                          child: Ink(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: AssetImage('assets/dog.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '웃는게 넘 귀여운 우리 애기',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '''강아지의 웃음은 너무나 무해하다.
오늘은 특히나 산책하는데...''',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 홈 클래스 _ 하단
  Widget _buildBottom() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30, top: 10),
          child: Align(
            alignment: Alignment.topLeft,
            child: TextButton(
              child: Text(
                '임시보호 가이드 >',
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black),
              ),
              onPressed: () {},
            ),
          ),
        ),
        SizedBox(
          height: 100,
          width: 350,
          child: ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
                backgroundColor:
                    MaterialStateProperty.all(const Color(0xFFFF86B2)),
              ),
              onPressed: () => {},
              child: Image.asset('assets/ic_guide1.png')),
        ),
        const SizedBox(
          height: 15,
        ),
        SizedBox(
          height: 100,
          width: 350,
          child: ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
                backgroundColor:
                    MaterialStateProperty.all(const Color(0xFFFDCC85)),
              ),
              onPressed: () => {},
              child: Image.asset('assets/ic_guide2.png')),
        ),
      ],
    );
  }
}

// 일기쓰기 클래스-> Scaffold의 body 프로퍼티에 코드 연동
class Page2 extends StatefulWidget {
  const Page2({Key? key}) : super(key: key);

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  @override
  Widget build(BuildContext context) {
    return Writing();
  }
}

// 커뮤니티 클래스-> Scaffold의 body 프로퍼티에 코드 연동
class Page3 extends StatefulWidget {
  const Page3({Key? key}) : super(key: key);

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> with TickerProviderStateMixin {
  // Tab 변수 선언
  late TabController tabController;

  // Tab 변수 초기화
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TabBar(
              controller: tabController,
              indicatorColor: Colors.black,
              indicatorWeight: 1,
              tabs: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text('카테고리1'),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text('카테고리2'),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text('카테고리3'),
                ),
              ]),
          Expanded(
            // 내 정보 내의 탭 컨트롤러 지정
            child: TabBarView(
              controller: tabController,
              children: <Widget>[
                Page11(),
                Page22(),
                Page33(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/com_writing');
        },
        backgroundColor: Color(0xfffd8801),
        child: Image.asset(
          'assets/ic_floating_pen.png',
        ),
      ),
    );
  }
}

//// 커뮤니티 클래스 _ 카테고리1 탭
class Page11 extends StatelessWidget {
  const Page11({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = List.generate(20, (i) {
      // 0부터 9까지의 수를 생성하여 두 번째 인수의 함수에 i 매개변수로 전달함
      return ListTile(
        // i 값을 전달받아 ListTile 위젯 형태로 변환하여 그것들의 리스트가 반환됨
        leading: Icon(Icons.question_answer_sharp),
        title: Text('산책 메이트 구해요'),
        subtitle: Text('역삼동 근처에 임보하시는 분 계신다면 함께..'),
      );
    });

    return SingleChildScrollView(
      child: ListView(
        physics: NeverScrollableScrollPhysics(), // 이 리스트의 스크롤 동작 금지
        shrinkWrap: true, // 이 리스트의 다른 스크롤 객체 안에 있다면 true로 설정해야 함
        children: items,
      ),
    );
  }
}

//// 커뮤니티 클래스 _ 카테고리2 탭
class Page22 extends StatelessWidget {
  const Page22({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = List.generate(20, (i) {
      // 0부터 9까지의 수를 생성하여 두 번째 인수의 함수에 i 매개변수로 전달함
      return ListTile(
        // i 값을 전달받아 ListTile 위젯 형태로 변환하여 그것들의 리스트가 반환됨
        leading: Icon(Icons.question_answer_sharp),
        title: Text('입양 문의 드립니다.'),
        subtitle: Text('역삼동 근처에 임보하시는 분 계신다면 함께..'),
      );
    });

    return SingleChildScrollView(
      child: ListView(
        physics: NeverScrollableScrollPhysics(), // 이 리스트의 스크롤 동작 금지
        shrinkWrap: true, // 이 리스트의 다른 스크롤 객체 안에 있다면 true로 설정해야 함
        children: items,
      ),
    );
  }
}

//// 커뮤니티 클래스 _ 카테고리3 탭
class Page33 extends StatelessWidget {
  const Page33({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = List.generate(20, (i) {
      // 0부터 9까지의 수를 생성하여 두 번째 인수의 함수에 i 매개변수로 전달함
      return ListTile(
        // i 값을 전달받아 ListTile 위젯 형태로 변환하여 그것들의 리스트가 반환됨
        leading: Icon(Icons.question_answer_sharp),
        title: Text('임보 물품 구해요!'),
        subtitle: Text('역삼동 근처에 임보하시는 분 계신다면 함께..'),
      );
    });

    return SingleChildScrollView(
      child: ListView(
        physics: NeverScrollableScrollPhysics(), // 이 리스트의 스크롤 동작 금지
        shrinkWrap: true, // 이 리스트의 다른 스크롤 객체 안에 있다면 true로 설정해야 함
        children: items,
      ),
    );
  }
}

// 마이페이지 클래스-> Scaffold의 body 프로퍼티에 코드 연동
class Page4 extends StatefulWidget {
  const Page4({Key? key}) : super(key: key);

  @override
  State<Page4> createState() => _Page4State();
}

class _Page4State extends State<Page4> with TickerProviderStateMixin {
  // Tab 변수 선언
  late TabController tabController;

  // Tab 변수 초기화
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TabBar(
              controller: tabController,
              indicatorColor: Colors.black,
              indicatorWeight: 1,
              tabs: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text('프로필'),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text('히스토리'),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text('내활동'),
                ),
              ]),
          Expanded(
            // 내 정보 내의 탭 컨트롤러 지정
            child: TabBarView(
              controller: tabController,
              children: <Widget>[
                Page111(),
                Page222(),
                Page333(),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/content');
        },
        backgroundColor: Color(0xfffd8801),
        child: Image.asset(
          'assets/ic_envelope.png',
        ),
      ),
    );
  }
}

//// 마이페이지 클래스 _ 프로필 탭
class Page111 extends StatelessWidget {
  const Page111({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _information(),
          _menu(),
          const SizedBox(height: 20),
          _tabView()
        ],
      ),
    );
  }

  Widget _statisticsOne(String title, int value) {
    return TextButton(
      onPressed: () {
      },
      child: Column(
        children: [
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
                fontSize: 15,
                color: Colors.orange,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // 프로필 탭 _ 내정보 위젯
  Widget _information() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage('assets/user1.png'),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '카야',
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(child: _statisticsOne('팔로우', 5)),
                        Expanded(child: _statisticsOne('팔로잉', 120)),
                        Expanded(child: _statisticsOne('북마크', 56)),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  // 프로필 탭 _ Edit profile 위젯
  Widget _menu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 50,
            width: 170,
            child: Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 20),
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
                  backgroundColor:
                      MaterialStateProperty.all(const Color(0xFFFFED8E)),
                ),
                onPressed: () {},
                child: const Text(
                  "채팅",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50,
            width: 170,
            child: Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 20),
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
                  backgroundColor:
                      MaterialStateProperty.all(const Color(0xFFFFED8E)),
                ),
                onPressed: () {},
                child: const Text(
                  "팔로우",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 프로필 탭 _ 게시물 GridView 위젯
  Widget _tabView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 100,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () {
                Navigator.of(context).pushNamed('/detail');
              },
              splashColor: Colors.white.withOpacity(0.05),
              child: Ink(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage('assets/dog.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }),
    );
  }
}

//// 마이페이지 클래스 _ 히스토리 탭
class Page222 extends StatelessWidget {
  const Page222({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('history');
  }
}

//// 마이페이지 클래스 _ 내활동 탭
class Page333 extends StatelessWidget {
  const Page333({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('activity');
  }
}
