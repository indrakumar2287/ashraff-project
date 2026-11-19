import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopping_app/route_names.dart';
import 'package:shopping_app/screens/images/controller/asset_controller.dart';

class ImageWidgets extends StatefulWidget {
  const ImageWidgets({super.key});

  @override
  State<ImageWidgets> createState() => _ImageWidgetsState();
}

class _ImageWidgetsState extends State<ImageWidgets> {
  IconData _getFileIcon(String fileName) {
    String ext = fileName.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic'].contains(ext)) {
      return Icons.image;
    } else if (ext == 'pdf') {
      return Icons.picture_as_pdf;
    } else if (['mp4', 'avi', 'mov', 'mkv'].contains(ext)) {
      return Icons.video_file;
    } else if (['mp3', 'wav', 'aac', 'm4a'].contains(ext)) {
      return Icons.audio_file;
    } else if (['doc', 'docx', 'txt'].contains(ext)) {
      return Icons.description;
    } else if (['zip', 'rar', '7z'].contains(ext)) {
      return Icons.folder_zip;
    }
    return Icons.insert_drive_file;
  }

  @override
  Widget build(BuildContext context) {
    Get.put(AssetController());

    return GetBuilder<AssetController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Image & File Widgets"),
            actions: [
              IconButton(
                onPressed: () => Get.toNamed(RouteNames.chatList),
                icon: const Icon(Icons.chat),
                tooltip: 'Chats',
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),

                if (controller.isImage &&
                    controller.selectedImage.value != null)
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
                SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          await controller.pickImage(
                            source: ImageSource.camera,
                          );
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
                          await controller.pickImage(
                            source: ImageSource.gallery,
                          );
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
                        onTap: () async {
                          await controller.pickFile();
                        },
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
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    await controller.pickMultiImage();
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(child: Text("Pick Multiple Images")),
                  ),
                ),
                SizedBox(height: 20),

                if (controller.selectedFileName.value.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: InkWell(
                      onTap: () {
                        controller.openSelectedFile();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getFileIcon(controller.selectedFileName.value),
                              color: Colors.blue.shade700,
                              size: 30,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.selectedFileName.value,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Tap to open file",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.open_in_new,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                SizedBox(height: 20),
                GestureDetector(
                  onTap: (){
                    // controller.launchUrl(controller.customUrl) ;
                  },
                  child: Text(controller.customUrl),
                ) ,
                SizedBox(height: 20),

                Obx(() {
                  return SizedBox(
                    height: 400,
                    child: ListView.builder(
                      itemCount: controller.selectedMultiImages.value.length,
                      itemBuilder: (context, index) {
                        return Image.memory(
                          height: 200,
                          controller.selectedMultiImages.value[index]!,
                        );
                      },
                    ),
                  );
                }),


              ],
            ),
          ),
        );
      },
    );
  }
}
