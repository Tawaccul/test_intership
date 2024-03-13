import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _image;
  TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Screen'),
      ),
      body: Column(
        children: [
          _image == null ? Placeholder() : Image.file(_image!),
          TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: 'Enter your comment...',
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final imagePicker = ImagePicker();
              final pickedFile = await imagePicker.getImage(source: ImageSource.camera);
              if (pickedFile != null) {
                setState(() {
                  _image = File(pickedFile.path);
                });

                final position = await Geolocator.getCurrentPosition();
                final latitude = position.latitude;
                final longitude = position.longitude;
                final comment = _commentController.text;

                final url = 'https://flutter-sandbox.free.beeceptor.com/upload_photo/';
                var request = http.MultipartRequest('POST', Uri.parse(url))
                  ..fields['comment'] = comment
                  ..fields['latitude'] = latitude.toString()
                  ..fields['longitude'] = longitude.toString()
                  ..files.add(await http.MultipartFile.fromPath('photo', _image!.path));

                var response = await request.send();
                if (response.statusCode == 200) {
                  // Handle success
                } else {
                  // Handle failure
                }
              }
            },
            child: Text('Send Request'),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CameraScreen(),
  ));
}
