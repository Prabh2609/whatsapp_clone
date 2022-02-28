import 'dart:collection';
import 'dart:typed_data';

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_contacts/flutter_contacts.dart';
import './ChatWindow.dart';
import 'package:contacts_service/contacts_service.dart';

class ContactList extends StatefulWidget {
  const ContactList({Key? key}) : super(key: key);

  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  List<Contact>? _contacts;
  List<Contact> _contactList=[];
  bool _permissionDenied = false;
  String state = 'Loading';
  List<String> phoneNumbers = [];
  List<HashMap> updatedPhoneNumers = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _askPermissions();
  }

  Future<void> _askPermissions() async{
    PermissionStatus permissionStatus = await _getContactsPermission();
    if(permissionStatus == PermissionStatus.granted){
      _fetchContacts();
    }else{
      setState(() {
        _permissionDenied = true;
      });
    }
  }

  Uint8List convertStringToUint8List(String str) {
    final List<int> codeUnits = str.codeUnits;
    final Uint8List unit8List = Uint8List.fromList(codeUnits);

    return unit8List;
  }

  Future<PermissionStatus> _getContactsPermission()async{
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
        PermissionStatus permissionStatus = await Permission.contacts.request();
        return permissionStatus;
    }else {
      return permission;
    }
  }
  Future _fetchContacts() async{
      final contacts = await ContactsService.getContacts();
      setState(() {
        _contacts = contacts;
      });
      CollectionReference users = FirebaseFirestore.instance.collection('Users');

      users
          .get()
          .then((QuerySnapshot snapshot)async{
        if(snapshot.size>0){
          print('Snapshot exists');
          snapshot.docs.forEach((element) {

            HashMap map = new HashMap();
            map.putIfAbsent('Phone_Number', () => element.get('Phone_Number'));
            map.putIfAbsent('profile_pic', () => element.get('Image'));
            map.putIfAbsent("userId", () => element.get('Id'));



            if(!updatedPhoneNumers.contains(map)){
              updatedPhoneNumers.add(map);
            }
            if(!phoneNumbers.contains(element.get('Phone_Number'))) {
              phoneNumbers.add(element.get('Phone_Number'));
            }
          });
          print(phoneNumbers);
          _contacts!.forEach((contact) {
            try{
              if(contact.phones!.isNotEmpty){
                String contactNumber =contact.phones!.elementAt(0).value!.replaceAll(new RegExp(r'[^0-9]'),'');
                
                var check = updatedPhoneNumers.firstWhere((element) => element["Phone_Number"]==contactNumber,orElse: ()=>new HashMap());
                if(check.isNotEmpty){
                  print(check["userId"]);
                  contact.identifier = check["userId"];
                  contact.avatar = convertStringToUint8List(check["profile_pic"]);
                  _contactList.add(contact);
                }
              }
            }on Exception catch(e){
              print(e.runtimeType);
            }
          });

          if(_contactList.length>0){

            setState(() {
              state='Loaded';
            });
          }else{
            setState(() {
              state='Does_Not_Exists';
            });
          }
        }else{


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
          title: const Text('Select Contact'),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))
          ],
        ),
        body:body()
    );
  }

  Widget body(){
    if(_permissionDenied) {
      return const Center(
        child: Text('Permission Denied',
          style: TextStyle(fontSize: 18, color: Colors.grey),),
      );
    }
    if(_contacts == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.tealAccent,
        )
      );
    }


    if(state == 'Does_Not_Exists'){
      return const Center(
        child: Text(
          'OOPS !! No Contacts Found :(',
          style:TextStyle(fontSize: 18,color: Colors.grey),
        ),
      );
    }if(state == 'Loaded') {
      print(convertUint8ListToString(_contactList.elementAt(0).avatar!));
      return ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: _contactList.length,
          itemBuilder: (context,index)=>ListTile(
            tileColor: Colors.white70,
            title: Text(_contactList[index].displayName!,style: TextStyle(fontSize: 18)),
            leading: CircularProfileAvatar(
              '',
              child: Image.network(convertUint8ListToString(_contactList.elementAt(0).avatar!)),
              radius: 25,
            ),
            onTap: (){
              // print("${_contactList[index].identifier} HI");

              Navigator.of(context).push(
                  MaterialPageRoute(

                      builder: (context)=>ChatWindow(
                          contact:_contactList[index],
                          title: _contactList[index].displayName!=null? _contactList[index].displayName!:"GHOST ACCOUNT",
                          profile_pic:convertUint8ListToString(_contactList[index].avatar!),
                          contact_number: _contactList[index].phones!.elementAt(0).value!.replaceAll(new RegExp(r'[^0-9]'),''),
                      )
                  )
              );
            },
          )
      );
    }else{
      return const Center(
          child: CircularProgressIndicator(
            color: Colors.tealAccent,
          )
      );
    }
  }
}
