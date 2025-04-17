import 'package:collection/collection.dart'; // For deep map equality
import 'package:flutter/foundation.dart'; // For @immutable and potentially kDebugMode

// --- Enums for Specific Option Choices ---

/// Represents common audio formats for extraction/conversion.
enum AudioFormat {
  best,
  aac,
  alac,
  flac,
  m4a,
  mp3,
  opus,
  vorbis,
  wav;

  /// Gets the string value expected by yt-dlp.
  String get value => name;
}

/// Represents common video containers for remuxing/recoding.
enum VideoContainerFormat {
  avi,
  flv,
  gif,
  mkv,
  mov,
  mp4,
  webm,
  // Audio-only containers sometimes used with remux:
  aac,
  aiff,
  alac,
  // flac, // Already in AudioFormat
  m4a, // Already in AudioFormat
  mka,
  mp3, // Already in AudioFormat
  ogg,
  opus, // Already in AudioFormat
  vorbis, // Already in AudioFormat
  wav; // Already in AudioFormat

  /// Gets the string value expected by yt-dlp.
  String get value => name;
}

/// Represents the policy for fixing up files.
enum FixupPolicy {
  never,
  warn,
  detect_or_warn, // Default in yt-dlp
  force;

  /// Gets the string value expected by yt-dlp.
  String get value => name.replaceAll('_', '-'); // yt-dlp uses hyphens here
}

// --- Main Configuration Model ---

@immutable
class YtdlpConfig {
  /// List of URLs (videos, playlists, channels) to process. (Required)
  final List<String> urls;

  // --- Common Options (Mapped to specific fields for type safety) ---

  // Filesystem
  /// Directory path to save files (sets -P). Use `outputTemplate` for filename.
  final String? outputPath;

  /// Output filename template (sets -o). See yt-dlp docs for syntax.
  /// Example: '%(title)s [%(id)s].%(ext)s'
  final String? outputTemplate;

  /// Overwrite existing files (sets --force-overwrites). Default: false (uses --no-force-overwrites behavior)
  final bool forceOverwrites;

  /// Do not overwrite existing files (sets --no-overwrites). Conflicts with forceOverwrites. Default: false.
  final bool noOverwrites;

  /// Resume partially downloaded files (sets --continue, default in yt-dlp).
  /// Setting this to `false` implies --no-continue.
  final bool continueDownload;

  /// Write video description to .description file.
  final bool writeDescription;

  /// Write video metadata to .info.json file.
  final bool writeInfoJson;

  /// Use .part files during download (default in yt-dlp).
  /// Setting this to `false` implies --no-part.
  final bool usePartFiles;

  // Download Control
  /// Ignore download errors and continue with playlist (sets --ignore-errors). Default: false.
  final bool ignoreErrors;

  /// Download playlist items in random order.
  final bool playlistRandom;

  /// Comma-separated playlist indices/ranges (e.g., "1,3-5,7"). Sets -I.
  final String? playlistItems;

  /// Maximum download rate (e.g., "50K", "4.2M"). Sets --limit-rate.
  final String? limitRate;

  /// Number of retries (default 10). Sets --retries. Use 'infinite' for infinite.
  final String? retries; // String to allow "infinite"
  /// Keep track of downloaded video IDs in this file. Sets --download-archive.
  final String? downloadArchive;

  // Video Format
  /// Video format code/selection preference. Sets -f.
  /// Examples: 'best', 'bv+ba/b', 'bestvideo[height<=?1080]+bestaudio/best', '22'
  final String? format;

  /// Sort order for formats. Sets -S. Example: 'height,fps,res,size'
  final String? formatSort;

  /// Merge output to a specific container (e.g., 'mkv', 'mp4'). Sets --merge-output-format.
  final VideoContainerFormat? mergeOutputFormat;

  // Audio Extraction / Conversion
  /// Extract audio track (sets -x). Requires ffmpeg.
  final bool extractAudio;

  /// Audio format to convert to when -x is used. Sets --audio-format.
  final AudioFormat? audioFormat;

  /// Audio quality (0=best to 10=worst, or bitrate like '128K'). Sets --audio-quality.
  final String?
      audioQuality; // String for flexibility (VBR number or bitrate string)
  /// Keep the original video file after processing when -x is used. Sets -k.
  final bool keepVideo;

  // Video Conversion / Remuxing
  /// Remux video to a different container if necessary. Sets --remux-video.
  final VideoContainerFormat? remuxVideoFormat;

  /// Re-encode video to a different format. Sets --recode-video.
  final VideoContainerFormat?
      recodeVideoFormat; // Less common, often remux is enough

  // Subtitles
  /// Write subtitle file. Sets --write-subs.
  final bool writeSubtitles;

  /// Write auto-generated subtitle file. Sets --write-auto-subs.
  final bool writeAutoSubtitles;

  /// Comma-separated list of subtitle languages (e.g., 'en,es', 'all,-live_chat'). Sets --sub-langs.
  final String? subtitleLangs;

  /// Subtitle format (e.g., 'srt', 'ass/srt/best'). Sets --sub-format.
  final String? subtitleFormat;

  /// Embed subtitles into the video file (mp4, mkv, webm). Sets --embed-subs.
  final bool embedSubtitles;

  /// Convert subtitles to a specific format (e.g., 'srt', 'vtt'). Sets --convert-subs.
  final String? convertSubtitlesFormat; // e.g., 'srt'

  // Thumbnails
  /// Write thumbnail image to disk. Sets --write-thumbnail.
  final bool writeThumbnail;

  /// Embed thumbnail into video/audio file as cover art. Sets --embed-thumbnail.
  final bool embedThumbnail;

  /// Convert thumbnail to a specific format (e.g., 'jpg', 'png'). Sets --convert-thumbnails.
  final String? convertThumbnailsFormat; // e.g., 'jpg'

  // Metadata
  /// Embed metadata (infojson, chapters) into the media file. Sets --embed-metadata.
  final bool embedMetadata;

  /// Embed chapters into the media file. Sets --embed-chapters. Enabled by embedMetadata unless disabled.
  final bool embedChapters;

  // Cookies / Authentication
  /// Path to Netscape cookie file. Sets --cookies.
  final String? cookiesFile;

  /// Load cookies from specified browser. Example: 'firefox', 'chrome'. Sets --cookies-from-browser.
  final String? cookiesFromBrowser;
  // Add username/password/twofactor/netrc if needed, but handle credentials securely!

  // Network
  /// Use specified proxy URL. Sets --proxy.
  final String? proxy;

  /// Client IP address to bind to. Sets --source-address.
  final String? sourceAddress;

  // Behavior / Verbosity
  /// Simulate download (do not download or write files). Sets -s.
  final bool simulate;

  /// Activate quiet mode (sets -q). Suppresses non-error output.
  final bool quiet;

  /// Print verbose debugging information (sets -v).
  final bool verbose;

  /// Policy for fixing known file faults. Sets --fixup.
  final FixupPolicy? fixup;

  // SponsorBlock
  /// Categories to mark as chapters. Sets --sponsorblock-mark. Example: "all,-preview"
  final String? sponsorBlockMark;

  /// Categories to remove from video. Sets --sponsorblock-remove. Example: "sponsor,intro"
  final String? sponsorBlockRemove;

  /// Catch-all for less common or custom options.
  /// Keys should be the yt-dlp option name (e.g., 'max-downloads', 'geo-bypass-country').
  /// Values should be the corresponding argument (String, int, bool, List<String>).
  /// The `toPythonOptionsMap` method will handle converting these.
  final Map<String, dynamic>? customOptions;

  const YtdlpConfig({
    required this.urls,
    // Filesystem
    this.outputPath,
    this.outputTemplate,
    this.forceOverwrites = false,
    this.noOverwrites = false,
    this.continueDownload = true, // Default in yt-dlp
    this.writeDescription = false,
    this.writeInfoJson = false,
    this.usePartFiles = true, // Default in yt-dlp
    // Download Control
    this.ignoreErrors = false,
    this.playlistRandom = false,
    this.playlistItems,
    this.limitRate,
    this.retries,
    this.downloadArchive,
    // Video Format
    this.format,
    this.formatSort,
    this.mergeOutputFormat,
    // Audio Extraction
    this.extractAudio = false,
    this.audioFormat,
    this.audioQuality,
    this.keepVideo = false, // Default is --no-keep-video
    // Video Conversion
    this.remuxVideoFormat,
    this.recodeVideoFormat,
    // Subtitles
    this.writeSubtitles = false,
    this.writeAutoSubtitles = false,
    this.subtitleLangs,
    this.subtitleFormat,
    this.embedSubtitles = false,
    this.convertSubtitlesFormat,
    // Thumbnails
    this.writeThumbnail = false,
    this.embedThumbnail = false,
    this.convertThumbnailsFormat,
    // Metadata
    this.embedMetadata = false,
    this.embedChapters = true, // Usually desired if embedMetadata is true
    // Cookies / Auth
    this.cookiesFile,
    this.cookiesFromBrowser,
    // Network
    this.proxy,
    this.sourceAddress,
    // Behavior / Verbosity
    this.simulate = false,
    this.quiet = false,
    this.verbose = false,
    this.fixup,
    // SponsorBlock
    this.sponsorBlockMark,
    this.sponsorBlockRemove,
    // Custom
    this.customOptions = const {},
  });

  /// Creates a copy of this config but with the given fields replaced with the new values.
  YtdlpConfig copyWith({
    List<String>? urls,
    // Optional<> wrapper might be needed for explicit null setting if required
    String? outputPath,
    String? outputTemplate,
    bool? forceOverwrites,
    bool? noOverwrites,
    bool? continueDownload,
    bool? writeDescription,
    bool? writeInfoJson,
    bool? usePartFiles,
    bool? ignoreErrors,
    bool? playlistRandom,
    String? playlistItems,
    String? limitRate,
    String? retries,
    String? downloadArchive,
    String? format,
    String? formatSort,
    VideoContainerFormat? mergeOutputFormat,
    bool? extractAudio,
    AudioFormat? audioFormat,
    String? audioQuality,
    bool? keepVideo,
    VideoContainerFormat? remuxVideoFormat,
    VideoContainerFormat? recodeVideoFormat,
    bool? writeSubtitles,
    bool? writeAutoSubtitles,
    String? subtitleLangs,
    String? subtitleFormat,
    bool? embedSubtitles,
    String? convertSubtitlesFormat,
    bool? writeThumbnail,
    bool? embedThumbnail,
    String? convertThumbnailsFormat,
    bool? embedMetadata,
    bool? embedChapters,
    String? cookiesFile,
    String? cookiesFromBrowser,
    String? proxy,
    String? sourceAddress,
    bool? simulate,
    bool? quiet,
    bool? verbose,
    FixupPolicy? fixup,
    String? sponsorBlockMark,
    String? sponsorBlockRemove,
    Map<String, dynamic>? customOptions,
  }) {
    return YtdlpConfig(
      urls: urls ?? this.urls,
      outputPath: outputPath ?? this.outputPath,
      outputTemplate: outputTemplate ?? this.outputTemplate,
      forceOverwrites: forceOverwrites ?? this.forceOverwrites,
      noOverwrites: noOverwrites ?? this.noOverwrites,
      continueDownload: continueDownload ?? this.continueDownload,
      writeDescription: writeDescription ?? this.writeDescription,
      writeInfoJson: writeInfoJson ?? this.writeInfoJson,
      usePartFiles: usePartFiles ?? this.usePartFiles,
      ignoreErrors: ignoreErrors ?? this.ignoreErrors,
      playlistRandom: playlistRandom ?? this.playlistRandom,
      playlistItems: playlistItems ?? this.playlistItems,
      limitRate: limitRate ?? this.limitRate,
      retries: retries ?? this.retries,
      downloadArchive: downloadArchive ?? this.downloadArchive,
      format: format ?? this.format,
      formatSort: formatSort ?? this.formatSort,
      mergeOutputFormat: mergeOutputFormat ?? this.mergeOutputFormat,
      extractAudio: extractAudio ?? this.extractAudio,
      audioFormat: audioFormat ?? this.audioFormat,
      audioQuality: audioQuality ?? this.audioQuality,
      keepVideo: keepVideo ?? this.keepVideo,
      remuxVideoFormat: remuxVideoFormat ?? this.remuxVideoFormat,
      recodeVideoFormat: recodeVideoFormat ?? this.recodeVideoFormat,
      writeSubtitles: writeSubtitles ?? this.writeSubtitles,
      writeAutoSubtitles: writeAutoSubtitles ?? this.writeAutoSubtitles,
      subtitleLangs: subtitleLangs ?? this.subtitleLangs,
      subtitleFormat: subtitleFormat ?? this.subtitleFormat,
      embedSubtitles: embedSubtitles ?? this.embedSubtitles,
      convertSubtitlesFormat:
          convertSubtitlesFormat ?? this.convertSubtitlesFormat,
      writeThumbnail: writeThumbnail ?? this.writeThumbnail,
      embedThumbnail: embedThumbnail ?? this.embedThumbnail,
      convertThumbnailsFormat:
          convertThumbnailsFormat ?? this.convertThumbnailsFormat,
      embedMetadata: embedMetadata ?? this.embedMetadata,
      embedChapters: embedChapters ?? this.embedChapters,
      cookiesFile: cookiesFile ?? this.cookiesFile,
      cookiesFromBrowser: cookiesFromBrowser ?? this.cookiesFromBrowser,
      proxy: proxy ?? this.proxy,
      sourceAddress: sourceAddress ?? this.sourceAddress,
      simulate: simulate ?? this.simulate,
      quiet: quiet ?? this.quiet,
      verbose: verbose ?? this.verbose,
      fixup: fixup ?? this.fixup,
      sponsorBlockMark: sponsorBlockMark ?? this.sponsorBlockMark,
      sponsorBlockRemove: sponsorBlockRemove ?? this.sponsorBlockRemove,
      customOptions: customOptions ?? this.customOptions,
    );
  }

  /// Converts this configuration into a Map suitable for the Python script's 'options' dictionary.
  /// Keys are yt-dlp command-line options (with hyphens).
  /// Values are arguments (as strings) or `true` for boolean flags.
  /// Null or default values for options are generally omitted unless they explicitly map
  /// to a --no-<option> flag or are the default behavior change.
  Map<String, dynamic> toPythonOptionsMap() {
    final Map<String, dynamic> options = {};

    // Helper to add option if value is not null (or bool is true)
    void addOption(String key, dynamic value) {
      if (value is bool) {
        if (value) options[key] = true; // Python script expects True for flags
      } else if (value != null) {
        options[key] = value.toString(); // Pass arguments as strings
      }
    }

    // Helper for boolean flags where false means adding the --no-<flag>
    void addBooleanOption(String key, bool value, bool defaultValue) {
      if (value != defaultValue) {
        options[value ? key : 'no-$key'] = true;
      }
    }

    // Filesystem
    if (outputPath != null)
      addOption('paths', outputPath); // -P maps to 'paths'
    if (outputTemplate != null)
      addOption('output', outputTemplate); // -o maps to 'output'
    if (forceOverwrites)
      addOption(
          'force-overwrites', true); // Overrides noOverwrites if both true
    else if (noOverwrites)
      addOption('no-overwrites', true); // Use else-if to avoid conflict
    addBooleanOption(
        'continue', continueDownload, true); // Default is true (--continue)
    addBooleanOption('write-description', writeDescription, false);
    addBooleanOption('write-info-json', writeInfoJson, false);
    addBooleanOption('part', usePartFiles, true); // Default is true (--part)

    // Download Control
    addOption('ignore-errors', ignoreErrors); // -i
    addOption('playlist-random', playlistRandom);
    if (playlistItems != null) addOption('playlist-items', playlistItems); // -I
    if (limitRate != null) addOption('limit-rate', limitRate); // -r
    if (retries != null) addOption('retries', retries); // -R
    if (downloadArchive != null) addOption('download-archive', downloadArchive);

    // Video Format
    if (format != null) addOption('format', format); // -f
    if (formatSort != null) addOption('format-sort', formatSort); // -S
    if (mergeOutputFormat != null)
      addOption('merge-output-format', mergeOutputFormat!.value);

    // Audio Extraction
    addOption('extract-audio', extractAudio); // -x
    if (extractAudio) {
      // Only add audio options if extracting
      if (audioFormat != null) addOption('audio-format', audioFormat!.value);
      if (audioQuality != null) addOption('audio-quality', audioQuality);
      addBooleanOption(
          'keep-video', keepVideo, false); // Default is --no-keep-video
    }

    // Video Conversion
    if (remuxVideoFormat != null)
      addOption('remux-video', remuxVideoFormat!.value);
    if (recodeVideoFormat != null)
      addOption('recode-video', recodeVideoFormat!.value);

    // Subtitles
    addBooleanOption('write-subs', writeSubtitles, false);
    addBooleanOption('write-auto-subs', writeAutoSubtitles, false);
    if (subtitleLangs != null) addOption('sub-langs', subtitleLangs);
    if (subtitleFormat != null) addOption('sub-format', subtitleFormat);
    addBooleanOption('embed-subs', embedSubtitles, false);
    if (convertSubtitlesFormat != null)
      addOption('convert-subs', convertSubtitlesFormat);

    // Thumbnails
    addBooleanOption('write-thumbnail', writeThumbnail, false);
    addBooleanOption('embed-thumbnail', embedThumbnail, false);
    if (convertThumbnailsFormat != null)
      addOption('convert-thumbnails', convertThumbnailsFormat);

    // Metadata
    addBooleanOption('embed-metadata', embedMetadata, false);
    if (embedMetadata) {
      // Only add chapter option if embedding metadata overall
      addBooleanOption('embed-chapters', embedChapters,
          true); // Default is true when embedMetadata is on
    }

    // Cookies / Auth
    if (cookiesFile != null) addOption('cookies', cookiesFile);
    if (cookiesFromBrowser != null)
      addOption('cookies-from-browser', cookiesFromBrowser);

    // Network
    if (proxy != null) addOption('proxy', proxy);
    if (sourceAddress != null) addOption('source-address', sourceAddress);

    // Behavior / Verbosity
    addOption('simulate', simulate); // -s
    addOption('quiet', quiet); // -q
    addOption('verbose', verbose); // -v
    if (fixup != null) addOption('fixup', fixup!.value);

    // SponsorBlock
    if (sponsorBlockMark != null)
      addOption('sponsorblock-mark', sponsorBlockMark);
    if (sponsorBlockRemove != null)
      addOption('sponsorblock-remove', sponsorBlockRemove);

    // Add custom options, converting keys if necessary
    if (customOptions != null) {
      customOptions!.forEach((key, value) {
        // Assume keys in customOptions are already hyphenated or need conversion
        final cliKey = key.replaceAll('_', '-'); // Ensure hyphenated
        if (value is bool) {
          if (value) options[cliKey] = true;
        } else if (value is List) {
          // Handle list values for options specified multiple times
          options[cliKey] = value.map((e) => e.toString()).toList();
        } else if (value != null) {
          options[cliKey] = value.toString();
        }
      });
    }

    return options;
  }

  @override
  String toString() {
    // Basic string representation for debugging
    return 'YtdlpConfig(urls: $urls, options: ${toPythonOptionsMap()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return other is YtdlpConfig &&
        listEquals(other.urls, urls) &&
        other.outputPath == outputPath &&
        other.outputTemplate == outputTemplate &&
        other.forceOverwrites == forceOverwrites &&
        other.noOverwrites == noOverwrites &&
        other.continueDownload == continueDownload &&
        other.writeDescription == writeDescription &&
        other.writeInfoJson == writeInfoJson &&
        other.usePartFiles == usePartFiles &&
        other.ignoreErrors == ignoreErrors &&
        other.playlistRandom == playlistRandom &&
        other.playlistItems == playlistItems &&
        other.limitRate == limitRate &&
        other.retries == retries &&
        other.downloadArchive == downloadArchive &&
        other.format == format &&
        other.formatSort == formatSort &&
        other.mergeOutputFormat == mergeOutputFormat &&
        other.extractAudio == extractAudio &&
        other.audioFormat == audioFormat &&
        other.audioQuality == audioQuality &&
        other.keepVideo == keepVideo &&
        other.remuxVideoFormat == remuxVideoFormat &&
        other.recodeVideoFormat == recodeVideoFormat &&
        other.writeSubtitles == writeSubtitles &&
        other.writeAutoSubtitles == writeAutoSubtitles &&
        other.subtitleLangs == subtitleLangs &&
        other.subtitleFormat == subtitleFormat &&
        other.embedSubtitles == embedSubtitles &&
        other.convertSubtitlesFormat == convertSubtitlesFormat &&
        other.writeThumbnail == writeThumbnail &&
        other.embedThumbnail == embedThumbnail &&
        other.convertThumbnailsFormat == convertThumbnailsFormat &&
        other.embedMetadata == embedMetadata &&
        other.embedChapters == embedChapters &&
        other.cookiesFile == cookiesFile &&
        other.cookiesFromBrowser == cookiesFromBrowser &&
        other.proxy == proxy &&
        other.sourceAddress == sourceAddress &&
        other.simulate == simulate &&
        other.quiet == quiet &&
        other.verbose == verbose &&
        other.fixup == fixup &&
        other.sponsorBlockMark == sponsorBlockMark &&
        other.sponsorBlockRemove == sponsorBlockRemove &&
        mapEquals(other.customOptions, customOptions);
  }

  @override
  int get hashCode {
    // Combine hash codes of all fields
    return Object.hashAll([
      Object.hashAll(urls), // Hash for list
      outputPath, outputTemplate, forceOverwrites, noOverwrites,
      continueDownload,
      writeDescription, writeInfoJson, usePartFiles, ignoreErrors,
      playlistRandom,
      playlistItems, limitRate, retries, downloadArchive, format, formatSort,
      mergeOutputFormat, extractAudio, audioFormat, audioQuality, keepVideo,
      remuxVideoFormat, recodeVideoFormat, writeSubtitles, writeAutoSubtitles,
      subtitleLangs, subtitleFormat, embedSubtitles, convertSubtitlesFormat,
      writeThumbnail, embedThumbnail, convertThumbnailsFormat, embedMetadata,
      embedChapters, cookiesFile, cookiesFromBrowser, proxy, sourceAddress,
      simulate, quiet, verbose, fixup, sponsorBlockMark, sponsorBlockRemove,
      const DeepCollectionEquality().hash(customOptions), // Hash for map
    ]);
  }
}
