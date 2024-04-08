import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery_picker/gallery_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? selctedMedia;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Text Recognition"),
        centerTitle: true,
      ),
      body: _buildUI(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          List<MediaFile>? media = await GalleryPicker.pickMedia(
              context: context, singleMedia: true);

          if (media != null && media.isNotEmpty) {
            var data = await media.first.getFile();
            setState(() {
              selctedMedia = data;
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _imageView(),
        Expanded(child: _extractTextView()),
      ],
    );
  }

  Widget _imageView() {
    if (selctedMedia == null) {
      return const Center(
        child: Text("Pick an Image for Text Recognition"),
      );
    } else {
      return Center(
        child: Image.file(
          selctedMedia!,
          width: 200,
        ),
      );
    }
  }

  Widget _extractTextView() {
    if (selctedMedia == null) {
      return const Center(
        child: Text('No result'),
      );
    }

    return FutureBuilder(
        future: _extractText(selctedMedia!),
        builder: (context, snapshot) {
          return Text(snapshot.data ?? "", style: const TextStyle(fontSize: 25),);
        });
  }

  Future<String?> _extractText(File file) async {
    final textRecognizer = TextRecognizer(
      script: TextRecognitionScript.latin,
    );

    final InputImage inputImage = InputImage.fromFile(file);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    String text = recognizedText.text;
    textRecognizer.close();
    return text;
  }
}
