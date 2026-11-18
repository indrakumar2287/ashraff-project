
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopping_app/screens/images/controller/asset_controller.dart';
import 'package:shopping_app/utils/app_images.dart';

class ImageWidgets extends StatefulWidget {
  const ImageWidgets({super.key});

  @override
  State<ImageWidgets> createState() => _ImageWidgetsState();
}

class _ImageWidgetsState extends State<ImageWidgets> {
  @override
  Widget build(BuildContext context) {
    Get.put(AssetController());

    return GetBuilder<AssetController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: Text("Image Widgets")),
          body: Column(
            children: [
              Container(
                color: Colors.red,
                height: 200,
                width: 200,
                child: Image.asset(
                  AppImages.photo1,
                  fit: BoxFit.cover,
                  errorBuilder: (context, obj, st) {
                    return Icon(
                      Icons.broken_image,
                      color: Colors.red,
                      size: 50,
                    );
                  },
                ),
              ),
              SizedBox(height: 20),

              if (controller.selectedImage.value != null)
                Container(
                  color: Colors.grey,
                  height: 200,
                  width: 200,
                  child: Image.memory(
                    controller.selectedImage.value!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, obj, st) {
                      return Icon(
                        Icons.broken_image,
                        color: Colors.red,
                        size: 50,
                      );
                    },
                  ),
                ),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await controller.pickImage(source: ImageSource.camera);
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(child: Text("Camera")),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await controller.pickImage(source: ImageSource.gallery);
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(child: Text("Gallery")),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(child: Text("File")),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
