import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'dart:typed_data';

class Send extends StatefulWidget {
  String userName;
  Send({required this.userName});
  @override
  _SendState createState() => _SendState();
}

class _SendState extends State<Send> {
  final Strategy strategy = Strategy.P2P_STAR;
  Map<String, ConnectionInfo> endpointMap = Map();

  File? tempFile; //reference to the file currently being transferred
  Map<int, String> map =
  Map();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            title: Text("Send"),
            backgroundColor: Colors.deepOrangeAccent,
          ),
        backgroundColor: Colors.deepOrange,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Number of connected devices: ${endpointMap.length}",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white
                ) ,),
              SizedBox(height: 40,),
              FlatButton(onPressed: (){
                startDiscovery();
              },
                child: Text("Start Discovering", style: TextStyle(
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
              SizedBox(height: 50,),
              FlatButton(onPressed: (){
                stopDiscovery();
              },
                child: Text("Stop Discovering", style: TextStyle(
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
              SizedBox(height: 50,),
              FlatButton(onPressed: (){
                sendFile();
              },
                child: Text("Send File", style: TextStyle(
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

  startDiscovery() async
  {
    try {
      bool a = await Nearby().startDiscovery(
        widget.userName,
        strategy,
        onEndpointFound: (id, name, serviceId) {
          // show sheet automatically to request connection
          showModalBottomSheet(
            context: context,
            builder: (builder) {
              return Center(
                child: Column(
                  children: <Widget>[
                    Text("id: " + id),
                    Text("Name: " + name),
                    Text("ServiceId: " + serviceId),
                    ElevatedButton(
                      child: Text("Request Connection"),
                      onPressed: () {
                        Navigator.pop(context);
                        Nearby().requestConnection(
                          widget.userName,
                          id,
                          onConnectionInitiated: (id, info) {
                            onConnectionInit(id, info);
                          },
                          onConnectionResult: (id, status) {
                            showSnackbar(status);
                          },
                          onDisconnected: (id) {
                            setState(() {
                              endpointMap.remove(id);
                            });
                            showSnackbar(
                                "Disconnected from: ${endpointMap[id]!.endpointName}, id $id");
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        onEndpointLost: (id) {
          showSnackbar(
              "Lost discovered Endpoint: ${endpointMap[id]!.endpointName}, id $id");
        },
      );
      showSnackbar("DISCOVERING: " + a.toString());
    } catch (e) {
      showSnackbar(e);
    }
  }
  stopDiscovery()async {
    await Nearby().stopDiscovery();
    await Nearby().stopAllEndpoints().then((value) =>  showSnackbar("Discovery mode stopped"));
    setState(() {
      endpointMap.clear();
    });
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

  sendFile() async
  {
    FilePickerResult? file =
        await FilePicker.platform.pickFiles(type: FileType.any);
    if (file == null) return;

    for (MapEntry<String, ConnectionInfo> m
    in endpointMap.entries) {
      int payloadId =
          await Nearby().sendFilePayload(m.key, file.files.single.path.toString());
      showSnackbar("Sending file to ${m.key}");
      Nearby().sendBytesPayload(
          m.key,
          Uint8List.fromList(
              "$payloadId:${file.files.single.path.toString().split('/').last}".codeUnits));
    }
  }

}
