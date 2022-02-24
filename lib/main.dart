import 'dart:collection';

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:whatsapp_clone/ChatWindow.dart';
import 'package:whatsapp_clone/splashScreen.dart';
import './ContactList.dart';
import './Settings.dart';
import './Signin.dart';
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
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const Settings()));
                    break;
                }
              },
              itemBuilder: (context) => [
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
          const Center(child: Text('Status', style: TextStyle(fontSize: 24))),
          const Center(child: Text('Calls', style: TextStyle(fontSize: 24))),
        ]),
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const Settings()));
  }
}

//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title:'Startup Name Generator',
//       theme:ThemeData(
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Colors.teal,
//           foregroundColor: Colors.white
//         )
//       ),
//
//       home: DefaultTabController(
//         length: 4,
//         initialIndex: 1,
//         child:  Scaffold(
//           appBar: AppBar(
//             title: const Text('Whatsapp'),
//             actions: [
//               IconButton(
//                   onPressed:(){} ,
//                   icon: const Icon(Icons.search)
//               ),
//               IconButton(
//                   onPressed: (){},
//                   icon: const Icon(Icons.more_vert)
//               )
//             ],
//             bottom:const TabBar(
//               tabs: [
//                 Tab(icon: Icon(Icons.camera)),
//                 Tab(
//                   text: 'Chats',
//                 ),
//                 Tab(
//                     text:'Status'
//                 ),
//                 Tab(
//                     text:'Calls'
//                 ),
//               ],
//             ),
//           ),
//           body:   TabBarView(
//               children:[
//                  const Center(child: Text('Camera',style: TextStyle(fontSize: 24))),
//                  Scaffold(
//
//                    body:const Center(
//                        child: Text(
//                            'Chats',
//                            style: TextStyle(
//                                fontSize: 24
//                            )
//                        )
//                    ),
//                    floatingActionButton: FloatingActionButton(
//                      backgroundColor: Colors.teal,
//                      onPressed: (){
//                         _openContactList();
//                      },
//                      child: const Icon(Icons.message),
//                    ),
//                  ),
//                  const Center(child: Text('Status',style: TextStyle(fontSize: 24))),
//                  const Center(child: Text('Calls',style: TextStyle(fontSize: 24))),
//               ]
//           ),
//         ),
//       )
//     );
//   }
//
//   void _pushSaved(){
//     Navigator.of(context).push(
//       MaterialPageRoute<void>(
//         builder: (context) {
//           final tiles = _saved.map(
//                 (pair) {
//               return ListTile(
//                 title: Text(
//                   pair.asPascalCase,
//                   style: _biggerFont,
//                 ),
//               );
//             },
//           );
//           final divided = tiles.isNotEmpty
//               ? ListTile.divideTiles(
//             context: context,
//             tiles: tiles,
//           ).toList()
//               : <Widget>[];
//
//           return Scaffold(
//             appBar: AppBar(
//               title: const Text('Saved Suggestions'),
//             ),
//             body: ListView(children: divided),
//           );
//         },
//       ),
//     );
//   }
//
// }
//

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  List _list =[];
  int length=0;
  Contact _contact = new Contact();
  final DatabaseReference ref = FirebaseDatabase.instance.ref("inbox/${FirebaseAuth.instance.currentUser!.uid}");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // ref.get().then((DataSnapshot snapshot) => print(snapshot.value));
    ref.orderByChild('/timestamp').onValue.listen((event) {
      event.snapshot.children.forEach((element) {
        final HashMap<String,String> obj = new HashMap();
        element.children.forEach((data) {
          obj.putIfAbsent(data.key.toString(), () => data.value.toString());
          print("${data.key} : ${data.value}");
        });
        _list.clear();
        if(!_list.contains(obj)){
          setState(() {
            _list.add(obj);
          });
        }

      });
      length = event.snapshot.children.length;
    });
    // ref.onValue.listen((event) { print("HELLO");});
  }

  Future _getContacts(String phone)async{
    final contact = await ContactsService.getContactsForPhone(phone);
    setState(() {
      _contact = contact.first;
    });

    // print(contact.first.displayName);
  }

  @override
  Widget build(BuildContext context) {

    if(length>0){
      return ListView.builder(
          padding: EdgeInsets.fromLTRB(0, 5, 16, 18),
          itemCount: _list.length,
          itemBuilder: (context,index){
            _getContacts(_list[index]["contact_no"]);
            String recentMessage = _list[index]["recentMessage"];

            print(DateTime.fromMillisecondsSinceEpoch(int.parse(_list[index]["timeStamp"])).day);
            return ListTile(

              title: Text(_contact.displayName!,
                style:const TextStyle(fontSize: 18),
              ),
              leading: CircularProfileAvatar(
                '',
                radius: 30,
                child: Image.network('https://firebasestorage.googleapis.com/v0/b/whatsapp-24711.appspot.com/o/LNs9JW1IzxT3asoZBCkqp97MORE3%2Fprofile_image?alt=media&token=84340b57-9cf1-4882-977c-0814cbcbdd21'),
              ),
              subtitle: Text(recentMessage),
              trailing: Text("time"),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ChatWindow(contact: _contact)));
              },
            );
          }
      );
    }else{
      return const Center(child: Text('No Chats Found , Lets start one ;)'));
    }


    // return ListView.builder(
    //     padding: const EdgeInsets.all(16),
    //     itemCount: _list.length,
    //     itemBuilder: (context, i) {
    //       if (i.isOdd) {
    //         return const Divider();
    //       }
    //
    //       return (_buildRows(_list[i]));
    //     });
  }

  Widget _buildRows(String name) {
    return ListTile(
      title: Text(
        name.toUpperCase(),
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}

class RandomWords extends StatefulWidget {
  const RandomWords({Key? key}) : super(key: key);

  @override
  State<RandomWords> createState() => _RandomWords();
}

class _RandomWords extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _saved = <WordPair>{};
  final _biggerFont = const TextStyle(fontSize: 18);

  Widget _buildSuggestion() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, i) {
        if (i.isOdd) {
          return const Divider();
        }
        final index = i ~/ 2;
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      },
    );
  }

  Widget _buildRow(WordPair pair) {
    final alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
        semanticLabel: alreadySaved ? 'Remove from Saved' : 'Save',
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final wordPair = WordPair.random();
    return Scaffold(
        appBar: AppBar(
          title: const Text('Startup Name Generator'),
          actions: [
            IconButton(
                onPressed: _pushSaved,
                tooltip: 'Saved suggestions',
                icon: const Icon(Icons.list))
          ],
        ),
        body: _buildSuggestion());
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          final tiles = _saved.map(
            (pair) {
              return ListTile(
                title: Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
                  context: context,
                  tiles: tiles,
                ).toList()
              : <Widget>[];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }
}
