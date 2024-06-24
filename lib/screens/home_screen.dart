import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';

final imagePicker = ImagePicker();
final gemini = Gemini.instance;

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  File? _pickedImage;
  String? _result;
  void _openModal() async {
    ImageSource? source;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text("Find your picture"),
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                source = ImageSource.camera;
                Navigator.of(context).pop();
              },
              label: Text("Camera"),
              icon: Icon(Icons.add_a_photo),
            ),
            ElevatedButton.icon(
              onPressed: () {
                source = ImageSource.gallery;
                Navigator.of(context).pop();
              },
              label: Text("Gallery"),
              icon: Icon(Icons.add_photo_alternate),
            )
          ],
        );
      },
    );
    if (source != null) {
      _takePicture(source!);
    }
  }

  void _takePicture(ImageSource source) async {
    final result = await imagePicker.pickImage(source: source);
    setState(() {
      _pickedImage = File(result!.path);
    });
    final response = await gemini.textAndImage(
        text:
            "first of all, must check whether the picture only include food or food ingredient only or not. if there are no food or food ingredient, then show wrong picture text. and if there are food or food ingredient, then could you recommend any food using this picture? must use the ingredient on picture only.",
        images: [File(result!.path).readAsBytesSync()]);
    setState(() {
      _result = response!.content!.parts![0].text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "what to eat today",
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                clipBehavior: Clip.hardEdge,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
                child: InkWell(
                    onTap: _openModal,
                    child: _pickedImage == null
                        ? Container(
                            width: double.infinity,
                            height: 400,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            child: Center(
                              child: Icon(
                                Icons.add_a_photo,
                                size: 50,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                            ),
                          )
                        : Image.file(_pickedImage!)),
              ),
            ),
            SizedBox(
              height: 24,
            ),
            GeminiResponseTypeView(
              builder: (context, child, response, loading) {
                if (loading) {
                  return CircularProgressIndicator();
                }

                if (_result != null) {
                  return SizedBox(
                    width: double.infinity,
                    height: 300,
                    child: Markdown(
                      data: _result!,
                      selectable: true,
                    ),
                  );
                } else {
                  return Text("Searching...");
                }
              },
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (value) {},
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_a_photo_outlined),
            label: "Picture",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.input),
            label: "Text",
          )
        ],
      ),
    );
  }
}
