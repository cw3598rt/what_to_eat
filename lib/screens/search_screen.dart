import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

final imagePicker = ImagePicker();
final gemini = Gemini.instance;
Location location = Location();
var format = DateFormat.yMd();

class SearchScreen extends StatefulWidget {
  SearchScreen({super.key, required this.detailOption});

  bool detailOption;

  @override
  State<SearchScreen> createState() {
    return _SearchScreenState();
  }
}

class _SearchScreenState extends State<SearchScreen> {
  File? _pickedImage;
  String? _result;
  String? _pictureResult;

  bool _isKorean = false;
  bool _isLoading = false;
  void _initLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData? locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();

    var response = await gemini.text(
        "You are a best chef. and Please suggest me top3 food for today. Your answer must be with name and recipe of the recommended food only beside recommended food name and recipe, please do not write on your answer! when you search the reference for the suggestion, please consider certain country where include this location in latitude ${locationData.latitude} and longitude ${locationData.longitude} and time must be ${DateTime.now().hour}");

    if (response != null) {
      if (response.content != null) {
        setState(() {
          _result = response.content!.parts![0].text;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _initLocation();
  }

  @override
  void didUpdateWidget(covariant SearchScreen oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);

    if (widget.detailOption) {
      _initLocation();
    } else {
      gemini.cancelRequest();
      setState(() {
        _result = null;
        _isKorean = false;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    gemini.cancelRequest();
  }

  void _openModal() async {
    setState(() {
      _pictureResult = null;
      _pickedImage = null;
    });

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
            "first of all, must check whether the picture only include food or food ingredient only or not. if there are no food or food ingredient, then show wrong picture text. and if there are food or food ingredient, then could you recommend any food using this picture? must use the ingredient on picture only. Answer must be with name and recipe of the recommended food only beside recommended food name and recipe, please do not write on your answer!",
        images: [File(result!.path).readAsBytesSync()]);

    if (response != null) {
      if (response.content != null) {
        setState(() {
          _pictureResult = response.content!.parts![0].text;
        });

        // RegExp regExp = RegExp(r'(?<=## \*\*).*(?=\*\*)',
        //     multiLine: true, caseSensitive: false);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        // List<String> menuNames = regExp
        //     .allMatches(response.content!.parts![0].text!)
        //     .map((item) => item.group(0).toString())
        //     .toList();

        await prefs.setString('menu', response.content!.parts![0].text!);
      }
    }
  }

  void _translate(String lang) async {
    if (widget.detailOption) {
      setState(() {
        _isLoading = true;
      });
      var response = await gemini.text("please translate $_result in $lang");

      if (response != null) {
        if (response.content != null) {
          setState(() {
            _result = response.content!.parts![0].text;
            _isKorean = !_isKorean;
          });
        }
      }
    } else {
      setState(() {
        _isLoading = true;
      });
      var response =
          await gemini.text("please translate $_pictureResult in $lang");

      if (response != null) {
        if (response.content != null) {
          setState(() {
            _pictureResult = response.content!.parts![0].text;
            _isKorean = !_isKorean;
          });
        }
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: TextButton(
            onPressed: () {
              if (widget.detailOption) {
                if (_result == null) {
                  return null;
                }
                _isKorean ? _translate("English") : _translate("Korean");
              } else {
                if (_pictureResult == null) {
                  return null;
                }
                _isKorean ? _translate("English") : _translate("Korean");
              }
            },
            child: _isKorean ? Text("English") : Text("Korean"),
          ),
        ),
        !widget.detailOption
            ? Padding(
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
                        : Image.file(_pickedImage!),
                  ),
                ),
              )
            : Text(""),
        SizedBox(
          height: 24,
        ),
        !_isLoading
            ? GeminiResponseTypeView(
                builder: (context, child, response, loading) {
                  if (widget.detailOption) {
                    if (_result != null) {
                      return SizedBox(
                        width: double.infinity,
                        height: 600,
                        child: Markdown(
                          data: _result!,
                          selectable: true,
                        ),
                      );
                    } else {
                      return Text("Searching...");
                    }
                  } else {
                    if (_pictureResult != null) {
                      return SizedBox(
                        width: double.infinity,
                        height: 600,
                        child: Markdown(
                          data: _pictureResult!,
                          selectable: true,
                        ),
                      );
                    } else {
                      return _pickedImage != null
                          ? CircularProgressIndicator()
                          : Text("...");
                    }
                  }
                },
              )
            : SizedBox(
                width: double.infinity,
                height: 600,
                child: Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                ),
              ),
      ],
    );
  }
}
