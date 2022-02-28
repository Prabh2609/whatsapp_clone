import 'dart:collection';
import 'dart:typed_data';

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'dart:convert';
import 'dart:math';
import 'package:image_picker/image_picker.dart';

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class ChatWindow extends StatefulWidget {
  final Contact contact;
  final String title;
  final String profile_pic;
  final String contact_number;

  const ChatWindow({Key? key,required this.contact, required this.title,required this.profile_pic,required this.contact_number}) : super(key: key);

  @override
  _ChatWindowState createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> {
  int triedCombinations = 0;
  types.User _user = const types.User(id: 'null');
  late String roomKey ;
  late User currentUser ;

  List<types.Message> _messages = [];
  // final _user = const types.User(id: '06c33e8b-e835-4736-80f4-63f44b66666c');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // print(widget.contact);
    FirebaseAuth.instance
        .authStateChanges()
        .listen((User? user) {
            if(user!= null){
              setState(() {
                _user = types.User(
                  id: user.uid
                );
                currentUser = user;
              });
              _getRoomKey();
            }
    });

  }

  Future<void> _getRoomKey()async{
    DatabaseReference inboxRef = FirebaseDatabase.instance.ref('inbox/${currentUser.uid}/${widget.contact_number}');
    String getRoomKey = await inboxRef.child("roomKey").get().then((DataSnapshot snapshot) => snapshot.value.toString());

    if(getRoomKey == "null"){
      // FIRST TIME USER , LETS CREATE ONE ROOM KEY
      setState(() {
        roomKey = (widget.contact.phones!.elementAt(0).value!+currentUser.phoneNumber!).hashCode.toString();
      });
    }else{
      // print("OLD CHAT with room key : ${getRoomKey}");
      setState(() {
        roomKey = getRoomKey;
      });

    //  ROOM ALREADY EXISTS
    }
    _readMessages(roomKey);
  }

  Future<void> _readMessages(String key)async{
    DatabaseReference databaseReference= FirebaseDatabase.instance.ref("rooms/$key");
    databaseReference.get().then((DataSnapshot snapshot) {
      if(snapshot.exists){
        databaseReference.onValue.listen((DatabaseEvent event) {
          final data = event.snapshot.children;
          List<types.TextMessage> messages = [];
          data.forEach((element) {
            var message;
            HashMap<String,dynamic> obj = new HashMap();
            element.children.forEach((msg) {
              obj.putIfAbsent(msg.key.toString(), () => msg.value);

            });
            print(obj["author"]["id"]);
            message = types.TextMessage(
                text: obj["text"],
                author: types.User(
                    id:obj["author"]["id"]
                ),
                id: obj["id"],
                createdAt: obj["createdAt"]
            );
            if(!_messages.contains(message)){
              setState(() {
                _messages.insert(0, message);
              });
            }

          });
        });
      }
    });

  }
  String convertUint8ListToString(Uint8List uint8list) {
    return String.fromCharCodes(uint8list);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          leading: CircularProfileAvatar(
            '',
            radius: 20,
            backgroundColor: Colors.teal,
            borderWidth: 0,
            borderColor: Colors.teal,

            child: Image.network(widget.profile_pic),

          ),
          title: Text(widget.title),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.videocam)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.call)),
            PopupMenuButton(
              itemBuilder: (context)=>[
                const PopupMenuItem(
                    child:Text('View Contact'),
                    value:1 ,
                ),
                const PopupMenuItem(
                  child:Text('Media,links, and docs'),
                  value:2 ,
                ),
                const PopupMenuItem(
                  child:Text('Search'),
                  value:3,
                ),
                const PopupMenuItem(
                  child:Text('Mute Notification'),
                  value:4,
                ),
                const PopupMenuItem(
                  child:Text('Wallpaper'),
                  value:5,
                ),
                const PopupMenuItem(
                    child: Text('More'),
                    value:6
                )
              ],
            )
          ],
        ),
        body: SafeArea(
          bottom: false,
          child: Chat(
            theme: const DefaultChatTheme(
              inputBackgroundColor: Colors.grey,
              primaryColor: Colors.tealAccent,
              sendButtonIcon: Icon(Icons.send, color: Colors.white),
              messageBorderRadius: 8,
              messageInsetsVertical: 8,
              sentMessageBodyTextStyle: TextStyle(color: Colors.black),
              inputPadding: EdgeInsets.all(16),
              inputBorderRadius: BorderRadius.all(Radius.circular(32)),
              inputMargin: EdgeInsets.all(12),
              attachmentButtonIcon: Icon(Icons.attachment, color: Colors.white),
            ),
            messages: _messages,
            onAttachmentPressed: _handleAttachmentPressed,
            onSendPressed:_handleSendPressed,
            user: _user,
          ),
        ));
  }

  void _addMessage(types.Message message) async{
    print("Room Key : ${roomKey}");
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref('rooms');
    DatabaseReference inboxSender = FirebaseDatabase.instance.ref('inbox/${currentUser.uid}');

    // String recieverID = await FirebaseFirestore.instance.collection("Users").where()


    DatabaseReference inboxReceiver = FirebaseDatabase.instance.ref('inbox/${widget.contact.identifier}');
    print("IDENTIFIER : ${widget.contact.identifier}");
    inboxReceiver.child(currentUser.phoneNumber!.replaceAll("+91", "")).set({
      "timeStamp":ServerValue.timestamp,
      "contact_no":currentUser.phoneNumber!.replaceAll("+91", ""),
      'recentMessage':message.type.toString() == "MessageType.text"?message.toJson()["text"]:message.type.toString(),
      'profile_pic':currentUser.photoURL,
      'receiverId':currentUser.uid,
      "roomKey":roomKey
    }).then((value) => print("Sender updated"));

    print(message.toJson()["text"]);
    print('hi');

    databaseReference.child(roomKey).push().set(message.toJson());
    inboxSender.child(widget.contact_number).set({
      "timeStamp":ServerValue.timestamp,
      "contact_no":widget.contact_number,
      'recentMessage':message.type.toString() == "MessageType.text"?message.toJson()["text"]:message.type.toString(),
      'profile_pic':widget.profile_pic,
      'receiverId':widget.contact.identifier,
       "roomKey":roomKey
    }).then((value) => print("Receiver updated"));
    if(_messages.isEmpty){
      _readMessages(roomKey);
    }
  }

  void _handleFileSelection(){

  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context){
          return SafeArea(
              child: SizedBox(
                height:144,
                child: Column(
                  children: <Widget>[
                    TextButton(
                        onPressed: (){
                          Navigator.pop(context);
                          _handleImageSelection();
                        },
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Photo'),
                        )
                    ),
                    TextButton(
                        onPressed: (){
                          Navigator.pop(context);
                          _handleFileSelection();
                        },
                        child: const Align(
                          alignment:Alignment.centerLeft ,
                          child: Text('File'),
                        )
                    ),
                    TextButton(
                        onPressed: ()=>Navigator.pop(context),
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Cancel'),
                        )
                    )
                  ],
                ),
              )
          );
        }
    );
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
          author: _user,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          height: image.height.toDouble(),
          id: randomString(),
          name: result.name,
          size: bytes.length,
          uri: result.path,
          width: image.width.toDouble());
      // _addMessage(message);

      print(message);
    }
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: randomString(),
        text: message.text);
    _addMessage(textMessage);
  }
}
