import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ImageUploadScreen extends StatefulWidget {
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  List<File> _imageFiles = []; // Use File directly

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();

    if (images?.isNotEmpty ?? false) {
      setState(() {
        _imageFiles = images!.map((xfile) => File(xfile.path)).toList(); // Convert to File
      });
    }
  }

  Future<void> _uploadImages() async {
    if (_imageFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please pick at least one image first.")));
      return;
    }

    Uri url = Uri.parse("https://www.workdonecorp.com/api/upload_image");
    var request = http.MultipartRequest('POST', url);

    for (var imageFile in _imageFiles) {
      request.files.add(http.MultipartFile(
        'images',
        imageFile.readAsBytes().asStream(),
        imageFile.lengthSync(),
        filename: imageFile.path.split('/').last,
      ));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Images uploaded!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image upload failed!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _imageFiles.isNotEmpty
                  ? GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                itemCount: _imageFiles.length,
                itemBuilder: (context, index) {
                  return Image.file(_imageFiles[index]);
                },
              )
                  : ElevatedButton(
                onPressed: _pickImages,
                child: Text('Choose Images'),
              ),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _uploadImages,
            child: Text('Upload Images'),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}