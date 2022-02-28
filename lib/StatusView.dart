import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    );
  }
}
