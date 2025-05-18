// TODO Implement this library.
import 'package:flutter/material.dart';

class DownloadsScreen extends StatelessWidget {
  final String? urllink;
  const DownloadsScreen({ this.urllink, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
      ),
    );
  }
}