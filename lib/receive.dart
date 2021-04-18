import 'package:flutter/material.dart';
class Receive extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrangeAccent,
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  child: Card(
                    child: Image.asset('assets/images/phone_receiver.jpg', ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 100,),
            Container(
              height: 250,
              width: 300,
              child:
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Column(
                  children: [
                    SizedBox(height: 30,),
                   FlatButton(
                       onPressed: (){},
                     child: Row(
                       children: [
                         SizedBox(width: 30,),
                         Icon(Icons.wifi_tethering, color: Colors.pink,),
                         SizedBox(width: 30,),
                         Text("Set up hotspot")
                       ],
                     ),
                   ),
                    SizedBox(height: 30,),
                    FlatButton(
                      onPressed: (){},
                      child: Row(
                        children: [
                          SizedBox(width: 30,),
                          Icon(Icons.bluetooth, color: Colors.pink,),
                          SizedBox(width: 30,),
                          Text("Set up Bluetooth")
                        ],
                      ),
                    ),
                    SizedBox(height: 30,),
                    FlatButton(
                      onPressed: ()=> Navigator.pop(context),
                      child: Row(
                        children: [
                          SizedBox(width: 30,),
                          Icon(Icons.arrow_back_rounded, color: Colors.pink,),
                          SizedBox(width: 30,),
                          Text("Go back to Home")
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      );
  }
}
