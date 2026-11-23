import 'package:flutter/material.dart';

import 'screens/converter_screen.dart';
import 'screens/month_screen.dart';
import 'screens/today_screen.dart';

void main() {
  runApp(const LichVanNienApp());
}

class LichVanNienApp extends StatelessWidget {
  const LichVanNienApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFFB71C1C); // đỏ truyền thống
    return MaterialApp(
      title: 'Lịch Vạn Niên',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        appBarTheme: const AppBarTheme(
          backgroundColor: seed,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  DateTime _selectedDate = DateTime.now();

  void _openDay(DateTime date) {
    setState(() {
      _selectedDate = date;
      _index = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      TodayScreen(
        date: _selectedDate,
        onDateChanged: (d) => setState(() => _selectedDate = d),
      ),
      MonthScreen(onDaySelected: _openDay),
      const ConverterScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Hôm nay',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Lịch tháng',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz),
            label: 'Đổi ngày',
          ),
        ],
      ),
    );
  }
}
