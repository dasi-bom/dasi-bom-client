import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:like_button/like_button.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Seeing extends StatefulWidget {
  final dynamic routeparam;

  // 서버에서 정보 받아올 때 변수 선언
  // final String userImage;
  // final String userName;
  // final List<String> images;
  // final int countLikes; // 좋아요 수
  // final int countComment; //댓글 수
  // const Feed(
  //     {super.key,
  //       required this.userImage,
  //       required this.userName,
  //       required this.images,
  //       required this.countLikes,
  //       required this.countComment});

  const Seeing({Key? key, required this.routeparam}) : super(key: key);

  @override
  State<Seeing> createState() => _SeeingState();
}

class _SeeingState extends State<Seeing> {
  // 일기 이미지 인덱스
  int _current = 0;

  // Textformfield 값 받아오기
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late bool validationResult;
  String _comments = ''; // 댓글달기

  var formData = {};
  final TextEditingController _commentsController = TextEditingController();

  final GlobalKey commentsHeaderKey = GlobalKey();
  double commentsHeaderHeight = 0;

  DateTime date = DateTime.now();

  @override
  void initState() {
    validationResult = false;
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Sets initial size of comments bottom sheet. Thanks to it users always see just a header of the bottom sheet at the beginning.
      final double currentCommentsHeaderHeight =
          commentsHeaderKey.currentContext?.size?.height ?? 0;
      if (currentCommentsHeaderHeight != commentsHeaderHeight) {
        setState(() {
          commentsHeaderHeight = currentCommentsHeaderHeight;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return SafeArea(
      key: scaffoldKey,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _header(), // 헤더 사용자 정보
              _images(), // 일기 사진
              _comment(), // 일기 내용
              _options(), // 댓글, 쓰다듬기, 공유하기
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //두개의 위젯을 서로 붙이려면 Row 내부에서 Row로 묶으면 됨.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 프로필 사진
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage('assets/user1.png'),
              ),
            ),
            // 프로필 이름 & 작성 시간
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '카야',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    date.toString().split(" ")[0],
                  ),
                ),
              ],
            ),
          ],
        ),
        // 더보기 버튼
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            child: Image.asset('assets/ic_more.png'),
            onTap: () {
              _moreBottomSheet();
            },
          ),
        ),
      ],
    );
  }

  Widget _images() {
    return CarouselSlider.builder(
        //이미지 갯수
        itemCount: 1,
        //   itemCount: widget.images.length,
        //이미지 빌더
        itemBuilder: (context, index, realIndex) {
          return Container(
            color: Colors.black,
            width: 500,
            height: 500,
            child: Image.asset(
              'assets/dog.jpg',
              fit: BoxFit.cover,
            ),
            // child: CachedNetworkImage(
            //   //인덱스에 해당하는 이미지 로드
            //   imageUrl: widget.images[index],
            //   fit: BoxFit.cover,
            // ),
          );
        },
        // carousel_slider 옵션 정의
        options: CarouselOptions(
          //무한대로 스크롤 되는 지
          enableInfiniteScroll: true,
          //가로세로 비율 정의
          aspectRatio: 1,
          //Fraction 비율 정의
          viewportFraction: 1,
          onPageChanged: (index, reason) {
            setState(() {
              //인덱스 갱신
              _current = index;
            });
          },
        ));
  }

  Widget _comment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 쓰다듬기 count
        GestureDetector(
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16, top: 10, bottom: 10),
                child: Text(
                  '123',
                  // '좋아요 ${widget.countLikes}개',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Text(
                  '번 쓰다듬었어요!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          onTap: () {
            _likeBottomSheet();
          },
        ),
        // 본문 내용
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: ExpandableText(
            // 피드 내용
            '카야랑 오늘은 한강을 따라 산책을 갔다.\n흙냄새가 좋은지..마구 달리던 카야\n너무 귀여웠다.\n오늘의 산책 완료!',
            expandText: '더보기', //더보기 글자
            linkColor: Colors.grey, //더보기 글자 색 지정
            prefixText: '글린다', // 작성자의 이름
            // 작성자의 이름 스타일
            prefixStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
        // 챌린지 주제
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Text(
            '[챌린지] 날도 좋은데, 기분 좋은 산책 일기',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        Divider(
            color: Colors.black.withOpacity(0.5), height: 2, thickness: 0.3),
      ],
    );
  }

  Widget _options() {
    const int numberOfLikes = 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // 쓰다듬기
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: GestureDetector(
                child: LikeButton(
                  size: 33,
                  animationDuration: Duration(milliseconds: 1000),
                  likeCount: numberOfLikes,
                  countPostion: CountPostion.right,
                  likeBuilder: (isTapped) {
                    return Image.asset('assets/ic_like.png',
                        color: isTapped ? Colors.red : Colors.black);
                  },
                ),
              ),
            ),
            // 댓글
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: GestureDetector(
                child: Image.asset('assets/ic_comment.png'),
                onTap: () {
                  _commentBottomSheet();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: const Text(
                '(10)',
              ),
            ),
          ],
        ),
        Row(
          children: [
            // 공유하기
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: GestureDetector(
                child: Image.asset('assets/ic_share.png'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 더보기 bottomsheet
  _moreBottomSheet() {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: OutlinedButton(
                  style: ButtonStyle(
                      side: MaterialStateProperty.all(const BorderSide(
                          color: Colors.black,
                          width: 1,
                          style: BorderStyle.solid))),
                  onPressed: () => {},
                  child: Image.asset('assets/ic_edit.png'),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: OutlinedButton(
                  style: ButtonStyle(
                      side: MaterialStateProperty.all(const BorderSide(
                          color: Colors.black,
                          width: 1,
                          style: BorderStyle.solid))),
                  onPressed: () => {},
                  child: Image.asset('assets/ic_delete.png'),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        );
      },
    );
  }

  // 쓰다듬기 bottomsheet
  _likeBottomSheet() {
    return showModalBottomSheet<dynamic>(
      backgroundColor: Colors.white,
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.1,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _LikesHeader(
                    key: commentsHeaderKey, scrollController: scrollController),
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16, top: 10, bottom: 10),
                      child: Text(
                        '123',
                        // '좋아요 ${widget.countLikes}개',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(
                        '번 쓰다듬었어요!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    itemCount: 30,
                    itemBuilder: (context, index) => Container(
                      color: index % 2 == 0
                          ? const Color(0xffffffff)
                          : const Color(0xffffffff),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage: AssetImage('assets/user2.png'),
                            ),
                          ),
                          Text('딩딩이'),
                          Padding(
                            padding:
                                const EdgeInsets.only(right: 16, left: 135),
                            child: SizedBox(
                              height: 40,
                              width: 100,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5))),
                                  backgroundColor: MaterialStateProperty.all(
                                      Color(0xFFFFED8E)),
                                ),
                                onPressed: () => setState(
                                  () async {},
                                ),
                                child: Text(
                                  "팔로우",
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }

  // 댓글 bottomsheet
  _commentBottomSheet() {
    const int numberOfLikes = 0;

    return showModalBottomSheet<dynamic>(
      backgroundColor: Colors.white,
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _CommentsHeader(
                    key: commentsHeaderKey, scrollController: scrollController),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    itemCount: 30,
                    itemBuilder: (context, index) => Container(
                      color: index % 2 == 0
                          ? const Color(0xffffffff)
                          : const Color(0xffffffff),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: CircleAvatar(
                              radius: 25,
                              backgroundImage: AssetImage('assets/user2.png'),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('딩딩이'),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      date.toString().split(" ")[0],
                                    ),
                                  ),
                                ],
                              ),
                              Text('카야 너무 귀여워요'),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextButton(
                                    child: Text(
                                      '답글달기',
                                      textAlign: TextAlign.left,
                                    ),
                                    onPressed: () {},
                                  ),
                                  TextButton(
                                    child: Text(
                                      '좋아요 12개',
                                      textAlign: TextAlign.left,
                                    ),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 100),
                            child: LikeButton(
                              size: 33,
                              animationDuration: Duration(milliseconds: 1000),
                              likeCount: numberOfLikes,
                              countPostion: CountPostion.bottom,
                              likeBuilder: (isTapped) {
                                return Icon(Icons.favorite_outlined,
                                    color:
                                        isTapped ? Colors.red : Colors.black);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Divider(
                    color: Colors.black.withOpacity(0.5),
                    height: 2,
                    thickness: 0.3),
                // 댓글 달기 영역
                Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Row(
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                        child: CircleAvatar(
                          radius: 15,
                          backgroundImage: AssetImage('assets/user2.png'),
                        ),
                        // child: ImageAvatar(
                        //   url:
                        //   'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTnnnObTCNg1QJoEd9Krwl3kSUnPYTZrxb5Ig&usqp=CAU',
                        //   type: AvatarType.BASIC,
                        // ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.5,
                        child: GestureDetector(
                          child: TextFormField(
                            maxLines: 1,
                            keyboardType: TextInputType.text,
                            autovalidateMode: AutovalidateMode.always,
                            decoration: InputDecoration(hintText: '댓글 달기...'),
                            onSaved: (value) {
                              setState(() {
                                _comments = value as String;
                                _commentsController.value =
                                    TextEditingValue(text: value);
                                formData['desc'] = value;
                              });
                            },
                            controller: _commentsController,
                          ),
                        ),
                      ),
                      // 댓글달기 업로드 버튼
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: IconButton(
                          onPressed: () => setState(
                            () {
                              validationResult =
                                  formKey.currentState?.validate() ?? false;
                              formKey.currentState!.save();
                              // registerPerProfile(formData);
                            },
                          ),
                          icon: Icon(Icons.arrow_upward),
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        );
      },
    );
  }
}

// 쓰다듬기 header
class _LikesHeader extends StatelessWidget {
  const _LikesHeader({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      controller: scrollController,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Image.asset('assets/ic_bottomsheetbar.png'),
          const SizedBox(height: 10),
          const Text(
            '쓰다듬은 사람',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 15),
          Divider(
              color: Colors.black.withOpacity(0.5), height: 2, thickness: 0.3),
        ],
      ),
    );
  }
}

// 댓글 header
class _CommentsHeader extends StatelessWidget {
  const _CommentsHeader({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      controller: scrollController,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Image.asset('assets/ic_bottomsheetbar.png'),
          const SizedBox(height: 10),
          const Text(
            '댓글',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 15),
          Divider(
              color: Colors.black.withOpacity(0.5), height: 2, thickness: 0.3),
        ],
      ),
    );
  }
}
