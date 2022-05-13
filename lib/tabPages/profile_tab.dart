import 'package:flutter/material.dart';
import 'package:go_dutch/global/global.dart';
import 'package:go_dutch/splashScreen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/info_design_ui.dart';


class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            //name
            Text(
              userModelCurrentInfo.name!,
              style: const TextStyle(
                fontSize: 30.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
              width: 200,
              child: Divider(
                color: Colors.white,
                height: 2,
                thickness: 2,
              ),
            ),

            const SizedBox(height: 20.0,),

            //phone
            InfoDesignUIWidget(
              textInfo: userModelCurrentInfo.phone!,
              iconData: Icons.phone_iphone,
            ),

            //email
            InfoDesignUIWidget(
              textInfo: userModelCurrentInfo.email!,
              iconData: Icons.email,
            ),

            InfoDesignUIWidget(
              textInfo: userModelCurrentInfo.vehicle_color! + " " + userModelCurrentInfo.vehicle_model! + " " +  userModelCurrentInfo.vehicle_number!,
              iconData: Icons.car_repair,
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton(
              onPressed: ()
              {
                firebaseAuth.signOut();
                SystemNavigator.pop();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.orangeAccent,
              ),
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.black),
              ),
            )

          ],
        ),
      ),

    );
  }
}
