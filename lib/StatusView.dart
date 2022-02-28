import 'dart:ui';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_randomcolor/flutter_randomcolor.dart';

class StatusView extends StatefulWidget {
  const StatusView({Key? key}) : super(key: key);

  @override
  _StatusViewState createState() => _StatusViewState();
}

class _StatusViewState extends State<StatusView> {
  String profile_image = 'https://www.pngfind.com/pngs/m/676-6764065_default-profile-picture-transparent-hd-png-download.png';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot snapshot) {
          setState(() {
              profile_image = snapshot.get("Image");
          });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            SizedBox(height:20),
            ListTile(
              leading: CircularProfileAvatar(
                '',
                child: Image.network(profile_image),
                radius: 30,
              ),
              title: Text('My Status',style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 20),
            Text('Status List'),
            SizedBox(height:20),
          ],
        ),
      ),
      floatingActionButton:Padding(
        padding: EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const TextStatus()));
              },
              child: new Icon(Icons.create),
            ),
            SizedBox(height:20),
            FloatingActionButton(
              onPressed: (){},
              child: new Icon(Icons.photo_camera),
            ),
          ],
        ),
      )
    );
  }
}

class TextStatus extends StatefulWidget {
  const TextStatus({Key? key}) : super(key: key);

  @override
  _TextStatusState createState() => _TextStatusState();
}



class _TextStatusState extends State<TextStatus> {
  Color getRandomColors(){

    return Colors.red;
  }
  late TextEditingController statusController;
  @override
  void initState() {
    // TODO: implement initState
    statusController = TextEditingController();
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    statusController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan,
      body: Padding(
        padding: EdgeInsets.all(24),
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              TextField(
                controller: statusController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                maxLength: 200,
                style: TextStyle(
                  fontSize: 48,
                  color: Colors.white
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Type Your Status",
                  hintStyle: TextStyle(color:Colors.white60)
                ),
              )
          ],
        )
      ),
      floatingActionButton:FloatingActionButton(
          onPressed: (){},
          child:Icon(Icons.send)
      ),
    );
  }
}

