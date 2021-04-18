import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:smart_sharer/home_view.dart';
class Receive extends StatefulWidget {
  String userName;
  Receive({required this.userName});
  @override
  _ReceiveState createState() => _ReceiveState();
}

class _ReceiveState extends State<Receive> {

  final Strategy strategy = Strategy.P2P_STAR;
  Map<String, ConnectionInfo> endpointMap = Map();

  File? tempFile; //reference to the file currently being transferred
  Map<int, String> map =
  Map();
  @override

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
                    onPressed: ()async{
                      await startAdvertising();
                    },
                    child: Row(
                      children: [
                        SizedBox(width: 30,),
                        Icon(Icons.wifi_tethering, color: Colors.pink,),
                        SizedBox(width: 30,),
                        Text("Start Receiving")
                      ],
                    ),
                  ),
                  SizedBox(height: 30,),
                  FlatButton(
                    onPressed: ()async{
                      await Nearby().stopAdvertising().then((value) async{
                        await Nearby().stopAllEndpoints().then((value) => showSnackbar("Receiving mode off"));
                        setState(() {
                          endpointMap.clear();
                        });
                      });
                    },
                    child: Row(
                      children: [
                        SizedBox(width: 30,),
                        Icon(Icons.cancel, color: Colors.pink,),
                        SizedBox(width: 30,),
                        Text("Stop Receiving")
                      ],
                    ),
                  ),
                  SizedBox(height: 30,),
                  FlatButton(
                    onPressed: (){
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeView()));
                    },
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
  void onConnectionInit(String id, ConnectionInfo info) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Center(
          child: Column(
            children: <Widget>[
              Text("id: " + id),
              Text("Token: " + info.authenticationToken),
              Text("Name" + info.endpointName),
              Text("Incoming: " + info.isIncomingConnection.toString()),
              ElevatedButton(
                child: Text("Accept Connection"),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    endpointMap[id] = info;
                  });
                  Nearby().acceptConnection(
                    id,
                    onPayLoadRecieved: (endid, payload) async {
                      if (payload.type == PayloadType.BYTES) {
                        String str = String.fromCharCodes(payload.bytes!);
                        showSnackbar(endid + ": " + str);

                        if (str.contains(':')) {
                          // used for file payload as file payload is mapped as
                          // payloadId:filename
                          int payloadId = int.parse(str.split(':')[0]);
                          String fileName = (str.split(':')[1]);

                          if (map.containsKey(payloadId)) {
                            if (await tempFile!.exists()) {
                              tempFile!.rename(
                                  tempFile!.parent.path + "/" + fileName);
                            } else {
                              showSnackbar("File doesn't exist");
                            }
                          } else {
                            //add to map if not already
                            map[payloadId] = fileName;
                          }
                        }
                      } else if (payload.type == PayloadType.FILE) {
                        showSnackbar(endid + ": File transfer started");
                        tempFile = File(payload.filePath!);
                      }
                    },
                    onPayloadTransferUpdate: (endid, payloadTransferUpdate) {
                      if (payloadTransferUpdate.status ==
                          PayloadStatus.IN_PROGRESS) {
                        print(payloadTransferUpdate.bytesTransferred);
                      } else if (payloadTransferUpdate.status ==
                          PayloadStatus.FAILURE) {
                        print("failed");
                        showSnackbar(endid + ": FAILED to transfer file");
                      } else if (payloadTransferUpdate.status ==
                          PayloadStatus.SUCCESS) {
                        showSnackbar(
                            "$endid success, total bytes = ${payloadTransferUpdate.totalBytes}");

                        if (map.containsKey(payloadTransferUpdate.id)) {
                          //rename the file now
                          String name = map[payloadTransferUpdate.id]!;
                          tempFile!.rename(tempFile!.parent.path + "/" + name);
                        } else {
                          //bytes not received till yet
                          map[payloadTransferUpdate.id] = "";
                        }
                      }
                    },
                  );
                },
              ),
              ElevatedButton(
                child: Text("Reject Connection"),
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await Nearby().rejectConnection(id);
                  } catch (e) {
                    showSnackbar(e);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
  void showSnackbar(dynamic a) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(a.toString()),
    ));
  }
  startAdvertising() async
  {
    try {
      bool a = await Nearby().startAdvertising(
        widget.userName,
        strategy,
        onConnectionInitiated: onConnectionInit,
        onConnectionResult: (id, status) {
          showSnackbar(status);
        },
        onDisconnected: (id) {
          showSnackbar(
              "Disconnected: ${endpointMap[id]!.endpointName}, id $id");
          setState(() {
            endpointMap.remove(id);
          });
        },
      );
      showSnackbar("Receiving mode on");
      print("Advertising: ${a.toString()}");
    } catch (exception) {
      showSnackbar(exception);
    }
  }
}
