import 'dart:collection';

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
  const ChatWindow({Key? key,required this.contact}) : super(key: key);

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
                roomKey = (widget.contact.phones!.elementAt(0).value!+currentUser.phoneNumber!).hashCode.toString();
              });
              _readMessages(roomKey);
            }
    });

  }

  Future<void> _readMessages(String key)async{
    DatabaseReference databaseReference= FirebaseDatabase.instance.ref("rooms/$key");
    print('inside read messages');
    databaseReference.get().then((DataSnapshot snapshot){
      triedCombinations++;
      print('getting values');
      if(!snapshot.exists ){
        //try different Id
        if(triedCombinations<=2){
          String roomId = (currentUser.phoneNumber!+widget.contact.phones!.elementAt(0).value!).hashCode.toString();
          setState(() {
            roomKey = roomId;
          });
          _readMessages(roomId);
        }
      }else{
        databaseReference.onValue.listen((DatabaseEvent event) {
          // print(event.snapshot.value);
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


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.contact.displayName!),
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
            onSendPressed: _handleSendPressed,
            user: _user,
          ),
        ));
  }

  void _addMessage(types.Message message) async{
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref('rooms');
    DatabaseReference inboxSender = FirebaseDatabase.instance.ref('inbox/${currentUser.uid}');
    // String contactNumber =widget.contact.phones!.elementAt(0).value!.replaceAll(new RegExp(r'[^0-9]'),'');
    // await FirebaseFirestore.instance.collection("Users").where("Phone_Number",isEqualTo: contactNumber);
    // DatabaseReference inboxReceiver =
    
    print(message.toJson()["text"]);
    print('hi');
    String contactNumber =widget.contact.phones!.elementAt(0).value!.replaceAll(new RegExp(r'[^0-9]'),'');
    databaseReference.child(roomKey).push().set(message.toJson());
    inboxSender.child(contactNumber).set({
      "timeStamp":ServerValue.timestamp,
      "contact_no":contactNumber,
      'recentMessage':message.type.toString() == "MessageType.text"?message.toJson()["text"]:message.type.toString(),
      'profile_pic':''
    });
    if(_messages.isEmpty){
      _readMessages(roomKey);
    }
    // setState(() {
    //   _messages.insert(0, message);
    // });
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
      _addMessage(message);
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
