import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';

class Settings extends StatelessWidget {
  bool checkLocation = false;
  bool checkStorage =false;
  @override
  Widget build(BuildContext context) {
    checkLocationPermission() async {
      if (await Nearby().checkLocationPermission()) {
        checkLocation = true;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Location permissions granted :)")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
            Text("Location permissions not granted :(")));
      }
    }
    askLocationPermission() async {
      if (await Nearby().askLocationPermission()) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Location Permission granted :)")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
            Text("Location permissions not granted :(")));
      }
    }

    checkExternalPermission() async {
      if (await Nearby().checkExternalStoragePermission()) {
        checkStorage = true;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
            Text("External Storage permissions granted :)")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "External Storage permissions not granted :(")));
      }
    }
    askStoragePermission() async {
      Nearby().askExternalStoragePermission();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: ListView(
        children: [
          GestureDetector(
            onTap: (){
              checkLocationPermission();
              if(checkLocation == true)
                askLocationPermission();
            },
            child: ListTile(
              title: Text("Enable Location permission"),
              trailing: Icon(Icons.location_on),
            ),
          ),
          GestureDetector(
            onTap: (){
              checkExternalPermission();
              if(checkStorage == true)
                return null;
              else
                askStoragePermission();
            },
            child: ListTile(
              title: Text("Enable Storage permission"),
              trailing: Icon(Icons.location_on),
            ),
          ),

        ],
      ),
    );
  }
}
