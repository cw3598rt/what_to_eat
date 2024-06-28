import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

final gemini = Gemini.instance;

class HistroyScreen extends StatefulWidget {
  HistroyScreen({
    super.key,
  });

  @override
  State<HistroyScreen> createState() {
    return _HistroyScreenState();
  }
}

class _HistroyScreenState extends State<HistroyScreen> {
  late final Future<String> _menus;
  String _translatedMenu = "";

  bool _isKorean = false;
  bool _isClicked = false;
  bool _isLoading = false;
  Future<String> _initSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('menu')!;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _menus = _initSharedPreferences();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    _isClicked = false;
  }

  void _translate(String lang) async {
    setState(() {
      _isClicked = true;
      _isLoading = true;
    });
    var data = await _menus;
    var response = await gemini.text("please translate $data in $lang");

    if (response != null) {
      if (response.content != null) {
        setState(() {
          _translatedMenu = response.content!.parts![0].text!;
          _isKorean = !_isKorean;
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return !_isClicked
        ? FutureBuilder(
            future: _menus,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (snapshot.data == null || snapshot.data!.isEmpty) {
                return Text("no data");
              }

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Dismissible(
                  key: ValueKey(snapshot.data!),
                  onDismissed: (direction) async {
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.remove('menu');
                  },
                  child: Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: TextButton(
                              onPressed: () {
                                _isKorean
                                    ? _translate("English")
                                    : _translate("Korean");
                              },
                              child:
                                  _isKorean ? Text("English") : Text("Korean"),
                            ),
                          ),
                          Expanded(
                            child: Markdown(
                              data: snapshot.data!,
                              selectable: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Dismissible(
              key: ValueKey(_translatedMenu),
              onDismissed: (direction) async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.remove('menu');
              },
              child: Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: SizedBox(
                  width: double.infinity,
                  child: !_isLoading
                      ? Column(
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: TextButton(
                                onPressed: () {
                                  _isKorean
                                      ? _translate("English")
                                      : _translate("Korean");
                                },
                                child: _isKorean
                                    ? Text("English")
                                    : Text("Korean"),
                              ),
                            ),
                            Expanded(
                              child: Markdown(
                                data: _translatedMenu,
                                selectable: true,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(),
                            )
                          ],
                        ),
                ),
              ),
            ),
          );
  }
}
