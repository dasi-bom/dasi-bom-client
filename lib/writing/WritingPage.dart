import 'dart:ffi';
import 'dart:io';
import 'package:dasi_bom_client/mypage/SeeingPage.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/route_manager.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dasi_bom_client/MainPage.dart';
import 'package:mime/mime.dart';
import 'package:remedi_kopo/remedi_kopo.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:flutter_switch/flutter_switch.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class Writing extends StatefulWidget {
  const Writing({Key? key}) : super(key: key);

  @override
  State<Writing> createState() => _WritingState();
}

class _WritingState extends State<Writing> with SingleTickerProviderStateMixin {
  final storage = FlutterSecureStorage();
  final baseUrl = dotenv.env['BASE_URL'].toString();
  final createDiaryUrl = dotenv.env['CREATE_DIARY_API'].toString();
  final uploadDiaryImagesUrl = dotenv.env['UPLOAD_DIARY_IMAGES_API'].toString();
  final getUserInfoUrl = dotenv.env['GET_USER_INFO_API'].toString();

  final userInfo = {};
  final diaryForm = {};

  // final TextEditingController _petIdController = TextEditingController();
  // final TextEditingController _categoryController = TextEditingController();
  // final TextEditingController _contentController = TextEditingController();
  // final TextEditingController _stampsController = TextEditingController();
  // final TextEditingController _isPublicController = TextEditingController();

  // 이미지 받아오기
  XFile? _pickedFile; // 이미지를 담을 변수 선언
  List<XFile?> _pickedImages = []; // 이미지 여러개 담을 변수 선언
  List<XFile> imageFiles = [];
  final ImagePicker imagePicker = ImagePicker(); // ImagePicker 초기화

  // 이미지 여러개 pick
  Future<void> _pickImg() async {
    final List<XFile>? images = await imagePicker.pickMultiImage();
    if (images != null) {
      setState(() {
        _pickedImages = images;
        imageFiles.addAll(images);
      });
    }
  }

  bool isDefault = false;

  // Textformfield 값 받아오기
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, String> formData = {};

  final TextEditingController _bodyController =
      TextEditingController(); // 본문 저장 변수

  late bool validationResult;
  String _body = ''; // 본문

  // 동물 친구 콤보박스
  var write = [];
  var _selectedWrite = null;
  var test = [];

  // 카테고리 콤보박스
  final _category = ['일기쓰기', '챌린지 등록하기'];
  var _selectedcategory = '일기쓰기';

  // 주제 다중 선택
  List<String> tags = [];
  List<String> options = [
    '산책',
    '간식',
    '장난감',
    '목욕',
    '소풍',
    '드라이브',
    '미용실',
    '병원',
    '잠',
  ];

  // 나만보기 토글
  bool? isPublic = false;
  var diaryId;

  getInitDiaryId() async {
    final accessToken = await storage.read(key: 'accessToken');

    String currentRoute = ModalRoute.of(context)!.settings.name ?? "";
    print("Current Route: $currentRoute");

    final getInit = Uri.parse('$baseUrl/diary/issue-id');
    final res = await http.get(
      getInit,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );

    final initResStatus = res.statusCode;
    print('${res.request} ==> $initResStatus');

    if (initResStatus == 200) {
      var initData = json.decode(res.body);
      setState(() {
        diaryId = initData['diaryId'];
      });
      print('diaryId ==> $diaryId');
    }
  }

  getUserInfo() async {
    try {
      final accessToken = await storage.read(key: 'accessToken');

      if (accessToken == null) {
        return;
      }

      final url = Uri.parse('$baseUrl$getUserInfoUrl');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };
      final res = await http.get(url, headers: headers);
      final status = res.statusCode;
      print('${res.request} ==> $status');

      if (status == 200) {
        final info = json.decode(res.body);
        // print('info ===> $info');

        if (info != null && info['petProfileResponses'] is List) {
          setState(() {
            List<dynamic> petProfileResponses = info['petProfileResponses'];

            petProfileResponses.forEach((petProfile) {
              String? petName = petProfile?['petInfo']?['name'];
              int? petId = petProfile?['petId'];

              if (petName != null && petId != null) {
                var petData = {
                  'petId': petId,
                  'name': petName,
                };

                write.add(petData);
              }
            });
          });

          Set<String> uniqueData = Set<String>();
          var result = write.where((pet) {
            return uniqueData.add(pet['name']);
          }).toList();

          print('petList => $result');

          setState(() {
            write = result;
          });
          if (!write.contains(_selectedWrite)) {
            if (write.isNotEmpty) {
              _selectedWrite = write[0];
            } else {
              _selectedWrite = null;
            }
          }

          print('_selectedWrite ==> $_selectedWrite');
          print('write ====> $write');

          if (diaryForm.isEmpty) {
            setState(() {
              diaryForm['petId'] = _selectedWrite['petId'];
              diaryForm['name'] = _selectedWrite['name'];
              diaryForm['challengeId'] = null;
            });
          }
        }
      } else {
        print('status != 200 ##');
      }
    } catch (err) {
      print('error 11111 ==> $err');
    }
  }

  late TabController _controller;

  @override
  void initState() {
    validationResult = false;

    getInitDiaryId();
    getUserInfo();

    super.initState();
    _controller = TabController(vsync: this, length: 7);
  }

  uploadImages(List<XFile?> images) async {
    print('images ==> $images');

    try {
      final accessToken = await storage.read(key: 'accessToken');
      final url = Uri.parse('$baseUrl$uploadDiaryImagesUrl/$diaryId');
      final headers = {
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $accessToken'
      };

      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);

      for (int i = 0; i < images.length; i++) {
        final image = images[i];
        if (image != null) {
          // final byteData = await File(image.path).readAsBytes();
          // final multipartFile =
          //     http.MultipartFile.fromBytes('multipartFiles', byteData);
          // request.files.add(multipartFile);
          request.files.add(
              await http.MultipartFile.fromPath('multipartFiles', image!.path));
        }
      }

      final res = await request.send();
      final status = res.statusCode;
      print('image upload status ==> $status');
    } catch (err) {
      print('image upload err ==> $err');
    }
  }

  Future<void> createDiary(data) async {
    print('data => $data');

    try {
      final accessToken = await storage.read(key: 'accessToken');
      final url = Uri.parse('$baseUrl$createDiaryUrl/$diaryId');
      final headers = {
        'Content-Type': 'application/json ',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };

      var petId;
      var challengeId;
      var content;
      var stamps = [];
      var isPublic;

      if (data['petId'] != null) {
        petId = data['petId'];
      } else {
        petId = _selectedWrite['petId'];
      }

      if (data['challengeId'] != null && data['challengeId'] != '일기쓰기') {
        challengeId = '1';
      } else {
        challengeId = null;
      }

      content = data['content'] ?? ' ';

      if (data['stamps'] != null) {
        data['stamps'].forEach((val) {
          var stamp;
          if (val == '산책') {
            stamp = 1;
          } else if (val == '간식') {
            stamp = 2;
          } else if (val == '장난감') {
            stamp = 3;
          } else {
            stamp = val;
          }

          stamps.add(stamp);
          setState(() {});
        });
      } else {
        setState(() {
          stamps = [];
        });
      }

      if (data['isPublic'] == null) {
        isPublic = 'False';
      } else {
        isPublic = 'True';
      }

      final body = jsonEncode({
        'petId': petId,
        'challengeId': challengeId,
        'content': content,
        'stamps': stamps,
        'isPublic': isPublic
      });

      print('body =====> $body');

      final res = await http.post(url, headers: headers, body: body);
      final status = res.statusCode;
      final info = res.body;
      print('${res.request} ==> $status');

      if (status == 201) {
        print('create diary ===> $info');
        await Navigator.pushNamed(context, '/main');
      } else if (status == 404) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('사진 등록 필요'),
              content: Text('사진을 등록해 주세요.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('확인'),
                ),
              ],
            );
          },
        );
      } else {
        print('fail ##');
      }
    } catch (err) {
      print('err ==> $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isPadMode = MediaQuery.of(context).size.width > 700;
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    // 사진 Gridview
    List<Widget> _boxContents = [
      IconButton(
          onPressed: () {
            // _pickImg();
            _showBottomSheet();
          },
          icon: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6), shape: BoxShape.circle),
              child: Icon(
                CupertinoIcons.camera,
                color: Theme.of(context).colorScheme.primary,
              ))),
      Container(),
      Container(),
      _pickedImages.length <= 4
          ? Container()
          : FittedBox(
              child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      shape: BoxShape.circle),
                  child: Text(
                    '+${(_pickedImages.length - 4).toString()}',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ))),
    ];

    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        body: Form(
          // form으로 input 데이터 저장
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 5,
                ),
                // 글 쓸 동물 친구 등록
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100),
                  child: DropdownButtonFormField(
                    items: write.map(
                      (value) {
                        return DropdownMenuItem(
                          value: value['name'].toString(),
                          child: Text(value['name'].toString()),
                        );
                      },
                    ).toList(),
                    value: _selectedWrite != null &&
                            _selectedWrite['name'] != null
                        ? _selectedWrite['name'].toString()
                        : (write.isNotEmpty ? write[0]['name'].toString() : ''),
                    onChanged: (value) {
                      print('@@ => $value');
                      setState(() {
                        _selectedWrite =
                            write.firstWhere((pet) => pet['name'] == value);
                        diaryForm['petId'] = _selectedWrite['petId'].toString();
                        diaryForm['name'] = _selectedWrite['name'].toString();
                      });
                      print(diaryForm);
                    },
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: const Text(
                      '카테고리 선택하기',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 13),
                    ),
                  ),
                ),
                // 카테고리 등록
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: DropdownButtonFormField(
                    items: _category.map(
                      (value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      },
                    ).toList(),
                    value: _selectedcategory,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      print(value);
                      setState(() {
                        _selectedcategory = value!;
                        diaryForm['challengeId'] = _selectedcategory;
                      });
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        child: const Text(
                          '사진 등록하기',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 13),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        width: 40,
                        child: GestureDetector(
                          child: Image.asset('assets/ic_addtexticon.png'),
                          onTap: () {
                            _showBottomSheet();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // 사진 등록
                GridView.count(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(16),
                  crossAxisCount: isPadMode ? 1 : 4,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  children: List.generate(
                    4,
                    (index) => GestureDetector(
                        onTap: () {
                          print('upload ###############');
                          _showBottomSheet();
                        },
                        child: DottedBorder(
                            child: Container(
                              child: Center(child: _boxContents[index]),
                              decoration: index <= _pickedImages.length - 1
                                  ? BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: FileImage(File(
                                              _pickedImages[index]!.path))))
                                  : null,
                            ),
                            color: Colors.grey,
                            dashPattern: [8, 3],
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(10))),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: const Text(
                      '본문 작성하기',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 13),
                    ),
                  ),
                ),
                // 본문 등록
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: TextFormField(
                    maxLines: 5,
                    keyboardType: TextInputType.text,
                    autovalidateMode: AutovalidateMode.always,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                        hintText: '카야와 3일째 기록!'),
                    onSaved: (value) {
                      setState(() {
                        _body = value as String;
                        diaryForm['content'] = value;
                      });
                    },
                    controller: _bodyController,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        child: const Text(
                          '텍스트 아이콘',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 13),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        width: 40,
                        child: GestureDetector(
                          child: Image.asset('assets/ic_addtexticon.png'),
                          onTap: () {
                            _texticonBottomSheet(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // 주제 해시태그 등록
                ChipsChoice<String>.multiple(
                  value: tags,
                  // onChanged: (val) => setState(() {
                  //   print(val);
                  //   tags = val;
                  //   diaryForm['stamps'] = tags;
                  // }),
                  onChanged: (value) {
                    print(value);
                    setState(() {
                      tags = value;
                      diaryForm['stamps'] = tags;
                    });
                  },

                  choiceItems: C2Choice.listFrom<String, String>(
                    source: options,
                    value: (i, v) => v,
                    label: (i, v) => v,
                    tooltip: (i, v) => v,
                  ),
                  choiceCheckmark: false,
                  choiceStyle: C2ChipStyle.filled(),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: const Text(
                      '나만 보기 설정',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 13),
                    ),
                  ),
                ),
                // 나만 보기 설정
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FlutterSwitch(
                        activeColor: Colors.green,
                        width: 60,
                        height: 30,
                        valueFontSize: 10,
                        toggleSize: 20,
                        value: isPublic ?? false,
                        borderRadius: 30,
                        padding: 8,
                        showOnOff: true,
                        onToggle: (val) {
                          setState(() {
                            isPublic = val;
                            diaryForm['isPublic'] = val;
                          });
                        },
                      ),
                      const Text(
                        '* 일기를 나만 열람할 수 있어요.',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                // 일기 등록하기
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: SizedBox(
                    height: 60,
                    width: double.infinity,
                    child: Container(
                      color: Colors.white,
                      margin: const EdgeInsets.only(top: 20),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15))),
                          backgroundColor: MaterialStateProperty.all(
                              const Color(0xFFFFED8E)),
                        ),
                        onPressed: () {
                          setState(
                            () {
                              validationResult =
                                  formKey.currentState?.validate() ?? false;
                              formKey.currentState!.save();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('$_selectedcategory/$_body')),
                              );

                              // Writing(formData);

                              createDiary(diaryForm); // 일기 등록 테스트
                            },
                          );
                        },
                        child: const Text(
                          "일기 등록하기",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 페이지 전환 애니메이션
  Route _createRoute() {
    return PageRouteBuilder(
      // pageBuilder: (context, animation, secondaryAnimation) => Seeing(),
      pageBuilder: (context, animation, secondaryAnimation) => MainPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 10.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  // 아래의 해당 함수(카메라, 갤러리, 기본이미지)를 버튼과 연결
  _showBottomSheet() {
    return showModalBottomSheet(
      context: this.context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () => _getCameraImage(),
              child: const Text('카메라'),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              thickness: 3,
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () => _getPhotoLibraryImage(),
              child: const Text('갤러리'),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        );
      },
    );
  }

// 카메라로 이동
  _getCameraImage() async {
    final pickedFile = await imagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        isDefault = false;
        _pickedImages = pickedFile as List<XFile?>;
      });
    } else {
      if (kDebugMode) {
        print('이미지 선택안함');
      }
    }
  }

// 갤러리로 이동
  _getPhotoLibraryImage() async {
    // final pickedFile = await imagePicker.pickImage(
    //     source: ImageSource.gallery, imageQuality: 50);
    final pickedFile = await imagePicker.pickMultiImage(imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        isDefault = false;
        // _pickedImages.add(pickedFile as XFile?);
        _pickedImages.addAll(pickedFile);
      });

      if (_pickedImages.isNotEmpty) {
        uploadImages(_pickedImages);
      }
    } else {
      if (kDebugMode) {
        print('이미지 선택안함');
      }
    }
  }
}

// 텍스트아이콘 bottomsheet
_texticonBottomSheet(BuildContext context) {
  List<String> tags = [];
  List<String> options1 = [
    '산책',
    '간식',
    '밥',
    '장난감',
    '목욕',
    '소풍',
    '드라이브',
    '데이트',
    '미용실',
    '병원',
    '다이어트',
    '친구',
    '수면',
    'TMI',
  ];
  List<String> options2 = [
    '행복',
    '사랑',
    '즐거움',
    '설렘',
    '호기심',
    '슬픔',
    '화남',
    '질투',
  ];
  List<String> options3 = [
    '특기',
    '취미',
    '건강',
    '패션',
    '매력포인트',
  ];
  List<String> options4 = [
    '맑음',
    '바람',
    '더움',
    '비',
    '눈',
    '흐림',
  ];
  List<String> options5 = [
    '세계강아지의날',
    '세계고양이의날',
    '지구의날',
  ];
  return showModalBottomSheet<dynamic>(
    isScrollControlled: true,
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(25),
      ),
    ),
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            var controller;
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height/2,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.0),
                  topRight: const Radius.circular(18.0),
                ),
              ),
              child: DefaultTabController(
                length: 7,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 15),
                            const Text(
                              '텍스트 아이콘',
                              style: TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 15),
                            Divider(
                                color: Colors.black.withOpacity(0.5), height: 2, thickness: 0.3),
                          ],
                        ),
                        TabBar(
                          isScrollable: true,
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
                          indicator: UnderlineTabIndicator(
                            borderSide: BorderSide(color: Colors.orange, width: 5), // Indicator height
                            insets: EdgeInsets.symmetric(horizontal: 5), // Indicator width
                          ),
                          tabs: [
                            Tab(
                              text: '추천',),
                            Tab(
                              text: '최근사용',),
                            Tab(
                              text: '일상',),
                            Tab(
                              text: '감정',),
                            Tab(
                              text: '궁금해요',),
                            Tab(
                              text: '날씨',),
                            Tab(
                              text: '이벤트',),
                          ],
                        ),
                        Divider(
                            color: Colors.black.withOpacity(0.5), height: 2, thickness: 0.3),
                        Expanded(
                          child: TabBarView(
                            controller: controller,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  ChipsChoice<String>.multiple(
                                    wrapped: true,
                                    padding: EdgeInsets.symmetric(vertical: 40),
                                    value: tags,
                                    onChanged: (value) {
                                      print(value);
                                      setState(() {
                                        tags = value;
                                        var diaryForm;
                                        diaryForm['stamps'] = tags;
                                      });
                                    },

                                    choiceItems: C2Choice.listFrom<String, String>(
                                      source: options1,
                                      value: (i, v) => v,
                                      label: (i, v) => v,
                                      tooltip: (i, v) => v,
                                    ),
                                    choiceCheckmark: false,
                                    choiceStyle: C2ChipStyle.filled(),
                                  ),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  ChipsChoice<String>.multiple(
                                    wrapped: true,
                                    padding: EdgeInsets.symmetric(vertical: 40),
                                    value: tags,
                                    onChanged: (value) {
                                      print(value);
                                      setState(() {
                                        tags = value;
                                        var diaryForm;
                                        diaryForm['stamps'] = tags;
                                      });
                                    },

                                    choiceItems: C2Choice.listFrom<String, String>(
                                      source: options2,
                                      value: (i, v) => v,
                                      label: (i, v) => v,
                                      tooltip: (i, v) => v,
                                    ),
                                    choiceCheckmark: false,
                                    choiceStyle: C2ChipStyle.filled(),
                                  ),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  ChipsChoice<String>.multiple(
                                    wrapped: true,
                                    padding: EdgeInsets.symmetric(vertical: 40),
                                    value: tags,
                                    onChanged: (value) {
                                      print(value);
                                      setState(() {
                                        tags = value;
                                        var diaryForm;
                                        diaryForm['stamps'] = tags;
                                      });
                                    },

                                    choiceItems: C2Choice.listFrom<String, String>(
                                      source: options3,
                                      value: (i, v) => v,
                                      label: (i, v) => v,
                                      tooltip: (i, v) => v,
                                    ),
                                    choiceCheckmark: false,
                                    choiceStyle: C2ChipStyle.filled(),
                                  ),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  ChipsChoice<String>.multiple(
                                    wrapped: true,
                                    padding: EdgeInsets.symmetric(vertical: 40),
                                    value: tags,
                                    onChanged: (value) {
                                      print(value);
                                      setState(() {
                                        tags = value;
                                        var diaryForm;
                                        diaryForm['stamps'] = tags;
                                      });
                                    },

                                    choiceItems: C2Choice.listFrom<String, String>(
                                      source: options4,
                                      value: (i, v) => v,
                                      label: (i, v) => v,
                                      tooltip: (i, v) => v,
                                    ),
                                    choiceCheckmark: false,
                                    choiceStyle: C2ChipStyle.filled(),
                                  ),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  ChipsChoice<String>.multiple(
                                    wrapped: true,
                                    padding: EdgeInsets.symmetric(vertical: 40),
                                    value: tags,
                                    onChanged: (value) {
                                      print(value);
                                      setState(() {
                                        tags = value;
                                        var diaryForm;
                                        diaryForm['stamps'] = tags;
                                      });
                                    },

                                    choiceItems: C2Choice.listFrom<String, String>(
                                      source: options5,
                                      value: (i, v) => v,
                                      label: (i, v) => v,
                                      tooltip: (i, v) => v,
                                    ),
                                    choiceCheckmark: false,
                                    choiceStyle: C2ChipStyle.filled(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ]),
                ),
              ),
            );
          }),
        ),
      );
    },
  );
}
