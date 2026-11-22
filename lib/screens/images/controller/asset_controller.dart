import 'dart:io';
import 'dart:typed_data';


import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';

class AssetController extends GetxController {
  Rx<Uint8List?> selectedImage = Rx<Uint8List?>(null);
  Rx<List<Uint8List?>> selectedMultiImages = Rx<List<Uint8List?>>([]);
  RxString selectedFileName = ''.obs;
  RxString selectedFilePath = ''.obs;

  bool get isImage {
    if (selectedFileName.value.isEmpty) return selectedImage.value != null;
    final ext = selectedFileName.value.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic'].contains(ext);
  }

  Future<void> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final imagePicker = ImagePicker();
      XFile? xFile = await imagePicker.pickImage(source: source);

      if (xFile != null) {
        selectedImage.value = await xFile.readAsBytes();
        selectedFileName.value = xFile.name;
        selectedFilePath.value = xFile.path;
        print("Bytes length > ${selectedImage.value?.length}");
        update();
      }
    } on Exception catch (e) {
      print('Error >> $e');
    }
  }

  Future<void> pickMultiImage() async {
    try {
      final imagePicker = ImagePicker();
      List<XFile> xFiles = await imagePicker.pickMultiImage();
      XFile? xFile = xFiles.lastOrNull  ;

      if(xFiles != null) {
        selectedMultiImages.value.clear() ;
        for (int i = 0; i < xFiles!.length; i++) {
          print("Path $i> ${xFiles[i].path}") ;


          final bytes = await xFiles[i].readAsBytes()  ;
          selectedMultiImages.value.add(bytes) ;
        }
      }

      if (xFile != null) {
        selectedImage.value = await xFile.readAsBytes();
        selectedFileName.value = xFile.name;
        selectedFilePath.value = xFile.path;
        print("Bytes length > ${selectedImage.value?.length}");
        update();
      }
    } on Exception catch (e) {
      print('Error >> $e');
    }
  }

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.any,
        withData: true,
        allowMultiple: true
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        if (file.bytes != null) {
          selectedImage.value = file.bytes;
        } else if (file.path != null) {
          selectedImage.value = await File(file.path!).readAsBytes();
        }
        selectedFileName.value = file.name;
        selectedFilePath.value = file.path ?? '';
        print("File picked > ${file.name}, bytes > ${selectedImage.value?.length}");
        update();
      }
    } on Exception catch (e) {
      print('Error picking file >> $e');
    }
  }

  Future<void> openSelectedFile() async {
    if (selectedFilePath.value.isNotEmpty) {
      final result = await OpenFilex.open(selectedFilePath.value);
      if (result.type != ResultType.done) {
        Get.snackbar(
          "Error",
          "Could not open file: ${result.message}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else if (selectedImage.value != null && selectedFileName.value.isNotEmpty) {
      try {
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/${selectedFileName.value}');
        await tempFile.writeAsBytes(selectedImage.value!);
        selectedFilePath.value = tempFile.path;
        await OpenFilex.open(tempFile.path);
      } catch (e) {
        Get.snackbar(
          "Error",
          "Could not open file",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        "No File",
        "Please select a file first",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String customUrl = 'https://pub.dev/packages/url_launcher' ;
  // Future<void> launchUrl(String url ) async {
  //  final uri =  Uri.parse(customUrl) ;
  //   // if ( await launchUrl(uri)) {
  //   //   throw Exception('Could not launch $url');
  //   // }
  //   await launchUrl(uri) ;
  // }

}
