import 'package:dasi_bom_client/profile/register_finish.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remedi_kopo/remedi_kopo.dart';
import 'package:dasi_bom_client/profile/profile_register_ani.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class RegisterProfileProtector extends StatefulWidget {
  const RegisterProfileProtector({Key? key}) : super(key: key);

  @override
  State<RegisterProfileProtector> createState() =>
      _RegisterProfileProtectorState();
}

class _RegisterProfileProtectorState extends State<RegisterProfileProtector> {
  final storage = FlutterSecureStorage();
  final baseUrl = dotenv.env['BASE_URL'].toString();
  final createUserProfile = dotenv.env['CREATE_USER_PROFILE_API'].toString();
  final uploadUserProfileImage =
      dotenv.env['UPLOAD_USER_PROFILE_IMAGE_API'].toString();

  // 프로필 이미지 받아오기
  XFile? _pickedFile; // 이미지를 담을 변수 선언
  CroppedFile? _croppedFile; // 크롭된 이미지 담을 변수 선언
  final List<XFile?> _pickedImages = []; // 이미지 여러개 담을 변수 선언
  final ImagePicker imagePicker = ImagePicker(); // ImagePicker 초기화

  var defaultImg = 'assets/ch_top_yellow.png';
  bool isDefault = false;
  bool isExist = false;

  // Textformfield 값 받아오기
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, String> formData = {};

  final TextEditingController _nicknameController = TextEditingController();

  late bool validationResult;
  String _nickname = ''; // 내 닉네임

  // String _times = ''; // 임시보호 횟수
  // String _address = ''; // 내 동네
  // 내 동네 카카오 API 값 컨트롤러
  // TextEditingController _AddressController = TextEditingController();

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
          elevation: 0.0,
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
          // form으로 input 데이터 저장
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: Color(0xffFFF5BF),
                  height: 110,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        SizedBox(
                          child: Image.asset('assets/ch_top_orange.png'),
                        ),
                        SizedBox(
                          child: Image.asset('assets/ic_balloon_pr.png'),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      '보호자 프로필',
                      textAlign: TextAlign.left,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      '내 프로필 사진',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
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
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                image: DecorationImage(
                                    image: FileImage(File(_pickedFile!.path)),
                                    fit: BoxFit.cover),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  _showBottomSheet();
                                },
                              ),
                            )
                          : Container(
                              width: _imageSize,
                              height: _imageSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    width: 2,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                image: DecorationImage(
                                    image: AssetImage(defaultImg),
                                    fit: BoxFit.contain),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  _showBottomSheet();
                                },
                              ),
                            )),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Text(
                          '내 닉네임',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 13),
                        ),
                        Text(
                          '*',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.normal,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                // 내 닉네임 등록
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: TextFormField(
                    maxLength: 14,
                    keyboardType: TextInputType.name,
                    inputFormatters: [
                      FilteringTextInputFormatter(
                        RegExp('[a-z A-Z ㄱ-ㅎ|가-힣| ·|： 0-9]'),
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
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.black,
                        ),
                        hintText: '영문/한글/숫자만 가능해요'),
                    onSaved: (value) {
                      setState(() {
                        _nickname = value as String;
                        _nicknameController.value =
                            TextEditingValue(text: value);
                        formData['nickname'] = value;
                      });
                    },
                    // 유효성 검사
                    validator: (value) {
                      if (value!.isEmpty) return '닉네임을 입력해 주세요.';
                      if (isExist == true) {
                        return '이미 사용중인 닉네임 입니다.';
                      }
                      if (value.toString().length <= 2)
                        return '닉네임은 두글자 이상 입력 해주셔야 합니다.';
                      return null;
                    },
                    controller: _nicknameController,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),

                // 내 동네 등록
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 16),
                //   child: SizedBox(
                //     width: double.infinity,
                //     child: Row(
                //       children: [
                //         Text(
                //           '내 동네',
                //           textAlign: TextAlign.left,
                //           style: TextStyle(
                //               fontWeight: FontWeight.normal, fontSize: 13),
                //         ),
                //         Text(
                //           '*',
                //           textAlign: TextAlign.left,
                //           style: TextStyle(
                //               color: Colors.orange,
                //               fontWeight: FontWeight.normal,
                //               fontSize: 13),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                // Padding(
                //   padding:
                //       const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                //   child: GestureDetector(
                //     onTap: () {
                //       HapticFeedback.mediumImpact();
                //       _addressAPI(); // 카카오 주소 API
                //     },
                //     child: TextFormField(
                //       enabled: false,
                //       autovalidateMode: AutovalidateMode.always,
                //       decoration: InputDecoration(
                //           isDense: false,
                //           border: OutlineInputBorder(
                //             borderSide: BorderSide(
                //               color: Colors.black,
                //             ),
                //           ),
                //           focusedBorder: OutlineInputBorder(
                //             borderSide: BorderSide(
                //               color: Colors.black,
                //               width: 1,
                //             ),
                //           ),
                //           prefixIcon: Icon(
                //             Icons.search,
                //             color: Colors.black,
                //           ),
                //           hintText: '주소 검색'),
                //       controller: _AddressController,
                //       style: TextStyle(fontSize: 15),
                //     ),
                //   ),
                // ),

                // 다음 단계로 이동하기
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 60,
                    width: double.infinity,
                    child: Container(
                      color: Colors.white,
                      margin: EdgeInsets.only(top: 20),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15))),
                          backgroundColor:
                              MaterialStateProperty.all(Color(0xFFFFED8E)),
                        ),
                        onPressed: () {
                          setState(
                            () async {
                              validationResult =
                                  formKey.currentState?.validate() ?? false;
                              formKey.currentState!.save();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$_nickname/')),
                              );

                              registerProtectorProfile(formData);
                            },
                          );
                        },
                        child: Text(
                          "다음 단계로 이동하기",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
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
      pageBuilder: (context, animation, secondaryAnimation) =>
          const RegisterFinish(),
          // const RegisterProfileAnimal(),
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
    final pickedFile = await imagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 30);
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
    final pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 30);
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
    final ByteData img = await rootBundle.load('assets/user_default.png');
    final List<int> bytes = img.buffer.asUint8List();
    uploadImage(bytes);

    setState(() {
      isDefault = true;
      _pickedFile = XFile('assets/user_default.png');
    });
  }

  // 카카오주소 API
  // _addressAPI() async {
  //   KopoModel model = await Navigator.push(
  //     context,
  //     CupertinoPageRoute(
  //       builder: (context) => RemediKopo(),
  //     ),
  //   );
  //
  //   _AddressController.text =
  //       '${model.sido!} ${model.sigungu!} ${model.bname!}';
  //
  //   final address = '${model.sido!} ${model.sigungu!} ${model.bname!}';
  //   _AddressController.value = TextEditingValue(text: address);
  //   formData['address'] = address;
  // }

  registerProtectorProfile(data) async {
    try {
      final accessToken = await storage.read(key: 'accessToken');
      final url = Uri.parse('$baseUrl$createUserProfile');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };

      final nickname = data['nickname'];
      final body = jsonEncode({'nickname': nickname});

      final res = await http.put(url, headers: headers, body: body);
      final status = res.statusCode;
      print('${res.request}  =>  $status');

      if (status == 200) {
        await Navigator.of(context).push(_createRoute());
      } else if (status == 201) {
        await Navigator.of(context).push(_createRoute());
      } else if (status == 302) {
        print('fail_1 => $status');
        await storage.deleteAll();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('로그인을 다시 해주세요.')));
        await Navigator.pushNamed(context, '/login');
      } else if (status == 403) {
        print('fail_2 => $status');
        await storage.deleteAll();
        await Navigator.pushNamed(context, '/login');
      } else {
        print('fail_3 => $status');
        print(jsonDecode(res.body));
        setState(() {
          setState(() {
            isExist = true;
          });
        });
      }

      return res;
    } catch (err) {
      print('error => ${err}');
    }
  }

  uploadImage(image) async {
    try {
      final accessToken = await storage.read(key: 'accessToken');
      final url = Uri.parse('$baseUrl$uploadUserProfileImage');
      final headers = {
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $accessToken'
      };

      var request = http.MultipartRequest('POST', url);
      if (image is List<int>) {
        // 기본 이미지
        request.files.add(http.MultipartFile.fromBytes('multipartFile', image,
            filename: 'default.png'));
      } else {
        // 갤러리
        request.files
            .add(await http.MultipartFile.fromPath('multipartFile', image));
      }

      request.headers.addAll(headers);

      var response = await request.send();
      print(response.statusCode);
    } catch (err) {
      print('err =>  $err');
    }
  }
}
