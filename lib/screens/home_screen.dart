import 'package:flutter/material.dart';
import 'package:what_to_eat/screens/search_screen.dart';
import 'package:what_to_eat/screens/history_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  bool _isToday = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentNavIndex == 0
          ? AppBar(
              title: Text(
                "what to eat today",
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isToday = false;
                    });
                  },
                  child: Text("Picture"),
                  style: TextButton.styleFrom(
                    backgroundColor: !_isToday
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white,
                    foregroundColor: !_isToday
                        ? Colors.white
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isToday = true;
                    });
                  },
                  child: Text("Today"),
                  style: TextButton.styleFrom(
                    backgroundColor: _isToday
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white,
                    foregroundColor: _isToday
                        ? Colors.white
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            )
          : AppBar(
              title: Text(
                "what to eat today",
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
      body: _currentNavIndex == 0
          ? SingleChildScrollView(child: SearchScreen(detailOption: _isToday))
          : HistroyScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (value) {
          setState(() {
            _currentNavIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_a_photo_outlined,
            ),
            label: "Picture",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.input,
            ),
            label: "History",
          )
        ],
      ),
    );
  }
}
