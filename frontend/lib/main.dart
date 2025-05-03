import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart'; // for basename
import 'package:http_parser/http_parser.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
	@override
	State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
	File? _image;
	String _result = "";
	final String backendUrl = 'http://10.0.2.2:8000';

	// Function to capture image using camera
	Future<void> _takePhoto() async {
		final picked = await ImagePicker().pickImage(source: ImageSource.camera);
		if (picked != null) {
			setState(() {
				_image = File(picked.path);
			});
		}
	}

	// Function to upload image to FastAPI server
	Future<void> _uploadImage() async {
		if (_image == null) return;

		// Prepare multipart request
		var uri = Uri.parse('$backendUrl/upload/');
		var request = http.MultipartRequest('POST', uri);

		// Attach the image file
		request.files.add(await http.MultipartFile.fromPath(
			'file',
			_image!.path,
			contentType: MediaType('image', 'jpeg'),
		));

		// Send the request
		var response = await request.send();
		if (response.statusCode == 200) {
			// Parse response
			var respStr = await response.stream.bytesToString();
			setState(() {
				_result = respStr;
			});
		} else {
			setState(() {
				_result = 'Error: ${response.statusCode}';
			});
		}
	}

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Clothing Scanner',
			home: Scaffold(
				appBar: AppBar(title: Text('Clothing Scanner')),
				body: Padding(
					padding: const EdgeInsets.all(16.0),
					child: Column(
						children: [
							// Button to take a photo
							ElevatedButton(
								onPressed: _takePhoto,
								child: Text('Take Photo'),
							),
							SizedBox(height: 10),
							// Show the captured image if available
							if (_image != null) Image.file(_image!, height: 200),
							SizedBox(height: 10),
							// Button to upload the photo
							ElevatedButton(
								onPressed: _uploadImage,
								child: Text('Upload Photo'),
							),
							SizedBox(height: 10),
							// Display the JSON result
							Text('Result: $_result'),
						],
					),
				),
			),
		);
	}
}
