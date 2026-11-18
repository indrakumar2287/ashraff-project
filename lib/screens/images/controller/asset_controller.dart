import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AssetController extends GetxController {
  Rx<Uint8List?> selectedImage = Rx<Uint8List?>(null);

  Future<void> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final imagePicker = ImagePicker();
      XFile? xFile = await imagePicker.pickImage(source: source);

      if (xFile != null) {
        selectedImage.value = await xFile.readAsBytes();
        print("Bytes length > ${selectedImage.value?.length}");
        update();
      }
    } on Exception catch (e) {
      print('Error >> $e');
    }
  }
}
