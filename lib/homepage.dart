import 'package:doku/pages/counter.dart';
import 'package:doku/pages/home.dart';
import 'package:doku/pages/prayer.dart';
import 'package:doku/pages/quran.dart';
import 'package:doku/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  void _navigate(int index) {
    setState(() => _index = index);
  }

  final List<Widget> _pages = [
    Home(),
    const Prayer(),
    const Counter(),
    const Quran(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          AppBar(
            title: Text(
              'LiMe',
              style: GoogleFonts.poppins(
                fontSize: 30,
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                height: kToolbarHeight,
                alignment: Alignment.center,
                child: Text(
                  'LiMe',
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: kToolbarHeight),
                child: IndexedStack(index: _index, children: _pages),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: GlassBottomNav(
        currentIndex: _index,
        onTap: _navigate,
        selectedItemColor: const Color(0xFFC4F000),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Prayer'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Counter'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Quran'),
        ],
      ),
    );
  }
}
