import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';

class MStreamClickExtractor {
  final String name = "${utf8.decode(base64.decode("bW9mbGl4LQ=="))}${utf8.decode(base64.decode("c3RyZWFtLmNsaWNr"))}";
  final String mainUrl = "${utf8.decode(base64.decode("aHR0cHM6Ly9tb2ZsaXgt"))}${utf8.decode(base64.decode("c3RyZWFtLmNsaWNrLw=="))}";

  Future<Video> extract(String link) async {
    final response = await http.get(Uri.parse(link));
    if (response.statusCode != 200) {
      throw Exception('Failed to load content');
    }

    final document = html_parser.parse(response.body);
    final scripts = document.getElementsByTagName('script');
    
    String? packedSource;
    for (var script in scripts) {
      if (script.text.contains("eval(function(p,a,c,k,e,d)")) {
        packedSource = script.text;
        break;
      }
    }

    if (packedSource == null) {
      throw Exception('Could not find packed JavaScript');
    }

    final unpackedSource = _unpackJavaScript(packedSource);
    final url = unpackedSource.split('file:"')[1].split('"}]')[0];

    return Video(source: url);
  }

  String _unpackJavaScript(String packed) {
    // This is a simplified version - you might need a proper JS unpacker implementation
    // For a complete solution, consider porting the JsUnpacker or using a Dart package
    if (packed.startsWith("eval")) {
      packed = packed.substring(4);
    }
    
    // Simple extraction - this won't work for all cases
    final matches = RegExp(r'file:"([^"]+)"').allMatches(packed);
    if (matches.isNotEmpty) {
      return packed;
    }
    
    // Fallback - in a real implementation you'd need proper JS unpacking
    return packed;
  }
}

class Video {
  final String source;

  Video({required this.source});
}