import 'package:firebase_database/firebase_database.dart';

class UserModel{

  String? name;
  String? phone;
  String? email;
  String? id;
  String? cnic;

  UserModel({this.name, this.phone, this.email, this.id,this.cnic});

  UserModel.fromSnapshot(DataSnapshot snap){
    name = (snap.value as dynamic)["name"];
    phone = (snap.value as dynamic)["phone"];
    email = (snap.value as dynamic)["email"];
    id = snap.key;
    cnic = (snap.value as dynamic)["cnic"];
  }
}