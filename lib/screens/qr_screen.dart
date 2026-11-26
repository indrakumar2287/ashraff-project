

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/item_model.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {

  MobileScannerController mobileScannerController = MobileScannerController();

  String dataPrice = '' ;
  String dataName = '' ;
  String errorText = '' ;

  ItemModel itemData = ItemModel(
    id: 12412312,
    name:  "Keyboard",
    price: 345
  ) ;



  String itemDataString = '' ;
  bool isLoadingApi = false ;


  @override
  void initState() {
    itemDataString = jsonEncode(itemData.toJson()) ;
    print("itemDataString >> ${itemDataString}") ;
    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("QR Screen"),
      ),
      body: Column(
        children: [
          if(isLoadingApi) CircularProgressIndicator(
            color: Colors.black,
          ) ,
             errorText.isEmpty ?  Column(
            children: [
              Text(
                "Name >> ${dataName}",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.blue
                ),
              ),
              Text(
                "Price >> ${dataPrice}",
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.blue
                ),
              ),
            ],
          ):  Text(
            errorText,
            style: TextStyle(
              color: Colors.red
            ),
          ),

          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Container(
          //       padding: EdgeInsets.all(10),
          //       decoration: BoxDecoration(
          //         color: Colors.red.withAlpha(100),
          //         borderRadius: BorderRadius.circular(20),
          //         border: Border.all(
          //           color: Colors.red
          //         )
          //       ),
          //
          //       child:  Text("Show QR")
          //     ),
          //     SizedBox(width: 20,),
          //
          //     Container(
          //         padding: EdgeInsets.all(10),
          //         decoration: BoxDecoration(
          //             color: Colors.red.withAlpha(100),
          //             borderRadius: BorderRadius.circular(20),
          //             border: Border.all(
          //                 color: Colors.red
          //             )
          //         ),
          //
          //
          //         child:  Text("Scan QR")
          //     ),
          //
          //
          //
          //   ],
          // ),

          SizedBox(height: 20,),
          Expanded(
            child:

            MobileScanner(
              controller: mobileScannerController,
              tapToFocus: true,
              onDetectError: (data, st){
                setState(() {
                  errorText = data.toString() ;
                });
              },
              onDetect: (data) async {


                if(isLoadingApi){
                  return ;
                }
                setState(() {
                  isLoadingApi =  true ;
                });

                final String result = data.barcodes.first.rawValue  ?? '{}';

                Map dataMap = jsonDecode(result) ;

                final itemModel = ItemModel.fromJson(dataMap) ;
                print("dataMap >> ${itemModel.name}");
                await Future.delayed(Duration(seconds: 5)) ;
                setState(() {
                  isLoadingApi =  false ;
                });

                setState(() {
                  dataName = itemModel.name ?? '' ;
                  dataPrice =  itemModel.price?.toString() ?? '' ;
                });






              },

            ),
          ) ,
          SizedBox(height: 20,),
          QrImageView(
            data: itemDataString,
            size: 200,
            // backgroundColor: Colors.blue,
            // gapless: false,
            // dataModuleStyle: QrDataModuleStyle(
            //   dataModuleShape: QrDataModuleShape.circle,
            //   color: Colors.black
            // ),



          ),

        ],
      ).paddingAll(10),
    );
  }
}
