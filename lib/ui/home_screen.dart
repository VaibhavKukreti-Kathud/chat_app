import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:olx_clone/constants.dart';
import 'package:olx_clone/models/app_user_model.dart';
import 'package:olx_clone/provider/home_provider.dart';
import 'package:olx_clone/services/auth_functions.dart';
import 'package:olx_clone/ui/chat_screen.dart';
import 'package:olx_clone/widgets/custom_app_bar.dart';
import 'package:olx_clone/widgets/custom_text_field.dart';

import '../utils/debouncer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  HomePageState({Key? key});

  final ScrollController listScrollController = ScrollController();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  int _limit = 20;
  final int _limitIncrement = 20;
  String _textSearch = "";
  late String currentUserId;
  StreamController<bool> btnClearController = StreamController<bool>();
  TextEditingController searchBarTec = TextEditingController();
  late HomeProvider homeProvider =
      HomeProvider(firebaseFirestore: FirebaseFirestore.instance);
  Debouncer searchDebouncer = Debouncer(milliseconds: 900);

  @override
  void initState() {
    super.initState();
    currentUserId = firebaseAuth.currentUser!.uid;
    listScrollController.addListener(scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
    btnClearController.close();
  }

  void scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  Future<bool> onBackPress() {
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: kBackgroundColor,
            systemNavigationBarColor: kBackgroundColor,
            systemNavigationBarContrastEnforced: false,
            systemStatusBarContrastEnforced: false),
        backgroundColor: kBackgroundColor,
        elevation: 0,
        toolbarHeight: 64,
        centerTitle: true,
        title: GestureDetector(
          onTap: () {
            firebaseAuth.signOut();
          },
          child: const CircleAvatar(
            backgroundColor: kDiabledButtonColor,
            child: Icon(
              LineIcons.user,
              size: 25,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: WillPopScope(
          onWillPop: onBackPress,
          child: Column(
            children: [
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CustomField(
                        controller: searchBarTec,
                        onEdit: (value) {
                          if (value.isNotEmpty) {
                            btnClearController.add(true);
                            setState(() {
                              _textSearch = value;
                            });
                          } else {
                            btnClearController.add(false);
                            setState(() {
                              _textSearch = "";
                            });
                          }
                        },
                        hintText: 'Search username',
                      ),
                    ),
                    StreamBuilder<bool>(
                        stream: btnClearController.stream,
                        builder: (context, snapshot) {
                          return snapshot.data == true
                              ? GestureDetector(
                                  onTap: () {
                                    searchBarTec.clear();
                                    btnClearController.add(false);
                                    setState(() {
                                      _textSearch = "";
                                    });
                                  },
                                  child: Container(
                                      height: 56,
                                      width: 56,
                                      margin: EdgeInsets.only(left: 8),
                                      decoration: BoxDecoration(
                                          color: kBGFieldColor,
                                          borderRadius: BorderRadius.circular(
                                              kBorderRadius)),
                                      child: LineIcon(
                                        Icons.close,
                                        size: 20,
                                        color: Colors.black.withOpacity(0.4),
                                      )),
                                )
                              : Container(
                                  height: 56,
                                  width: 56,
                                  margin: EdgeInsets.only(left: 8),
                                  decoration: BoxDecoration(
                                      color: kBGFieldColor,
                                      borderRadius:
                                          BorderRadius.circular(kBorderRadius)),
                                  child: LineIcon(
                                    LineIcons.search,
                                    size: 20,
                                    color: Colors.black.withOpacity(0.4),
                                  ));
                        }),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: homeProvider.getStreamFireStore(
                      FirestoreConstants.USER_COLLECTION, _limit, _textSearch),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      if ((snapshot.data!.docs.length - 1) > 0) {
                        return ListView.builder(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 15),
                          itemBuilder: (context, index) =>
                              buildItem(context, snapshot.data?.docs[index]),
                          itemCount: snapshot.data?.docs.length,
                          controller: listScrollController,
                        );
                      } else {
                        return const Center(
                          child: Text("No users"),
                        );
                      }
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: kButtonPColor,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot? document) {
    if (document != null) {
      AppUser appUser = AppUser.fromSnap(document);
      if (appUser.uid == currentUserId) {
        return const SizedBox();
      } else {
        return GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(chattingWith: appUser)));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(kBorderRadius),
                color: kButtonPColor,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 86,
              child: Row(
                children: <Widget>[
                  Material(
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    clipBehavior: Clip.hardEdge,
                    child: appUser.photoUrl != null
                        ? Image.network(
                            appUser.photoUrl!,
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return SizedBox(
                                width: 50,
                                height: 50,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: kButtonPColor,
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, object, stackTrace) {
                              return Icon(
                                Icons.account_circle,
                                size: 50,
                                color: Colors.black.withOpacity(0.15),
                              );
                            },
                          )
                        : Icon(
                            LineIcons.user,
                            size: 50,
                            color: Colors.black.withOpacity(0.15),
                          ),
                  ),
                  Flexible(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${appUser.username}',
                            maxLines: 1,
                            style: TextStyle(
                              color: Colors.white.withOpacity(1),
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'ha bhai bilkul theek thaak tu bata tu kaisa hai',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }
}
