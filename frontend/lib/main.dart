import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
	@override
	State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
	File? _image;
	String _result = "";
	final String backendUrl = 'http://10.0.2.2:8000'; // Change if using physical device

	// Function to handle both camera and gallery input
	Future<void> _pickImage(ImageSource source) async {
		final picked = await ImagePicker().pickImage(source: source);
		if (picked != null) {
			final imageFile = File(picked.path);
			setState(() {
				_image = imageFile;
				_result = "Uploading...";
			});
			await _uploadImage(imageFile);
		}
	}

	// Automatically uploads the selected image
	Future<void> _uploadImage(File imageFile) async {
		try {
			var uri = Uri.parse('$backendUrl/upload/');
			var request = http.MultipartRequest('POST', uri);

			final extension = imageFile.path.split('.').last;
			final mediaType = extension == 'png' ? 'png' : 'jpeg';

			request.files.add(await http.MultipartFile.fromPath(
				'file',
				imageFile.path,
				contentType: MediaType('image', mediaType),
			));

			var response = await request.send();
			if (response.statusCode == 200) {
				var respStr = await response.stream.bytesToString();
				setState(() {
					_result = respStr;
				});
			} else {
				setState(() {
					_result = 'Error: ${response.statusCode}';
				});
			}
		} catch (e) {
			setState(() {
				_result = 'Upload failed: $e';
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
					child: Center(
                      child: Column(
                        // Center the content vertically
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Take Photo button
                          ElevatedButton(
                            onPressed: () => _pickImage(ImageSource.camera),
                            child: Text('Take Photo'),
                          ),
                          SizedBox(height: 10),
                          // Choose from gallery button
                          ElevatedButton(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            child: Text('Upload from Storage'),
                          ),
                          SizedBox(height: 20),
                          // Show the selected image
                          if (_image != null)
                            Image.file(_image!, height: 200),
                          SizedBox(height: 20),
                          // Show result
                          Text('Result: $_result'),
                        ],
                      ),
                    ),
				),
			),
		);
	}
}
