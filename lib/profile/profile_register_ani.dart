import 'dart:ffi';
import 'package:dasi_bom_client/provider/user_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dasi_bom_client/profile/register_finish.dart';
import '../MainPage.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RegisterProfileAnimal extends StatefulWidget {
  const RegisterProfileAnimal({Key? key}) : super(key: key);

  @override
  State<RegisterProfileAnimal> createState() => _RegisterProfileAnimalState();
}

class _RegisterProfileAnimalState extends State<RegisterProfileAnimal> {
  final storage = FlutterSecureStorage();
  final baseUrl = dotenv.env['BASE_URL'].toString();
  final createPetProfile = dotenv.env['CREATE_PET_PROFILE_API'].toString();
  final uploadPetProfileImage =
      dotenv.env['UPLOAD_PET_PROFILE_IMAGE_API'].toString();

  // 프로필 이미지 받아오기
  XFile? _pickedFile; // 이미지를 담을 변수 선언
  final List<XFile?> _pickedImages = []; // 이미지 여러개 담을 변수 선언
  final ImagePicker imagePicker = ImagePicker(); // ImagePicker 초기화

  var defaultImg = 'assets/ch_top_yellow.png';
  bool isDefault = false;

  // Textformfield 값 받아오기
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late bool validationResult;
  String _name = ''; // 이름
  String _age = ''; // 나이
  String _intro = ''; // 소개
  String _kindinput = ''; // 종

  var formData = {};
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _startDtController = TextEditingController();
  final TextEditingController _introController = TextEditingController();

  // 이름 정규식
  final Pattern _validateName = RegExp('[a-z A-Z ㄱ-ㅎ|가-힣| ·|： ᆞ|ᆢ]');

  // 종류 콤보박스
  final _animals = ['강아지', '고양이', '염소', '여우', '기타', '직접 입력'];
  var _selectedValue = '강아지';

  // 성별 콤보박스
  final _kind = ['남', '여'];
  var _selectedKind = '남';

  // 처음 만난 날 변수 선언
  DateTime date = DateTime.now();

  uploadImage(image) async {
    try {
      var petId;

      final accessToken = await storage.read(key: 'accessToken');
      final url = Uri.parse('$baseUrl$uploadPetProfileImage?petId=$petId');
      final headers = {
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $accessToken'
      };

      final req = http.MultipartRequest('POST', url);
      if (image is List<int>) {
        // 기본 이미지
        req.files.add(http.MultipartFile.fromBytes('multipartFile', image,
            filename: 'default.png'));
      } else {
        // 갤러리
        req.files
            .add(await http.MultipartFile.fromPath('multipartFile', image));
      }

      req.headers.addAll(headers);

      final res = await req.send();
      final status = res.statusCode;
      print('${res.request}  =>  $status');
    } catch (err) {
      print('err =>  $err');
    }
  }

  registerPerProfile(data) async {
    try {
      final accessToken = await storage.read(key: 'accessToken');
      final url = Uri.parse('$baseUrl$createPetProfile');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };

      var typeFormat;
      if (data['type'] == null || data['type'] == '강아지') {
        typeFormat = 'DOG';
      } else if (data['type'] == '고양이') {
        typeFormat = 'CAT';
      } else if (data['type'] == '염소') {
        typeFormat = 'GOAT';
      } else if (data['type'] == '여우') {
        typeFormat = 'FOX';
      } else {
        typeFormat = 'ETC';
      }

      var genderFormat;
      if ((data['gender'] == null) || (data['gender'] == '남')) {
        genderFormat = 'MALE';
      } else {
        genderFormat = 'FEMALE';
      }

      var startDtFormat;
      if (data['startDt'] != null) {
        startDtFormat = data['startDt'].substring(0, 10);
      } else {
        startDtFormat = DateTime.now().toString().substring(0, 10);
      }

      final age = data['age'] != '' ? int.parse(data['age']) : 1;
      final type = typeFormat;
      final gender = genderFormat;
      final startDt = startDtFormat;
      final desc = data['desc'] ?? ' ';

      final body = jsonEncode({
        'name': data['name'],
        'age': age,
        'type': type,
        'sex': gender,
        'startTempProtectedDate': startDt,
        'bio': desc
      });
      print('body =>  $body');

      final res = await http.post(url, headers: headers, body: body);
      final status = res.statusCode;
      final info = res.body;
      print('${res.request}  =>  $status');

      if (status == 200) {
        await Navigator.of(context).push(_createRoute(null));
      } else if (status == 201) {
        await Navigator.of(context).push(_createRoute(info));
      } else if (status == 302) {
        print('fail_1 => $status');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('로그인을 다시 해주세요.')));
        await Navigator.pushNamed(context, '/login');
      } else if (status == 403) {
        print('fail_2 => $status');
        await storage.deleteAll();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('관리자에게 문의해 주세요.')));
        await Navigator.pushNamed(context, '/login');
      } else {
        print('fail_3 => $status');
        print(status);
        print(jsonDecode(res.body));
      }

      return res;
    } catch (err) {
      print(err);
    }
  }

  @override
  void initState() {
    validationResult = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _imageSize = MediaQuery.of(context).size.width / 4;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          title: const Text(
            '프로필 등록하기',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        body: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: Color(0xffFFF5BF),
                  height: 110,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      SizedBox(
                        child: Image.asset('assets/ch_top_orange.png'),
                      ),
                      SizedBox(
                        child: Image.asset('assets/ic_balloon_an.png'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  width: 300,
                  child: Text(
                    '함께하는 동물 친구 프로필',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                // 사진 등록
                if (_pickedFile == null)
                  Container(
                    constraints: BoxConstraints(
                      minHeight: _imageSize,
                      minWidth: _imageSize,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        _showBottomSheet();
                      },
                      child: Center(
                        child: Image.asset('assets/img_register.png'),
                      ),
                    ),
                  )
                else
                  Center(
                      child: isDefault == false
                          ? Container(
                              width: _imageSize,
                              height: _imageSize,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      width: 2,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  image: DecorationImage(
                                      image: FileImage(File(_pickedFile!.path)),
                                      fit: BoxFit.cover)))
                          : Container(
                              width: _imageSize,
                              height: _imageSize,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      width: 2,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  image: DecorationImage(
                                    image: AssetImage(defaultImg),
                                    fit: BoxFit.contain,
                                  )),
                            )),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: 340,
                  child: Text(
                    '이름 *',
                    textAlign: TextAlign.left,
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
                  ),
                ),
                // 이름 등록 - 30자 이내, 영문/한글만 가능
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: TextFormField(
                    maxLength: 30,
                    keyboardType: TextInputType.name,
                    inputFormatters: [
                      FilteringTextInputFormatter(
                        _validateName,
                        allow: true,
                      )
                    ],
                    autovalidateMode: AutovalidateMode.always,
                    decoration: InputDecoration(
                        // counterText: '',
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
                        prefixIcon: Icon(
                          Icons.star,
                          color: Colors.black,
                        ),
                        hintText: '동물의 애칭을 적어주세요.'),
                    // onChanged: (value) {
                    //   print(value);
                    // },
                    onSaved: (value) {
                      setState(() {
                        _name = value as String;
                        _nameController.value = TextEditingValue(text: value);
                        formData['name'] = value;
                      });

                      // context.read<UserStore>().setName(
                      //     value.toString()); // UserStore에 있는 animalName 핸들링
                      // print(context
                      //     .read<UserStore>()
                      //     .animalName); // UserStore에 있는 animalName에 접근
                    },
                    controller: _nameController,
                    // 유효성 검사
                    validator: (value) {
                      if (value?.isEmpty ?? true) return '이름을 입력해 주세요.';
                      if (value.toString().length <= 1)
                        return '이름은 한글자 이상 입력 해주셔야 합니다.';
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  width: 340,
                  child: Text(
                    '나이',
                    textAlign: TextAlign.left,
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
                  ),
                ),
                // 나이 등록
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    autovalidateMode: AutovalidateMode.always,
                    decoration: InputDecoration(
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
                        hintText: '1(모르실 경우 비워두셔도 좋아요!)'),
                    onSaved: (value) {
                      setState(() {
                        _age = value as String;
                        _ageController.value = TextEditingValue(text: value);
                        formData['age'] = value;
                      });
                    },
                    controller: _ageController,
                  ),
                ),
                Container(
                  width: 340,
                  child: Text(
                    '연 단위로 입력해 주세요. 12개월 미만의 친구들은 1을 입력해 주세요.',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 11),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  width: 340,
                  child: Text(
                    '종류 *',
                    textAlign: TextAlign.left,
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
                  ),
                ),
                // 종류 등록
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
                  child: DropdownButtonFormField(
                    hint: Text('동물 친구의 종은 무엇인가요?'),
                    value: _selectedValue,
                    items: _animals.map(
                      (value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      },
                    ).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedValue = value!;
                        if (value != '직접 입력') {
                          _typeController.value = TextEditingValue(text: value);
                          formData['type'] = value;
                        } else {
                          _typeController.value = TextEditingValue(text: '');
                          formData['type'] = '';
                        }
                      });
                    },
                  ),
                ),
                // 종류 직접 입력시 등록(직접 입력 시에만 뜨도록 구현해야 합니다!)
                if (_selectedValue == '직접 입력')
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: TextFormField(
                      maxLength: 10,
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        FilteringTextInputFormatter(
                          RegExp('[a-z A-Z ㄱ-ㅎ|가-힣| ·|：]'),
                          allow: true,
                        )
                      ],
                      autovalidateMode: AutovalidateMode.always,
                      decoration: InputDecoration(
                          counterText: '',
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
                          hintText: '동물의 종을 적어주세요.'),
                      onSaved: (value) {
                        setState(() {
                          _kindinput = value as String;
                          _typeController.value = TextEditingValue(text: value);
                          formData['type'] = value;
                        });
                      },
                      controller: _typeController,
                    ),
                  ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  width: 340,
                  child: Text(
                    '성별 *',
                    textAlign: TextAlign.left,
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
                  ),
                ),
                // 성별 등록
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
                  child: DropdownButtonFormField(
                    hint: Text('동물 친구의 성은 무엇인가요?'),
                    value: _selectedKind,
                    items: _kind.map(
                      (value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      },
                    ).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedKind = value!;
                        _genderController.value =
                            TextEditingValue(text: value == '' ? '남' : value);
                        formData['gender'] = value == '' ? '남' : value;
                      });
                    },
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  width: 340,
                  child: Text(
                    '처음 만난 날 *',
                    textAlign: TextAlign.left,
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
                  ),
                ),
                // 처음 만난 날 등록
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: date,
                            firstDate: DateTime(1990),
                            lastDate: DateTime.now(),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              date = selectedDate;
                              _startDtController.value = TextEditingValue(
                                  text: selectedDate.toString());
                              formData['startDt'] = selectedDate.toString();
                            });
                          } else {
                            formData['startDt'] = DateTime.now().toString();
                          }
                        },
                        child: Text("날짜 선택"),
                      ),
                      Text(
                        date != null
                            ? date.toString().split(" ")[0]
                            : "날짜가 아직 선택되지 않았습니다.",
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  width: 340,
                  child: Text(
                    '소개',
                    textAlign: TextAlign.left,
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
                  ),
                ),
                // 소개 등록
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: TextFormField(
                    maxLines: 6,
                    maxLength: 300,
                    keyboardType: TextInputType.text,
                    autovalidateMode: AutovalidateMode.always,
                    decoration: InputDecoration(
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
                        hintText: '외적인 특징이나 좋아하는 것, 성격, 별명 등을 자유롭게 소개해 주세요:)'),
                    onSaved: (value) {
                      setState(() {
                        _intro = value as String;
                        _introController.value = TextEditingValue(text: value);
                        formData['desc'] = value;
                      });
                    },
                    controller: _introController,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: 340,
                  child: Text(
                    '동물 프로필은 마이페이지에서 추가로 등록할 수 있습니다!',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                // 등록 완료하기
                // Text(validationResult ? 'Success' : 'Failed'),
                SizedBox(
                  height: 60,
                  width: 350,
                  child: Container(
                    height: 30,
                    color: Colors.white,
                    margin: EdgeInsets.only(top: 20),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                        backgroundColor:
                            MaterialStateProperty.all(Color(0xFFFFED8E)),
                      ),
                      onPressed: () => setState(
                        () {
                          validationResult =
                              formKey.currentState?.validate() ?? false;
                          formKey.currentState!.save();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    context.read<UserStore>().animalName +
                                        '/' +
                                        _age +
                                        '/' +
                                        _selectedKind +
                                        '/' +
                                        _selectedValue +
                                        '/' +
                                        _intro)),
                          );

                          registerPerProfile(formData);

                          // 홈 화면으로 이동
                          // final result =
                          //     await Navigator.of(context).push(_createRoute());
                        },
                      ),
                      child: Text(
                        "등록 완료하기",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                // 나중에 등록하기
                SizedBox(
                  height: 60,
                  width: 350,
                  child: Container(
                    height: 30,
                    color: Colors.white,
                    margin: EdgeInsets.only(top: 20),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                        backgroundColor:
                            MaterialStateProperty.all(Color(0xFFF8F8F9)),
                      ),
                      onPressed: () async {
                        // 홈 화면으로 이동
                        final result = await Navigator.of(context)
                            .push(_createRoute(null));
                      },
                      child: Text(
                        "나중에 등록하기",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 페이지 전환 애니메이션
  Route _createRoute(petInfo) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          RegisterFinish(data: petInfo),
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
            const Divider(
              thickness: 3,
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                _getDefaultImage();
                setState(() {
                  isDefault = true;
                });
              },
              child: const Text('기본이미지'),
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
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        isDefault = false;
        _pickedFile = pickedFile;
      });
    } else {
      if (kDebugMode) {
        print('이미지 선택안함');
      }
    }
  }

// 갤러리로 이동
  _getPhotoLibraryImage() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        isDefault = false;
        _pickedFile = pickedFile;
      });

      if (_pickedFile != null) {
        uploadImage(_pickedFile!.path);
      }
    } else {
      if (kDebugMode) {
        print('이미지 선택안함');
      }
    }
  }

// 기본이미지 설정
  _getDefaultImage() async {
    final ByteData img = await rootBundle.load('assets/pet_default.png');
    final List<int> bytes = img.buffer.asUint8List();
    uploadImage(bytes);

    setState(() {
      isDefault = true;
      _pickedFile = XFile('assets/pet_default.png');
    });
  }
}
