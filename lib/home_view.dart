import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:smart_sharer/receive.dart';
import 'package:smart_sharer/send.dart';
import 'package:smart_sharer/settings.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final String userName = Random().nextInt(10000).toString();
  bool checkLocationService =false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Column(
                children: [
                  SafeArea(
                    child:  Stack(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.orangeAccent,
                          radius: 40,
                          child: Text(userName, style: TextStyle(
                              fontSize: 30
                          ),) ,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text("User ID: $userName",
                    style: TextStyle(
                      fontSize: 15,
                    ),)
                ],
              ) ,
              decoration: BoxDecoration(
                color:Colors.deepOrangeAccent,
              ),
            ),
            ListTile(
              title: Text('Home'),
              trailing: Icon(
                Icons.home,
              ),
              onTap: ()=> Navigator.pop(context),
            ),
            ListTile(
              title: Text('Send Files'),
              trailing: Icon(
                Icons.send,
              ),
              onTap: (){
                checkLocationEnabled();
                if(checkLocationService == true)
                  return null;
                else
                  enableLocationServices().then((value)=>
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> Send(userName: userName,))));
              },
            ),
            ListTile(
                title: Text('Recieve Files'),
                trailing: Icon(
                  Icons.login,
                ),
                onTap: (){
                  checkLocationEnabled();
                  if(checkLocationService == true)
                    return null;
                  else
                    enableLocationServices().then((value)=>
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Receive(userName: userName,))));
                }
            ),
            ListTile(
              title: Text('Settings'),
              trailing: Icon(
                Icons.settings,
              ),
              onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> Settings())),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.deepOrangeAccent,
      ),
      backgroundColor: Colors.deepOrange,

      body: Container(
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(top:10, left: 15),
                  child: CircleAvatar(
                    backgroundColor: Colors.orangeAccent,
                    radius: 60,
                    child: Text(userName,
                      style: TextStyle(
                          fontSize:  40,
                          fontWeight: FontWeight.bold
                      ),
                    ) ,
                  ),
                ),
                SizedBox(width: 70,),
                Text("User ID: $userName", style: TextStyle(
                  fontSize: 25,

                ),)
              ],
            ),
            SizedBox(height: 80,),
            FlatButton(onPressed: () {
              checkLocationEnabled();
              if(checkLocationService == true)
                return null;
              else
                enableLocationServices().then((value)=>
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> Send(userName: userName,))));
            },
              child: Text("Send", style: TextStyle(
                  fontSize: 30,
                  color: Colors.white
              ),),
              minWidth: 250,
              color: Colors.pink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(70),
              ),
              height: 150,

            ),
            SizedBox(height: 80,),
            FlatButton(onPressed: (){
              checkLocationEnabled();
              if(checkLocationService == true)
                return null;
              else
                enableLocationServices().then((value){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Receive(userName: userName,)));
                });
            },
              child: Text("Receive", style: TextStyle(
                  fontSize: 30,
                  color: Colors.white
              ),),
              minWidth: 250,
              color: Colors.pink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(70),
              ),
              height: 150,
            ),
          ],
        ),
      ),

    );

  }
  checkLocationEnabled() async {
    if (await Nearby().checkLocationEnabled()) {
      checkLocationService = true;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location is ON :)")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location is OFF :(")));
    }
  }
  enableLocationServices() async {
    if (await Nearby().enableLocationServices()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Location Service Enabled :)")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
          Text("Enabling Location Service Failed :(")));
    }
  }


}
