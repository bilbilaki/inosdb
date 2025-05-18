import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class MoflixExtractor {
  static const String name = "Moflix";
  static const String mainUrl = "https://moflix-stream.xyz";

  Future<Map<String, dynamic>> server(String videoType, dynamic videoData) async {
    String src;
    
    if (videoType == 'episode') {
      final id = base64Encode(utf8.encode("tmdb|series|${videoData['tvShowId']}"));
      final mediaId = await _getMediaId(id);
      src = "$mainUrl/api/v1/titles/$mediaId/seasons/${videoData['season']}/episodes/${videoData['episode']}?loader=episodePage";
    } else {
      final id = base64Encode(utf8.encode("tmdb|movie|${videoData['id']}"));
      src = "$mainUrl/api/v1/titles/$id?loader=titlePage";
    }
    
    return {
      'id': name,
      'name': name,
      'src': src,
    };
  }

  Future<String> _getMediaId(String id) async {
    try {
      final response = await http.get(
        Uri.parse("$mainUrl/api/v1/titles/$id?loader=titlePage"),
        headers: {'referer': mainUrl},
      );
      final data = jsonDecode(response.body);
      return data['title']['id'].toString();
    } catch (e) {
      return id;
    }
  }

  Future<String> extract(String link) async {
    final response = await http.get(
      Uri.parse(link),
      headers: {'referer': mainUrl},
    );
    final data = jsonDecode(response.body);
    
    final frames = (data['episode'] ?? data['title'])['videos']
        .where((video) => video['category'].toLowerCase() == 'full')
        .toList();
    
    if (frames.isEmpty) throw Exception("No frames found");
    
    for (var frame in frames) {
      try {
        final iframeSrc = frame['src'];
        if (iframeSrc == null) continue;
        
        final iframeResponse = await http.get(Uri.parse(iframeSrc));
        final host = Uri.parse(iframeSrc).host;
        
        // Extract script content
        final script = _extractScriptContent(iframeResponse.body);
        
        // Find m3u8 URL
        final m3u8 = _extractM3u8Url(script);
        
        // Check for dub (simplified)
        final hasDub = await _checkForDub(m3u8, host);
        if (!hasDub) continue;
        
        return m3u8;
      } catch (e) {
        continue;
      }
    }
    
    throw Exception("Failed to extract video");
  }

  String _extractScriptContent(String html) {
    // Implement script extraction logic
    // This would parse the HTML and find the relevant script tag
    return '';
  }

  String _extractM3u8Url(String script) {
    // Implement regex to find m3u8 URL
    final regex = RegExp(r'file:\s*\"(.*?m3u8.*?)\"');
    final match = regex.firstMatch(script);
    if (match == null) throw Exception("Can't find m3u8");
    return match.group(1)!;
  }

  Future<bool> _checkForDub(String m3u8Url, String host) async {
    final response = await http.get(Uri.parse(m3u8Url));
    return response.body.contains("TYPE=AUDIO");
  }
}