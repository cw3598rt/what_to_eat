import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as myPermission;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_settings/app_settings.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

final imagePicker = ImagePicker();
final gemini = Gemini.instance;
Location location = Location();
var format = DateFormat.yMd();

class SearchScreen extends StatefulWidget {
  SearchScreen({
    super.key,
    required this.detailOption,
  });

  bool detailOption;

  @override
  State<SearchScreen> createState() {
    return _SearchScreenState();
  }
}

class _SearchScreenState extends State<SearchScreen>
    with WidgetsBindingObserver {
  File? _pickedImage;
  String? _result;
  String? _pictureResult;
  String _isConnected = "";
  bool _isKorean = false;
  bool _isLoading = false;

  void _initLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData? locationData;
    bool result;

    result = await InternetConnection().hasInternetAccess;
    if (!result) {
      setState(() {
        _isConnected = "wrong";
      });
      return;
    }
    setState(() {
      _isConnected = "";
    });
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        setState(() {
          _result = "try again";
        });
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();

      if (_permissionGranted != PermissionStatus.granted) {
        setState(() {
          _result = "To use this app need to allow location";
        });
        return;
      }
    }

    locationData = await location.getLocation();

    try {
      var response = await gemini.text(
          "You are a best chef. and Please suggest me top1 food for today. Your answer must be with name and recipe of the recommended food only beside recommended food name and recipe, please do not write on your answer! when you search the reference for the suggestion, please consider certain country where include this location in latitude ${locationData.latitude} and longitude ${locationData.longitude} and time must be ${DateTime.now().hour}");
      if (response != null) {
        if (response.content != null) {
          setState(() {
            _isConnected = "";
            _result = response.content!.parts![0].text;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isConnected = "wrong";
      });
    }
  }

  void _initInternetCheck() async {
    bool result;

    result = await InternetConnection().hasInternetAccess;
    if (!result) {
      setState(() {
        _isConnected = "wrong";
        _pictureResult = null;
      });
      return;
    }
    setState(() {
      _isConnected = "";
    });
  }

  @override
  void initState() {
    super.initState();

    _initLocation();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(covariant SearchScreen oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);

    if (widget.detailOption) {
      _initLocation();
    } else {
      gemini.cancelRequest();
      _initInternetCheck();

      setState(() {
        _result = null;
        _isKorean = false;
      });
      retryPictureResul();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
    gemini.cancelRequest();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      var location = await myPermission.Permission.location.status;
      var locationAlways = await myPermission.Permission.locationAlways.status;
      var locationWhenInUse =
          await myPermission.Permission.locationWhenInUse.status;

      if (location == myPermission.PermissionStatus.granted ||
          locationAlways == myPermission.PermissionStatus.granted ||
          locationWhenInUse == myPermission.PermissionStatus.granted) {
        setState(() {
          _result = null;
          _isKorean = false;
        });
        _initLocation();
      }
      _initInternetCheck();
      retryPictureResul();
    }
  }

  void _openModal() async {
    setState(() {
      _pictureResult = null;
      _pickedImage = null;
    });

    ImageSource? source;

    var camera = await myPermission.Permission.camera.status;
    var photos = await myPermission.Permission.photos.status;

    if (camera == myPermission.PermissionStatus.granted ||
        photos == myPermission.PermissionStatus.granted) {
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
    } else {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(
              child: Text(
                  "To get suggestion need to set camera or gallery permission"),
            ),
            actions: [
              ElevatedButton.icon(
                onPressed: () async {
                  if (camera ==
                      myPermission.PermissionStatus.permanentlyDenied) {
                    myPermission.openAppSettings();
                  }
                  if (camera == myPermission.PermissionStatus.denied) {
                    myPermission.Permission.camera.request();
                  }

                  Navigator.of(context).pop();
                },
                label: Text("Camera"),
                icon: Icon(Icons.add_a_photo),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (photos ==
                      myPermission.PermissionStatus.permanentlyDenied) {
                    myPermission.openAppSettings();
                  }
                  if (photos == myPermission.PermissionStatus.denied) {
                    myPermission.Permission.camera.request();
                  }

                  Navigator.of(context).pop();

                  myPermission.openAppSettings();
                  Navigator.of(context).pop();
                },
                label: Text("Gallery"),
                icon: Icon(Icons.add_photo_alternate),
              ),
            ],
          );
        },
      );
    }
  }

  void retryPictureResul() async {
    if (_pickedImage != null) {
      try {
        final response = await gemini.textAndImage(
            text:
                "first of all, must check whether the picture only include food or food ingredient only or not. if there are no food or food ingredient, then show wrong picture text. and if there are food or food ingredient, then could you recommend any food using this picture? must use the ingredient on picture only. Answer must be with name and recipe of the recommended food only beside recommended food name and recipe, please do not write on your answer!",
            images: [_pickedImage!.readAsBytesSync()]);

        if (response != null) {
          if (response.content != null) {
            setState(() {
              _pictureResult = response.content!.parts![0].text;
            });

            // RegExp regExp = RegExp(r'(?<=## \*\*).*(?=\*\*)',
            //     multiLine: true, caseSensitive: false);
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            // List<String> menuNames = regExp
            //     .allMatches(response.content!.parts![0].text!)
            //     .map((item) => item.group(0).toString())
            //     .toList();

            await prefs.setString('menu', response.content!.parts![0].text!);
          }
        }
      } catch (e) {
        setState(() {
          _isConnected = "wrong";
        });
      }
    }
  }

  void _takePicture(ImageSource source) async {
    final result = await imagePicker.pickImage(source: source);

    setState(() {
      _pickedImage = File(result!.path);
    });

    bool _result;

    _result = await InternetConnection().hasInternetAccess;
    if (!_result) {
      setState(() {
        _isConnected = "wrong";
      });
      return;
    }
    setState(() {
      _isConnected = "";
    });

    try {
      final response = await gemini.textAndImage(
          text:
              "first of all, must check whether the picture only include food or food ingredient only or not. if there are no food or food ingredient, then show wrong picture text. and if there are food or food ingredient, then could you recommend any food using this picture? must use the ingredient on picture only. Answer must be with name and recipe of the recommended food only beside recommended food name and recipe, please do not write on your answer!",
          images: [File(result!.path).readAsBytesSync()]);

      if (response != null) {
        if (response.content != null) {
          setState(() {
            _isConnected = "";
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
    } catch (e) {
      setState(() {
        _isConnected = "wrong";
      });
    }
  }

  void _translate(String lang) async {
    bool result;

    result = await InternetConnection().hasInternetAccess;
    if (!result) {
      setState(() {
        _isConnected = "wrong";
      });
      return;
    }
    setState(() {
      _isConnected = "";
    });

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
                      if (_result != "try again" &&
                          _result != "To use this app need to allow location") {
                        return SizedBox(
                          width: double.infinity,
                          height: 600,
                          child: Markdown(
                            data: _result!,
                            selectable: true,
                          ),
                        );
                      } else {
                        return Column(
                          children: [
                            Text("Try again"),
                            SizedBox(
                              height: 16,
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  AppSettings.openAppSettings(
                                    type: AppSettingsType.location,
                                  );
                                },
                                child: Text("open location setting"))
                          ],
                        );
                      }
                    } else {
                      if (_isConnected == "wrong") {
                        return Text(
                            "To get AI suggestion needs internet connection...");
                      }

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
                          ? _isConnected == "wrong"
                              ? Text(
                                  "To get AI suggestion needs internet connection...")
                              : CircularProgressIndicator()
                          : _isConnected == "wrong"
                              ? Text(
                                  "To get AI suggestion needs internet connection...")
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
