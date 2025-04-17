/*import 'dart:convert'; // For JSON parsing of custom options
import 'package:flutter/material.dart';
// Assuming your model is in this file:
import 'package:myapp/models/yt-dlp_model.dart';
import 'package:myapp/externals/pyapp_yt-dlp.dart' as pyapp;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class YtdlpConfigScreen extends StatefulWidget {
  // Optional: Pass initial config if needed
  // final YtdlpConfig? initialConfig;

  const YtdlpConfigScreen({
    super.key,
    /* this.initialConfig */
  });

  @override
  State<YtdlpConfigScreen> createState() => _YtdlpConfigScreenState();
}

class _YtdlpConfigScreenState extends State<YtdlpConfigScreen> {
  // --- Controllers for TextFields ---
  final _urlsController = TextEditingController();
  final _outputPathController = TextEditingController();
  final _outputTemplateController = TextEditingController();
  final _playlistItemsController = TextEditingController();
  final _limitRateController = TextEditingController();
  final _retriesController = TextEditingController();
  final _downloadArchiveController = TextEditingController();
  final _formatController = TextEditingController();
  final _formatSortController = TextEditingController();
  final _audioQualityController = TextEditingController();
  final _subtitleLangsController = TextEditingController();
  final _subtitleFormatController = TextEditingController();
  final _convertSubtitlesFormatController = TextEditingController();
  final _convertThumbnailsFormatController = TextEditingController();
  final _cookiesFileController = TextEditingController();
  final _cookiesFromBrowserController = TextEditingController();
  final _proxyController = TextEditingController();
  final _sourceAddressController = TextEditingController();
  final _sponsorBlockMarkController = TextEditingController();
  final _sponsorBlockRemoveController = TextEditingController();
  final _customOptionsController = TextEditingController();

  // --- State Variables for Switches ---
  bool _forceOverwrites = false;
  bool _noOverwrites = false;
  bool _continueDownload = true;
  bool _writeDescription = true;
  bool _writeInfoJson = true;
  bool _usePartFiles = true;
  bool _ignoreErrors = true;
  bool _playlistRandom = false;
  bool _extractAudio = false;
  bool _keepVideo = false;
  bool _writeSubtitles = true;
  bool _writeAutoSubtitles = true;
  bool _embedSubtitles = true;
  bool _writeThumbnail = true;
  bool _embedThumbnail = true;
  bool _embedMetadata = true;
  bool _embedChapters = true;
  bool _simulate = false;
  bool _quiet = false;
  bool _verbose = false;

  // --- State Variables for Dropdowns ---
  VideoContainerFormat? _selectedMergeOutputFormat = VideoContainerFormat.mp4;
  AudioFormat? _selectedAudioFormat = AudioFormat.mp3;
  VideoContainerFormat? _selectedRemuxVideoFormat;
  VideoContainerFormat? _selectedRecodeVideoFormat;
  FixupPolicy? _selectedFixupPolicy = FixupPolicy.detect_or_warn;

  bool _isDownloading = false;
  late SharedPreferences _prefs;
  final String _lastOutputPathKey = 'last_output_path';

  pyapp.PyAppYtDlp? _pyApp;

  @override
  void initState() {
    super.initState();
    _loadLastOutputPath();
    // Set default values for other fields
    _outputTemplateController.text = '%(title)s [%(id)s].%(ext)s';
    _limitRateController.text = '1M';
    _retriesController.text = '10';
    _downloadArchiveController.text = 'downloaded.txt';
    _formatController.text = 'bestvideo[height<=1080]+bestaudio/best';
    _formatSortController.text = 'height,fps,res,size';
    _audioQualityController.text = '192K';
    _subtitleLangsController.text = 'en,es';
    _subtitleFormatController.text = 'srt';
    _convertSubtitlesFormatController.text = 'srt';
    _convertThumbnailsFormatController.text = 'jpg';
    _sponsorBlockMarkController.text = 'all,-preview';
    _sponsorBlockRemoveController.text = 'sponsor,intro';
    _customOptionsController.text = jsonEncode({
      'add-header': ['User-Agent:Mozilla/5.0'],
    });
  }

  Future<void> _loadLastOutputPath() async {
    _prefs = await SharedPreferences.getInstance();
    final lastPath = _prefs.getString(_lastOutputPathKey);
    if (lastPath != null) {
      _outputPathController.text = lastPath;
    }
  }

  Future<void> _pickOutputPath() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory != null) {
        setState(() {
          _outputPathController.text = selectedDirectory;
          _prefs.setString(_lastOutputPathKey, selectedDirectory);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting directory: $e')),
      );
    }
  }

  Future<void> _startStopDownload() async {
    if (_isDownloading) {
      // Stop the download
      setState(() {
        _isDownloading = false;
      });
      _pyApp?.stop();
      return;
    }

    // Start the download
    if (_urlsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least one URL')),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      final config = YtdlpConfig(
        urls: _urlsController.text
            .split('\n')
            .where((url) => url.isNotEmpty)
            .toList(),
        outputPath: _outputPathController.text,
        outputTemplate: _outputTemplateController.text,
        forceOverwrites: _forceOverwrites,
        noOverwrites: _noOverwrites,
        continueDownload: _continueDownload,
        writeDescription: _writeDescription,
        writeInfoJson: _writeInfoJson,
        usePartFiles: _usePartFiles,
        ignoreErrors: _ignoreErrors,
        playlistRandom: _playlistRandom,
        playlistItems: _playlistItemsController.text.isEmpty
            ? null
            : _playlistItemsController.text,
        limitRate: _limitRateController.text.isEmpty
            ? null
            : _limitRateController.text,
        retries:
            _retriesController.text.isEmpty ? null : _retriesController.text,
        downloadArchive: _downloadArchiveController.text.isEmpty
            ? null
            : _downloadArchiveController.text,
        format: _formatController.text.isEmpty ? null : _formatController.text,
        formatSort: _formatSortController.text.isEmpty
            ? null
            : _formatSortController.text,
        mergeOutputFormat: _selectedMergeOutputFormat,
        extractAudio: _extractAudio,
        audioFormat: _selectedAudioFormat,
        audioQuality: _audioQualityController.text.isEmpty
            ? null
            : _audioQualityController.text,
        keepVideo: _keepVideo,
        remuxVideoFormat: _selectedRemuxVideoFormat,
        recodeVideoFormat: _selectedRecodeVideoFormat,
        writeSubtitles: _writeSubtitles,
        writeAutoSubtitles: _writeAutoSubtitles,
        subtitleLangs: _subtitleLangsController.text.isEmpty
            ? null
            : _subtitleLangsController.text,
        subtitleFormat: _subtitleFormatController.text.isEmpty
            ? null
            : _subtitleFormatController.text,
        embedSubtitles: _embedSubtitles,
        convertSubtitlesFormat: _convertSubtitlesFormatController.text.isEmpty
            ? null
            : _convertSubtitlesFormatController.text,
        writeThumbnail: _writeThumbnail,
        embedThumbnail: _embedThumbnail,
        convertThumbnailsFormat: _convertThumbnailsFormatController.text.isEmpty
            ? null
            : _convertThumbnailsFormatController.text,
        embedMetadata: _embedMetadata,
        embedChapters: _embedChapters,
        cookiesFile: _cookiesFileController.text.isEmpty
            ? null
            : _cookiesFileController.text,
        cookiesFromBrowser: _cookiesFromBrowserController.text.isEmpty
            ? null
            : _cookiesFromBrowserController.text,
        proxy: _proxyController.text.isEmpty ? null : _proxyController.text,
        sourceAddress: _sourceAddressController.text.isEmpty
            ? null
            : _sourceAddressController.text,
        simulate: _simulate,
        quiet: _quiet,
        verbose: _verbose,
        fixup: _selectedFixupPolicy,
        sponsorBlockMark: _sponsorBlockMarkController.text.isEmpty
            ? null
            : _sponsorBlockMarkController.text,
        sponsorBlockRemove: _sponsorBlockRemoveController.text.isEmpty
            ? null
            : _sponsorBlockRemoveController.text,
        customOptions: _parseCustomOptions(),
      );

      _pyApp = pyapp.PyAppYtDlp(config);
      _pyApp!.onInit();
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting download: $e')),
      );
    }
  }

  Map<String, dynamic>? _parseCustomOptions() {
    try {
      if (_customOptionsController.text.isEmpty) return null;
      return jsonDecode(_customOptionsController.text) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    // Dispose controllers
    _urlsController.dispose();
    _outputPathController.dispose();
    _outputTemplateController.dispose();
    _playlistItemsController.dispose();
    _limitRateController.dispose();
    _retriesController.dispose();
    _downloadArchiveController.dispose();
    _formatController.dispose();
    _formatSortController.dispose();
    _audioQualityController.dispose();
    _subtitleLangsController.dispose();
    _subtitleFormatController.dispose();
    _convertSubtitlesFormatController.dispose();
    _convertThumbnailsFormatController.dispose();
    _cookiesFileController.dispose();
    _cookiesFromBrowserController.dispose();
    _proxyController.dispose();
    _sourceAddressController.dispose();
    _sponsorBlockMarkController.dispose();
    _sponsorBlockRemoveController.dispose();
    _customOptionsController.dispose();
    super.dispose();
  }

  // --- Helper to build Dropdown ---
  Widget _buildDropdown<T>({
    required String label,
    required T? currentValue,
    required List<T> items,
    required String Function(T) itemTextBuilder,
    required void Function(T?)? onChanged,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        filled: !enabled, // Visually indicate disabled state
        fillColor: enabled ? null : Colors.grey[200],
      ),
      value: currentValue,
      // If items doesn't contain currentValue (e.g. it's null), dropdown shows hint/label
      // Ensure currentValue is actually present in items or handle null case appropriately
      // It's generally better if the list includes a "None" or default option if currentValue can be null
      items: items.map((T value) {
        return DropdownMenuItem<T>(
          value: value,
          child: Text(itemTextBuilder(value)),
        );
      }).toList(),
      onChanged: enabled
          ? onChanged
          : null, // Disable onChanged callback if not enabled
      disabledHint: currentValue != null
          ? Text(itemTextBuilder(currentValue))
          : null, // Show current value when disabled
    );
  }

  // --- Helper for TextFields ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    bool enabled = true,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        filled: !enabled, // Visually indicate disabled state
        fillColor: enabled ? null : Colors.grey[200],
      ),
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: maxLines > 1 ? TextInputType.multiline : TextInputType.text,
    );
  }

  // --- Build the final config object ---
  YtdlpConfig _buildConfigFromState() {
    // Basic URL parsing (split by newline or comma, remove empty entries)
    List<String> urls = _urlsController.text
        .split(RegExp(r'[,\n]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // Parse custom options from JSON TextField
    Map<String, dynamic>? customOptions;
    try {
      if (_customOptionsController.text.trim().isNotEmpty) {
        final decoded = jsonDecode(_customOptionsController.text.trim());
        if (decoded is Map<String, dynamic>) {
          customOptions = decoded;
        } else {
          // Handle case where JSON is valid but not a map
          print("Warning: Custom options JSON is not a Map<String, dynamic>");
          // Optionally show a snackbar to the user
        }
      }
    } catch (e) {
      print("Error decoding custom options JSON: $e");
      // Optionally show a snackbar or validation message to the user
      // Provide empty map or null if parsing fails? Decide based on requirements.
      customOptions = null; // Or empty map: {}
    }

    return YtdlpConfig(
      urls: urls.isEmpty
          ? ['']
          : urls, // Ensure at least one empty string if none provided? Or validate.
      outputPath: _outputPathController.text.trim().nullIfEmpty(),
      outputTemplate: _outputTemplateController.text.trim().nullIfEmpty(),
      forceOverwrites: _forceOverwrites,
      noOverwrites: _noOverwrites,
      continueDownload: _continueDownload,
      writeDescription: _writeDescription,
      writeInfoJson: _writeInfoJson,
      usePartFiles: _usePartFiles,
      ignoreErrors: _ignoreErrors,
      playlistRandom: _playlistRandom,
      playlistItems: _playlistItemsController.text.trim().nullIfEmpty(),
      limitRate: _limitRateController.text.trim().nullIfEmpty(),
      retries: _retriesController.text.trim().nullIfEmpty(),
      downloadArchive: _downloadArchiveController.text.trim().nullIfEmpty(),
      format: _formatController.text.trim().nullIfEmpty(),
      formatSort: _formatSortController.text.trim().nullIfEmpty(),
      mergeOutputFormat: _selectedMergeOutputFormat,
      extractAudio: _extractAudio,
      audioFormat: _selectedAudioFormat,
      audioQuality: _audioQualityController.text.trim().nullIfEmpty(),
      keepVideo: _keepVideo,
      remuxVideoFormat: _selectedRemuxVideoFormat,
      recodeVideoFormat: _selectedRecodeVideoFormat,
      writeSubtitles: _writeSubtitles,
      writeAutoSubtitles: _writeAutoSubtitles,
      subtitleLangs: _subtitleLangsController.text.trim().nullIfEmpty(),
      subtitleFormat: _subtitleFormatController.text.trim().nullIfEmpty(),
      embedSubtitles: _embedSubtitles,
      convertSubtitlesFormat:
          _convertSubtitlesFormatController.text.trim().nullIfEmpty(),
      writeThumbnail: _writeThumbnail,
      embedThumbnail: _embedThumbnail,
      convertThumbnailsFormat:
          _convertThumbnailsFormatController.text.trim().nullIfEmpty(),
      embedMetadata: _embedMetadata,
      embedChapters: _embedChapters,
      cookiesFile: _cookiesFileController.text.trim().nullIfEmpty(),
      cookiesFromBrowser:
          _cookiesFromBrowserController.text.trim().nullIfEmpty(),
      proxy: _proxyController.text.trim().nullIfEmpty(),
      sourceAddress: _sourceAddressController.text.trim().nullIfEmpty(),
      simulate: _simulate,
      quiet: _quiet,
      verbose: _verbose,
      fixup: _selectedFixupPolicy,
      sponsorBlockMark: _sponsorBlockMarkController.text.trim().nullIfEmpty(),
      sponsorBlockRemove:
          _sponsorBlockRemoveController.text.trim().nullIfEmpty(),
      customOptions: customOptions,
    );
  }

  @override
  Widget build(BuildContext context) {
    const double itemSpacing = 16.0; // Spacing between form elements

    return Scaffold(
      appBar: AppBar(
        title: const Text('yt-dlp Configuration'),
        actions: [
          IconButton(
            icon: Icon(_isDownloading ? Icons.stop : Icons.play_arrow),
            onPressed: _startStopDownload,
            tooltip: _isDownloading ? 'Stop Download' : 'Start Download',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(itemSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(
                controller: _urlsController,
                label: 'Video/Playlist URLs',
                hintText: 'Enter URLs (one per line or comma-separated)',
                maxLines: 3),
            const SizedBox(height: itemSpacing),

            ExpansionTile(
              title: const Text('Filesystem Options'),
              initiallyExpanded: true,
              childrenPadding: const EdgeInsets.symmetric(
                      horizontal: itemSpacing / 2, vertical: itemSpacing / 2)
                  .copyWith(top: 0),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _outputPathController,
                        decoration: const InputDecoration(
                          labelText: 'Output Path',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _pickOutputPath,
                      icon: const Icon(Icons.folder),
                      label: const Text('Pick'),
                    ),
                  ],
                ),
                const SizedBox(height: itemSpacing),
                _buildTextField(
                    controller: _outputTemplateController,
                    label: 'Output Template (-o)'),
                const SizedBox(height: itemSpacing),
                SwitchListTile(
                  title: const Text('Force Overwrites (--force-overwrites)'),
                  value: _forceOverwrites,
                  onChanged: (value) => setState(() {
                    _forceOverwrites = value;
                    if (value)
                      _noOverwrites = false; // Ensure mutual exclusivity
                  }),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('No Overwrites (--no-overwrites)'),
                  value: _noOverwrites,
                  onChanged: (value) => setState(() {
                    _noOverwrites = value;
                    if (value)
                      _forceOverwrites = false; // Ensure mutual exclusivity
                  }),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Continue Downloads (--continue)'),
                  value: _continueDownload,
                  onChanged: (value) =>
                      setState(() => _continueDownload = value),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Write Description File'),
                  value: _writeDescription,
                  onChanged: (value) =>
                      setState(() => _writeDescription = value),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Write Info JSON File'),
                  value: _writeInfoJson,
                  onChanged: (value) => setState(() => _writeInfoJson = value),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Use .part Files (--part)'),
                  value: _usePartFiles,
                  onChanged: (value) => setState(() => _usePartFiles = value),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),

            ExpansionTile(
              title: const Text('Download Control'),
              childrenPadding: const EdgeInsets.symmetric(
                      horizontal: itemSpacing / 2, vertical: itemSpacing / 2)
                  .copyWith(top: 0),
              children: [
                SwitchListTile(
                  title: const Text('Ignore Errors (--ignore-errors)'),
                  value: _ignoreErrors,
                  onChanged: (value) => setState(() => _ignoreErrors = value),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Playlist Random (--playlist-random)'),
                  value: _playlistRandom,
                  onChanged: (value) => setState(() => _playlistRandom = value),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: itemSpacing),
                _buildTextField(
                    controller: _playlistItemsController,
                    label: 'Playlist Items (-I)',
                    hintText: 'e.g., 1,3-5'),
                const SizedBox(height: itemSpacing),
                _buildTextField(
                    controller: _limitRateController,
                    label: 'Limit Rate (-r)',
                    hintText: 'e.g., 50K, 4.2M'),
                const SizedBox(height: itemSpacing),
                _buildTextField(
                    controller: _retriesController,
                    label: 'Retries (-R)',
                    hintText: 'e.g., 10, infinite'),
                const SizedBox(height: itemSpacing),
                _buildTextField(
                    controller: _downloadArchiveController,
                    label: 'Download Archive File'),
              ],
            ),

            ExpansionTile(
              title: const Text('Format Selection'),
              childrenPadding: const EdgeInsets.symmetric(
                      horizontal: itemSpacing / 2, vertical: itemSpacing / 2)
                  .copyWith(top: 0),
              children: [
                _buildTextField(
                    controller: _formatController,
                    label: 'Format Selection (-f)',
                    hintText: 'e.g., best, bv+ba/b'),
                const SizedBox(height: itemSpacing),
                _buildTextField(
                    controller: _formatSortController,
                    label: 'Format Sort (-S)'),
                const SizedBox(height: itemSpacing),
                _buildDropdown<VideoContainerFormat>(
                  label: 'Merge Output Format (--merge-output-format)',
                  currentValue: _selectedMergeOutputFormat,
                  items: VideoContainerFormat
                      .values, // Add a "None" option if needed
                  itemTextBuilder: (format) => format.value,
                  onChanged: (value) =>
                      setState(() => _selectedMergeOutputFormat = value),
                ),
              ],
            ),

            ExpansionTile(
              title: const Text('Audio Options'),
              childrenPadding: const EdgeInsets.symmetric(
                      horizontal: itemSpacing / 2, vertical: itemSpacing / 2)
                  .copyWith(top: 0),
              children: [
                SwitchListTile(
                  title: const Text('Extract Audio (-x)'),
                  value: _extractAudio,
                  onChanged: (value) => setState(() => _extractAudio = value),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: itemSpacing),
                _buildDropdown<AudioFormat>(
                  label: 'Audio Format (--audio-format)',
                  currentValue: _selectedAudioFormat,
                  items: AudioFormat.values,
                  itemTextBuilder: (format) => format.value,
                  onChanged: (value) =>
                      setState(() => _selectedAudioFormat = value),
                  enabled:
                      _extractAudio, // Enable/disable based on extractAudio
                ),
                const SizedBox(height: itemSpacing),
                _buildTextField(
                  controller: _audioQualityController,
                  label: 'Audio Quality (--audio-quality)',
                  hintText: '0 (best) to 10 (worst) or 128K etc.',
                  enabled:
                      _extractAudio, // Enable/disable based on extractAudio
                ),
                const SizedBox(height: itemSpacing),
                SwitchListTile(
                  title: const Text('Keep Video File (-k)'),
                  value: _keepVideo,
                  onChanged: _extractAudio
                      ? (value) => setState(() => _keepVideo = value)
                      : null,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),

            ExpansionTile(
              title: const Text('Video Conversion'),
              childrenPadding: const EdgeInsets.symmetric(
                      horizontal: itemSpacing / 2, vertical: itemSpacing / 2)
                  .copyWith(top: 0),
              children: [
                _buildDropdown<VideoContainerFormat>(
                  label: 'Remux Video Format (--remux-video)',
                  currentValue: _selectedRemuxVideoFormat,
                  items: VideoContainerFormat
                      .values, // Consider adding a "None" item explicitly
                  itemTextBuilder: (format) => format.value,
                  onChanged: (value) =>
                      setState(() => _selectedRemuxVideoFormat = value),
                ),
                const SizedBox(height: itemSpacing),
                _buildDropdown<VideoContainerFormat>(
                  label: 'Recode Video Format (--recode-video)',
                  currentValue: _selectedRecodeVideoFormat,
                  items: VideoContainerFormat
                      .values, // Consider adding a "None" item explicitly
                  itemTextBuilder: (format) => format.value,
                  onChanged: (value) =>
                      setState(() => _selectedRecodeVideoFormat = value),
                ),
              ],
            ),

            ExpansionTile(
              title: const Text('Subtitle Options'),
              childrenPadding: const EdgeInsets.symmetric(
                      horizontal: itemSpacing / 2, vertical: itemSpacing / 2)
                  .copyWith(top: 0),
              children: [
                SwitchListTile(
                  title: const Text('Write Subtitles (--write-subs)'),
                  value: _writeSubtitles,
                  onChanged: (value) => setState(() => _writeSubtitles = value),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Write Auto Subtitles (--write-auto-subs)'),
                  value: _writeAutoSubtitles,
                  onChanged: _writeSubtitles
                      ? (value) => setState(() => _writeAutoSubtitles = value)
                      : null,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: itemSpacing),
                _buildTextField(
                  controller: _subtitleLangsController,
                  label: 'Subtitle Languages (--sub-langs)',
                  hintText: 'e.g., en,es,ja',
                  enabled: _writeSubtitles, // Only enable if writing subs
                ),
                const SizedBox(height: itemSpacing),
                _buildTextField(
                  controller: _subtitleFormatController,
                  label: 'Subtitle Format (--sub-format)',
                  hintText: 'e.g., srt, ass/srt/best',
                  enabled: _writeSubtitles, // Only enable if writing subs
                ),
                const SizedBox(height: itemSpacing),
                SwitchListTile(
                  title: const Text('Embed Subtitles (--embed-subs)'),
                  value: _embedSubtitles,
                  onChanged: _writeSubtitles
                      ? (value) => setState(() => _embedSubtitles = value)
                      : null,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: itemSpacing),
                _buildTextField(
                  controller: _convertSubtitlesFormatController,
                  label: 'Convert Subtitles Format (--convert-subs)',
                  hintText: 'e.g., srt, vtt',
                  enabled: _writeSubtitles, // Only enable if writing subs
                ),
              ],
            ),

            ExpansionTile(
              title: const Text('Thumbnail Options'),
              childrenPadding: const EdgeInsets.symmetric(
                      horizontal: itemSpacing / 2, vertical: itemSpacing / 2)
                  .copyWith(top: 0),
              children: [
                SwitchListTile(
                  title: const Text('Write Thumbnail (--write-thumbnail)'),
                  value: _writeThumbnail,
                  onChanged: (value) => setState(() => _writeThumbnail = value),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Embed Thumbnail (--embed-thumbnail)'),
                  value: _embedThumbnail,
                  onChanged: (value) => setState(() => _embedThumbnail = value),
                  // Keep enabled even if not writing separately? User might want only embedded.
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: itemSpacing),
                _buildTextField(
                  controller: _convertThumbnailsFormatController,
                  label: 'Convert Thumbnail Format (--convert-thumbnails)',
                  hintText: 'e.g., jpg, png',
                  enabled:
                      _writeThumbnail, // Only enable if writing separate thumb
                ),
              ],
            ),

            ExpansionTile(
              title: const Text('Metadata Options'),
              childrenPadding: const EdgeInsets.symmetric(
                      horizontal: itemSpacing / 2, vertical: itemSpacing / 2)
                  .copyWith(top: 0),
              children: [
                SwitchListTile(
                  title: const Text('Embed Metadata (--embed-metadata)'),
                  value: _embedMetadata,
                  onChanged: (value) => setState(() => _embedMetadata = value),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Embed Chapters (--embed-chapters)'),
                  value: _embedChapters,
                  onChanged: _embedMetadata
                      ? (value) => setState(() => _embedChapters = value)
                      : null,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),

            ExpansionTile(
              title: const Text('Authentication / Network'),
              childrenPadding: const EdgeInsets.symmetric(
                      horizontal: itemSpacing / 2, vertical: itemSpacing / 2)
                  .copyWith(top: 0),
              children: [
                _buildTextField(
                    controller: _cookiesFileController,
                    label: 'Cookies File (--cookies)'),
                const SizedBox(height: itemSpacing),
                _buildTextField(
                    controller: _cookiesFromBrowserController,
                    label: 'Cookies from Browser (--cookies-from-browser)'),
                const SizedBox(height: itemSpacing),
                _buildTextField(
                    controller: _proxyController, label: 'Proxy URL (--proxy)'),
                const SizedBox(height: itemSpacing),
                _buildTextField(
                    controller: _sourceAddressController,
                    label: 'Source IP Address (--source-address)'),
              ],
            ),

            ExpansionTile(
              title: const Text('Behavior / Verbosity'),
              childrenPadding: const EdgeInsets.symmetric(
                      horizontal: itemSpacing / 2, vertical: itemSpacing / 2)
                  .copyWith(top: 0),
              children: [
                SwitchListTile(
                  title: const Text('Simulate (--simulate)'),
                  value: _simulate,
                  onChanged: (value) => setState(() => _simulate = value),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Quiet Mode (--quiet)'),
                  value: _quiet,
                  onChanged: (value) => setState(() => _quiet = value),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Verbose Mode (--verbose)'),
                  value: _verbose,
                  onChanged: (value) => setState(() => _verbose = value),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: itemSpacing),
                _buildDropdown<FixupPolicy>(
                  label: 'Fixup Policy (--fixup)',
                  currentValue: _selectedFixupPolicy,
                  items: FixupPolicy
                      .values, // Consider adding a "None" item explicitly
                  itemTextBuilder: (policy) => policy.value,
                  onChanged: (value) =>
                      setState(() => _selectedFixupPolicy = value),
                ),
              ],
            ),

            ExpansionTile(
              title: const Text('SponsorBlock'),
              childrenPadding: const EdgeInsets.symmetric(
                      horizontal: itemSpacing / 2, vertical: itemSpacing / 2)
                  .copyWith(top: 0),
              children: [
                _buildTextField(
                    controller: _sponsorBlockMarkController,
                    label: 'Mark Categories (--sponsorblock-mark)'),
                const SizedBox(height: itemSpacing),
                _buildTextField(
                    controller: _sponsorBlockRemoveController,
                    label: 'Remove Categories (--sponsorblock-remove)'),
              ],
            ),

            ExpansionTile(
              title: const Text('Custom Options (Advanced)'),
              childrenPadding: const EdgeInsets.symmetric(
                      horizontal: itemSpacing / 2, vertical: itemSpacing / 2)
                  .copyWith(top: 0),
              children: [
                _buildTextField(
                  controller: _customOptionsController,
                  label: 'Custom Options (JSON format)',
                  hintText: 'e.g., {"option-name": "value", "flag-name": true}',
                  maxLines: 5,
                ),
                const SizedBox(height: itemSpacing),
                Text(
                  'Enter as a JSON object. Keys are yt-dlp option names (e.g., "max-downloads"). Values are strings, numbers, booleans, or lists of strings.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),

            const SizedBox(height: 30), // Space at the bottom
          ],
        ),
      ),
    );
  }
}

// Helper extension for TextFields where empty string should mean null config value
extension NullIfEmpty on String {
  String? nullIfEmpty() => isEmpty ? null : this;
}
*/