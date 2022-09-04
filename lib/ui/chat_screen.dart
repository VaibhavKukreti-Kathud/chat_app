import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:line_icons/line_icons.dart';
import 'package:olx_clone/auth/sign_in_screen.dart';
import 'package:olx_clone/constants.dart';
import 'package:olx_clone/models/message_model.dart';
import 'package:olx_clone/services/snackbar.dart';
import 'package:olx_clone/widgets/custom_app_bar.dart';
import 'package:olx_clone/widgets/custom_button.dart';
import 'package:olx_clone/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:show_up_animation/show_up_animation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/app_user_model.dart';
import '../provider/chat_provider.dart';
import '../services/auth_functions.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.chattingWith});
  final AppUser chattingWith;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  List<QueryDocumentSnapshot> listMessage = [];

  int _limit = 20;

  final int _limitIncrement = 20;

  String groupChatId = "";

  File? imageFile;

  bool isLoading = false;

  bool showSticker = false;

  String imageUrl = "";

  bool sendEnabled = false;

  final TextEditingController textEditingController = TextEditingController();

  final ScrollController listScrollController = ScrollController();

  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    setState(() {
      if (currentUserId.compareTo(widget.chattingWith.uid) > 0) {
        groupChatId = '$currentUserId-${widget.chattingWith.uid}';
      } else {
        groupChatId = '${widget.chattingWith.uid}-$currentUserId';
      }
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      readLocal();
    });
    listScrollController.addListener(_scrollListener);
  }

  _scrollListener() {
    if (!listScrollController.hasClients) return;
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange &&
        _limit <= listMessage.length) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void sendMessage(String content, int type) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      Provider.of<ChatProvider>(context, listen: false).sendMessage(
          content, type, groupChatId, currentUserId, widget.chattingWith.uid);
      if (listScrollController.hasClients) {
        listScrollController.animateTo(0,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    }
  }

  Widget buildItem(int index, DocumentSnapshot? document) {
    readLocal();
    if (document != null) {
      MessageChat messageChat = MessageChat.fromDocument(document);
      if (messageChat.uidFrom == currentUserId) {
        // Right (my message)
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            messageChat.type == TypeMessage.text
                // Text
                ? Container(
                    padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width / 1.35),
                    decoration: BoxDecoration(
                        color: kBGFieldColor,
                        borderRadius: BorderRadius.circular(kBorderRadius)),
                    margin: EdgeInsets.only(
                        bottom: isLastMessageRight(index) ? 20 : 10, right: 10),
                    child: Text(
                      messageChat.content,
                      style: TextStyle(color: kButtonPColor),
                    ),
                  )
                : messageChat.type == TypeMessage.image
                    // Image
                    ? Container(
                        margin: EdgeInsets.only(
                            bottom: isLastMessageRight(index) ? 20 : 10,
                            right: 10),
                        child: OutlinedButton(
                          onPressed: () {},
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                  EdgeInsets.all(0))),
                          child: Material(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            clipBehavior: Clip.hardEdge,
                            child: Image.network(
                              messageChat.content,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  decoration: BoxDecoration(
                                    color: kDiabledButtonColor,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                  width: 200,
                                  height: 200,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: kButtonPColor,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, object, stackTrace) {
                                return Material(
                                  child: Image.asset(
                                    'images/img_not_available.jpeg',
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                );
                              },
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                    // Sticker
                    : Container(
                        margin: EdgeInsets.only(
                            bottom: isLastMessageRight(index) ? 20 : 10,
                            right: 10),
                        child: Image.asset(
                          'images/${messageChat.content}.gif',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
          ],
        );
      } else {
        // Left (peer message)
        return Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  isLastMessageLeft(index)
                      ? Material(
                          borderRadius: BorderRadius.all(
                            Radius.circular(18),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Image.network(
                            widget.chattingWith.photoUrl ?? '',
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: kButtonPColor,
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, object, stackTrace) {
                              return const Icon(Icons.account_circle,
                                  size: 35, color: kBGFieldColor);
                            },
                            width: 35,
                            height: 35,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(width: 35),
                  messageChat.type == TypeMessage.text
                      ? Container(
                          padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width / 1.35),
                          decoration: BoxDecoration(
                              color: kButtonPColor,
                              borderRadius:
                                  BorderRadius.circular(kBorderRadius)),
                          margin: EdgeInsets.only(left: 10),
                          child: Text(
                            messageChat.content,
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : messageChat.type == TypeMessage.image
                          ? Container(
                              margin: EdgeInsets.only(left: 10),
                              child: TextButton(
                                onPressed: () {},
                                style: ButtonStyle(
                                    padding:
                                        MaterialStateProperty.all<EdgeInsets>(
                                            EdgeInsets.all(0))),
                                child: Material(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  clipBehavior: Clip.hardEdge,
                                  child: Image.network(
                                    messageChat.content,
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        decoration: const BoxDecoration(
                                          color: kBGFieldColor,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8),
                                          ),
                                        ),
                                        width: 200,
                                        height: 200,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: kButtonPColor,
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, object, stackTrace) =>
                                            Material(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: Image.asset(
                                        'images/img_not_available.jpeg',
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              margin: EdgeInsets.only(
                                  bottom: isLastMessageRight(index) ? 20 : 10,
                                  right: 10),
                              child: Image.asset(
                                'images/${messageChat.content}.gif',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                ],
              ),

              // Time
              isLastMessageLeft(index)
                  ? Container(
                      margin: EdgeInsets.only(left: 50, top: 5, bottom: 5),
                      child: Text(
                        '',
                        style: TextStyle(
                            color: kBGFieldColor,
                            fontSize: 12,
                            fontStyle: FontStyle.italic),
                      ),
                    )
                  : SizedBox.shrink()
            ],
          ),
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage[index - 1].get(FirestoreConstants.UID_FROM) ==
                currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage[index - 1].get(FirestoreConstants.UID_FROM) !=
                currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  void readLocal() {
    ChatProvider chatProvider = ChatProvider(
        firebaseFirestore: FirebaseFirestore.instance,
        prefs: Provider.of<SharedPreferences>(context, listen: false));

    String peerId = widget.chattingWith.uid;
    if (currentUserId.compareTo(peerId) > 0) {
      groupChatId = '$currentUserId-$peerId';
    } else {
      groupChatId = '$peerId-$currentUserId';
    }

    chatProvider.updateDataFirestore(
      FirestoreConstants.USER_COLLECTION,
      currentUserId,
      {FirestoreConstants.CHATTING_WITH: peerId},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: CustomAppBar(title: widget.chattingWith.username),
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () => Future.value(true),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Column(
                children: <Widget>[
                  // List of messages
                  buildListMessage(ChatProvider(
                      firebaseFirestore: FirebaseFirestore.instance,
                      prefs: Provider.of<SharedPreferences>(context))),

                  // Input content
                  buildInput(),
                ],
              ),
              IgnorePointer(
                child: Container(
                  height: 16,
                  margin: EdgeInsets.only(bottom: 71),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        kBackgroundColor,
                        kBackgroundColor.withOpacity(0)
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInput() {
    return Container(
      width: double.infinity,
      height: 72,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        children: <Widget>[
          // Edit text
          Flexible(
            child: CustomField(
              onEdit: (v) {
                setState(() {
                  sendEnabled = v.toString().trim() == '' ? false : true;
                });
              },
              hintText: 'Type message here',
              controller: textEditingController,
            ),
          ),
          SizedBox(width: 8),
          SizedBox(
            width: 56,
            height: 56,
            child: CustomButton(
              onPressed: () {},
              icon: Icon(
                Icons.add,
                size: 25,
                color: kBackgroundColor,
              ),
            ),
          ),
          SizedBox(width: 8),
          SizedBox(
            width: 56,
            height: 56,
            child: CustomButton(
              disabled: !sendEnabled,
              onPressed: () {
                sendMessage(textEditingController.text, 0);
              },
              icon: Icon(
                Icons.send,
                color: kBackgroundColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildListMessage(ChatProvider chatProvider) {
    return Flexible(
      child: groupChatId.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
              stream: chatProvider.getChatStream(groupChatId, _limit),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  listMessage = snapshot.data!.docs;
                  if (listMessage.length > 0) {
                    return ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        int delay = 75 * index;
                        return ShowUpAnimation(
                            offset: 0.1,
                            delayStart: Duration(
                                milliseconds: delay > 1000 ? 20 : delay),
                            animationDuration: Duration(milliseconds: 500),
                            direction: Direction.horizontal,
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: buildItem(
                                    index, snapshot.data?.docs[index])));
                      },
                      itemCount: snapshot.data?.docs.length,
                      reverse: true,
                      controller: listScrollController,
                    );
                  } else {
                    return ShowUpAnimation(
                      offset: 0.1,
                      animationDuration: Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              height: MediaQuery.of(context).size.width / 1.5,
                              child: SvgPicture.asset('assets/begin_chat.svg')),
                          SizedBox(height: 20),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 1.5,
                            child: Text(
                              'Say hi to ' + widget.chattingWith.username + '!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.4),
                                  fontSize: 14),
                            ),
                          )
                        ],
                      ),
                    );
                  }
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      color: kButtonPColor,
                    ),
                  );
                }
              },
            )
          : Center(
              child: CircularProgressIndicator(
                color: kButtonPColor,
              ),
            ),
    );
  }
}

class ChatPageArguments {
  final String peerId;
  final String peerAvatar;
  final String peerNickname;

  ChatPageArguments(
      {required this.peerId,
      required this.peerAvatar,
      required this.peerNickname});
}
