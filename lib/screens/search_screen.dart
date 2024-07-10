import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart' as myPermission;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

final imagePicker = ImagePicker();
final gemini = Gemini.instance;
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
  String _myPlace = "";

  _openPlaceModal() async {
    return showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("Pick your Place"),
          content: Container(
            width: double.infinity,
            height: 100,
            child: ListView(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _myPlace = "New Zealand";
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text("New Zealand"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _myPlace = "Taiwan";
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text("Taiwan"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _myPlace = "Republic of Korea";
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text("Republic of Korea"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _myPlace = "Malaysia";
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text("Malaysia"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _myPlace = "USA";
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text("USA"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _myPlace = "Vietnam";
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text("Vietnam"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _myPlace = "Brunei";
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text("Brunei"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _myPlace = "Singapore";
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text("Singapore"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _myPlace = "Australia";
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text("Australia"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _myPlace = "India";
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text("India"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _myPlace = "Indonesia";
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text("Indonesia"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _myPlace = "Japan";
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text("Japan"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _myPlace = "Canada";
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text("Canada"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _myPlace = "Thailand";
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text("Thailand"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _myPlace = "Philippines";
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text("Philippines"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _myPlace = "Hong Kong";
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text("Hong Kong"),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _initLocation() async {
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

    await _openPlaceModal();

    try {
      var response = await gemini.text(
          "You are a best chef. and Please suggest me top1 food in ${_myPlace} for today. Your answer must be with name and recipe of the recommended food only beside recommended food name and recipe, please do not write on your answer! when you search the reference for the suggestion, please consider time information too. Time must be ${DateTime.now().hour}");
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
        _myPlace = "";
      });
      retryPictureResult();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
    gemini.cancelRequest();
    setState(() {
      _result = null;
      _isKorean = false;
      _myPlace = "";
    });
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      if (_myPlace != "") {
        setState(() {
          _result = null;
          _isKorean = false;
          _myPlace = "";
        });
        _initLocation();
      } else {
        _initInternetCheck();
        retryPictureResult();
      }
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

  void retryPictureResult() async {
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
                      return SizedBox(
                        width: double.infinity,
                        height: 600,
                        child: Markdown(
                          data: _result!,
                          selectable: true,
                        ),
                      );
                    } else {
                      if (_isConnected == "wrong") {
                        return Text(
                            "To get AI suggestion needs internet connection...");
                      }

                      return _myPlace != ""
                          ? Text("Searching...")
                          : Text("...");
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
