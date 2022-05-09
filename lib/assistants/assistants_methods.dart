
import 'package:firebase_database/firebase_database.dart';
import 'package:go_dutch/global/global.dart';

import '../models/user_model.dart';

class AssistantMethods{

  static void readCurrentOnlineUserInfo() async {

    currentfirebaseuser = firebaseAuth.currentUser;
    DatabaseReference userref= FirebaseDatabase.instance.ref().child("Users").child(currentfirebaseuser!.uid);
    userref.once().then((snap){

      if(snap.snapshot.value != null){
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);// for getting current online users info
      }
    });
  }
}