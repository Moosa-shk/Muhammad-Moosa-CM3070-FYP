import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

/// Cloudinary configuration class.
/// Stores static configuration values used for uploading images.
class CloudinaryConfig {

  /// Cloudinary cloud account name
  static const cloudName = "drwrlrpzs";

  /// Unsigned upload preset created in Cloudinary dashboard
  static const unsignedPreset = "disasteraid_preset";

  /// Default folder where uploaded images will be stored
  static const defaultFolder = "disasteraid_users";
}

/// Service class responsible for uploading images to Cloudinary.
class CloudinaryService {

  /// Uploads an image file to Cloudinary using an unsigned upload preset.
  /// Returns the secure URL of the uploaded image.
  static Future<String> uploadImageUnsigned(File file) async {

    /// Build the Cloudinary upload endpoint URL
    final url = Uri.parse(
        "https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload");

    /// Create a multipart HTTP POST request
    final req = http.MultipartRequest("POST", url)

      /// Attach required Cloudinary upload preset
      ..fields["upload_preset"] = CloudinaryConfig.unsignedPreset

      /// Specify the destination folder inside Cloudinary
      ..fields["folder"] = CloudinaryConfig.defaultFolder;

    /// Extract the file extension to determine image type
    final ext = p.extension(file.path).replaceAll(".", "");

    /// Attach the image file to the multipart request
    req.files.add(
      await http.MultipartFile.fromPath(
        "file",
        file.path,
        contentType: MediaType("image", ext),
      ),
    );

    /// Send the upload request
    final res = await req.send();

    /// Convert streamed response into readable HTTP response
    final body = await http.Response.fromStream(res);

    /// If upload fails, throw an error with response details
    if (body.statusCode != 200) {
      throw "Cloudinary upload failed: ${body.body}";
    }

    /// Extract the secure image URL from the response JSON
    final match =
        RegExp('"secure_url":"(.*?)"').firstMatch(body.body)?.group(1);

    /// If URL is missing, throw an error
    if (match == null) throw "secure_url missing in response";

    /// Return the final image URL
    return match.replaceAll(r'\/', '/');
  }
}