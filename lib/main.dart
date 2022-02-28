import 'dart:collection';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/ChatWindow.dart';
import 'package:whatsapp_clone/StatusView.dart';
import 'package:whatsapp_clone/splashScreen.dart';
import './ContactList.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Startup Name Generator',
        theme: ThemeData(
            primaryColor: Colors.teal,
            primarySwatch: Colors.teal,
            appBarTheme: const AppBarTheme(
                backgroundColor: Colors.teal, foregroundColor: Colors.white)),
        home: const SplashScreen()
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      if (FirebaseAuth.instance.currentUser != null) {
        FirebaseAuth.instance.currentUser?.updatePhotoURL(
            snapshot.get('Image'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Whatsapp'),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            PopupMenuButton(
              onSelected: (index) {
                switch (index) {
                  case 6:
                  // Navigator.of(context).push(MaterialPageRoute(
                  //     builder: (context) => const Settings()));
                    break;
                }
              },
              itemBuilder: (context) =>
              [
                const PopupMenuItem(
                  child: Text('New Group'),
                  value: 1,
                ),
                const PopupMenuItem(child: Text('New Broadcast'), value: 2),
                const PopupMenuItem(child: Text('Linked Devices'), value: 3),
                const PopupMenuItem(child: Text('Starred Messages'), value: 4),
                const PopupMenuItem(child: Text('Payments'), value: 5),
                const PopupMenuItem(
                  child: Text('Settings'),
                  value: 6,
                ),
              ],
            )
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.photo_camera)),
              Tab(
                text: 'Chats',
              ),
              Tab(text: 'Status'),
              Tab(text: 'Calls'),
            ],
          ),
        ),
        body: TabBarView(children: [
          const Center(child: Text('Camera', style: TextStyle(fontSize: 24))),
          Scaffold(
            body: const Center(
              child: ChatList(),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.teal,
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const ContactList()));
              },
              child: const Icon(Icons.message),
            ),
          ),
          // const Center(child: Text('Status', style: TextStyle(fontSize: 24))),
          const StatusView(),
          const Center(child: Text('Calls', style: TextStyle(fontSize: 24))),
        ]),
      ),
    );
  }

}

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  List _list = [];
  int length = 0;
  Contact _contact = new Contact();
  final DatabaseReference ref = FirebaseDatabase.instance.ref(
      "inbox/${FirebaseAuth.instance.currentUser!.uid}");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ref
        .orderByChild('/timestamp')
        .onValue
        .listen((event) {
      event.snapshot.children.forEach((element) {
        final HashMap<String, String> obj = new HashMap();
        element.children.forEach((data) {
          obj.putIfAbsent(data.key.toString(), () => data.value.toString());
        });
        _list.clear();
        if (!_list.contains(obj)) {
          setState(() {
            _list.add(obj);
          });
        }
      });
      length = event.snapshot.children.length;
    });
  }

  String getTime(String timeStamp){
    DateTime now = DateTime.now();
    DateTime time = DateTime.fromMillisecondsSinceEpoch(int.parse(timeStamp));
    int difference = now.difference(time).inDays;


    if(difference==0){
      return "${time.hour}:${time.minute}";
    }else if(difference == -1){
      return "Yesterday";
    }else{
      return "${time.day}/${time.month}";
    }
  }

  Future _getContacts(String phone) async {
    final contact = await ContactsService.getContactsForPhone(phone);

    setState(() {
      _contact = contact.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (length > 0) {
      return ListView.builder(
          padding: EdgeInsets.fromLTRB(0, 5, 16, 18),
          itemCount: _list.length,
          itemBuilder: (context, index) {
            _getContacts(_list[index]["contact_no"]);
            String recentMessage = _list[index]["recentMessage"];
            _contact.identifier = _list[index]["receiverId"];

            return ListTile(
              title: Text(_contact.displayName != null
                  ? _contact.displayName
                  : _list[index]["contact_no"],
                style: const TextStyle(fontSize: 18),
              ),
              leading: CircularProfileAvatar(
                '',
                radius: 30,
                child: Image.network(_list[index]["profile_pic"]),
              ),
              subtitle: Text(recentMessage),
              trailing: Text(getTime(_list[index]["timeStamp"]),style: TextStyle(fontWeight:FontWeight.bold),),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) =>
                        ChatWindow(
                            contact: _contact,
                            title: _contact.displayName != null ? _contact
                                .displayName! : _list[index]["contact_no"]
                                .toString(),
                            profile_pic: _list[index]["profile_pic"],
                            contact_number: _list[index]["contact_no"]
                        )));
              },
            );
          }
      );
    } else {
      return const Center(child: Text('No Chats Found , Lets start one ;)'));
    }
  }

}
