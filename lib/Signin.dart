import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:whatsapp_clone/main.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body:SignInHome()
    );
  }
}

//SIGN-IN HOMEPAGE

class SignInHome extends StatefulWidget {
  const SignInHome({Key? key}) : super(key: key);

  @override
  _SignInHomeState createState() => _SignInHomeState();
}

class _SignInHomeState extends State<SignInHome> {
  late TextEditingController _phoneController,_codeController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _phoneController = TextEditingController();
    _codeController = TextEditingController();
  }
  
  @override
  void dispose() {
    // TODO: implement dispose
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 50, 25, 25),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.center,
            child: Text(
              'Enter your phone number',
              style: TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                  fontSize: 24
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'WhatsApp will need to verify your phone number.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:[
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.add,size: 18),
                  ),
                ),
              ),
              SizedBox(
                width:200,
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: _phoneController,
                  decoration:const InputDecoration(
                      hintText: 'phone number'
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Carrier charges may apply',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          Align(
            alignment:Alignment.center ,
            child: ElevatedButton(
                onPressed: (){
                  String no = '+'+_codeController.text+_phoneController.text;
                  showDialog(
                      context: context,
                      builder: (context){
                        return AlertDialog(
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: [
                                const Text('You entered the phone number :'),
                                const SizedBox(height: 20),
                                Text(no,style:const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height:20),
                                const Text('Is this OK, or would you like to edit the number?')
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(onPressed: ()=>Navigator.pop(context,"Cancel"),child: const Text('EDIT')),
                            TextButton(onPressed: (){
                              Navigator.pop(context);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context)=>_VerificationProcess(phoneNumber:no)
                                )
                              );

                            },
                                child:const Text('OK'))
                          ],
                          actionsAlignment: MainAxisAlignment.spaceBetween,
                        );

                      }
                  );
                },
                child: const Text('NEXT')
            ),
          )
        ],
      ),
    );
  }
}

//VERIFICATION PROCESS

class _VerificationProcess extends StatefulWidget {
  final String phoneNumber;
  const _VerificationProcess({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  _VerificationProcessState createState() => _VerificationProcessState();
}

class _VerificationProcessState extends State<_VerificationProcess> {
  late String _verificationId ;

  void  phoneAuth (String number) async {

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: number,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async{
          await FirebaseAuth.instance.signInWithCredential(credential).then(
                  (UserCredential userCredential) => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>const BasicDetails()))
          );
        },
        verificationFailed: (FirebaseAuthException e){
          if(e.code == 'invalid-phone-number'){
            showDialog(
                context: context,
                builder: (context)=>
                    AlertDialog(
                      title:const Text('Invalid Phone Number'),
                      actions: [
                        TextButton(
                            onPressed: ()=>Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context)=>const SignInHome())
                            ),
                            child:const Text('Edit')
                        )
                      ],
                    )

            );
            print(e.code);
            print(e.stackTrace);
            // print('The provided phone number is not valid.');
          }
        },
        codeSent: (String verificationId,int? resendToken) async{
          _verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId){}
    );
  }
  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    phoneAuth(widget.phoneNumber);
  }
  
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:Container(
          color:Colors.white,
          padding: const EdgeInsets.fromLTRB(25, 50, 25, 25),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.center,
                child: Text(
                  'Verifying your number',
                  style: TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      decoration:TextDecoration.none
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Waiting to automatically detect an SMS sent to ${widget.phoneNumber}',
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w300
                ),
              ),
              SizedBox(
                height: 80,
                child:OTPTextField(
                  length:6,
                  width: MediaQuery.of(context).size.width,
                  fieldWidth: 40,
                  style: const TextStyle(
                      fontSize: 17,
                  ),
                  textFieldAlignment: MainAxisAlignment.spaceAround,
                  fieldStyle: FieldStyle.underline,
                  onCompleted: (pin)async{
                    PhoneAuthCredential authCredential = PhoneAuthProvider.credential(
                        verificationId: _verificationId,
                        smsCode: pin
                    );
                    await FirebaseAuth.instance.
                      signInWithCredential(authCredential)
                      .then((UserCredential credential){

                       Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>const BasicDetails()));
                    });
                  },
                ) ,
              ),

              const SizedBox(height: 20),
              const Text(
                'Enter 6-digit code ',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    decoration: TextDecoration.none
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        )
    );
  }
}

class BasicDetails extends StatefulWidget {
  const BasicDetails({Key? key}) : super(key: key);

  @override
  _BasicDetailsState createState() => _BasicDetailsState();
}

enum AppState {
  free,
  picked,
  cropped,
}
class _BasicDetailsState extends State<BasicDetails> {
  late TextEditingController _name,_about;
  late AppState state;
  String imageUrl = 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ6xSz0eMW7GmpKukczOHvPWWGDqaBCqWA-Mw&usqp=CAU';
  File? imageFile ;
  bool _validate = false;
  CollectionReference users = FirebaseFirestore.instance.collection('Users');

  Future<Null> _pickImage() async{
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    imageFile = pickedImage != null?File(pickedImage.path):null;
    if(imageFile != null){
      setState(() {
        state = AppState.picked;
      });
      _cropImage();
    }
  }

  Future<Null> _cropImage() async{
    File? croppedImage = await ImageCropper().cropImage(
        sourcePath: imageFile!.path,
        cropStyle: CropStyle.circle,
        androidUiSettings: const AndroidUiSettings(
          toolbarColor: Colors.teal,
          toolbarTitle: 'Edit Image',
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false
        ),
        iosUiSettings: const IOSUiSettings(
          title:'Edit Image'
        )
    );
    if(croppedImage != null){
      setState(() {
        imageFile = croppedImage;
        AppState.cropped;
      });
    }
  }

  Future uploadImage()async{
    await FirebaseStorage.instance
        .ref("${FirebaseAuth.instance.currentUser!.uid}/profile_image")
        .putFile(imageFile!)
        .whenComplete(()async{
          String url = await FirebaseStorage.instance.ref("${FirebaseAuth.instance.currentUser!.uid}/profile_image").getDownloadURL();
          setState(() {
            imageUrl=url;
          });
    }).then((TaskSnapshot snapshot) => _addUser());
  }

  Future _addUser()async{

          users
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .set({
            'Name':_name.text,
            'About':_about.text,
            'Phone_Number':FirebaseAuth.instance.currentUser?.phoneNumber?.replaceAll("+91", ""),
            'Image':imageUrl,
            'Id':FirebaseAuth.instance.currentUser?.uid
          })
              .then((value) => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context)=>const Home())
          ))
              .catchError((error)=>print('failed to add user'+error.toString()));
  }
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _name = TextEditingController();
    _about = TextEditingController();
    state = AppState.free;
    users.doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot snapshot){
          if(snapshot.exists){
            _name.text = snapshot.get("Name").toString();
            _about.text = snapshot.get("About").toString();
            setState(() {
              imageUrl = snapshot.get("Image");
            });

          }

    });
  }
  
  @override
  void dispose() {
    // TODO: implement dispose
    _name.dispose();
    _about.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.fromLTRB(25, 80, 25, 25),
        color:Colors.white,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 85,

                  child: CircularProfileAvatar(
                    '',
                    child: imageFile!=null?Image.file(imageFile!):Image.network(imageUrl),
                    radius: 40,
                    cacheImage: true,
                    imageFit: BoxFit.cover,
                    onTap: ()=>_pickImage(),
                  ),

                ),
                SizedBox(
                  width:250,
                  child: TextField(
                    controller: _name,
                    decoration: InputDecoration(
                      hintText: 'Enter Your Name',
                      errorText: _validate && _name.text.isEmpty?'Username can\'t be Empty':null,
                      errorStyle: TextStyle(color: Colors.red)
                    ),
                  )
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: _about,
              decoration: InputDecoration(
                hintText: 'Enter About',
                errorText: _validate && _about.text.isEmpty?'About can\'t be empty':null,
                errorStyle: TextStyle(color: Colors.red)
              ),
            ),
            SizedBox(height:40),
            ElevatedButton(
                onPressed: (){
                  setState(() {
                    _validate = true;
                  });
                  if(_name.text.isNotEmpty && _about.text.isNotEmpty){
                    if(imageFile != null){
                      uploadImage();
                    }else{
                      // print(FirebaseAuth.instance.currentUser?.phoneNumber);
                      _addUser();
                    }

                  }
                },
                child: Text('SAVE',
                  style: TextStyle(
                  fontSize: 16
                ),
                )
            )
          ],

        ),
      ),
    );
  }
}


