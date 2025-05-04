import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import '../models/clothing_item.dart';

class ClothingService {
  static const String baseUrl = 'https://e54d-147-83-201-101.ngrok-free.app';

  Future<List<ClothingItem>> uploadImage(File imageFile) async {
    try {
      final uri = Uri.parse('$baseUrl/upload/');
      final request = http.MultipartRequest('POST', uri);

      final extension = imageFile.path.split('.').last.toLowerCase();
      final mediaType = extension == 'png' ? 'png' : 'jpeg';

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType('image', mediaType),
      ));

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(respStr);
        return jsonList.map((json) => ClothingItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }
}
